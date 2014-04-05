require "pathname"
require "yaml"
require "json"
require "plist"
require "ruby_identicon"

module Picon
  class Generator
    RESOLUTIONS_LIST_PATH = File.expand_path("./resolutions.yml", __dir__)

    def self.run
      new.run
    end

    def initialize(args = {})
      if args[:current_path]
        @current_path = Pathname.new(File.expand_path(args[:current_path]))
      else
        @current_path = Pathname.pwd
      end

      @product_name = get_product_name
      @appiconset_path = get_appiconset_path
      @bundle_identifier = get_bundle_identifier
    end

    def run
      generate_identicons
      generate_contents_json
      edit_project_pbxproj
    end

    private

    def get_shallowest_filepath(path)
      pathnames = Pathname.glob(path)
      pathnames.reject! { |pathname| pathname.to_s =~ /Test/ }

      # pick shallowest file to avoid selecting submodule's one
      lengths = pathnames.map { |pathname| pathname.to_s.split("/").length }
      pathname = pathnames[lengths.index(lengths.min)]

      pathname
    end

    def get_product_name
      xcodeproj_path = get_shallowest_filepath(@current_path.to_s + "/**/*.xcodeproj")
      File.basename(xcodeproj_path.to_s, ".xcodeproj")
    end

    def get_appiconset_path
      path = get_shallowest_filepath(@current_path.to_s + "/**/*.xcassets")
      path = path.join("Picon.appiconset")
      path.mkdir unless path.exist?
      path
    end

    def get_bundle_identifier
      pathname = get_shallowest_filepath(@current_path.to_s + "/**/*-Info.plist")
      plist = Plist.parse_xml(pathname.to_s)
      plist["CFBundleIdentifier"].gsub!(/\${PRODUCT_NAME.*}$/) { @product_name }
    end

    def generate_identicons
      resolutions = YAML.load_file(RESOLUTIONS_LIST_PATH)
      resolutions.each do |device, images|
        images.each do |image|
          filepath = @appiconset_path.join(image["filename"])
          next if filepath.exist?

          grid_size = 7
          square_size = image["size"].to_i / grid_size
          border_size = ((image["size"].to_i - grid_size * square_size).to_f / 2).ceil
          RubyIdenticon.create_and_save(@bundle_identifier, filepath, border_size: border_size, grid_size: grid_size, square_size: square_size)
        end
      end
    end

    def generate_contents_json
      contents = { "images" => [] }

      resolutions = YAML.load_file(RESOLUTIONS_LIST_PATH)
      resolutions.each do |device, properties|
        properties.each do |property|
          size = property["size"].to_i
          size /= 2 if property["scale"] == "2x"

          image = {}
          image["idiom"] = device
          image["filename"] = property["filename"]
          image["size"] = "#{size}x#{size}"
          image["scale"] = property["scale"]
          contents["images"] << image
        end
      end

      contents["info"] = { "version" => 1, "author" => "picon" }

      filepath = @appiconset_path.join("Contents.json")
      filepath.open("wb") do |file|
        file << JSON.pretty_generate(contents)
      end
    end

    def edit_project_pbxproj
      data = ""

      pbxproj_path = get_shallowest_filepath(@current_path.to_s + "/**/project.pbxproj")
      pbxproj_path.open("rb") do |file|
        data = file.read
      end

      xcworkspace_path = get_shallowest_filepath(@current_path.to_s + "/**/#{@product_name}.xcworkspace")
      if xcworkspace_path && xcworkspace_path.exist?
        data.gsub!(/(<key>ASSETCATALOG_COMPILER_APPICON_NAME<\/key>\n\t+<string>).+(<\/string>)/) { "#{$1}Picon#{$2}" }
      else
        data.gsub!(/(ASSETCATALOG_COMPILER_APPICON_NAME = )AppIcon/) { "#{$1}Picon" }
      end

      pbxproj_path.open("wb") do |file|
        file.flush
        file << data
      end
    end
  end
end


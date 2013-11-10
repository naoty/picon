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

    def initialize
      @appiconset_path = get_appiconset_path
      @bundle_identifier = get_bundle_identifier
    end

    def run
      generate_identicons
      edit_contents_json
      edit_project_pbxproj
    end

    private

    def get_appiconset_path
      path = Pathname.glob("**/*.xcassets").first
      path = path.join("Picon.appiconset")
      path.mkdir unless path.exist?
      path
    end

    def get_bundle_identifier
      xcodeproj_path = Pathname.glob("**/*.xcodeproj").first
      product_name = File.basename(xcodeproj_path.to_s, ".xcodeproj")

      pathnames = Pathname.glob("**/*-Info.plist")
      pathnames.reject! { |pathname| pathname.to_s =~ /Test/ }
      pathname = pathnames.first
      plist = Plist.parse_xml(pathname.to_s)
      plist["CFBundleIdentifier"].gsub!(/\${PRODUCT_NAME.*}$/) { product_name }
    end

    def generate_identicons
      resolutions = YAML.load_file(RESOLUTIONS_LIST_PATH)
      resolutions.each do |device, info|
        info.each do |os, info|
          info.each do |display, info|
            filepath = @appiconset_path.join(info["filename"])
            grid_size = 7
            square_size = info["size"].to_i / grid_size
            border_size = ((info["size"].to_i - grid_size * square_size).to_f / 2).ceil
            RubyIdenticon.create_and_save(@bundle_identifier, filepath, border_size: border_size, grid_size: grid_size, square_size: square_size)
          end
        end
      end
    end

    def edit_contents_json
    end

    def edit_project_pbxproj
    end
  end
end


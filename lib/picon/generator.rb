require "pathname"
require "plist"

module Picon
  class Generator
    def self.run
      new.run
    end

    def initialize
    end

    def run
    end

    private

    def identifier
      xcodeproj_path = Pathname.glob("**/*.xcodeproj").first
      product_name = File.basename(xcodeproj_path.to_s, ".xcodeproj")

      pathnames = Pathname.glob("**/*-Info.plist")
      pathnames.reject! { |pathname| pathname.to_s =~ /Test/ }
      pathname = pathnames.first
      plist = Plist.parse_xml(pathname.to_s)
      plist["CFBundleIdentifier"].gsub!(/\${PRODUCT_NAME.*}$/) { product_name }
    end
  end
end

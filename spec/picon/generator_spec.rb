require "fileutils"
require "spec_helper"

describe Picon::Generator do
  describe "#run" do
    let(:generator) { described_class.new }
    let(:appiconset_path) { Pathname.glob("./spec/PiconSample/**/Picon.appiconset").first }
    let(:pbxproj_path) { Pathname.glob("./spec/PiconSample/**/project.pbxproj").first }

    before(:each) do
      generator.run
    end

    after(:each) do
      appiconset_path.rmtree

      # Reset an edited file
      original_pbxproj_path = Pathname.glob("./spec/PiconSample/**/project.pbxproj.orig").first
      FileUtils.cp_r(original_pbxproj_path.to_s, pbxproj_path.to_s)
    end

    it "makes Picon.appiconset directory" do
      expect(appiconset_path).to exist
    end

    it "generates identicons" do
      identicon_paths = appiconset_path.entries.select { |entry| entry.extname == ".png" }
      expect(identicon_paths.count).to be > 0
    end

    it "generates Contents.json" do
      path = appiconset_path.join("Contents.json")
      expect(path).to exist
    end

    it "edits project.pbxproj to use identicons as appicon" do
      pbxproj_path.open("rb") do |file|
        data = file.read
        matched = data.scan(/ASSETCATALOG_COMPILER_APPICON_NAME = (.*);$/).first
        expect(matched.first).to eq "Picon"
      end
    end
  end
end


require "fileutils"
require "spec_helper"

describe Picon::Generator do
  describe "#run" do
    let(:generator) { described_class.new({ current_path: project_root }) }

    before(:each) do
      generator.run
    end

    after(:each) do
      appiconset_path.rmtree
      FileUtils.cp(original_pbxproj_path.to_s, pbxproj_path.to_s)
    end

    shared_examples_for "generator" do
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
    end

    context "at the root of a project" do
      let(:project_root) { File.expand_path("./spec/PiconSampleProject") }
      let(:appiconset_path) { Pathname.glob("./spec/PiconSampleProject/**/Picon.appiconset").first }
      let(:pbxproj_path) { Pathname.glob("./spec/PiconSampleProject/**/project.pbxproj").first }
      let(:original_pbxproj_path) { Pathname.glob("./spec/PiconSampleProject/**/project.pbxproj.orig").first }

      it_behaves_like "generator"

      it "edits project.pbxproj to use identicons as appicon" do
        pbxproj_path.open("rb") do |file|
          data = file.read
          matched = data.scan(/ASSETCATALOG_COMPILER_APPICON_NAME = (.*);$/).first
          expect(matched.first).to eq "Picon"
        end
      end
    end

    context "at the root of a workspace" do
      let(:project_root) { File.expand_path("./spec/PiconSampleWorkspace") }
      let(:appiconset_path) { Pathname.glob("./spec/PiconSampleWorkspace/**/Picon.appiconset").first }
      let(:pbxproj_path) { Pathname.glob("./spec/PiconSampleWorkspace/**/project.pbxproj").first }
      let(:original_pbxproj_path) { Pathname.glob("./spec/PiconSampleWorkspace/**/project.pbxproj.orig").first }

      it_behaves_like "generator"

      it "edits project.pbxproj to use identicons as appicon" do
        pbxproj_path.open("rb") do |file|
          data = file.read
          matched = data.scan(/<key>ASSETCATALOG_COMPILER_APPICON_NAME<\/key>\n\t+<string>(.+)<\/string>/).first
          expect(matched.first).to eq "Picon"
        end
      end
    end
  end
end


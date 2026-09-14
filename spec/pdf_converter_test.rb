require "test_helper"
require "minitest/autorun"
require_relative "../src/components/PDFConverter.rb"

class PDFConverterTest < Minitest::Test
  SAMPLE_FILES_DIR = "./spec/sample_files"
  PDFConverter = HPNET::PDFConverter

  attr_reader :file_paths

  def setup
    @file_paths = Dir.glob(
      File.join(
        SAMPLE_FILES_DIR,
        "*.{doc,docx}"
      )
    )
  end

  def test_pdf_convert_success
    refute_empty self.file_paths
    self.file_paths.each do |path|
      output_file_path = PDFConverter.convert(path)
      assert_instance_of String, output_file_path
      refute_empty output_file_path
      assert File.file? output_file_path
    end
  end

  def test_pdf_convert_fail
    refute_empty self.file_paths

    # fails if soffice could not be found
    assert_raises(PDFConverter::ExecutableNotFoundException) do
      PDFConverter.convert(file_paths.first, soffice_command: "")
    end

    # fails if input file path is not a valid file
    assert_raises(PDFConverter::InvalidFileError) do
      PDFConverter.convert(file_paths.first + ".invalid")
    end
  end
end

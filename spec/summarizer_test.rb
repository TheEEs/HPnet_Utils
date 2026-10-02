require "test_helper"
require "minitest/autorun"
require_relative "../src/components/Summarizer.rb"

class DocumentSummarizerTest < Minitest::Test
  SAMPLE_FILES_DIR = "./spec/sample_files"
  Summarizer = HPNET::Summarizer
  Schema = Summarizer::SummarySchema

  attr_reader :file_paths

  def setup
    @file_paths = Dir.glob(
      File.join(
        SAMPLE_FILES_DIR,
        "*.pdf"
      )
    )
  end

  def test_summarize_information_success
    refute_empty file_paths
    path = file_paths.sample
    summary = Schema.from_hash Summarizer.summarize(path).parsed
    refute_empty summary.type
    refute_empty summary.name
    refute_empty summary.title
  end
end

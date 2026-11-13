# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require_relative '../src/components/Engine'

class EngineTest < Minitest::Test
  attr_reader :engine

  def setup
    @engine = HPNET::Engine.new
  end

  def test_engine_initialization_success
    engine.launch
    assert engine.client.logged_in?
  end

  def test_engine_initialization_fail
    temp_user_name = ENV['USER_NAME']
    temp_password = ENV['PASSWORD']
    ENV['USER_NAME'] = 'wrong_user_name'
    ENV['PASSWORD'] = 'wrong_password'
    engine.launch
    refute engine.client.logged_in?
    ENV['USER_NAME'] = temp_user_name
    ENV['PASSWORD'] = temp_password
  end

  def test_upload_returns_early_on_invalid_arguments
    refute engine.upload(nil, lanhdao_id: '123', how_we_should_set_title_of_document: 0)
    refute engine.upload('/non_existing_dir_12345', lanhdao_id: '123', how_we_should_set_title_of_document: 0)
    refute engine.upload('./spec/sample_files', lanhdao_id: nil, how_we_should_set_title_of_document: 0)
    refute engine.upload('./spec/sample_files', lanhdao_id: '123', how_we_should_set_title_of_document: nil)
  end

  def test_upload_manual_title_and_yield
    mock_client = Object.new #Minitest::Mock.new
    uploaded_records = []
    engine.instance_variable_set(:@client, mock_client)

    # Allow client.upload to succeed
    mock_client.define_singleton_method(:upload) do |file_path, to: nil, title: nil|
      uploaded_records << { file_path:, to:, title: }
      true
    end

    yielded = []
    engine.upload('./spec/sample_files',
                  lanhdao_id: 'leader_001',
                  how_we_should_set_title_of_document: HPNET::Engine::Helpers::HowWeShouldSetTitleOfDocument::Manual,
                  manual_title: 'Trích yếu thử nghiệm') do |res, file, files|
      yielded << [res, file, files]
    end

    refute_empty uploaded_records
    assert_equal yielded.size, uploaded_records.size
    uploaded_records.each do |rec|
      assert_equal 'leader_001', rec[:to]
      assert_equal 'Trích yếu thử nghiệm', rec[:title]
    end
  end

  def test_upload_from_filepath_title
    mock_client = Object.new
    uploaded_records = []
    mock_client.define_singleton_method(:upload) do |file_path, to: nil, title: nil|
      uploaded_records << { file_path:, to:, title: }
      true
    end
    engine.instance_variable_set(:@client, mock_client)

    engine.upload('./spec/sample_files',
                  lanhdao_id: 'leader_002',
                  how_we_should_set_title_of_document: HPNET::Engine::Helpers::HowWeShouldSetTitleOfDocument::FromFilePath)

    refute_empty uploaded_records
    uploaded_records.each do |rec|
      assert_equal 'leader_002', rec[:to]
      refute_empty rec[:title]
    end
  end

  def test_approve_with_empty_documents
    mock_client = Object.new
    mock_client.define_singleton_method(:get_uploaded_documents) { |_filter = nil| [] }
    engine.instance_variable_set(:@client, mock_client)

    yielded = false
    engine.approve(filter: 'test', lanhdao_id: 'leader_001') do
      yielded = true
    end

    refute yielded
  end

  def test_approve_with_documents
    mock_client = Object.new
    mock_client.define_singleton_method(:get_uploaded_documents) do |_filter = nil|
      [{ 'VanbanDiId' => 'doc_1' }, { 'VanbanDiId' => 'doc_2' }]
    end
    approved_ids = []
    mock_client.define_singleton_method(:approve_document) do |document_id:, lanhdao_id:|
      approved_ids << [document_id, lanhdao_id]
      true
    end
    engine.instance_variable_set(:@client, mock_client)

    yielded_results = []
    engine.approve(filter: 'test', lanhdao_id: 'leader_001') do |res, doc, all_docs|
      yielded_results << [res, doc['VanbanDiId'], all_docs.size]
    end

    assert_equal 2, approved_ids.size
    assert_equal 2, yielded_results.size
    assert_equal [%w[doc_1 leader_001], %w[doc_2 leader_001]], approved_ids
  end
end

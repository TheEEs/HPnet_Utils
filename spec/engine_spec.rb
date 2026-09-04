require "minitest/autorun"
require_relative "../src/utils/HTTP.rb"
require_relative "../src/utils/PDFConverter.rb"
require "async"

class EngineTest < Minitest::Test
  extend HPNET::Utils
  extend HPNET::PDFConverter
  attr_reader :username
  attr_reader :password

  def setup
    @username = ENV['USER_NAME']
    @password = ENV['PASSWORD']
  end

  def test_login_success
    res = self.class.login(username:, password:)
    assert res
  end

  def test_login_fail
    res = self.class.login(username:, password: "wrong_password")
    assert_nil res
  end

  def test_extract_leaders_info_success
    test_login_success
    leaders = self.class.extract_get_leaders
    assert_instance_of Array, leaders
    assert leaders.size > 0
  end

  def test_extract_leaders_info_fail
    File.write(".cookie", "")
    test_login_fail
    leaders = self.class.extract_get_leaders
    assert leaders.nil?
  end

  def test_convert_word_to_pdf_success
    paths = Dir.glob("./spec/samples_word_file/*.{doc,docx}")
    paths.each do |path|
      self.class.convert(path)
      dir = File.dirname path
      basename = File.basename path
      basename_without_extension = File.basename path, ".*"
      extension = File.extname path
      assert File.exist? File.join(dir, "#{basename_without_extension}.pdf")
      # assert File.exist? File.join(dir, "#{basename}.unused")
      # assert not File.exist? File.join(dir, "#{basename}")
    end
    assert_equal paths.size, Dir.glob("./spec/samples_word_file/*.pdf").size
  end
end

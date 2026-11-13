# frozen_string_literal: true

require "json"
require "fileutils"

module HPNET
  class CredentialStore
    DEFAULT_FILE_PATH = File.expand_path("~/.hpnet_credentials.json")

    class << self
      attr_writer :file_path

      def file_path
        @file_path || DEFAULT_FILE_PATH
      end

      def save(username, password)
        return false if username.to_s.strip.empty? || password.to_s.empty?

        data = {
          "username" => username.to_s.strip,
          "password" => password.to_s,
          "updated_at" => Time.now.iso8601
        }
        File.write(file_path, JSON.pretty_generate(data))
        File.chmod(0o600, file_path) rescue nil
        true
      rescue StandardError
        false
      end

      def load
        return nil unless File.file?(file_path)

        content = File.read(file_path)
        data = JSON.parse(content)
        return nil unless data.is_a?(Hash)

        username = data["username"].to_s.strip
        password = data["password"].to_s
        return nil if username.empty? || password.empty?

        { username: username, password: password }
      rescue StandardError
        nil
      end

      def clear
        File.delete(file_path) if File.exist?(file_path)
        true
      rescue StandardError
        false
      end

      def saved?
        !load.nil?
      end
    end
  end
end

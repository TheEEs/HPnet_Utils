require "libreconv"
module HPNET
  module PDFConverter
    EXTENSION_REGEX = /^\.docx?$/
    def convert(path)
      dir = File.dirname path
      basename = File.basename path
      basename_without_extension = File.basename path, ".*"
      extension = File.extname path
      return unless extension.match? EXTENSION_REGEX

      output_path = File.join(dir, "#{basename_without_extension}.pdf")
      Libreconv.convert path, output_path
      # File.rename path, File.join(dir, "#{basename}.unused")
      return output_path
    end
  end
end

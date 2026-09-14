module HPNET
  class PDFConverter
    class ExecutableNotFoundException < Exception; end
    class InvalidFileError < Exception; end

    module Helpers
    end

    include Helpers

    class << self
      def convert(file_path, soffice_command: get_soffice)
        raise InvalidFileError.new unless File.file? file_path

        basename_without_extension = File.basename file_path, ".*"
        dirname = File.dirname file_path
        output_file_path = File.join(dirname, "#{basename_without_extension}.pdf")
        Libreconv.convert(
          file_path,
          output_file_path,
          soffice_command
        )
        output_file_path
      rescue IOError => e
        raise ExecutableNotFoundException.new
      end

      private

      def get_soffice
        @soffice_path ||= if OS.windows?
                            'C:\Program Files\LibreOffice\program\soffice.exe'
                          elsif OS.mac?
                            '/Applications/LibreOffice.app/Contents/MacOS/soffice'
                          elsif OS.linux?
                            `which soffice`.strip
                          end
      end
    end
  end
end

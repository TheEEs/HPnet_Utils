# frozen_string_literal: true

module HPNET
  class PDFConverter
    class ExecutableNotFoundException < StandardError; end
    class InvalidFileError < StandardError; end

    class << self
      def convert(file_path, soffice_command: get_soffice)
        raise InvalidFileError, "Tệp không tồn tại: #{file_path}" unless File.file?(file_path.to_s)
        raise ExecutableNotFoundException, 'Không tìm thấy LibreOffice (soffice)' if soffice_command.to_s.strip.empty?

        basename_without_extension = File.basename(file_path, '.*')
        dirname = File.dirname(file_path)
        output_file_path = File.join(dirname, "#{basename_without_extension}.pdf")

        Libreconv.convert(file_path, output_file_path, soffice_command)
        output_file_path
      rescue IOError, Errno::ENOENT
        raise ExecutableNotFoundException, 'Không tìm thấy hoặc không thực thi được LibreOffice'
      end

      private

      def get_soffice
        @soffice_path ||= if OS.windows?
                            candidates = [
                              'C:\Program Files\LibreOffice\program\soffice.exe',
                              'C:\Program Files (x86)\LibreOffice\program\soffice.exe'
                            ]
                            candidates.find { |path| File.file?(path) } || candidates.first
                          elsif OS.mac?
                            '/Applications/LibreOffice.app/Contents/MacOS/soffice'
                          elsif OS.linux?
                            path = `which soffice 2>/dev/null`.strip
                            path.empty? ? 'soffice' : path
                          end
      end
    end
  end
end

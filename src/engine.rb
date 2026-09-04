require_relative "utils/HTTP.rb"
class HPNET::Engine
  include HPNET::Utils
  include HPNET::Summarizer
  include HPNET::PDFConverter
end

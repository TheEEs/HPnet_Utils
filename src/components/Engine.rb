require_relative "./Client"
module HPNET
  class Engine
    attr_reader :client

    def launch
      @client = HPNET::Client.new
      client.login(username: ENV['USER_NAME'], password: ENV['PASSWORD'])
      yield client.logged_in? if block_given?
    end

    def approve(filter: nil)
    end
  end
end

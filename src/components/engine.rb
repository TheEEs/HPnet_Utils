require_relative "../windows/main"
module HPNET
    class Engine
        
        attr_reader :client

        def launch
            @client = HPNET::Client.new 
            client.login(username: ENV['USER_NAME'], password: ENV['PASSWORD'])
            unless client.logged_in?
                #show error then quit with exit code 1
            end
        end

    end
end
if SERVER then
    include( "azlink/azlink.lua" )
    include( "azlink/logger/logger.lua" )
    include( "azlink/fetcher.lua" )
    include( "azlink/http/http_client.lua" )
    include( "azlink/http/promise.lua" )
    include( "azlink/commands/azlink_command.lua" )
end

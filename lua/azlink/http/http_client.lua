local httpClient = {
    timeout = 10
}
local httpRequest = HTTP

if util.IsBinaryModuleInstalled( "chttp" ) and pcall( require, "chttp" ) then
    MsgN( "[AzLink] Using CHTTP for HTTP requests." )
else
    MsgN( "[AzLink] CHTTP is not available; using the built-in HTTP module for HTTP requests. Consider" )
    MsgN( "  installing CHTTP for better performance: https://github.com/timschumi/gmod-chttp#installation" )
end

function httpClient:Request( requestMethod, endpoint, data )
    return AzLink.Promise( function( onResolve, onReject )
        httpRequest( {
            method = requestMethod,
            url = AzLink.config.url .. "/api/azlink" .. endpoint,
            timeout = self.timeout,
            headers = {
                ["Azuriom-Link-Token"] = AzLink.config.site_key,
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
            },
            type = "application/json",
            body = data and util.TableToJSON( data ) or nil,
            success = function( code, body )
                local jsonBody = body and util.JSONToTable( body ) or body

                if code >= 300 then
                    onReject( jsonBody.message or body, code )

                    return
                end

                onResolve( jsonBody )
            end,
            failed = onReject,
        } )
    end )
end

AzLink.HttpClient = httpClient

local httpClient = {
    timeout = 5000
}
local httpRequest

if pcall( require, "chttp" ) and CHTTP ~= nil then
	httpRequest = CHTTP
else
	httpRequest = HTTP
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

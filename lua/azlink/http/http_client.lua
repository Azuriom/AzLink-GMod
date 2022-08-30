local httpClient = {
    timeout = 5000
}

function httpClient:Request( requestMethod, endpoint, data )
    return AzLink.Promise( function( onResolve, onReject )
        HTTP( {
            method = requestMethod,
            url = AzLink.config.url .. "/api/azlink" .. endpoint,
            timeout = self.timeout,
            headers = {
                ["Azuriom-Link-Token"] = AzLink.config.site_key,
                ["Accept"] = "application/json",
                ["User-Agent"] = "AzLink Garry's Mod - v" .. AZLINK_VERSION,
            },
            type = "application/json",
            body = data and util.TableToJSON( data ) or nil,
            success = function( code, body )
                body = body and util.JSONToTable( body ) or body

                if code >= 300 then
                    onReject( body, code )

                    return
                end

                onResolve( body )
            end,
            failed = onReject,
        } )
    end )
end

AzLink.HttpClient = httpClient

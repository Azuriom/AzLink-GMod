local httpClient = {
    timeout = 5000
}

function httpClient:Request(requestMethod, endpoint, data)
    return AzLink.Promise(function(onResolve, onReject)
        local request = CHTTP({
            method = requestMethod,
            url = AzLink.config.url .. "/api/azlink" .. endpoint,
            timeout = self.timeout,
            headers = {
                ["Azuriom-Link-Token"] = AzLink.config.site_key,
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
            },
            body = data and util.TableToJSON(data) or nil,
            success = function(code, body, headers)
                local jsonBody = body and util.JSONToTable(body) or body

                if code >= 300 then
                    onReject(jsonBody.message or body, code)
                    return
                end

                onResolve(jsonBody)
            end,
            failed = function(error)
                onReject(error)
            end,
        })
    end)
end

AzLink.HttpClient = httpClient

local fetcher = { }

function fetcher:Run( sendFull )
    local data = AzLink:GetServerData( sendFull )

    return AzLink.HttpClient:Request( "POST", "", data ):Then( function( commands )
        self:DispatchCommands( commands )
    end ):Catch( function( error, status )
        if status == nil then
            AzLink.Logger:Error( "A connection error occured: " .. error )
        else
            local errorMessage = ( error.message or error ) .. " (" .. status .. ")"
            AzLink.Logger:Error( "An HTTP error occured: " .. errorMessage )
        end
    end )
end

function fetcher:DispatchCommands( data )
    if not data.commands then return end
    local total = 0

    for _, commandData in pairs( data.commands ) do
        local player = player.GetBySteamID64( commandData.uid )
        local playerName = player and player:Nick( ) or commandData.name
        local steamId32 = player and player:SteamID() or commandData.steamid_32

        for _, command in pairs( commandData.values ) do
            local display = playerName .. " (" .. commandData.uid .. ")"
            local playerCommand = command:gsub( "{player}", playerName )
            playerCommand = playerCommand:gsub( "{steam_id}", commandData.uid )
            playerCommand = playerCommand:gsub( "{steam_id_32}", steamId32 )
            AzLink.Logger:Info( "Dispatching command to " .. display .. ": " .. playerCommand )
            game.ConsoleCommand( playerCommand .. "\n" )
        end
    end

    if total > 0 then
        AzLink.Logger:Info( "Dispatched commands to " .. total .. " players." )
    end
end

AzLink.Fetcher = fetcher

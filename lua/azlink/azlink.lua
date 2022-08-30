AZLINK_VERSION = "0.1.0" -- TODO
AzLink = AzLink or { }
AzLink.lastSent = 0
AzLink.lastFullSent = 0
AzLink.config = { }

function AzLink:Fetch( force )
    local siteKey = AzLink.config.site_key
    local baseUrl = AzLink.config.url
    if siteKey == nil or baseUrl == nil or not force and RealTime( ) - AzLink.lastSent < 15 then return end
    local sendFull = os.date( "*t" ).min % 15 == 0 and RealTime( ) - AzLink.lastFullSent > 60
    AzLink.lastSent = RealTime( )

    if sendFull then
        AzLink.lastFullSent = RealTime( )
    end

    return AzLink.Fetcher:Run( sendFull )
end

function AzLink:Ping( )
    local siteKey = AzLink.config.site_key
    local baseUrl = AzLink.config.url
    if siteKey == nil or baseUrl == nil then return nil end

    return AzLink.HttpClient:Request( "GET", "", data ):Catch( function( error, status )
        if status == nil then
            AzLink.Logger:Error( "Unable to ping: " .. error )
        else
            local errorMessage = ( error.message or error ) .. " (" .. status .. ")"
            AzLink.Logger:Error( "An HTTP error occured during ping: " .. errorMessage )
        end
    end )
end

function AzLink:GetServerData( full )
    local players = { }

    for _, player in ipairs( player.GetHumans( ) ) do
        table.insert( players, {
            ["name"] = player:Nick( ),
            ["uid"] = player:SteamID64( ),
        } )
    end

    local baseData = {
        ["platform"] = {
            ["type"] = "GMOD",
            ["name"] = "Garry's Mod",
            ["version"] = VERSIONSTR,
        },
        ["version"] = AZLINK_VERSION,
        ["players"] = players,
        ["maxPlayers"] = game.MaxPlayers( ),
        ["full"] = full,
    }

    if not full then return baseData end

    baseData.worlds = {
        ["entities"] = ents.GetCount( ),
    }

    if serverstat ~= nil then
        baseData.system = {
            ["cpu"] = serverstat.ProcessCPUUsage( ) * 100.0,
            ["ram"] = serverstat.ProcessMemoryUsage( ),
        }
    end

    return baseData
end

function AzLink:SaveConfig( )
    file.Write( "azlink/config.json", util.TableToJSON( AzLink.config ) )
end

MsgN( "[AzLink] Starting AzLink v" .. AZLINK_VERSION .. "..." )

hook.Add( "Initialize", "azlink-init", function( )
    timer.Create( "azlink-fetcher-task", 60, 0, function( )
        AzLink:Fetch( )
    end )

    timer.Start( "azlink-fetcher-task" )
end )

file.CreateDir( "azlink" )
local rawConfig = file.Read( "azlink/config.json" )

if rawConfig ~= nil then
    AzLink.config = util.JSONToTable( rawConfig )
end

if #file.Find( "lua/bin/gmsv_serverstat*", "GAME" ) == 0 or not pcall( require, "serverstat" ) then
    MsgN( "[AzLink] Unable to load serverstat, please install the module by following" )
    MsgN( "these instructions: https://github.com/WilliamVenner/gmsv_serverstat#installation" )
end

MsgN( "[AzLink] AzLink successfully enabled." )

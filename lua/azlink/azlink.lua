AZLINK_VERSION = "1.1.0"

AzLink = AzLink or { }
AzLink.lastSent = 0
AzLink.lastFullSent = 0
AzLink.config = { }

function AzLink:Fetch( force )
    local siteKey = AzLink.config.site_key
    local baseUrl = AzLink.config.url

    if siteKey == nil or baseUrl == nil then return nil end

    if not force and RealTime( ) - AzLink.lastSent < 15 then return nil end

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

    return AzLink.HttpClient:Request( "GET", "", nil ):Catch( function( error, status )
        if status == nil then
            AzLink.Logger:Error( "Unable to ping: " .. error )
        else
            local errorMessage = ( error.message or error ) .. " (" .. status .. ")"
            AzLink.Logger:Error( "An HTTP error occurred during ping: " .. errorMessage )
        end
    end )
end

function AzLink:GetServerData( fullData )
    local players = { }

    for _, localPlayer in ipairs( player.GetHumans( ) ) do
        table.insert( players, {
            ["name"] = localPlayer:Nick( ),
            ["uid"] = localPlayer:SteamID64( ),
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
        ["full"] = fullData,
    }

    if not fullData then return baseData end

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
end )

file.CreateDir( "azlink" )
local rawConfig = file.Read( "azlink/config.json" )

if rawConfig ~= nil then
    AzLink.config = util.JSONToTable( rawConfig )
end

if not util.IsBinaryModuleInstalled( "serverstat" ) or not pcall( require, "serverstat" ) then
    MsgN( "[AzLink] serverstat is not available, server statistics will be unavailable. Consider" )
    MsgN( "  installing it to enable server statistics: https://github.com/WilliamVenner/gmsv_serverstat#installation" )
end

MsgN( "[AzLink] AzLink successfully enabled." )

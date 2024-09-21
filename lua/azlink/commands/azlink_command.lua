local function setupAzLink( baseUrl, siteKey )
    AzLink.config.url = baseUrl
    AzLink.config.site_key = siteKey

    AzLink:Ping( ):Then( function( )
        AzLink.Logger:Info( "Linked to the website successfully." )
        AzLink:SaveConfig( )
    end )
end

concommand.Add( "azlink", function( _, _, args )
    if args[2] == "setup" then
        if args[3] == nil or args[4] == nil then
            AzLink.Logger:Error( "You must first add this server in your Azuriom admin dashboard, in the 'Servers' section." )
            return
        end

        -- TODO find a cleaner way to support column
        setupAzLink( args[3]:gsub( "!", ":" ):gsub( "|", "/" ), args[4] )

        return
    end

    if args[2] == "status" then
        local result = AzLink:Ping( )

        if result == nil then
            AzLink.Logger:Error( "AzLink is not configured yet, use the 'setup' subcommand first." )
            return
        end

        result:Then( function( )
            AzLink.Logger:Info( "Connected to the website successfully." )
        end )

        return
    end

    if args[2] == "fetch" then
        local result = AzLink:Fetch( true )

        if result == nil then
            AzLink.Logger:Error( "AzLink is not configured yet, use the 'setup' subcommand first." )
            return
        end

        result:Then( function( )
            AzLink.Logger:Info( "Data has been fetched successfully." )
        end )

        return
    end

    AzLink.Logger:Info( "Unknown subcommand. Must be 'setup', 'status' or 'fetch'." )
end )

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
            AzLink.Logger:Error( "Mising URL and/or site key!" )

            return
        end

        -- TODO find a cleaner way to support column?
        setupAzLink( args[3]:gsub( "!", ":" ):gsub( "|", "/" ), args[4] )

        return
    end

    if args[2] == "status" then
        local promise = AzLink:Ping( )

        if promise == nil then
            AzLink.Logger:Error( "No URL and/or site key configured yet!" )
        end

        promise:Then( function( )
            AzLink.Logger:Info( "Connected to the website successfully." )
        end )

        return
    end

    if args[2] == "fetch" then
        AzLink:Fetch( true ):Then( function( )
            AzLink.Logger:Info( "Data has been fetched successfully." )
        end )

        return
    end

    AzLink.Logger:Info( "Uknown subcommand. Must be 'setup', 'status' or 'fetch'." )
end )

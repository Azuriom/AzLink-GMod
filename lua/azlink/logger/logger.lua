local logger = { }

local function log( level, message )
    print( "[AzLink - " .. level .. "] " .. message )
end

function logger:Info( message )
    log( "INFO", message )
end

function logger:Warn( message )
    log( "WARN", message )
end

function logger:Error( message )
    log( "ERROR", message )
end

AzLink.Logger = logger

-- Lua Promise implementation inspired by JavaScript's Promises
local Promise = { }
Promise.__index = Promise
local PENDING = 0
local RESOLVED = 1
local REJECTED = -1

function Promise:new( resolver )
    local target = {
        state = PENDING,
        queue = { },
        handlers = { },
    }

    setmetatable( target, Promise )

    local resolve = function( ... )
        if target.state ~= PENDING then return end

        for _, callback in pairs( target.queue ) do
            callback( ... )
        end

        target.values = { ... }

        target.state = RESOLVED
    end

    local reject = function( ... )
        if target.state ~= PENDING then return end

        for _, callback in pairs( target.handlers ) do
            callback( ... )
        end

        target.values = { ... }

        target.state = REJECTED
    end

    resolver( resolve, reject )

    return target
end

function Promise:Then( callback )
    if self.state == PENDING then
        table.insert( self.queue, callback )
    elseif self.state == RESOLVED then
        callback( self.values )
    end

    return self
end

function Promise:Catch( callback )
    if self.state == PENDING then
        table.insert( self.handlers, callback )
    elseif self.state == RESOLVED then
        callback( self.values )
    end

    return self
end

setmetatable( Promise, {
    __call = Promise.new
} )

AzLink.Promise = Promise

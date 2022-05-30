local vector = require 'vector'

local tab, container = 'VISUALS', 'Other ESP'
local interface = {
    enabled = ui.new_checkbox(tab, container, 'Pet chicken')
}

local on_net_update = function()
    local local_player = entity.get_local_player()
    local local_origin = vector(entity.get_origin(local_player))

    local chickens = entity.get_all('CChicken')
    for i=1, #chickens do
        local chicken = chickens[i]

        entity.set_prop(chicken, 'm_vecOrigin', local_origin:unpack())
    end
end

local handle_callback = function(self)
    local handle = ui.get(self) and client.set_event_callback or client.unset_event_callback
    
    -- we want all the chinkins
    handle('net_update_start', on_net_update)
    handle('net_update_end', on_net_update)
end

ui.set_callback(interface.enabled, handle_callback)
handle_callback(interface.enabled)

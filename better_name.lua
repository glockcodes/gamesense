local tab, container = 'VISUALS', 'Player ESP'
local reference = {
    teammates = ui.reference(tab, container, 'Teammates'),
    name = ui.reference(tab, container, 'Name')
}

local interface = {
    enabled = ui.new_checkbox(tab, container, 'Better name'),
    color = ui.new_color_picker(tab, container, 'Color', 255, 255, 255, 255)
}

local get_players = function(enemies_only)
    local result = {}

    local maxplayers = globals.maxplayers()
    local player_resource = entity.get_player_resource()
    
    for player = 1, maxplayers do
        local enemy = entity.is_enemy(player)
        local alive = entity.get_prop(player_resource, 'm_bAlive', player)

        if (not enemy and enemies_only) or alive ~= 1 then goto skip end

        table.insert(result, player) 

        ::skip::
    end

    return result
end

local on_paint = function()
    local teammates = ui.get(reference.teammates)
    local r, g, b, a = ui.get(interface.color)

    local players = get_players(not teammates)
    for i, player in pairs(players) do
        local box = { entity.get_bounding_box(player) }
        local name = entity.get_player_name(player)
        local nw, nh = renderer.measure_text('cb', name) -- lazy

        if box[1] and box[5] > 0 then
            renderer.rectangle(box[1]/2 + box[3]/2 - nw/2, box[2] - nh - 2, nw, 2, r, g, b, box[5]*255)
            renderer.blur(box[1]/2 + box[3]/2 - nw/2, box[2] - nh, nw, nh)
            renderer.rectangle(box[1]/2 + box[3]/2 - nw/2, box[2] - nh, nw, nh, 17, 17, 17, box[5]*255 / 3)
            renderer.text(box[1]/2 + box[3]/2, box[2] - nh/2, 255, 255, 255, box[5]*255, 'c', 0, name)
        end
    end
end

local handle_callback = function(event)
	local handle = event and client.set_event_callback or client.unset_event_callback

	handle('paint', on_paint)
end

ui.set_callback(interface.enabled, function()
	local enabled = ui.get(interface.enabled)
	handle_callback(enabled)
end)

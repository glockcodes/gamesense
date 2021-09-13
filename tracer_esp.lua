--[[
    Script: tracer_esp.lua

    * This script will create tracer and/or line esp.
--]]

--> Variable(s)
local tab, container = 'VISUALS', 'Player ESP'

--> User interface
local ui_enabled = ui.new_checkbox(tab, container, 'Tracer')
local ui_color = ui.new_color_picker(tab, container, 'Color picker #1', 255, 255, 255, 155)

--> Main function(s)
local on_paint = function()
    local x, y = client.screen_size()
    local local_player = entity.get_local_player()

    local enabled = ui.get(ui_enabled)
    if not enabled or not local_player then return end

    local color = { ui.get(ui_color) } -- Better in my opinion than r, g, b, a variables.

    local all_players = entity.get_players(true)
    for k, v in pairs(all_players) do
        local player = all_players[k]
        local x1, y1, x2, y2, a = entity.get_bounding_box(player)
        
        if x1 ~= nil and a > 0 then
            renderer.line(x/2, y, x1/2 + x2/2, y2, color[1], color[2], color[3], color[4])
        end
    end
end

--> Callback(s)
client.set_event_callback('paint', on_paint)

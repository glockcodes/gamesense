local vector = require 'vector'

local clamp = function(x, min, max)
    return math.min(math.max(x, min), max)
end

local round = function(x, place)
    local m = 10 ^ (place or 0)
    return math.floor(x * m + 0.5) / m
end

local tab, container = 'LUA', 'A'
local interface = {
    enabled = ui.new_checkbox(tab, container, '3D Bomb timer'),
    color = ui.new_color_picker(tab, container, 'Bomb timer color', 210, 207, 205, 255),
    height = ui.new_slider(tab, container, 'Height offset', 0, 80, 40, true, 'px'),
    render = ui.new_slider(tab, container, 'Render distance', 0, 1000, 800, true, 'u'),
    alpha = ui.new_checkbox(tab, container, 'Render distance alpha'),
}

local on_paint = function()
    local local_player = entity.get_local_player()
    local is_alive = entity.is_alive(local_player)

    if not local_player or not is_alive then
        return
    end

    local color = {ui.get(interface.color)}
    local height = ui.get(interface.height)
    local render = ui.get(interface.render)
    local alpha = ui.get(interface.alpha)

    local local_origin = vector(entity.get_prop(local_player, 'm_vecOrigin'))

    local planted_bombs = entity.get_all('CPlantedC4')
    for index, bomb in ipairs(planted_bombs) do
        if not bomb then
            goto skip
        end

        local bomb_origin = vector(entity.get_prop(bomb, 'm_vecOrigin'))
        local bomb_time = entity.get_prop(bomb, 'm_flC4Blow')
        local bomb_time_left = bomb_time - globals.curtime()
        local bomb_defused = entity.get_prop(bomb, 'm_bBombDefused') == 1

        if bomb_time_left < 0 or bomb_defused then
            goto skip
        end

        local bomb_distance = local_origin:dist(bomb_origin)

        local x, y = renderer.world_to_screen(bomb_origin.x, bomb_origin.y, bomb_origin.z + height)

        if x and y then
            local r, g, b, a = color[1], color[2], color[3], alpha and  clamp(255 - (bomb_distance / render) * 255, 0, 255) or color[4]
            if bomb_distance <= render then
                renderer.circle_outline(x, y - 5, 30, 30, 30, a, 20, 0, 100, 6)
                renderer.circle_outline(x, y - 5, r, g, b, a, 20 - 1, 0, bomb_time_left / 40, 7 -3)
                renderer.text(x, y - 5, 255, 255, 255, a, 'c', 0, round(bomb_time_left, 1))
            end
        end

        ::skip::
    end
end

local handle_callback = function(self)
    local handle = ui.get(self) and client.set_event_callback or client.unset_event_callback
    handle('paint', on_paint)
end

ui.set_callback(interface.enabled, handle_callback)
handle_callback(interface.enabled)

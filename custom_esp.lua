--[[
    Custom ESP in lua (recode)
    Credits: halflifefan, Nexxed, and Aviarita. looked at some of their related luas on github to see how some things are done and copied some stuff.
    Note: Anything commented out will be added later.
]]

--> Requirements
local csgo_weapons = require('gamesense/csgo_weapons')

--> Variables
local tab, container = 'LUA', 'A'

--> User interface
local ui_hotkey = ui.new_hotkey(tab, container, 'Activation type', false, 0)
local ui_teammates = ui.new_checkbox(tab, container, 'Teammates')
-- local ui_dormant = ui.new_checkbox(tab, container, 'Dormant')
local ui_bounding_box = ui.new_checkbox(tab, container, 'Bounding box')
local ui_bounding_box_color = ui.new_color_picker(tab, container, 'Bounding box color', 255, 255, 255, 255)
local ui_health_bar = ui.new_checkbox(tab, container, 'Health bar')
local ui_health_bar_color = ui.new_color_picker(tab, container, 'Health bar color', 255, 255, 255, 255)
local ui_name = ui.new_checkbox(tab, container, 'Name')
local ui_name_color = ui.new_color_picker(tab, container, 'Name color', 255, 255, 255, 255)
local ui_flags = ui.new_checkbox(tab, container, 'Flags')
local ui_flags_color = ui.new_color_picker(tab, container, 'Flags color', 255, 255, 255, 255)
local ui_weapon_text = ui.new_checkbox(tab, container, 'Weapon text')
local ui_weapon_text_color = ui.new_color_picker(tab, container, 'Weapon text color', 255, 255, 255, 255)
local ui_distance = ui.new_checkbox(tab, container, 'Distance')
local ui_distance_color = ui.new_color_picker(tab, container, 'Distance color', 255, 255, 255, 255)
-- local ui_skeleton = ui.new_checkbox(tab, container, 'Skeleton')
-- local ui_skeleton_color = ui.new_color_picker(tab, container, 'Skeleton color', 255, 255, 255, 255)

--> Important functions

local round = function(value)
    return math.floor(value + 0.5)
end

local units_to_feet = function(units)
    local units_to_meters = units * 0.0254

    return units_to_meters * 3.281
end

local vec2_distance = function(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end

renderer.bounding_box = function(x, y, w, h, r, g, b, a)
    renderer.rectangle(x + 1, y, w - 1, 1, r, g, b, a)
    renderer.rectangle(x + w - 1, y + 1, 1, h - 1, r, g, b, a)
    renderer.rectangle(x, y + h - 1, w - 1, 1, r, g, b, a)
    renderer.rectangle(x, y, 1, h - 1, r, g, b, a)
end


--> Main functions
local on_paint = function()
    if not ui.get(ui_hotkey) then return end

    -- local dormant = ui.get(ui_dormant)
    local teammates = ui.get(ui_teammates)
    local bounding_box = ui.get(ui_bounding_box)
    local b_r, b_g, b_b, b_a = ui.get(ui_bounding_box_color)
    local health_bar = ui.get(ui_health_bar)
    local h_r, h_g, h_b, h_a = ui.get(ui_health_bar_color)
    local name = ui.get(ui_name)
    local n_r, n_g, n_b, n_a = ui.get(ui_health_bar_color)
    local flags = ui.get(ui_flags)
    local f_r, f_g, f_b, f_a = ui.get(ui_name_color)
    local weapon_text = ui.get(ui_weapon_text)
    local w_r, w_g, w_b, w_a = ui.get(ui_flags_color)
    local distance = ui.get(ui_distance)
    local d_r, d_g, d_b, d_a = ui.get(ui_distance_color)
    -- local skeleton = ui.get(ui_skeleton)
    -- local s_r, s_g, s_b, s_a = ui.get(ui_skeleton_color)

    local players = entity.get_players(not teammates)
    for k, v in pairs(players) do
        local enemy_players = players[k]
        local enemy_dormant = entity.is_dormant(player)
        local enemy_resource = entity.get_player_resource()
        local enemy_name = entity.get_player_name(enemy_players)
        local enemy_health = entity.get_prop(enemy_players, 'm_iHealth')
        local enemy_vip = entity.get_prop(enemy_players, 'm_iPlayerVIP')
        local enemy_c4 = entity.get_prop(enemy_players, 'm_iPlayerC4')
        local enemy_duck = entity.get_prop(enemy_players, 'm_flDuckAmount')
        local enemy_duckspeed = entity.get_prop(enemy_players, 'm_flDuckSpeed')
        local enemy_flags_height = 0
        local bottom_text_height = 0

        local x1, y1, x2, y2, a = entity.get_bounding_box(enemy_players)
        
        if x1 ~= nil and a > 0 then

            if bounding_box then
                renderer.bounding_box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2, 0, 0, 0, 155)
                renderer.bounding_box(x1, y1, x2 - x1, y2 - y1, b_r, b_g, b_b, b_a)
                renderer.bounding_box(x1 - 1, y1 - 1, x2 - x1 + 2, y2 - y1 + 2, 0, 0, 0, 155)
            end

            if health_bar then
                local update = y2 - y1 + 2

                renderer.rectangle(x1 - 6, y1 - 1, x2 - x2 + 4, y2 - y1 + 2, 0, 0, 0, 200)
                renderer.rectangle(x1 - 5, math.floor(y2-(update*enemy_health/100)) + 2, 2, math.floor(update*enemy_health/100) - 2, h_r, h_g, h_b, h_a)

                if enemy_health < 100 then
                    renderer.text(x1 - 7, math.floor(y2-(update*enemy_health/100)) + 2, 255, 255, 255, 255, 'c-', 0, enemy_health)
                end
            end

            if name then
                renderer.text(x1/2 + x2/2, y1 - 8, n_r, n_g, n_b, n_a, 'c', 0, string.format('%s...', enemy_name:sub(1, 10)))
            end

            if flags then
                if enemy_health < 92 then
                    renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'LETHAL')
                end

                if enemy_c4 then
                    enemy_flags_height = enemy_flags_height + 10
                    renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'BOMB')
                end

                if enemy_vip then
                    enemy_flags_height = enemy_flags_height + 10
                    renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'HOSTAGE')
                end

                if enemy_duckspeed == 8 and enemy_duck <= 0.9 and enemy_duck > 0.01 then
                    enemy_flags_height = enemy_flags_height + 10
                    renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'DUCK')
                end
            end

            if distance then
                bottom_text_height = bottom_text_height + 10

                local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
                local ex, ey, ez = entity.get_prop(enemy_players, "m_vecOrigin")
                local unit = vec2_distance(lx, ly, lz, ex, ey, ez)
                local converted = round(units_to_feet(unit))
                
                renderer.text(x1/2 + x2/2, y2 + 6, d_r, d_g, d_b, d_a, 'c-', 0, string.format('%sFT', converted))
            end

            if weapon_text then
                bottom_text_height = bottom_text_height + 6

                local weapon_ent = entity.get_player_weapon(enemy_players)
                if weapon_ent == nil then return end
                local weapon = csgo_weapons(weapon_ent)

                renderer.text(x1/2 + x2/2, y2 + bottom_text_height, w_r, w_g, w_b, w_a, 'c-', 0, string.upper(weapon.name))
            end
        end
    end
end

client.set_event_callback('paint', on_paint)

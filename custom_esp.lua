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
local ui_label = ui.new_label(tab, container, 'Player ESP in lua with customization')
local ui_hotkey = ui.new_hotkey(tab, container, 'Activation type', false, 0)
local ui_teammates = ui.new_checkbox(tab, container, 'Teammates')
local ui_bounding_box = ui.new_checkbox(tab, container, 'Bounding box')
local ui_bounding_box_color = ui.new_color_picker(tab, container, 'Bounding box color', 255, 255, 255, 255)
local ui_health_bar = ui.new_checkbox(tab, container, 'Health bar')
local ui_health_bar_color = ui.new_color_picker(tab, container, 'Health bar color', 255, 255, 255, 255)
local ui_health_bar_style = ui.new_combobox(tab, container, 'Health bar style', 'Color', 'Gradient')
local ui_name = ui.new_checkbox(tab, container, 'Name')
local ui_name_color = ui.new_color_picker(tab, container, 'Name color', 255, 255, 255, 255)
local ui_name_truncate = ui.new_slider(tab, container, 'Name truncate', 0, 20, 10, true, nil, 1, false)
local ui_flags = ui.new_checkbox(tab, container, 'Flags')
local ui_flags_color = ui.new_color_picker(tab, container, 'Flags color', 255, 255, 255, 255)
local ui_flags_options = ui.new_multiselect(tab, container, 'Flags selection', 'Money', 'Armour', 'Defuser', 'Bomb', 'Scoped', 'Fake duck')
local ui_weapon_text = ui.new_checkbox(tab, container, 'Weapon text')
local ui_weapon_text_color = ui.new_color_picker(tab, container, 'Weapon text color', 255, 255, 255, 255)
local ui_distance = ui.new_checkbox(tab, container, 'Distance')
local ui_distance_color = ui.new_color_picker(tab, container, 'Distance color', 255, 255, 255, 255)

--> Important functions
local round = function(value) return math.floor(value + 0.5) end
local contains = function(b,c)for d=1,#b do if b[d]==c then return true end end;return false end

local get_distance = function(from, to, unit) -- big credits to Nexxed :)
    local xDist, yDist, zDist = to[1] - from[1], to[2] - from[2], to[3] - from[3]

    local m1, m2 = 0, 0
    if(unit ~= nil and unit == "feet") then
        m1 = 2
        m2 = 30.48
    end

    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) + (zDist ^ 2) ) * m1 / m2
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

    local teammates = ui.get(ui_teammates)
    local bounding_box = ui.get(ui_bounding_box)
    local b_r, b_g, b_b, b_a = ui.get(ui_bounding_box_color)
    local health_bar = ui.get(ui_health_bar)
    local h_r, h_g, h_b, h_a = ui.get(ui_health_bar_color)
    local health_bar_style = ui.get(ui_health_bar_style)
    local name = ui.get(ui_name)
    local name_truncate = ui.get(ui_name_truncate)
    local n_r, n_g, n_b, n_a = ui.get(ui_name_color)
    local flags = ui.get(ui_flags)
    local flags_selection = ui.get(ui_flags_options)
    local f_r, f_g, f_b, f_a = ui.get(ui_flags_color)
    local weapon_text = ui.get(ui_weapon_text)
    local w_r, w_g, w_b, w_a = ui.get(ui_weapon_text_color)
    local distance = ui.get(ui_distance)
    local d_r, d_g, d_b, d_a = ui.get(ui_distance_color)

    local all_players = entity.get_players(not teammates)
    for k, v in pairs(all_players) do
        local players = all_players[k]

        --> Information
        local player_dormant = entity.is_dormant(players)
        local player_name = entity.get_player_name(players)
        local player_money = entity.get_prop(players, "m_iAccount")

        --> Health
        local player_health = entity.get_prop(players, "m_iHealth")
        local player_helmet, player_kevlar = entity.get_prop(players, 'm_bHasHelmet') == 1, entity.get_prop(players, 'm_ArmorValue') ~= 0

        --> Misc
        local player_defuser = entity.get_prop(players, 'm_bHasDefuser')
        local player_carrier = entity.get_prop(players, "m_iPlayerC4")
        local player_scoped = entity.get_prop(players, 'm_bIsScoped') == 1
        local player_duck_amount = entity.get_prop(players, 'm_flDuckAmount')

        local enemy_flags_height = 0
        local bottom_text_height = 0

        local x1, y1, x2, y2, a = entity.get_bounding_box(players)
        
        if x1 ~= nil and a > 0 then

            if bounding_box then
                renderer.bounding_box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2, 0, 0, 0, 155)
                renderer.bounding_box(x1, y1, x2 - x1, y2 - y1, b_r, b_g, b_b, b_a)
                renderer.bounding_box(x1 - 1, y1 - 1, x2 - x1 + 2, y2 - y1 + 2, 0, 0, 0, 155)
            end

            if health_bar then
                local update = y2 - y1 + 2

                renderer.rectangle(x1 - 6, y1 - 1, x2 - x2 + 4, y2 - y1 + 2, 0, 0, 0, 200)
                
                if health_bar_style == 'Color' then
                    renderer.rectangle(x1 - 5, math.floor(y2-(update*player_health/100)) + 2, 2, math.floor(update*player_health/100) - 2, h_r, h_g, h_b, h_a)
                else
                    renderer.gradient(x1 - 5, math.floor(y2-(update*player_health/100)) + 2, 2, math.floor(update*player_health/100) - 2, h_r, h_g, h_b, h_a, h_r*1/4, h_g*1/4, h_b*1/4, h_a, false)
                end

                if player_health < 100 then
                    renderer.text(x1 - 7, math.floor(y2-(update*player_health/100)) + 2, 255, 255, 255, 255, 'c-', 0, player_health)
                end
            end

            if name then
                renderer.text(x1/2 + x2/2, y1 - 8, n_r, n_g, n_b, n_a, 'c', 0, string.format('%s...', player_name:sub(1, name_truncate)))
            end

            if flags then

                if contains(flags_selection, 'Money') then
                    renderer.text(x2 + 2, y1 + enemy_flags_height, 0, 255, 0, f_a, '-', 0, string.format('$%s', player_money))
                end

                if contains(flags_selection, 'Armour') then
                    if player_helmet and player_kevlar then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'HK')
                    elseif player_helmet then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'H')
                    end
                end

                if contains(flags_selection, 'Defuser') then
                    if player_defuser then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'KIT')
                    end
                end

                if contains(flags_selection, 'Bomb') then
                    if player_carrier then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'BOMB')
                    end
                end

                if contains(flags_selection, 'Scoped') then
                    if player_scoped then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'SCOPED')
                    end    
                end

                if contains(flags_selection, 'Fake duck') then
                    if player_duck_amount > 0 and player_duck_amount < 1 then
                        enemy_flags_height = enemy_flags_height + 10
                        renderer.text(x2 + 2, y1 + enemy_flags_height, f_r, f_g, f_b, f_a, '-', 0, 'DUCK')
                    end
                end
            end

            if distance then
                bottom_text_height = bottom_text_height + 10

                local local_origin = { entity.get_prop(entity.get_local_player(), "m_vecAbsOrigin") }
                local player_origin = { entity.get_prop(players, "m_vecOrigin") }
                
                renderer.text(x1/2 + x2/2, y2 + 6, d_r, d_g, d_b, d_a, 'c-', 0, string.format('%sFT', round(get_distance(local_origin, player_origin, "feet"))))
            end

            if weapon_text then
                bottom_text_height = bottom_text_height + 6

                local weapon_ent = entity.get_player_weapon(players)
                local weapon = csgo_weapons(weapon_ent)

                renderer.text(x1/2 + x2/2, y2 + bottom_text_height, w_r, w_g, w_b, w_a, 'c-', 0, string.upper(weapon.name))
            end
        end
    end
end

client.set_event_callback('paint', on_paint)

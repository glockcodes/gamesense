--[[
    Script: pulse_chams.lua
    Author: glock#3574

    * Allows you to have pulsing chams on every local player related cham
]]

--> Variable(s)
local tab, container = 'VISUALS', 'Colored models'
local alpha = 0

--> User interface
local ui_local_player, ui_local_player_color = ui.reference(tab, container, 'Local player')
local ui_local_player_fake, ui_local_player_fake_color = ui.reference(tab, container, 'Local player fake')
local ui_hands, ui_hands_color = ui.reference(tab, container, 'Hands')
local ui_weapon_viewmodel, ui_weapon_viewmodel_color = ui.reference(tab, container, 'Weapon viewmodel')
local ui_third_person, ui_third_person_key = ui.reference(tab, 'Effects', 'Force third person (alive)')

local ui_enabled = ui.new_checkbox(tab, container, 'Pulse')
local ui_pulse_option = ui.new_multiselect(tab, container, '\n', 'Local player', 'Local player fake', 'Hands', 'Weapon viewmodel')
local ui_pulse_speed = ui.new_slider(tab, container, 'Speed', 0, 10, 1)

--> Important function(s)
local contains = function(b,c)for d=1,#b do if b[d]==c then return true end end;return false end

--> Main function(s)
local on_paint = function()
    local local_player = entity.get_local_player()
    local is_alive = entity.is_alive(local_player)
    local enabled = ui.get(ui_enabled)

    if not enabled or not local_player or not is_alive then return end

    local local_player_color = { ui.get(ui_local_player_color) }
    local local_player_fake_color = { ui.get(ui_local_player_fake_color) }
    local hands_color = { ui.get(ui_hands_color) }
    local weapon_viewmodel_color = { ui.get(ui_weapon_viewmodel_color) }

    local pulse_option = ui.get(ui_pulse_option)
    local pulse_speed = ui.get(ui_pulse_speed)

    local alpha = math.sin(math.abs((math.pi * -1) + (globals.curtime() * pulse_speed) % (math.pi * 2))) * 255

    if contains(pulse_option, 'Local player') then
        ui.set(ui_local_player_color, local_player_color[1], local_player_color[2], local_player_color[3], alpha)
    end

    if contains(pulse_option, 'Local player fake') then
        ui.set(ui_local_player_fake_color, local_player_fake_color[1], local_player_fake_color[2], local_player_fake_color[3], alpha)
    end

    if contains(pulse_option, 'Hands') then
        ui.set(ui_hands_color, hands_color[1], hands_color[2], hands_color[3], alpha)
    end

    if contains(pulse_option, 'Weapon viewmodel') then
        ui.set(ui_weapon_viewmodel_color, weapon_viewmodel_color[1], weapon_viewmodel_color[2], weapon_viewmodel_color[3], alpha)
    end
end

--> Callback(s)
client.set_event_callback('paint', on_paint)

local override_zoom_fov = ui.reference('MISC', 'Miscellaneous', 'Override zoom FOV')
local override_zoom_fov_slider = ui.new_slider('MISC', 'Miscellaneous', 'Override zoom FOV on second scope', 0, 100, 0, true, '%', 1)

client.set_event_callback('paint', function()
    local ent = entity.get_local_player()
    local weapon = entity.get_player_weapon(ent)
    local prop = entity.get_prop(weapon, 'm_zoomLevel')

    if prop == nil or prop == 0 then
        ui.set(override_zoom_fov, 0)
        return
    end

    if prop == 1 then
        ui.set(override_zoom_fov, 0)
    elseif prop == 2 then
        ui.set(override_zoom_fov, ui.get(override_zoom_fov_slider))
    end
end)

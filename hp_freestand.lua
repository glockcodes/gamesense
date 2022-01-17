local tab, container = 'AA', 'Anti-aimbot angles'

local references = {
	freestanding = ui.reference(tab, container, 'Freestanding')
}

local interface = {
	enabled = ui.new_checkbox(tab, container, 'Health based freestanding'),
	disabler = ui.new_slider(tab, container, 'Disabler health', 1, 100, 1, true, 'hp')
}

local on_run_cmd = function(cmd)
	local local_player = entity.get_local_player()
	local is_alive = entity.is_alive(local_player)

	if not local_player or not is_alive then return end

	local health = entity.get_prop(local_player, 'm_iHealth')
	local disabler = ui.get(interface.disabler)

	ui.set(references.freestanding, 'Default')

    if disabler >= health then
        ui.set(references.freestanding, '-')
    end
end

local handle_callback = function(event)
	local handle = event and client.set_event_callback or client.unset_event_callback

	handle('run_command', on_run_cmd)
	handle('shutdown', function()
		ui.set(references.freestanding, '-')
	end)
end

ui.set_callback(interface.enabled, function()
	local enabled = ui.get(interface.enabled)
	handle_callback(enabled)
end)

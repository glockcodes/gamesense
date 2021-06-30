local tab, container = 'MISC', 'Settings'

local ui_unload = ui.reference(tab, container, 'Unload')

local ui_bad_inject = ui.new_checkbox(tab, container, 'Bad inject detection')
local ui_misses = ui.new_slider(tab, container, 'Misses required for detection', 1, 12, 3, true, nil, 1, true)
local ui_option = ui.new_combobox(tab, container, 'Perform action on detection', 'Unload', 'Quit')

local shots = {
	miss = 0
}

local on_aim_miss = function(e)
	if not ui.get(ui_bad_inject) then return end

	if e.reason ~= 'death' and e.reason ~= 'unregistered shot' and e.reason == '?' then
		shots.miss = shots.miss + 1
	end

	if shots.miss <= ui.get(ui_misses) then
		if ui.get(ui_option) == 'Unload' then
			ui.set(ui_unload, true)
		else
			client.exec('quit')
		end
	end
end

local on_round_start = function()
	if not ui.get(ui_bad_inject) then return end

	shots.miss = 0
end

client.set_event_callback('aim_miss', on_aim_miss)
client.set_event_callback('round_start', on_round_start)

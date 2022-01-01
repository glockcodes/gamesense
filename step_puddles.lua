local vector = require 'vector'

local tab, container = 'LUA', 'B'
local interface = {
	enabled = ui.new_checkbox(tab, container, 'Step puddles'),
	color = ui.new_color_picker(tab, container, 'Color', 255, 255, 255, 255),
	duration = ui.new_slider(tab, container, 'Duration', 1, 8, 2, true, 's', 1),
	size = ui.new_slider(tab, container, 'Size', 10, 30, 20, true, 'p')
}

local step_data = {}
local last_step = 0
local step_size = 0
local step_alpha = 0

local renderer_3d_circle_outline = function(pos, radius, r, g, b, a, inc)
	local old = {}

	for rot = 0, 360, inc do
		local rad_rot = math.rad(rot)
		local cos_rot = math.cos(rad_rot)
		local sin_rot = math.sin(rad_rot)

		local line = vector(radius * cos_rot + pos.x, radius * sin_rot + pos.y, pos.z)
		local w2s = { renderer.world_to_screen(line.x, line.y, line.z) }

		if w2s[1] ~= nil and old[1] ~= nil then
			for i = 1, 1 do
				local i = i - 1
				renderer.line(w2s[1], w2s[2] - i, old[1], old[2] - i, r, g, b, a)
			end
		end

		old = { w2s[1], w2s[2] }
	end
end

local on_player_footstep = function(e)
	local local_player = entity.get_local_player()
	local userid_to_entindex = client.userid_to_entindex(e.userid)

	if local_player == userid_to_entindex then
		local curtime = globals.curtime()
		local origin = vector(entity.get_prop(local_player, 'm_vecAbsOrigin'))

		if curtime and origin then
			table.insert(step_data, { 
				curtime = curtime,
				origin = origin,
			})
		end
	end
end

local on_paint = function()
	local local_player = entity.get_local_player()
	local is_alive = entity.is_alive(local_player)

	if not local_player or not is_alive then return end

	local curtime = globals.curtime()

	local r, g, b, a = ui.get(interface.color)
	local duration = ui.get(interface.duration)
	local size = ui.get(interface.size)

	for i, step in pairs(step_data) do
		if step.curtime + duration > curtime then
			last_step = curtime - step.curtime
			step_size = last_step / duration

			if duration - last_step < duration then 
				step_alpha = (duration - last_step) / duration 
			end

			renderer_3d_circle_outline(step.origin, step_size * size, r, g, b, a * step_alpha, 15)
		else
			table.remove(step_data, i)
		end
	end
end

local handle_callback = function(event)
	local handle = event and client.set_event_callback or client.unset_event_callback

	handle('player_footstep', on_player_footstep)
	handle('paint', on_paint)
end

ui.set_callback(interface.enabled, function()
	local enabled = ui.get(interface.enabled)
	handle_callback(enabled)
end)

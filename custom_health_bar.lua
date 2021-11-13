--> Requirement(s)
local vector = require 'vector'
local entity = require 'gamesense/entity'
local surface = require 'gamesense/surface'

--> Important function(s)
local round = function(int)
	return math.floor(int + 0.5)
end

--> User interface
local tab, container = 'VISUALS', 'Player ESP'
local esp = {
	health = ui.new_checkbox(tab, container, 'Lua health bar'),
	color = ui.new_color_picker(tab, container, 'Lua health bar color', 255, 255, 255, 255)
}

local on_paint = function()
	local players = entity.get_players(false)
	local enabled = ui.get(esp.health)

	if not enabled then return end

	local clr = { ui.get(esp.color) }

	for i, v in ipairs(players) do
		local box = { v:get_bounding_box() } --> x1, y1, x2, y2, alpha == box[1] box[2] box[3] box[4], box[5]

		local health = v:get_prop 'm_iHealth'

		if box[1] and box[5] > 0 then
			local h = box[4] - box[2]
			surface.draw_filled_outlined_rect(box[1] - 6, box[2] - 1, 4, box[4] - box[2] + 2, 0, 0, 0, 200, 0, 0, 0, 255)
			surface.draw_filled_rect(box[1] - 5, round(box[4] - (h*health/100)), 2, round(h*health/100), clr[1], clr[2], clr[3], clr[4])
			local t = health < 100 and renderer.text(box[1] - 7, round(box[4]-(h*health/100)) + 2, 255, 255, 255, 255, 'c-', 0, health)
		end
	end
end

client.set_event_callback('paint', on_paint)

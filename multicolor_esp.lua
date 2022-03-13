local vector = require 'vector'

local contains = function(b,c)for d=1,#b do if b[d]==c then return true end end;return false end

local tab, container = 'VISUALS', 'Player ESP'
local interface = {
    enabled = ui.new_checkbox(tab, container, 'Multicolored ESP'),
    colors = {
        ui.new_color_picker(tab, container, 'Player', 150, 200, 60, 255),
        ui.new_color_picker(tab, container, 'Player behind wall', 60, 120, 180, 255)
    },
    options = ui.new_multiselect(tab, container, '\n', 'Bounding box', 'Skeleton', 'Name')
}

local get_players = function(enemies_only)
    local result = {}

    local maxplayers = globals.maxplayers()
    local player_resource = entity.get_player_resource()
    
    for player = 1, maxplayers do
        local enemy = entity.is_enemy(player)
        local alive = entity.get_prop(player_resource, 'm_bAlive', player)

        if (not enemy and enemies_only) or alive ~= 1 then goto skip end

        table.insert(result, player) 

        ::skip::
    end

    return result
end

local paint_box = function(x, y, w, h, r, g, b, a)
    renderer.rectangle(x + 1, y, w - 1, 1, r, g, b, a)
    renderer.rectangle(x + w - 1, y + 1, 1, h - 1, r, g, b, a)
    renderer.rectangle(x, y + h - 1, w - 1, 1, r, g, b, a)
    renderer.rectangle(x, y, 1, h - 1, r, g, b, a)
end

-- paint_line & paint_skeleton [[ty sapphyrus]]
local paint_line = function(pos1, pos2, r, g, b, a)
	if pos1[1] == nil or pos2[1] == nil then
		return
	end

	renderer.line(pos1[1], pos1[2], pos2[1], pos2[2], r, g, b, a)
end

local paint_skeleton = function(player, r, g, b, a)
	local hitboxes = {}

	for i=1, 19 do
		local wx, wy = renderer.world_to_screen(entity.hitbox_position(player, i-1))
		hitboxes[i] = {wx, wy}
	end

	paint_line(hitboxes[1], hitboxes[2], r, g, b, a)
	paint_line(hitboxes[2], hitboxes[7], r, g, b, a)
	paint_line(hitboxes[7], hitboxes[18], r, g, b, a)
	paint_line(hitboxes[7], hitboxes[16], r, g, b, a)
	paint_line(hitboxes[7], hitboxes[5], r, g, b, a)
	paint_line(hitboxes[5], hitboxes[3], r, g, b, a)

	-- waist
	paint_line(hitboxes[3], hitboxes[8], r, g, b, a)
	paint_line(hitboxes[3], hitboxes[9], r, g, b, a)

	-- left leg
	paint_line(hitboxes[8], hitboxes[10], r, g, b, a)
	paint_line(hitboxes[10], hitboxes[12], r, g, b, a)

	-- right leg
	paint_line(hitboxes[9], hitboxes[11], r, g, b, a)
	paint_line(hitboxes[11], hitboxes[13], r, g, b, a)

	-- left arm
	paint_line(hitboxes[18], hitboxes[19], r, g, b, a)
	paint_line(hitboxes[19], hitboxes[15], r, g, b, a)

	-- right arm
	paint_line(hitboxes[16], hitboxes[17], r, g, b, a)
	paint_line(hitboxes[17], hitboxes[14], r, g, b, a)
end
-- paint_line & paint_skeleton [[ty sapphyrus]]

local on_paint = function()
    local local_player = entity.get_local_player()
    local local_eyes = vector(client.eye_position(local_player))
    local enemies = get_players(true)
    local options = ui.get(interface.options)

    if #enemies == 0 or #options == 0 then return end
    
    print('test')

    for i, enemy in ipairs(enemies) do
        local box = {entity.get_bounding_box(enemy)} -- [1] = x1, [2] = y1, [3] = x2, [4] = y2, [5] = a
        local origin = vector(entity.get_prop(enemy, 'm_vecOrigin')) -- [1] = x, [2] = y, [3] = z
        local name = entity.get_player_name(enemy)

        local r, g, b = ui.get(interface.colors[2])
        local alpha = box[5]*255

        for i = 1, 19 do
            local hitbox = vector(entity.hitbox_position(enemy, i))
			local fraction, entindex = client.trace_line(local_player, local_eyes.x, local_eyes.y, local_eyes.z, hitbox.x, hitbox.y, hitbox.z)

			if enemy == entindex or fraction == 1 then
                r, g, b = ui.get(interface.colors[1])
			end
        end

        if box[1] and box[5] > 0 then
            if contains(options, 'Name') then
                renderer.text(box[1]/2 + box[3]/2, box[2] - 8, r, g, b, alpha, 'c', 0, name)
            end

            if contains(options, 'Bounding box') then
                paint_box(box[1], box[2], box[3] - box[1], box[4] - box[2], r, g, b, alpha)
                paint_box(box[1] + 1, box[2] + 1, box[3] - box[1] - 2, box[4] - box[2] - 2, 0, 0, 0, alpha)
                paint_box(box[1], box[2], box[3] - box[1], box[4] - box[2], r, g, b, alpha)
                paint_box(box[1] - 1, box[2] - 1, box[3] - box[1] + 2, box[4] - box[2] + 2, 0, 0, 0, alpha)
            end

            if contains(options, 'Skeleton') then
                paint_skeleton(enemy, r, g, b, alpha)
            end
        end
    end
end

local function handle_callback(self)
    local handle = ui.get(self) and client.set_event_callback or client.unset_event_callback

    handle('paint', on_paint)
end

ui.set_callback(interface.enabled, handle_callback)
handle_callback(interface.enabled)

client.set_event_callback('shutdown', function()
    ui.set(interface.enabled, false)
    handle_callback(interface.enabled)
end)

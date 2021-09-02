--[[
	Menu Sound 
	- Allows you to play a sound file upon opening the menu.

	* Thank you to a friend that purchased fanta and gave me this amazing idea.
]]

--> Variables
local executed = false
local tab, container = 'CONFIG', 'Lua'

--> User interface
local ui_enabled = ui.new_checkbox(tab, container, 'Sound on menu open')
local ui_label = ui.new_label(tab, container, 'File name')
local ui_file = ui.new_textbox(tab, container, 'File name text box')

--> Main function(s)
local on_paint_ui = function()
	local enabled = ui.get(ui_enabled)

	if not enabled then return end
	
	local is_menu_open = ui.is_menu_open()
	local file = ui.get(ui_file)

	if is_menu_open then
		if not executed then
			client.exec(string.format('playvol %s 1', file))
			executed = true
		end
	else
		executed = false
	end
end

--> Callback(s)
client.set_event_callback('paint_ui', on_paint_ui)

local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local renderer_circle = renderer.circle
local vector = require 'vector'
local m_render_engine = (function()

	local a = {}
	local container_main = function(x, y, long, width, round, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + round, y, long - round * 2, round, color_r, color_g, color_b, alpha)
		renderer_rectangle(x, y + round, round, width - round * 2, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + round, y + width - round, long - round * 2, round, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + long - round, y + round, round, width - round * 2, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + round, y + round, long - round * 2, width - round * 2, color_r, color_g, color_b, alpha)
		renderer_circle(x + round, y + round, color_r, color_g, color_b, alpha, round, 180, 0.25)
		renderer_circle(x + long - round, y + round, color_r, color_g, color_b, alpha, round, 90, 0.25)
		renderer_circle(x + round, y + width - round, color_r, color_g, color_b, alpha, round, 270, 0.25)
		renderer_circle(x + long - round, y + width - round, color_r, color_g, color_b, alpha, round, 0, 0.25)
	end;
	local glow_color = function(x, y, long, width, round, color_r, color_g, color_b, alpha)
		renderer_rectangle(x, y + round, 1, width - round * 2 + 2, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + long - 1, y + round, 1, width - round * 2 + 1, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + round, y, long - round * 2, 1, color_r, color_g, color_b, alpha)
		renderer_rectangle(x + round, y + width, long - round * 2, 1, color_r, color_g, color_b, alpha)
		renderer_circle_outline(x + round, y + round, color_r, color_g, color_b, alpha, round, 180, 0.25, 2)
		renderer_circle_outline(x + long - round, y + round, color_r, color_g, color_b, alpha, round, 270, 0.25, 2)
		renderer_circle_outline(x + round, y + width - round + 1, color_r, color_g, color_b, alpha, round, 90, 0.25, 2)
		renderer_circle_outline(x + long - round, y + width - round + 1, color_r, color_g, color_b, alpha, round, 0, 0.25, 2)
	end;
	--Circle Round
	local Round = 3;
    --Container Downword Alpha
	local n = 30;
    --Glow Object
	local o = 8;
	local container_uphalf = function(x, y, long, width, round, color_r, color_g, color_b, alpha, alpha_glow)
        --Main line from upper
		renderer_rectangle(x + round, y, long - round * 2, 1, color_r, color_g, color_b, alpha)
        --Upper left/right circle
		renderer_circle_outline(x + round, y + round, color_r, color_g, color_b, alpha, round - 1, 180, 0.25, 2)
		renderer_circle_outline(x + long - round, y + round, color_r, color_g, color_b, alpha, round - 1, 270, 0.25, 2)
        --Left/Right Gradient
		renderer_gradient(x, y + round, 1, width - round * 2, color_r, color_g, color_b, alpha, color_r, color_g, color_b, n, false)
		renderer_gradient(x + long - 2, y + round, 1, width - round * 2, color_r, color_g, color_b, alpha, color_r, color_g, color_b, n, false)
        --Down left/right circle
		renderer_circle_outline(x + round, y + width - round, color_r, color_g, color_b, n, round - 1, 90, 0.25, 2)
		renderer_circle_outline(x + long - round, y + width - round, color_r, color_g, color_b, n, round - 1, 0, 0.25, 2)
        --Main line from down
		renderer_rectangle(x + round, y + width - 2, long - round * 2, 1, color_r, color_g, color_b, n)

		for r = 1, alpha_glow do
			glow_color(x - r, y - r, long + r * 2, width + r * 2, round, color_r, color_g, color_b, alpha_glow - r)
		end
	end;
	--Main Theme for container
		local container_lefthalf = function(x, y, long, width, round, color_r, color_g, color_b, alpha, alpha_glow)
        --Main line from upper
		--renderer_rectangle(x + round, y, long - round * 2, 2, color_r, color_g, color_b, alpha)
        renderer_gradient(x + round, y, long / 10, 1, color_r, color_g, color_b, alpha, color_r, color_g, color_b, 0, true)
        --Upper left/right circle
		renderer_circle_outline(x + round, y + round, color_r, color_g, color_b, alpha, round, 180, 0.25, 2)
		--renderer_circle_outline(x + long - round, y + round, color_r, color_g, color_b, alpha, round, 270, 0.25, 2)
        --Left/Right Gradient
		renderer_gradient(x, y + round, 1, width - round * 2, color_r, color_g, color_b, alpha, color_r, color_g, color_b, alpha, false)
		--renderer_gradient(x + long - 2, y + round, 2, width - round * 2, color_r, color_g, color_b, alpha, color_r, color_g, color_b, alpha, false)
        --Down left/right circle
		renderer_circle_outline(x + round, y + width - round, color_r, color_g, color_b, alpha, round, 90, 0.25, 2)
		--renderer_circle_outline(x + long - round, y + width - round, color_r, color_g, color_b, alpha, round, 0, 0.25, 2)
        --Main line from down
		renderer_gradient(x + round, y + width - 2, long / 10, 1, color_r, color_g, color_b, alpha, 17, 17, 17, 0, true)
		--renderer_rectangle(x + round, y + width - 2, long - round * 2, 2, color_r, color_g, color_b, n + 50)
		for r = 1, alpha_glow do
			glow_color(x - r, y - r, long + r * 2, width + r * 2, round, color_r, color_g, color_b, alpha_glow - r)
		end
	end;
	a.render_halfcontainer = function(x, y, long, width, color_red, color_green, color_blue, alpha, w)
		container_lefthalf(x, y, long, width, Round, color_red, color_green, color_blue, alpha, o )
	end;
	local ar, ag, ab, aa = 15, 15, 15, 80
	a.render_container = function(x, y, long, width, color_red, color_green, color_blue, alpha, w)
		container_main(x, y, long, width, Round, ar, ag, ab, aa)
		container_uphalf(x, y, long, width, Round, color_red, color_green, color_blue, alpha, o)
		if w then
			w(x + Round, y + Round, long - Round * 2, width - Round * 2)
		end
	end;
	a.render_glow_line = function(x1, y1, x2, y2, color_r, color_g, color_b, alpha, glow_r, glow_g, glow_b, glow_alpha)
		local C = vector(x1, y1, 0)
		local D = vector(x2, y2, 0)
		local E = ({
			C:to(D):angles()
		})[2]
		for r = 1, glow_alpha do
			renderer_circle_outline(x1, y1, glow_r, glow_g, glow_b, glow_alpha - r, r, E + 90, 0.5, 1)
			renderer_circle_outline(x2, y2, glow_r, glow_g, glow_b, glow_alpha - r, r, E - 90, 0.5, 1)
			local F = vector(math_cos(math_rad(E + 90)), math_sin(math_rad(E + 90)), 0):scaled(r * 0.95)
			local G = vector(math_cos(math_rad(E - 90)), math_sin(math_rad(E - 90)), 0):scaled(r * 0.95)
			local H = F + C;
			local I = F + D;
			local J = G + C;
			local K = G + D;
			renderer_line(H.x, H.y, I.x, I.y, glow_r, glow_g, glow_b, glow_alpha - r)
			renderer_line(J.x, J.y, K.x, K.y, glow_r, glow_g, glow_b, glow_alpha - r)
		end;
		renderer_line(x1, y1, x2, y2, color_r, color_g, color_b, alpha)
	end;
	return a
end)()

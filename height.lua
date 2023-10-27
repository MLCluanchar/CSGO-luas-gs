---Libarys
local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local client_register_esp_flag, client_visible, entity_hitbox_position, math_ceil, math_pow, math_sqrt, renderer_indicator, unpack, tostring, pairs = client.register_esp_flag, client.visible, entity.hitbox_position, math.ceil, math.pow, math.sqrt, renderer.indicator, unpack, tostring, pairs
local ui_new_button, ui_new_color_picker, ui_new_label, ui_reference, ui_new_checkbox, ui_new_combobox, ui_new_hotkey, ui_new_multiselect, ui_new_slider, ui_set, ui_get, ui_set_callback, ui_set_visible = ui.new_button, ui.new_color_picker, ui.new_label, ui.reference, ui.new_checkbox, ui.new_combobox, ui.new_hotkey, ui.new_multiselect, ui.new_slider, ui.set, ui.get, ui.set_callback, ui.set_visible
local client_screen_size, client_set_cvar, client_log, client_color_log, client_set_event_callback, client_unset_event_callback = client.screen_size, client.set_cvar, client.log, client.color_log, client.set_event_callback, client.unset_event_callback
local entity_get_player_name, entity_get_local_player, entity_get_player_weapon, entity_get_prop, entity_get_players, entity_is_alive = entity.get_player_name, entity.get_local_player, entity.get_player_weapon, entity.get_prop, entity.get_players, entity.is_alive
local globals_tickcount, globals_curtime, globals_realtime, globals_frametime = globals.tickcount, globals.curtime, globals.realtime, globals.frametime
local renderer_triangle, renderer_text, renderer_rectangle, renderer_gradient = renderer.triangle, renderer.text, renderer.rectangle, renderer.gradient
local client_exec = client.exec

local pi = 3.14159265358979323846
local vector = require "vector"
local pi = 3.14159265358979323846
local rtd = function(a)
    return a * 180 / pi
end
local sub = function (a, b) 
    return vector(a.x - b.x, a.y - b.y, a.z - b.z)
end


local slider = ui_new_slider("LUA", "B", "Angle", 0, 180, 0)
local height = function(angle)

    local entities = {
        me = entity_get_local_player(),
        target = client.current_threat(),
    }
    if entities.me == nil or entities.target == nil then return false end

    local player = vector(client.eye_position())
    local target = vector(entity_hitbox_position(entities.target, 0))

    local distance = {
        vector = sub(player, target),
        range = player:dist(target),
    }
    local enemyAngle = (rtd(math.asin(distance.vector.z / distance.range)))
    return ((player.z > target.z) and (enemyAngle < angle))
end

local setup_command = function()
    local angle = ui_get(slider)
    print(height(angle))
end

client_set_event_callback("setup_command", setup_command)
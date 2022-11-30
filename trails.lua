local vector = require "vector"

local trails = function()

    local menu = {
        enable = ui.new_checkbox("LUA", "B", "Enemy trails"),
        color = ui.new_color_picker("LUA", "B", "\n Color picker", 255, 255, 255, 255)
    }

    local draw_3d_line = function(screen, dest, color)
        local start = {screen[1] / 2, screen[2]}
        local ends = {renderer.world_to_screen(dest.x, dest.y, dest.z)}

        renderer.line(start[1], start[2], ends[1], ends[2], color[1], color[2], color[3], color[4])
    end

    local paint = function()
        local player = entity.get_local_player()
        local threat = client.current_threat()

        if player ~= nil and threat ~= nil and ui.get(menu.enable) then
            local start_pos = {client.screen_size()}
            local enemy_pos = vector(entity.hitbox_position(threat, 2))

            draw_3d_line(start_pos, enemy_pos, {ui.get(menu.color)})
        end
    end

    client.set_event_callback("paint", paint)
end

trails()


local animate = (function()
    local anim = {}

    local lerp = function(start, vend)
        local anim_speed = 12
        return start + (vend - start) * (globals.frametime() * anim_speed)
    end

    

    anim.new = function(value,startpos,endpos,condition)
        if condition ~= nil then
            if condition then
                return lerp(value,startpos)
            else
                return lerp(value,endpos)
            end

        else
            return lerp(value,startpos)
        end

    end
    
    return anim
end)()

local images = require "gamesense/images" or error("Missing gamesense/images")

local imgsPath = "Drainyaw/666.gif"
local gif_decoder = require "gamesense/gif_decoder"
local gif1 = gif_decoder.load_gif(readfile("666.gif") or error("file example.gif doesn't exist"))
--local gif = images.load(readfile('Drainyaw/666.gif'))

local var = {
    g_alpha = 0,
    start = false,
    time = globals.realtime()
}

local startup_paint = function()

    var.g_alpha = animate.new(var.g_alpha, 0, 1, var.start)


    local screen_x, screen_y = client.screen_size()

    renderer.blur(0, 0, screen_x * var.g_alpha, screen_y * var.g_alpha)
    if var.g_alpha < 0.99 then
        return
    end


    local cx,cy = screen_x / 2, screen_y / 2
    
    gif1:draw((globals.realtime() + 4.4) - var.time, cx - gif1.width / 2, cy - gif1.height / 2, gif1.width, gif1.height, 255, 255, 255, 255 * var.g_alpha)

    --renderer.texture(gif,cx - 350,cy - 200,700,400,255,255,255,255 * var.g_alpha,'f')

    if var.time + 6.5 < globals.realtime() then
        var.time = globals.realtime()
        var.start = true
    end
end

client.set_event_callback("paint_ui", startup_paint)

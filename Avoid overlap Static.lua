----------------------------Reminder
--Why are you overlaping?
--Your yaw function not working properly in specific time frame
--Use overlap to detect your antiaim and gives a break so it can be run again

local anti_aim = require 'gamesense/antiaim_funcs'
local references = {
    yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
    body_yaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
    fake_yaw_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    jitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")},
}
local vars = {
    y_reversed = 1,
    by_reversed = 1,

    by_vars = 0,
    y_vars = 0,
    chocke = 0

}
local a = ui.new_slider("AA", "Anti-aimbot angles", "1", -180, 180, 40, true, "")
local b = ui.new_slider("AA", "Anti-aimbot angles", "2", -180, 180, -40, true, "")
local c = ui.new_slider("AA", "Anti-aimbot angles", "3", 0, 100, 77, true, "")
local d = ui.get(c) / 100
local function antiaim_yaw_jitter(a,b)
    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end

local function antiaim_yaw_jitter_abs()
    return ui.get(references.yaw[2]) > 0
end


local overlap = function(cmd)
    if cmd.chokedcommands ~= 0 then return end
    if anti_aim.get_overlap(rotation) > d then
        ui.set(references.yaw[2], antiaim_yaw_jitter(-40,40))
        ui.set(references.body_yaw[2], antiaim_yaw_jitter_abs() and 40 or -40)
    else
    end
end

client.set_event_callback('setup_command', overlap)

local ss = {client.screen_size()}
local center_x, center_y = ss[1] / 2, ss[2] / 2 

client.set_event_callback(
    "paint",
    function(e)
        local overlap_out = math.floor(100 *anti_aim.get_overlap(rotation))

        local r5 = 255
        local g5 = 255
        local b5 = 255
        if overlap_out > 90 then
            r5 = 188
            g5 = 150
            b5 = 150
            else if overlap_out < 50 then
            r5 = 0
            g5 = 180
            b5 = 0
            end
        end
        renderer.text(center_x + 50, center_y + 35, r5, g5, b5, 255, " ", nil, "("..overlap_out.."%)")
        renderer.text(center_x, center_y + 43, 255, 255, 255, 255, "c+", nil, status)
        renderer.text(center_x, center_y + 73, 255, 255, 255, 255, "c+", nil, ui.get(c) / 100)
        renderer.text(center_x, center_y + 103, 255, 255, 255, 255, "c+", nil, antiaim_yaw_jitter(ui.get(a),ui.get(b)))
    end)
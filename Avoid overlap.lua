----------------------------Reminder
--Why are you overlaping?
--Your yaw function not working properly in specific time frame
--Use overlap to detect your antiaim and gives a break so it can be run again

local anti_aim = require 'gamesense/antiaim_funcs'
local function velocity()
    local me = entity.get_local_player()
    local velocity_x, velocity_y = entity.get_prop(me, "m_vecVelocity")
    return math.sqrt(velocity_x ^ 2 + velocity_y ^ 2)
end
local references = {
    yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
    body_yaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
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
local b = ui.new_slider("AA", "Anti-aimbot angles", "1", -180, 180, -40, true, "")

local function antiaim_yaw_jitter(a,b)
    print(anti_aim.get_overlap(rotation))
    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end
client.set_event_callback('setup_command', function(cmd)
    -----------Moving overlap
    --send packets can be considered not using it
    if cmd.chokedcommands ~= 0 then return end
    if velocity() < 120 then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.77 then
        ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.77 then
        ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
    else return end
    end
    end)

client.set_event_callback('setup_command', function(cmd)
    -----------Standing overlap
    --send packets can be considered not using it
    if cmd.chokedcommands ~= 0 then return end
    if velocity() > 120 then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.63 then
        ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.84 then
        ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
    else return end
end
end)
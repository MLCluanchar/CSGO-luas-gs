
----------------------------Reminder
--Why are you overlaping?
--Your yaw function not working properly in specific time frame
--Use overlap to detect your overlap satus and gives a break so it can be run it again
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
<<<<<<< HEAD
local a = ui.new_slider("AA", "Anti-aimbot angles", "1", -180, 180, 40, true, "")
local b = ui.new_slider("AA", "Anti-aimbot angles", "2", -180, 180, -40, true, "")
=======
>>>>>>> parent of 7e5b2c6 (Update Avoid overlap.lua)

local function antiaim_yaw_jitter(a,b)

    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end
<<<<<<< HEAD

client.set_event_callback('setup_command', function(cmd)
    if cmd.chokedcommands ~= 0 then return end
    print(anti_aim.get_overlap(rotation))
    ui.set(references.body_yaw[2],antiaim_yaw_jitter(ui.get(a),ui.get(b)))
end)

client.set_event_callback('setup_command', function(cmd)
    -----------Moving overlap (Jitter)
    --send packets can be considered not using it
    --The function automatic stop if anti aim is not meeting the overlap requirement
    if cmd.chokedcommands ~= 0 then return end
    if velocity() < 120 then return end
    if references.body_yaw ~= "Jitter" then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.77 then
            ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
        else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.77 then
            ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
        else 
            return end
        end
    end)

client.set_event_callback('setup_command', function(cmd)
    -----------Standing overlap (Jitter)
    --send packets can be considered not using it
    --The function automatic stop if anti aim is not meeting the overlap requirement
    if cmd.chokedcommands ~= 0 then return end
    if velocity() > 120 then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.8 then
            ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
        else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.77 then
            ui.set(references.yaw[2], antiaim_yaw_jitter(ui.get(a),ui.get(b)))
        else return end
    end
end)
=======
local status
client.set_event_callback('setup_command', function(cmd)
    -----------Moving overlap
    if cmd.chokedcommands ~= 0 then return end
    if velocity() < 120 then return end
    if ui.get(references.jitter[2]) < 60 then
        ui.set(references.yaw[2], anti_aim.get_overlap(rotation) > 0.77 and antiaim_yaw_jitter(15,-25) or 0)
    end
    if ui.get(references.jitter[2]) > 60 then
        ui.set(references.yaw[2], anti_aim.get_overlap(rotation) > 0.97 and antiaim_yaw_jitter(15,-25) or 0)
    end
    end)

client.set_event_callback('setup_command', function(cmd)
    -----------Standing overlap
    if cmd.chokedcommands ~= 0 then return end
    if velocity() > 120 then return end
    if ui.get(references.jitter[2]) < 60 then
        ui.set(references.yaw[2], anti_aim.get_overlap(rotation) > 0.63 and antiaim_yaw_jitter(15,-25) or 0)
    end
    if ui.get(references.jitter[2]) > 60 then
        ui.set(references.yaw[2], anti_aim.get_overlap(rotation) > 0.84 and antiaim_yaw_jitter(15,-25) or 0)
    end
    if anti_aim.get_overlap(rotation) > 0.77 then
        status = "FAKE YAW"
    else
        status = "OVERLAP"
    end
    print(status..anti_aim.get_overlap(rotation))
end)
>>>>>>> parent of 7e5b2c6 (Update Avoid overlap.lua)

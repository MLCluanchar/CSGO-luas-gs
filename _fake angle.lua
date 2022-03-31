local bit_band = bit.band
local entity_get_local_player, entity_is_alive, entity_get_prop, entity_get_player_weapon = entity.get_local_player, entity.is_alive, entity.get_prop, entity.get_player_weapon
--------------------------------FFI
local ffi = require "ffi"

local angle_t = ffi.typeof("struct { float pitch; float yaw; float roll; }")
local vector3_t = ffi.typeof("struct { float x; float y; float z; }")

local usercmd_t =
    ffi.typeof(
    [[
    struct
    {
        uintptr_t vfptr;
        int command_number;
        int tick_count;
        $ viewangles;
        $ aimdirection;
        float forwardmove;
        float sidemove;
        float upmove;
        int buttons;
        uint8_t impulse;
        int weaponselect;
        int weaponsubtype;
        int random_seed;
        short mousedx;
        short mousedy;
        bool hasbeenpredicted;
        $ headangles;
        $ headoffset;
    }
    ]],
    angle_t,
    vector3_t,
    angle_t,
    vector3_t
)

local get_user_cmd_t = ffi.typeof("$* (__thiscall*)(uintptr_t ecx, int nSlot, int sequence_number)", usercmd_t)

local input_vtbl_t =
    ffi.typeof(
    [[
    struct
    {
        uintptr_t padding[8];
        $ GetUserCmd;
    }
    ]],
    get_user_cmd_t
)

local input_t = ffi.typeof([[
    struct
    {
        $* vfptr;
    }*
    ]], input_vtbl_t)

-- ugly casting LMAO
local g_pInput =
    ffi.cast(
    input_t,
    ffi.cast(
        "uintptr_t**",
        tonumber(
            ffi.cast(
                "uintptr_t",
                client.find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85") or
                    error("client.dll!:input not found.")
            )
        ) + 1
    )[0]
)
local buttons_e = {
    attack = bit.lshift(1, 0),
    attack_2 = bit.lshift(1, 11),
    use = bit.lshift(1, 5)

}
--------------------------------end ffi

local invert_key = ui.new_hotkey("aa", "fake lag", "Fake Angle Invert")
local fakelag = ui.reference("aa", "fake lag", "limit")
-------------------------------In Air Check
local function inair()
    return (bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"), 1) == 0)
end
-------------------------------Low Stamina Check
local function stamina()
    return (80 - entity.get_prop(entity.get_local_player(), "m_flStamina"))
end

local function general_set()
if inair() or stamina() < 70 then
    ui.set(fakelag, 15)
else
   ui.set(fakelag, 17)
end

end
client.set_event_callback("setup_command", function(cmd)
    
    general_set()


    local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)
    local local_player = entity_get_local_player()
    if not entity_is_alive(local_player) then
        return
    end
    local my_weapon = entity_get_player_weapon(local_player)
    local wepaon_id = bit_band(0xffff, entity_get_prop(my_weapon, "m_iItemDefinitionIndex"))
    local is_grenade =
        ({
        [43] = true,
        [44] = true,
        [45] = true,
        [46] = true,
        [47] = true,
        [48] = true,
        [68] = true
    })[wepaon_id] or false

    if is_grenade then
        local throw_time = entity_get_prop(my_weapon, "m_fThrowTime")
        if bit_band(pUserCmd.buttons, buttons_e.attack) == 0 or bit_band(pUserCmd.buttons, buttons_e.attack_2) == 0 then
            if throw_time > 0 then
                return
            end
        end
    end

    -- +use to disable like any anti aim
    if bit_band(pUserCmd.buttons, buttons_e.use) > 0 then
        return
    end

    if bit_band(pUserCmd.buttons, buttons_e.attack) > 0 then
        return
    end

    if wepaon_id == 64 and bit_band(pUserCmd.buttons, buttons_e.attack_2) > 0 then
        return
    end

    if inair() and stamina() < 70 then return end
    cmd.allow_send_packet = false
    local nigger = ui.get(invert_key)
    local num
    if nigger == true then
        num = 90
    else
        num = 270
    end

    local angles = {client.camera_angles()}
    if (cmd.chokedcommands % 2 == 0) then
        cmd.yaw = angles[2] + num
        cmd.pitch = 80, angles[1]
    else
        cmd.yaw = angles[2] + 180
        cmd.pitch = 80, angles[1] - 80
    end
    
end)
client.set_event_callback("paint", function()
    if ui.get(invert_key) then
        renderer.indicator(255, 255, 255, 255, "LEFT")
    else
        renderer.indicator(255, 255, 255, 255, "RIGHT")
    end
end)
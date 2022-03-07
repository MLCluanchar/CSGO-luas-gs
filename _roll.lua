local bit_band = bit.band
local vector = require("vector")
local http = require("gamesense/http")
local entity_get_local_player, entity_is_alive, entity_get_prop, entity_get_player_weapon =
    entity.get_local_player,
    entity.is_alive,
    entity.get_prop,
    entity.get_player_weapon

-- Libraries

local ffi = require "ffi"
local vector = require("vector")
local ui_set = ui.set
local globals_tickcount, globals_realtime = globals.tickcount, globals.realtime


local buttons_e = {
    attack = bit.lshift(1, 0),
    attack_2 = bit.lshift(1, 11),
    use = bit.lshift(1, 5)

}
local entity_get_local_player, entity_is_enemy, entity_get_all, entity_set_prop, entity_is_alive, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy,  entity.get_all, entity.set_prop, entity.is_alive, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_players, entity.get_prop
local math_cos, math_sin, math_rad, math_sqrt = math.cos, math.sin, math.rad, math.sqrt
local function math_clamp(v, min, max)
    if v < min then
        v = min
    elseif v > max then
        v = max
    end
    return v
end
local function contains(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end
ui_reference = ui.reference
local ref = {
    ["rage"] = {
        ["dt"] = {ui_reference("RAGE", "Other", "Double tap")},
        ["dtmode"] = ui_reference("RAGE", "Other", "Double tap mode"),
        ["dtfl"] = ui_reference("RAGE", "Other", "Double tap fake lag limit"),
        ["duck_assist"] = ui_reference("RAGE", "Other", "Duck peek assist"),
        ["multp"] = {ui_reference("RAGE", "Aimbot", "Multi-point")},
        ["prefer_sp"] = ui_reference("RAGE", "Aimbot", "Prefer safe point")
    },
    ["aa"] = {
        ["pitch"] = ui_reference("AA", "Anti-aimbot angles", "Pitch"),
        ["yaw_base"] = ui_reference("AA", "Anti-aimbot angles", "Yaw base"),
        ["yaw"] = {ui_reference("AA", "Anti-aimbot angles", "Yaw")},
        ["jitter"] = {ui_reference("AA", "Anti-aimbot angles", "Yaw Jitter")},
        ["body"] = {ui_reference("AA", "Anti-aimbot angles", "Body yaw")},
        ["freestanding_body_yaw"] = ui_reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
        ["fyaw_limit"] = ui_reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
        ["edge_yaw"] = ui_reference("AA", "Anti-aimbot angles", "Edge yaw"),
        ["freestanding"] = {ui_reference("AA", "Anti-aimbot angles", "Freestanding")},
        ["limit_ref"] = ui_reference("AA", "Fake lag", "Limit"),
        ["onshot"] = {ui_reference("AA", "Other", "On shot anti-aim")},
        ["slowwalk"] = {ui_reference("AA", "Other", "Slow motion")},
        ["amount"] = ui_reference("AA", "Fake lag", "Amount"),
        ["variance"] = ui_reference("AA", "Fake lag", "Variance"),
        ["fake_peek"] = {ui_reference("AA", "Other", "Fake peek")}
    },
    ["ticks"] = ui_reference("MISC", "Settings", "sv_maxusrcmdprocessticks")
}
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

local g_pOldAngles = nil

local function angle_forward(angle)
    local sin_pitch = math_sin(math_rad(angle.x))
    local cos_pitch = math_cos(math_rad(angle.x))
    local sin_yaw = math_sin(math_rad(angle.y))
    local cos_yaw = math_cos(math_rad(angle.y))

    return vector(cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch)
end

local function angle_right(angle)
    local sin_pitch = math_sin(math_rad(angle.x))
    local cos_pitch = math_cos(math_rad(angle.x))
    local sin_yaw = math_sin(math_rad(angle.y))
    local cos_yaw = math_cos(math_rad(angle.y))
    local sin_roll = math_sin(math_rad(angle.z))
    local cos_roll = math_cos(math_rad(angle.z))

    return vector(
        -1.0 * sin_roll * sin_pitch * cos_yaw + -1.0 * cos_roll * -sin_yaw,
        -1.0 * sin_roll * sin_pitch * sin_yaw + -1.0 * cos_roll * cos_yaw,
        -1.0 * sin_roll * cos_pitch
    )
end

local function angle_up(angle)
    local sin_pitch = math_sin(math_rad(angle.x))
    local cos_pitch = math_cos(math_rad(angle.x))
    local sin_yaw = math_sin(math_rad(angle.y))
    local cos_yaw = math_cos(math_rad(angle.y))
    local sin_roll = math_sin(math_rad(angle.z))
    local cos_roll = math_cos(math_rad(angle.z))

    return vector(
        cos_roll * sin_pitch * cos_yaw + -sin_roll * -sin_yaw,
        cos_roll * sin_pitch * sin_yaw + -sin_roll * cos_yaw,
        cos_roll * cos_pitch
    )
end
local function MovementFix(old_angles, current_angles, current_forward, current_sidemove)
    local real_angle = vector(current_angles.pitch, current_angles.yaw, current_angles.roll)
    local real_forward = angle_forward(real_angle)
    local real_right = angle_right(real_angle)

    local wish_angle = old_angles
    local wish_forward = angle_forward(wish_angle)
    local wish_right = angle_right(wish_angle)

    local wish_vel =
        vector(
        wish_forward.x * current_forward + wish_right.x * current_sidemove,
        wish_forward.y * current_forward + wish_right.y * current_sidemove,
        0
    )

    local a = real_forward.x
    local b = real_right.x
    local c = real_forward.y
    local d = real_right.y
    local v = wish_vel.x
    local w = wish_vel.y

    local divide = a * d - b * c
    if divide == 0.0 then
        return
    end

    local new_forward = (d * v - b * w) / divide
    local new_side = (a * w - c * v) / divide
    --print(string.format("new_forward: %.3f / new_side: %.3f", new_forward, new_side))
    return new_forward, new_side
end

local lua_log = function(...) --inspired by sapphyrus' multicolorlog
    client.color_log(255, 59, 59, "[ mlc.yaw ]\0")
    local arg_index = 1
    while select(arg_index, ...) ~= nil do
        client.color_log(217, 217, 217, " ", select(arg_index, ...), "\0")
        arg_index = arg_index + 1
    end
    client.color_log(217, 217, 217, " ") -- this is needed to end the line
end

lua_log("欢迎使用_roll, Update Version: 2022/2/24")
lua_log("discord:https://discord.gg/GDy32vshVG")
lua_log("Set Velocity Triggers to 80 if you are using Auto/AWP, Load Roll Preset is suggested")

local references = {
    fake_yaw_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    aa_enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled"),
    body_freestanding = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    pitch = ui.reference("AA", "Anti-aimbot angles", "Pitch"),
    yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
    body_yaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
    jitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")},
    fake_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
    freestanding = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
    fake_lag = ui.reference("AA", "Fake lag", "Amount"),
    fake_lag_limit = ui.reference("AA", "Fake lag", "Limit"),
    fakeduck = {ui.reference("RAGE", "Other", "Duck peek assist")},
    legmovement = ui.reference("AA", "Other", "Leg movement"),
    slow_walk = {ui.reference("AA", "Other", "Slow motion")},
    roll = {ui.reference("AA", "Anti-aimbot angles", "Roll")},
    -- rage references
    doubletap = {ui.reference("RAGE", "Other", "Double Tap")},
    doubletap_mode = ui.reference("RAGE", "Other", "Double tap mode"),
    dt_hit_chance = ui.reference("RAGE", "Other", "Double tap hit chance"),
    osaa,
    osaa_hkey = ui.reference("AA", "Other", "On shot anti-aim"),
    mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage"),
    fba_key = ui.reference("RAGE", "Other", "Force body aim"),
    fsp_key = ui.reference("RAGE", "Aimbot", "Force safe point"),
    ap = ui.reference("RAGE", "Other", "Delay shot"),
    sw,
    slowmotion_key = ui.reference("AA", "Other", "Slow motion"),
    quick_peek = {ui.reference("Rage", "Other", "Quick peek assist")},
    fake_lag_limit = ui.reference("aa", "Fake lag", "Limit"),

    -- misc references
    untrust = ui.reference("MISC", "Settings", "Anti-untrusted"),
    sv_maxusrcmdprocessticks = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks"),
    -- end of menu references and menu creation
}

local function setup_loop()
    ui.set(references.yaw[1], "180")
    ui.set(references.body_yaw[2], 137)
    ui.set(references.yaw_base, "Local view")
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.pitch, "Minimal")
    ui.set(references.jitter[2], 0)
    ui.set(references.fake_limit, 60)
    ui.set(references.untrust, false)
end
local function dangerous()
    ui.set(references.yaw[1], "180")
    ui.set(references.body_yaw[2], 137)
    ui.set(references.yaw_base, "Local view")
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.pitch, "Minimal")
    ui.set(references.jitter[2], 20)
    ui.set(references.fake_limit, 60)
    ui.set(references.untrust, false)
    setup_loop()
end
local function setup()
    ui.set(references.yaw[1], "180")
    ui.set(references.body_yaw[2], 137)
    ui.set(references.yaw_base, "At targets")
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.pitch, "Minimal")
    ui.set(references.jitter[2], 0)
    ui.set(references.fake_limit, 60)
 --   ui.set(static_mode_combobox, "< Speed Velocity",true)
    ui.set(references.untrust, true)
end

local function on_setup_command(cmd)
    g_pOldAngles = vector(cmd.pitch, cmd.yaw, cmd.roll)
end
local disable_button_danger = ui.new_button("AA", "Anti-aimbot angles", "Load up untrusted feature(DANGER)", dangerous)
local disable_button = ui.new_button("AA", "Anti-aimbot angles", "Load anti-aim preset", setup)
local slider_roll = ui.new_slider("AA", "Anti-aimbot angles", "Roll Angle", -90, 90, 50, true, "°")
local debugwarning = ui.new_label("AA", "Anti-aimbot angles", "-->Customized Roll")
local static_mode_combobox =
    ui.new_multiselect(
    "AA",
    "Anti-aimbot angles",
    "Roll State On:",
    "In Air",
    "On Ladders",
    "Low Stamina",
    "On Key",
    "< Speed Velocity"
)
local indicators = ui.new_multiselect("AA", "Anti-aimbot angles", "Enable Indicators", "Status Netgraph", "Debug")
local key3 = ui.new_hotkey("AA", "Anti-aimbot angles", "Force Rolling Angle on Key (Speed Decrease)")
local checkbox_hitchecker = ui.new_checkbox("AA", "Anti-aimbot angles", "Disable Roll when impacted", true)
local velocity_slider = ui.new_slider("AA", "Anti-aimbot angles", "Roll Velocity Trigger", 0, 250, 120, true, " ")
local stamina_slider = ui.new_slider("AA", "Anti-aimbot angles", "Stamina Recovery", 0, 80, 70, true, " ")
local in_air_roll = ui.new_slider("AA","Anti-aimbot angles","Customized Roll in air",  -50, 50, 50, true, " ")
local function velocity()
    local me = entity_get_local_player()
    local velocity_x, velocity_y = entity_get_prop(me, "m_vecVelocity")
    return math.sqrt(velocity_x ^ 2 + velocity_y ^ 2)
end
local antiaim_enable = ui.new_checkbox("AA","Anti-aimbot angles","Enable Jitter if Not Rolling", false)
local antiaim_enable_desync = ui.new_checkbox("AA","Anti-aimbot angles","Setup High desync", false)
ui.set_visible(key3, false)
ui.set_visible(velocity_slider, false)
ui.set_visible(stamina_slider, false)
ui.set_visible(checkbox_hitchecker, false)
ui.set_visible(in_air_roll, false)
ui.set_visible(references.roll[1], false)
local TIME = 0
local function stamina()
    return (80 - entity_get_prop(entity_get_local_player(), "m_flStamina"))
end
ui.set_visible(checkbox_hitchecker, false)
local function on_hit()
    return (entity.get_prop(entity.get_local_player(), "m_flVelocityModifier"))
end

local function hit_bind()
    local hit_health = on_hit()
    if contains(ui.get(static_mode_combobox), "< Speed Velocity") then
        ui.set_visible(velocity_slider, true)
        ui.set_visible(checkbox_hitchecker, true)
        if ui.get(checkbox_hitchecker) and hit_health <= 0.9 then
            return 0
        else if is_on_ladder == 1 then
            return  0
        else
            return ui.get(velocity_slider)
            end
        end
    end
    ui.set_visible(velocity_slider, false)
    ui.set_visible(checkbox_hitchecker, false)
    return 0
end

local function Ladder_status()
    local ladd_stat = 0
    if contains(ui.get(static_mode_combobox), "On Ladders") then
        if is_on_ladder == 1 then
            ladd_stat = 1
        else
            ladd_stat = 0
        end
    end
    return ladd_stat
end


local function stamina_bind()
    if contains(ui.get(static_mode_combobox), "Low Stamina") then
        ui.set_visible(stamina_slider, true)
        return ui.get(stamina_slider)
    else
        ui.set_visible(stamina_slider, false)
        return 0
    end
end

    
local function static()
    if globals_realtime() >= TIME then
        local epeek = client.key_state(0x45)
    if epeek then   
    else
        ui.set(ref.aa.yaw[2], 0)
        ui.set(references.yaw[1], "180")
        ui.set(references.body_yaw[2], 137)
        ui.set(references.yaw_base, "Local view")
        ui.set(references.body_yaw[1], "Static")
        ui.set(references.pitch, "Minimal")
        ui.set(references.jitter[2], 0)
        ui.set(references.fake_limit, 60)
        TIME = globals_realtime() + 0.12
    end
end
end
local function jitter()
    if globals_realtime() >= TIME then
        ui.set(ref.aa.body[1], "Jitter")
        ui.set(ref.aa.jitter[1], "Center")
        ui.set(ref.aa.fyaw_limit, math.random(10,60))
        client.delay_call(0.04, ui.set, ref.aa.body[2], 20)
        client.delay_call(0.04, ui.set, ref.aa.yaw[2], -37)
        client.delay_call(0.07, ui.set, ref.aa.body[2], -40)
        client.delay_call(0.07, ui.set, ref.aa.yaw[2], 20)
        ui.set(ref.aa.pitch, "Minimal")
        ui.set(ref.aa.yaw[1], "180")
        ui.set(ref.aa.jitter[2], math.random(45,75))
        ui.set(ref.aa.freestanding_body_yaw, false)
        TIME = globals_realtime() + 0.09
    end
end
local function inair()
    return (bit_band(entity_get_prop(entity_get_local_player(), "m_fFlags"), 1) == 0)
end

local function air_status()
    local air_stat = 0
    if contains(ui.get(static_mode_combobox), "In Air") then
        if inair() then
            air_stat = 1
        else
            air_stat = 0
        end
    end
    return air_stat
end
local function roll_bind()
    local roll_set = ui.get(slider_roll)
    if contains(ui.get(static_mode_combobox), "In Air") then
        ui.set_visible(in_air_roll, true)
    else
        ui.set_visible(in_air_roll, false)
    end
    if air_status() == 1 then
        roll_set = ui.get(in_air_roll)
    else
        return ui.get(slider_roll)
    end
        return roll_set
end

local function hide_keys()
    local key100 = 1
    if contains(ui.get(static_mode_combobox), "On Key") then
        ui.set_visible(key3, true)
    else
        ui.set_visible(key3, false)
        return key100
    end
end
client.set_event_callback(
    "setup_command",
    function(e)
        local local_player = entity.get_local_player()
        if entity.get_prop(local_player, "m_MoveType") == 9 then
            is_on_ladder = 1
        else
            is_on_ladder = 0
        end
    end
)
local is_rolling = true
local function on_run_command(cmd)
    hide_keys()
    local speed = velocity()
    local recovery = stamina()
    if air_status() == 0 and not ui.get(key3) and speed >= hit_bind() and recovery >= stamina_bind() and Ladder_status() == 0 then
        is_rolling = false
        return
    end
    local local_player = entity_get_local_player()
    if not entity_is_alive(local_player) then
        return
    end
    is_rolling = true
    stamina_bind()
    hit_bind()
    local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)

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

    g_ForwardMove = pUserCmd.forwardmove
    g_SideMove = pUserCmd.sidemove
    g_pOldAngles = vector(pUserCmd.viewangles.pitch, pUserCmd.viewangles.yaw, pUserCmd.viewangles.roll)

    pUserCmd.viewangles.roll = roll_bind()

    local new_forward, new_side = MovementFix MovementFix(g_pOldAngles, pUserCmd.viewangles, g_ForwardMove, g_SideMove)

    if contains(ui.get(indicators), "Debug") then
--        pUserCmd.forwardmove = math_clamp(new_forward, -450.0, 450.0)           not working properly
--        pUserCmd.sidemove = math_clamp(new_side, -450.0, 450.0)
    end

    -- your aa
end
function is_dt( )
    local local_player = entity_get_local_player()

    if local_player == nil then
        return
    end

    if not entity_is_alive( local_player ) then
        return
    end

    local active_weapon = entity_get_prop( local_player, "m_hActiveWeapon" )

    if active_weapon == nil then
        return
    end

    next_attack = entity_get_prop( local_player,"m_flNextAttack" )
    next_shot = entity_get_prop( active_weapon,"m_flNextPrimaryAttack" )
    next_shot_secondary = entity_get_prop( active_weapon,"m_flNextSecondaryAttack" )

    if next_attack == nil or next_shot == nil or next_shot_secondary == nil then
        return
    end

    next_attack = next_attack+0.5
    next_shot = next_shot+0.5
    next_shot_secondary = next_shot_secondary+0.5

        if math.max( next_shot, next_shot_secondary ) < next_attack then
            if next_attack-globals.curtime( ) > 0.00 then
                return false
            else
                return true
            end
        else -- shooting or just shot
            if math.max( next_shot, next_shot_secondary )-globals.curtime( ) > 0.00  then
                return false
            else
                if math.max( next_shot, next_shot_secondary )-globals.curtime( ) < 0.00  then
                    return true
                end
            end
        end

    return false
end

function distance_3d( x1, y1, z1, x2, y2, z2 )
    return math.sqrt( ( x1-x2 )*( x1-x2 )+( y1-y2 )*( y1-y2 ) )
end

function local_origin_State()
    local player = entity.get_local_player()
    local ex,ey,ez = entity_get_origin( player ) 
    return ex,ey,ez
end

---------------------------------------------anti aim sections
function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity_get_prop( player, "m_vecVelocity" )
    local new_x = x+globals_tickinterval( )*xv*ticks
    local new_y = y+globals_tickinterval( )*yv*ticks
    local new_z = z+globals_tickinterval( )*zv*ticks
    return new_x, new_y, new_z

end

function is_local_peeking_enemy( local_player )
    
    local vx,vy,vz = entity_get_prop( entity_get_local_player(), "m_vecVelocity")
    local speed = math_sqrt( vx*vx+vy*vy+vz*vz )
    if speed < 5 then
        return false
    end
    local ex,ey,ez = local_origin_State()
    local lx,ly,lz = entity_get_origin( entity_get_local_player() )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 1, 17 do

        local tex,tey,tez = extrapolate( entity_get_local_player(), ticks, lx, ly, lz )
        local distance = distance_3d( ex, ey, ez, tex, tey, tez )

        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
        if error then return end
    end
    return smallest_distance < start_distance
end

local function get_nearest( )
    local me = vector( entity_get_prop( entity_get_local_player( ), "m_vecOrigin" ) )
    
    local nearest_distance
    local nearest_entity

    for _, player in ipairs( entity.get_players( true ) ) do
        local target = vector( entity_get_prop( player, "m_vecOrigin") )
        local _distance = me:dist( target )

        if ( nearest_distance == nil or _distance < nearest_distance ) then
            nearest_entity = player
            nearest_distance = _distance
        end  
    end

    if ( nearest_distance ~= nil and nearest_entity ~= nil ) then
        return ( { target = nearest_entity, distance =  math.floor( ( math.floor( nearest_distance * 0.0254 + 0.5 ) * 3.281 )+0.5 )  } )
    end
end

function is_enemy_peeking( local_player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local local_pos = local_origin_State()
    local lx, ly, lz = entity_get_origin( entity_get_local_player ( ) )
    local start_distance = math.abs( distance_3d( local_pos, lx, ly, lz ) )
    local smallest_distance = 999999
    for ticks = 1, 17 do
        local tex,tey,tez = extrapolate( player, ticks, local_pos )
        local distance = math.abs( distance_3d( tex, tey, tez, lx, ly, lz ) )

        if distance < smallest_distance then
            smallest_distance = distance
        end
        if smallest_distance < start_distance then
            return true
        end
        if error then return end
    end
    --client_log(smallest_distance .. "      " .. start_distance)
    return smallest_distance < start_distance
end
local nigger_indicator 

local aa_setup = function(cmd)
    if not ui.get(antiaim_enable) then return end
    if is_rolling == true then
        static()
        else
        jitter ()
        end
    end
    if ui.get(antiaim_enable_desync) then return end
    static()
    
local ss = {client.screen_size()}
local center_x, center_y = ss[1] / 2, ss[2] / 2
local ref = {
    ["pitch"] = ui.reference("AA", "Anti-aimbot angles", "Pitch"),
    ["yaw"] = {ui.reference("AA", "Anti-aimbot angles", "yaw")},
    ["body_freestanding"] = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    ["body_yaw"] = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    ["fake_limit"] = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    ["dt"] = {ui.reference("RAGE", "Other", "Double tap")},
    ["onshot"] = {ui.reference("AA", "Other", "On shot anti-aim")},
    ["safe_point"] = ui.reference("RAGE", "Aimbot", "Force safe point"),
    ["force_baim"] = ui.reference("RAGE", "Other", "Force body aim"),
    ["fs"] = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
    ["mupct"] = ui.reference("Misc", "Settings", "sv_maxusrcmdprocessticks")
}
client.set_event_callback(
    "paint",
    function(e)
        aa_setup()
        local local_player = entity.get_local_player()
        local local_pos = vector(entity.get_origin( local_player ))
        local_origin_State()
        data = get_nearest()
        if contains(ui.get(indicators), "Status Netgraph") then
            local pulse = math.sin(math.abs((math.pi * -1) + (globals.curtime() * (1 / 0.35)) % (math.pi * 2))) * 255
            local r, g, b = 30, 255, 109
            local recovery = stamina()
            if velocity() > hit_bind() then
                if ui.get(key3) then
                    r, g, b = 250, 140, 53
                else
                    r, g, b = 127, 255, 0
                end
            end

            if velocity() <= hit_bind() then
                if ui.get(key3) then
                    r, g, b = 250, 140, 53
                else
                    r, g, b = 255, 119, 119
                end
            end

            local r2, g2, b2 = 30, 255, 109

            if recovery <= stamina_bind() then
                if ui.get(key3) then
                    r2, g2, b2 = 250, 140, 53
                else
                    r2, g2, b2 = 255, 119, 119
                end
            end

            if recovery >= stamina_bind() then
                if ui.get(key3) then
                    r2, g2, b2 = 250, 140, 53
                else
                    r2, g2, b2 = 30, 255, 109
                end
            end

            local r4 = 124 * 2 - 124 * on_hit()
            local g4 = 255 * on_hit()
            local b4 = 13

            if ui.get(key3) then
                renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL ( KEY )")
            end
            renderer.text(center_x, center_y + 35, 255, 255, 255, 255, "-", nil, "_ROLL")
            renderer.text(center_x + 23, center_y + 35, r4, g4, b4, 255, "-", nil, ".LUA")
            renderer.text(center_x, center_y + 28, r, g, b, 255, "-", nil, "SPEED")
            --    renderer.text(center_x + 35, center_y + 28, r, g, b, 255, "-", nil, math.floor(velocity()))
            renderer.text(center_x, center_y + 43, r2, g2, b2, 255, "-", nil, "STAMINA")

            --        if stamina() >= 45 and velocity() <= ui.get(velocity_slider)  then
            --           renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL")
            --       end
            --        if inair() and stamina() >= 45  then
            --            renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL")
            --        end
            if is_rolling == true then
                renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL")
            else
                renderer.text(center_x, center_y + 50, 255, 255, 255, 255, "-", nil, "MLC.YAW")
            end
            if
                not ui.get(checkbox_hitchecker) and on_hit() < 0.9 and air_status() == 1 and not ui.get(key3) and
                is_on_ladder
             then
                renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL ( DISABLE )")
            end
        if contains(ui.get(indicators), "Debug") then
         --   renderer.text(center_x, center_y + 50, 253, 162, 180, 255, "+", nil, stamina_bind())
         --   renderer.text(center_x, center_y + 70, 253, 162, 180, 255, "+", nil, air_status())
         --   renderer.text(center_x, center_y + 90, 253, 162, 180, 255, "+", nil, hit_bind())
        --    renderer.text(center_x, center_y + 110, 253, 162, 180, 255, "+", nil, is_on_ladder)
            renderer.text(center_x, center_y + 130, 253, 162, 180, 255, "+", nil, "Is Rolling:")
            renderer.text(center_x + 100, center_y + 130, 253, 162, 180, 255, "+", nil, "123")
        end
    end
end
)

client.set_event_callback("run_command", on_run_command)
client.set_event_callback("setup_command", on_setup_command)

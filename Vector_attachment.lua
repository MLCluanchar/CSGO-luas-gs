local ffi = require 'ffi'
local entitylib = require 'gamesense/entity'
local anti_aim = require 'gamesense/antiaim_funcs'
local third_check, third  = ui.reference("Visuals", "Effects", "Force Third Person (alive)")
local vector = require 'vector'
pClientEntityList = client.create_interface("client_panorama.dll", "VClientEntityList003") or error("invalid interface", 2)
fnGetClientEntity = vtable_thunk(3, "void*(__thiscall*)(void*, int)")

ffi.cdef('typedef struct { float x; float y; float z; } bbvec3_t;')

local fnGetAttachment = vtable_thunk(84, "bool(__thiscall*)(void*, int, bbvec3_t&)")
local fnGetMuzzleAttachmentIndex1stPerson = vtable_thunk(468, "int(__thiscall*)(void*, void*)")
local fnGetMuzzleAttachmentIndex3stPerson = vtable_thunk(469, "int(__thiscall*)(void*)")

ffi.cdef('typedef struct { float x; float y; float z; } vmodel_vec3_t;')
ffi.cdef('typedef struct { float x; float y; float z; } vmodel_ang3_t;')

local native_GetClientEntity = vtable_bind("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*,int)")
local native_GetClientEntityFromHandle = vtable_bind("client.dll", "VClientEntityList003", 4, "void*(__thiscall*)(void*,unsigned long)")
local native_GetRenderOrigin = vtable_thunk(1, "vmodel_vec3_t(__thiscall*)(void**)")
local native_LookupAttachment = vtable_thunk(33, "int(__thiscall*)(void*, const char*)")
local native_GetAttachment = vtable_thunk(34, "bool(__thiscall*)(void*, int, vmodel_vec3_t&, vmodel_ang3_t&)")
local native_GetActiveWeapon vtable_thunk(267, "void*(__thiscall*)(void*)")
function angle_forward(angle)
    local sin_pitch = math.sin(math.rad(angle.x))
    local cos_pitch = math.cos(math.rad(angle.x))
    local sin_yaw   = math.sin(math.rad(angle.y))
    local cos_yaw   = math.cos(math.rad(angle.y))

    return vector(cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch)
end

function angle_right( angle )
    local sin_pitch = math.sin( math.rad( angle.x ) );
    local cos_pitch = math.cos( math.rad( angle.x ) );
    local sin_yaw   = math.sin( math.rad( angle.y ) );
    local cos_yaw   = math.cos( math.rad( angle.y ) );
    local sin_roll  = math.sin( math.rad( angle.z ) );
    local cos_roll  = math.cos( math.rad( angle.z ) );

    return vector(
        -1.0 * sin_roll * sin_pitch * cos_yaw + -1.0 * cos_roll * -sin_yaw,
        -1.0 * sin_roll * sin_pitch * sin_yaw + -1.0 * cos_roll * cos_yaw,
        -1.0 * sin_roll * cos_pitch
    );
end


function vecotr_ma(start, scale, direction_x, direction_y, direction_z)
    return vector(start.x + scale * direction_x, start.y + scale * direction_y, start.z + scale * direction_z)
end

local get_attachment_vector = function(world_model)
    local me = entity.get_local_player()
    local wpn = entity.get_player_weapon(me)

    local model =
        world_model and 
        entity.get_prop(wpn, 'm_hWeaponWorldModel') or
        entity.get_prop(me, 'm_hViewModel[0]')

    if me == nil or wpn == nil then
        return
    end

    local active_weapon = fnGetClientEntity(pClientEntityList, wpn)
    local g_model = fnGetClientEntity(pClientEntityList, model)

    if active_weapon == nil or g_model == nil then
        return
    end

    local attachment_vector = ffi.new("bbvec3_t[1]")
    local att_index = world_model and
        fnGetMuzzleAttachmentIndex3stPerson(active_weapon) or
        fnGetMuzzleAttachmentIndex1stPerson(active_weapon, g_model)

    if att_index > 0 and fnGetAttachment(g_model, att_index, attachment_vector[0]) and not nil then 
        return { attachment_vector[0].x, attachment_vector[0].y, attachment_vector[0].z }
    end
end

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
    osaa, osaa_hkey = ui.reference("AA", "Other", "On shot anti-aim"),
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
    third = ui.reference("Visuals", "Effects", "Force Third Person (alive)")
    -- end of menu references and menu creation
}
local onshot, onshotkey = ui.reference('aa', 'other', 'On shot anti-aim')
local quickpeek, quickpeekk = ui.reference("Rage", "Other", "Quick peek assist")
local ani = {
    third = 0,
    third1 = 0,
    dt = 0,
    dt_alpha = 0,
    dt_alpha2 = 0,
    charged = 0,
    -------
    hide = 0,
    hide_alpha = 0,
    hide_alpha2 = 0,
    --------
    baim = 0,
    baim_alpha = 0,
    baim_alpha2 = 0,
    --------
    desync_r = 0,
    desync_g = 0,
    desync_b =0,
    --------
    ap = 0,
    ap_alpha = 0,
    ap_alpha2 = 0,
    --------
    sp = 0,
    sp_alpha = 0,
    sp_alpha2 = 0,
    --------
    desync_r1 = 0,
    desync_g1 = 0,
    desync_b1 = 0,
}

function lerp(start, vend, time)
return start + (vend - start) * time end

function thrid_person()
    local entities = entitylib.get_all("CPredictedViewModel")
    for _, entidx in ipairs(entities) do
        
        local vector_origin = vector(entidx:get_origin())
        local view_punch_angle = vector(entitylib.get_local_player():get_prop("m_vecOrigin"))
        local aim_punch_angle = vector(entitylib.get_local_player():get_prop("m_vecOrigin"))
        local camera_angles = vector(client.camera_angles()) -- [[+ (view_punch_angle + aim_punch_angle)]]

        local forward = angle_forward(camera_angles)
        local right = angle_right(view_punch_angle + aim_punch_angle)

        vector_origin = vecotr_ma(vector_origin, 1, right.x, right.y, right.z)
        vector_origin = vecotr_ma(vector_origin, 30, forward.x, forward.y, forward.z)
        return vector_origin
    end
end

function container(x, y, text, alpha)
    local lp_bodyyaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
    local length, width = renderer.measure_text("+c", text), 38
    local adjust_x, adjust_y, adjust_length = x - 16, y - 16, length + 8
    --renderer.gradient(adjust_x, adjust_y, adjust_length, width, 15, 15, 15, alpha)
    --dont ask me why am i not just do a forloop and check based on graident, i love making things seperated
    if anti_aim.get_desync(1) > 0 then
        ani.desync_r =  (lerp(ani.desync_r, 253,globals.frametime() * 3))
        ani.desync_g =  (lerp(ani.desync_g, 162,globals.frametime() * 3))
        ani.desync_b =  (lerp(ani.desync_b, 180,globals.frametime() * 3))
        ani.desync_r1 = (lerp(ani.desync_r1, 80,globals.frametime() * 3))
        ani.desync_g1 = (lerp(ani.desync_g1, 80,globals.frametime() * 3))
        ani.desync_b1 = (lerp(ani.desync_b1, 80,globals.frametime() * 3))
    else
        ani.desync_r =  (lerp(ani.desync_r, 80,globals.frametime() * 3))
        ani.desync_g =  (lerp(ani.desync_g, 80,globals.frametime() * 3))
        ani.desync_b =  (lerp(ani.desync_b, 80,globals.frametime() * 3))
        ani.desync_r1 = (lerp(ani.desync_r1, 253,globals.frametime() * 3))
        ani.desync_g1 = (lerp(ani.desync_g1, 162,globals.frametime() * 3))
        ani.desync_b1 = (lerp(ani.desync_b1, 180,globals.frametime() * 3))
    end
    renderer.gradient(adjust_x, adjust_y, adjust_length, width, ani.desync_r1, ani.desync_g1, ani.desync_b1, alpha, ani.desync_r, ani.desync_g, ani.desync_b, alpha, true)
end

function container_normal(x, y, text, alpha, r, g, b)
    local length, width = renderer.measure_text("+c", text), 38
    local adjust_x, adjust_y, adjust_length = x - 18, y - 16, length + 8
    local round = 10;
    renderer.gradient(adjust_x, adjust_y, adjust_length, width, r, g, b, alpha, r, g, b, alpha, true)
end

client.set_event_callback('paint', function ()
    -- DONT ASK ME WHY I DONT USE FOR LOOP CUS IM LAZY AF
    local local_player = entity.get_local_player( )
    if ( not entity.is_alive( local_player ) ) then
        return     
    end
    local vector_origin = thrid_person()
    local w2s_pos = vector(renderer.world_to_screen(vector_origin.x, vector_origin.y, vector_origin.z))
    pos = get_attachment_vector(false)
    local is_scoped = entity.get_prop(entity.get_player_weapon(entity.get_local_player()), "m_zoomLevel" )

    local Animation_speed = 6
    local ss = {client.screen_size()}
    local center_x, center_y = ss[1] / 2, ss[2] / 2 

    if pos ~= nil then
        x1, y1 = renderer.world_to_screen(pos[1], pos[2], pos[3])
    else
        x1, y1 = center_x + 200, center_y + 15
    end

    if ui.get(third) then
        ani.third = lerp(ani.third, w2s_pos.x - 90, globals.frametime() * Animation_speed)
        ani.third1 = lerp(ani.third1, w2s_pos.y - 40, globals.frametime() * Animation_speed)
    else
        ani.third = lerp(ani.third, x1 - 50,globals.frametime() * Animation_speed)
        ani.third1 = lerp(ani.third1 ,y1 - 50,globals.frametime() * Animation_speed)
    end
    
    --Quick Peek
    local mode, rgb = ui.reference("Rage", "Other", "Quick peek assist mode")
    local r, g, b = ui.get(rgb)
    if ui.get(quickpeekk) then
        ani.ap = (lerp(ani.ap, 45,globals.frametime() * Animation_speed))
        ani.ap_alpha =  (lerp(ani.ap_alpha, 45,globals.frametime() * Animation_speed))
        ani.ap_alpha2 = (lerp(ani.ap_alpha2, 220,globals.frametime() * Animation_speed))
    else
        ani.ap = (lerp(ani.ap, 0,globals.frametime() * Animation_speed))
        ani.ap_alpha =  (lerp(ani.ap_alpha, 0,globals.frametime() * Animation_speed))
        ani.ap_alpha2 = (lerp(ani.ap_alpha2, 0,globals.frametime() * Animation_speed))
    end
    local AP = "AP"
    local exp0 = ani.ap
    container_normal(ani.third, ani.third1 + exp0, AP, ani.ap_alpha, r, g, b)
    renderer.text(ani.third, ani.third1 + exp0, 255, 255, 255, ani.ap_alpha2, "+c", nil, AP)

    --DT
    if ui.get(references.doubletap[2]) then
        ani.dt = (lerp(ani.dt,45,globals.frametime() * Animation_speed))
        ani.dt_alpha =  (lerp(ani.dt_alpha, 50,globals.frametime() * Animation_speed))
        ani.dt_alpha2 = (lerp(ani.dt_alpha2, 120,globals.frametime() * Animation_speed))
    else
        ani.dt = (lerp(ani.dt,0,globals.frametime() * 6))
        ani.dt_alpha =  (lerp(ani.dt_alpha, 0,globals.frametime() * Animation_speed))
        ani.dt_alpha2 = (lerp(ani.dt_alpha2, 0,globals.frametime() * Animation_speed))
    end

    if anti_aim.get_double_tap() then
        ani.charged = math.floor(lerp(ani.charged,130, globals.frametime() * 14))
    else
        ani.charged = math.floor(lerp(ani.charged,0, globals.frametime() * Animation_speed))
    end

    local DT = "DT"
    local exp = ani.dt + exp0
    container(ani.third, ani.third1 + exp, DT, ani.dt_alpha)
    renderer.text(ani.third, ani.third1 + exp, 255, 255, 255, ani.dt_alpha2 + ani.charged, "+c", nil, DT)

    --HIDE
    if ui.get(onshotkey) then
        ani.hide = (lerp(ani.hide,45,globals.frametime() * Animation_speed))
        ani.hide_alpha =  (lerp(ani.hide_alpha, 45,globals.frametime() * Animation_speed))
        ani.hide_alpha2 = (lerp(ani.hide_alpha2, 220,globals.frametime() * Animation_speed))
    else
        ani.hide = (lerp(ani.hide,0,globals.frametime() * Animation_speed))
        ani.hide_alpha =  (lerp(ani.hide_alpha, 0,globals.frametime() * Animation_speed))
        ani.hide_alpha2 = (lerp(ani.hide_alpha2, 0,globals.frametime() * Animation_speed))
    end

    local HIDE = "OS"
    local exp2 = exp + ani.hide
    container(ani.third, ani.third1 + exp2, HIDE, ani.hide_alpha)
    renderer.text(ani.third, ani.third1 + exp2, 255, 255, 255, ani.hide_alpha2, "+c", nil, HIDE)
    
    --BAIM
    if ui.get(references.fba_key) then
        ani.baim = (lerp(ani.baim,45,globals.frametime() * Animation_speed))
        ani.baim_alpha =  (lerp(ani.baim_alpha, 45,globals.frametime() * Animation_speed))
        ani.baim_alpha2 = (lerp(ani.baim_alpha2, 220,globals.frametime() * Animation_speed))
    else
        ani.baim = (lerp(ani.baim, 0,globals.frametime() * Animation_speed))
        ani.baim_alpha =  (lerp(ani.baim_alpha, 0,globals.frametime() * Animation_speed))
        ani.baim_alpha2 = (lerp(ani.baim_alpha2, 0,globals.frametime() * Animation_speed))
    end
    local BAIM = "BA"
    local exp3 = exp2 + ani.baim
    container(ani.third, ani.third1 + exp3, BAIM, ani.baim_alpha)
    renderer.text(ani.third, ani.third1 + exp3, 255, 255, 255, ani.baim_alpha2, "+c", nil, BAIM)

    --SAFE
    if ui.get(references.fsp_key) then
        ani.sp = (lerp(ani.sp,45,globals.frametime() * Animation_speed))
        ani.sp_alpha =  (lerp(ani.sp_alpha, 45,globals.frametime() * Animation_speed))
        ani.sp_alpha2 = (lerp(ani.sp_alpha2, 220,globals.frametime() * Animation_speed))
    else
        ani.sp = (lerp(ani.sp, 0,globals.frametime() * Animation_speed))
        ani.sp_alpha =  (lerp(ani.sp_alpha, 0,globals.frametime() * Animation_speed))
        ani.sp_alpha2 = (lerp(ani.sp_alpha2, 0,globals.frametime() * Animation_speed))
    end
    local SAFE = "SP"
    local exp4 = exp3 + ani.sp
    container(ani.third, ani.third1 + exp4, BAIM, ani.sp_alpha)
    renderer.text(ani.third, ani.third1 + exp4, 255, 255, 255, ani.sp_alpha2, "+c", nil, SAFE)



end)

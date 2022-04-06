local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local entity_get_local_player, entity_is_enemy, entity_get_all, entity_set_prop, entity_is_alive, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy,  entity.get_all, entity.set_prop, entity.is_alive, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_players, entity.get_prop
local math_cos, math_sin, math_rad, math_sqrt = math.cos, math.sin, math.rad, math.sqrt

local _V3_MT   = {};
_V3_MT.__index = _V3_MT;

local function Vector3( x, y, z )
    -- check args
    if( type( x ) ~= "number" ) then
        x = 0.0;
    end

    if( type( y ) ~= "number" ) then
        y = 0.0;
    end

    if( type( z ) ~= "number" ) then
        z = 0.0;
    end

    x = x or 0.0;
    y = y or 0.0;
    z = z or 0.0;

    return setmetatable(
        {
            x = x,
            y = y,
            z = z
        },
        _V3_MT
    );
end


function _V3_MT.__sub( a, b ) -- subtract another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x - b,
            a.y - b,
            a.z - b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a - b.x,
            a - b.y,
            a - b.z
        );
    end
end

function _V3_MT:length_sqr() -- squared 3D length
    return ( self.x * self.x ) + ( self.y * self.y ) + ( self.z * self.z );
end

function _V3_MT:length() -- 3D length
    return math_sqrt( self:length_sqr() );
end

function _V3_MT:dot( other ) -- dot product
    return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
end

function _V3_MT:cross( other ) -- cross product
    return Vector3(
        ( self.y * other.z ) - ( self.z * other.y ),
        ( self.z * other.x ) - ( self.x * other.z ),
        ( self.x * other.y ) - ( self.y * other.x )
    );
end

function _V3_MT:dist_to( other ) -- 3D length to another vector
    return ( other - self ):length();
end

function _V3_MT:normalize() -- normalizes this vector and returns the length
    local l = self:length();
    if( l <= 0.0 ) then
        return 0.0;
    end

    self.x = self.x / l;
    self.y = self.y / l;
    self.z = self.z / l;

    return l;
end


function _V3_MT:normalized() -- returns a normalized unit vector
    local l = self:length();
    if( l <= 0.0 ) then
        return Vector3();
    end

    return Vector3(
        self.x / l,
        self.y / l,
        self.z / l
    );
end


local function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );

    return Vector3(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end

local function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;

    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math.acos( fwd:dot( delta ) / delta:length() );

    return math_max( 0.0, math.deg( fov ) );
end

local predict_ticks         = 17
-- end of the anti-aim peeking function for smart jitter

-- this is a function to help with on peeking and getting peeked functions
local function distance_3d( x1, y1, z1, x2, y2, z2 )

        return math.sqrt( ( x1-x2 )*( x1-x2 )+( y1-y2 )*( y1-y2 ) )
end

-- function for extrapolating player
local function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity.get_prop( player, "m_vecVelocity" )
    local new_x = x+globals.tickinterval( )*xv*ticks
    local new_y = y+globals.tickinterval( )*yv*ticks
    local new_z = z+globals.tickinterval( )*zv*ticks
    return new_x, new_y, new_z

end
-- end of functions to help with on peeking and getting peeked functions

-- this is the start of a function for detecting whether the local player is peeking an enemy
local function is_enemy_peeking( player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local ex, ey, ez = entity.get_origin( player ) 
    local lx, ly, lz = entity.get_origin( entity.get_local_player ( ) )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    for ticks = 1, predict_ticks do
        local tex,tey,tez = extrapolate( player, ticks, ex, ey, ez )
        local distance = math.abs( distance_3d( tex, tey, tez, lx, ly, lz ) )

        if distance < smallest_distance then
            smallest_distance = distance
        end
        if smallest_distance < start_distance then
            return true
        end
    end
    --client.log(smallest_distance .. "      " .. start_distance)
    return smallest_distance < start_distance
end
-- this is the end of a function for detecting whether the local player is peeking an enemy

-- this is the start of a function for detecting whether the enemy is peeking the local player
local function is_local_peeking_enemy( player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local ex,ey,ez = entity.get_origin( player )
    local lx,ly,lz = entity.get_origin( entity.get_local_player() )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 1, predict_ticks do

        local tex,tey,tez = extrapolate( entity.get_local_player(), ticks, lx, ly, lz )
        local distance = distance_3d( ex, ey, ez, tex, tey, tez )

        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end


function detection()


    local closest_fov           = 100000

    local player_list           = entity.get_players( true )

    local eye_pos               = Vector3( x, y, z )
    x,y,z                       = client.camera_angles( )
    local cam_angles            = Vector3( x, y, z )
    
    for i = 1 , #player_list do
        player                  = player_list[ i ]
        if not entity.is_dormant( player ) and entity.is_alive( player ) then
            if is_enemy_peeking( player ) or is_local_peeking_enemy( player ) then
                last_time_peeked        = globals.curtime( )
                local enemy_head_pos    = Vector3( entity.hitbox_position( player, 0 ) )
                local current_fov       = get_FOV( cam_angles,eye_pos, enemy_head_pos )
                if current_fov < closest_fov then
                    closest_fov         = current_fov
                    needed_player       = player
                end
            end
        end
    end
    if needed_player ~= -1 then
        if not entity.is_dormant( player ) and entity.is_alive( player ) then
            if ( ( is_enemy_peeking( player ) or is_local_peeking_enemy( player ) ) ) == true then
                print("LEFT PEEK")
            else
                print("RIGHT PEEK")
            end
        end
    end
end
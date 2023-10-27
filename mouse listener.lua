
local dragging_2 = (function()local b={}local c,d,e,f,g,h,i,j,k,l,m,n,o,p,q;local r={__index={drag=function(self,...)local s,t=self:get()local u,v=b.drag(s,t,...)if s~=u or t~=v then self:set(u,v)end;return u,v end,status=function(self,...)local s,t=self:get()local u,v=b.status(s,t,...)return u end,set=function(self,s,t)local k,l=client.screen_size()ui.set(self.x_reference,s/k*self.res)ui.set(self.y_reference,t/l*self.res)end,get=function(self)local k,l=client.screen_size()return ui.get(self.x_reference)/self.res*k,ui.get(self.y_reference)/self.res*l end}}function b.new(w,x,y,z)z=z or 10000;local k,l=client.screen_size()local A=ui.new_slider("LUA","A",w.." window position 2",0,z,x/k*z)local B=ui.new_slider("LUA","A","\n"..w.." window position y 2",0,z,y/l*z)ui.set_visible(A,false)ui.set_visible(B,false)return setmetatable({name=w,x_reference=A,y_reference=B,res=z},r)end;function b.drag(s,t,C,D,E,F,G)if globals.framecount()~=c then d=ui.is_menu_open()g,h=e,f;e,f=ui.mouse_position()j=i;i=client.key_state(0x01)==true;n=m;m={}p=o;o=false;k,l=client.screen_size()end;if d and j~=nil then if(not j or p)and i and g>s and h>t and g<s+C and h<t+D then o=true;s,t=s+e-g,t+f-h;if not F then s=math.max(0,math.min(k-C,s))t=math.max(0,math.min(l-D,t))end end;if g>=s and h>=t and g<=s+C and h<=t+D then q=true else q=false end else g,h,e,f=0,0,0,0;q=false end;table.insert(m,{s,t,C,D})return s,t,C,D end;function b.status(s,t,C,D,E,F,G)if globals.framecount()~=c then d=ui.is_menu_open()g,h=e,f;e,f=ui.mouse_position()j=i;i=client.key_state(0x01)==true;n=m;m={}p=o;o=false;k,l=client.screen_size()end;if d then if g>s and h>t and g<s+C and h<t+D then o=true;s,t=s+e-g,t+f-h;if not F then s=math.max(0,math.min(k-C,s))t=math.max(0,math.min(l-D,t))end end;if g>=s and h>=t and g<=s+C and h<=t+D then q=true else q=false end else g,h,e,f=0,0,0,0;q=false end;return q end;function b.match()return q end;return b end)()
local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local renderer_circle = renderer.circle



local reference = {
    enabled = ui_reference("AA", "Anti-aimbot angles", "Enabled"),
    pitch = ui_reference("AA", "Anti-aimbot angles", "Pitch"),
    yaw_base = ui_reference("AA", "Anti-aimbot angles", "Yaw base"),
    yaw = { ui_reference("AA", "Anti-aimbot angles", "Yaw") },
    yaw_jitter = { ui_reference("AA", "Anti-aimbot angles", "Yaw jitter") } ,
    body_yaw = { ui_reference("AA", "Anti-aimbot angles", "Body yaw") },
    freestanding_body_yaw = ui_reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    fake_yaw_limit = ui_reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    edge_yaw = ui_reference("AA", "Anti-aimbot angles", "Edge yaw"),
    freestanding = { ui_reference("AA", "Anti-aimbot angles", "Freestanding") },
    roll =  ui_reference("AA", "Anti-aimbot angles", "Roll") ,

    slow_motion = { ui_reference("AA", "Other", "Slow motion") },
    slow_motion_type = ui_reference("AA", "Other", "Slow motion type"),
    leg_movement = ui_reference("AA", "Other", "Leg movement"),
    hide_shots = { ui_reference("AA", "Other", "On shot anti-aim") },
    fake_peek = { ui_reference("AA", "Other", "Fake peek") },
    fake_lag = ui_reference("AA", "Fake lag", "Enabled") ,
    fake_lag_limit = ui_reference("AA", "Fake lag", "Limit") ,
    anti_untrusted = ui.reference("MISC", "Settings", "Anti-untrusted"),

    fakeduck = ui.reference("Rage", "Other", "Duck peek assist"),

    doubletap = {ui_reference("RAGE","Other","Double tap")},
    force_body_aim = ui.reference("RAGE", "Other", "Force body aim"),
    force_safe_point = ui.reference("RAGE", "Aimbot", "Force safe point"),
    ping_spike = {ui_reference("MISC", "miscellaneous", "ping spike")},
    menu_color = ui.reference("MISC", "Settings", "Menu color"),
    quick_peek_assist = { ui.reference("RAGE", "Other", "Quick peek assist") },
}


local solus_render = (function()
    local solus_m = {}
    local RoundedRect = function(x, y, width, height, radius, r, g, b, a)
        renderer.rectangle(x + radius, y, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + height - radius, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x + width - radius, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + radius, width - radius * 2, height - radius * 2, r, g, b, a)
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
        renderer.circle(x + width - radius, y + radius, r, g, b, a, radius, 90, 0.25)
        renderer.circle(x + radius, y + height - radius, r, g, b, a, radius, 270, 0.25)
        renderer.circle(x + width - radius, y + height - radius, r, g, b, a, radius, 0, 0.25)
    end
    local rounding = 4
    local rad = rounding + 2
    local n = 45
    local o = 20
    local OutlineGlow = function(x, y, w, h, radius, r, g, b, a)
        renderer.rectangle(x + 2, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + w - 3, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + 2, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + h - 3, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius + rad, y + radius + rad, r, g, b, a, radius + rounding, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + radius + rad, r, g, b, a, radius + rounding, 270, 0.25, 1)
        renderer.circle_outline(x + radius + rad, y + h - radius - rad, r, g, b, a, radius + rounding, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + h - radius - rad, r, g, b, a, radius + rounding, 0, 0.25, 1)
    end
    local FadedRoundedRect = function(x, y, w, h, radius, r, g, b, a, glow)
        local n = a / 255 * n
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, 270, 0.25, 1)
        renderer.gradient(x, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.gradient(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n, radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)
        local something = true
        if something then
            for radius = 4, glow do
                local radius = radius / 2
                OutlineGlow(x - radius, y - radius, w + radius * 2, h + radius * 2, radius, r, g, b, glow - radius * 2)
            end
        end
    end
    local HorizontalFadedRoundedRect = function(x, y, w, h, radius, r, g, b, a, glow, r1, g1, b1, state)
        local n = a / 255 * n
        renderer.rectangle(x, y + radius, 1, h - radius * 2, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, 1)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, 1)
        renderer.gradient(x + radius, y, w / 3.5 - radius * 2, 1, r, g, b, a, 0, 0, 0, n / 0, true)
        renderer.gradient(x + radius, y + h - 1, w / 3.5 - radius * 2, 1, r, g, b, a, 0, 0, 0, n / 0, true)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r1, g1, b1, n)
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r1, g1, b1, n)
        renderer.circle_outline(x + w - radius, y + radius, r1, g1, b1, n, radius, -90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r1, g1, b1, n, radius, 0, 0.25, 1)
        renderer.rectangle(x + w - 1, y + radius, 1, h - radius * 2, r1, g1, b1, n)
        if state then
            for radius = 4, glow do
                local radius = radius / 2
                OutlineGlow(
                    x - radius,
                    y - radius,
                    w + radius * 2,
                    h + radius * 2,
                    radius,
                    r1,
                    g1,
                    b1,
                    glow - radius * 2
                )
            end
        end
    end
    local FadedRoundedGlow = function(x, y, w, h, radius, r, g, b, a, glow, r1, g1, b1)
        local n = a / 255 * n
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, n)
        renderer.circle_outline(x + radius, y + radius, r, g, b, n, radius, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, n, radius, 270, 0.25, 1)
        renderer.rectangle(x, y + radius, 1, h - radius * 2, r, g, b, n)
        renderer.rectangle(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, n)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n, radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)
        if ui_get(config.glow_enabled) then
            for radius = 4, glow do
                local radius = radius / 2
                OutlineGlow(x - radius, y - radius, w + radius * 2, h + radius * 2, radius, r1, g1, b1, glow - radius * 2)
            end
        end
    end
    solus_m.linear_interpolation = function(start, _end, time)
        return (_end - start) * time + start
    end
    solus_m.clamp = function(value, minimum, maximum)
        if minimum > maximum then
            return math.min(math.max(value, maximum), minimum)
        else
            return math.min(math.max(value, minimum), maximum)
        end
    end
    solus_m.lerp = function(start, _end, time)
        time = time or 0.005
        time = solus_m.clamp(globals.frametime() * time * 175.0, 0.01, 1.0)
        local a = solus_m.linear_interpolation(start, _end, time)
        if _end == 0.0 and a < 0.01 and a > -0.01 then
            a = 0.0
        elseif _end == 1.0 and a < 1.01 and a > 0.99 then
            a = 1.0
        end
        return a
    end
    solus_m.container = function(x, y, w, h, r, g, b, a, alpha, br, bg, bb, ba, fn)
        if alpha * 255 > 0 then
            renderer.blur(x, y, w, h)
        end
        RoundedRect(x, y, w, h, rounding, br, bg, bb, ba)
        FadedRoundedRect(x, y, w, h, rounding, r, g, b, a, alpha * o)
        if not fn then
            return
        end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end
    solus_m.horizontal_container = function(x, y, w, h, r, g, b, a, alpha, r1, g1, b1, fn)
        if alpha * 255 > 0 then
            renderer.blur(x, y, w, h)
        end
        RoundedRect(x, y, w, h, rounding, 17, 17, 17, a)
        HorizontalFadedRoundedRect(x, y, w, h, rounding, r, g, b, alpha * 255, alpha * o, r1, g1, b1)
        if not fn then
            return
        end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end
    solus_m.container_glow = function(x, y, w, h, r, g, b, a, alpha, r1, g1, b1, fn)
        if alpha * 255 > 0 then
            renderer.blur(x, y, w, h)
        end
        RoundedRect(x, y, w, h, rounding, 17, 17, 17, a)
        FadedRoundedGlow(x, y, w, h, rounding, r, g, b, alpha * 255, alpha * o, r1, g1, b1)
        if not fn then
            return
        end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end
    solus_m.measure_multitext = function(flags, _table)
        local a = 0
        for b, c in pairs(_table) do
            c.flags = c.flags or ""
            a = a + renderer.measure_text(c.flags, c.text)
        end
        return a
    end
    solus_m.multitext = function(x, y, _table)
        for a, b in pairs(_table) do
            b.flags = b.flags or ""
            b.limit = b.limit or 0
            b.color = b.color or {255, 255, 255, 255}
            b.color[4] = b.color[4] or 255
            renderer.text(x, y, b.color[1], b.color[2], b.color[3], b.color[4], b.flags, b.limit, b.text)
            x = x + renderer.measure_text(b.flags, b.text)
        end
    end
    return solus_m
end)()

local function lerp(start, vend, time)
return start + (vend - start) * time end

local dragging_fn = function(b,c,d)return(function()local e={}local f,g,h,i,j,k,l,m,n,o,p,q,r,s;local t={__index={drag=function(self,...)local u,v=self:get()local w,x,q=e.drag(u,v,...)if u~=w or v~=x then self:set(w,x)end;return w,x,q end,status=function(self,...)local w,x=self:get()local y,z=e.status(w,x,...)return y end,set=function(self,u,v)local n,o=client_screen_size()ui_set(self.x_reference,u/n*self.res)ui_set(self.y_reference,v/o*self.res)end,get=function(self)local n,o=client_screen_size()return ui_get(self.x_reference)/self.res*n,ui_get(self.y_reference)/self.res*o end}}function e.new(y,z,A,B)B=B or 10000;local n,o=client_screen_size()local C=ui_new_slider("LUA","A",y.." window position",0,B,z/n*B)local D=ui_new_slider("LUA","A","\n"..y.." window position y",0,B,A/o*B)ui_set_visible(C,false)ui_set_visible(D,false)return setmetatable({name=y,x_reference=C,y_reference=D,res=B},t)end;function e.drag(u,v,E,F,G,H,I)local t="n"if globals_framecount()~=f then g=ui_is_menu_open()j,k=h,i;h,i=ui_mouse_position()m=l;l=client_key_state(0x01)==true;q=p;p={}s=r;r=false;n,o=client_screen_size()end;if g and m~=nil then if(not m or s)and l and j>u and k>v and j<u+E and k<v+F then r=true;u,v=u+h-j,v+i-k;if not H then u=math_max(0,math_min(n-E,u))v=math_max(0,math_min(o-F,v))end end end;if g and m~=nil then if j>u and k>v and j<u+E and k<v+F then if l then t="c"else t="o"end end end;table_insert(p,{u,v,E,F})return u,v,t,E,F end;function e.status(u,v,E,F,G,H,I)if globals_framecount()~=f then g=ui_is_menu_open()j,k=h,i;h,i=ui_mouse_position()m=l;l=true;q=p;p={}s=r;r=false;n,o=client_screen_size()end;if g and m~=nil then if j>u and k>v and j<u+E and k<v+F then return true end end;return false end;return e end)().new(b,c,d)end
local render = {

    outline = function(x, y, w, h, t, r, g, b, a)
        renderer.rectangle(x, y, w, t, r, g, b, a)
        renderer.rectangle(x, y, t, h, r, g, b, a)
        renderer.rectangle(x, y+h-t, w, t, r, g, b, a)
        renderer.rectangle(x+w-t, y, t, h, r, g, b, a)
    end,

    text = function(x, y, text, r, g, b, alpha, font)
        renderer.text(x, y, r, g, b, alpha, font, nil, text)
    end
}



local ani = {
    alpha = 1,
    offset = 0,
    c_alpha = 1,
    c_offset = 0,
}
local mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage")

-- init_drag1()
-- init_drag2()

local d = {
    m_alpha = 0,
}
local slider = ui.new_slider("LUA", "A", "Slider", 0, 100, 50)

local handle_draging = {

    container = function() 
        local screen_size = { client_screen_size() }
        local screen_size = {
            screen_size[1] - screen_size[1] * cvar.safezonex:get_float(),
            screen_size[2] * cvar.safezoney:get_float()
        }
        local dragging = dragging_fn('fucker', screen_size[1] / 1.385, screen_size[2] / 2)

        local paint = function()
            local x, y = dragging:get()
            local _, _, status = dragging:drag(68, 25 + 5)
            local selected = (status ~= "n" and true) or false
            local clicked = (status == "o" and true) or false
            ani.c_offset = lerp(ani.c_offset, clicked and 180 or 250, 6 * globals.frametime())
            ani.c_alpha = lerp(ani.c_alpha, selected and 2.3 or 1.1, 3.5 * globals.frametime())
            solus_render.container(x, y, 68, 25 + 5, 184, 187, 230, 230, ani.c_alpha, 134, 137, 180, 80)
            -- print(status)
        end

        client_set_event_callback('paint', paint)
    end,

    text = function()  

        local font = ""
        local dragging = dragging_fn('nigger', 600, 600)

        local paint = function()
            local text = ui.get(mindmg)
            local x, y = dragging:get()
            local width, height = renderer.measure_text(font, text)
            local _, _, status = dragging:drag(width + 3, height + 3)
            local selected = (status == "n" and true) or false
            local clicked = (status == "c" and true) or false
            ani.offset = lerp(ani.offset, clicked and 150 or 250, 6 * globals.frametime())
            ani.alpha = lerp(ani.alpha, selected and 0 or 250, 3.5 * globals.frametime())
            render.outline(x - 3, y - 3, width + 6, height + 6, 2, 255, 255, 255, ani.alpha)
            render.text(x, y, text, 255, 255, 255, ani.offset, font)
        end

        client_set_event_callback('paint', paint)
    end,

    debug = function()

        local function draw_layer_1(x, y, w, h, header, a)
            local c = {10, 60, 40, 40, 40, 60, 20}
        
            
            for i = 0,6,1 do
                renderer.rectangle(x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], a)
            end
            if header then
                local x_inner, y_inner = x+7, y+7
                local w_inner = w-14
        
                local a_lower = a
                renderer.gradient(x_inner, y_inner+1, math_floor(w_inner/2), 1, 59, 175, 222, a_lower, 202, 70, 205, a_lower, true)
                renderer.gradient(x_inner+math.floor(w_inner/2), y_inner+1, math.ceil(w_inner/2), 1, 202, 70, 205, a_lower, 201, 227, 58, a_lower, true)
            end
        end

        local function draw_layer2(x, y, w, h, a)
            renderer_rectangle(x + 13, y + 15, math_abs(w - 30 + 2 + 2), math_abs(h-30 + 2 + 2), 12, 12, 12, a)
            renderer_rectangle(x + 14, y + 16, math_abs(w - 30 + 2), math_abs(h-30 + 2), 40, 40, 40,a)
            renderer_rectangle(x + 15 ,y + 17, math_abs(w - 30), math_abs(h-30), 23, 23, 23, a)
        end

        local render_outline_text = function(x, y, r, g, b, a, flags, text)
            renderer_text(x + 1,y - 1,12,12,12,a*0.7,flags,0,text)
            renderer_text(x + 1,y + 1,12,12,12,a*0.7,flags,0,text)
            renderer_text(x - 1,y + 1,12,12,12,a*0.7,flags,0,text)
            renderer_text(x - 1,y - 1,12,12,12,a*0.7,flags,0,text)
            renderer_text(x,y,r,g,b,a,flags,0,text)
        end

        local draw_layer_boxes = function(x, y, a, text, content)
            renderer_text(x + 25,y + (25), 205, 205, 205, a,"",0, text)
            renderer_rectangle(x + 25, y + 15+ (25), 150 + 2, 20, 12, 12, 12, a)
            renderer_rectangle(x + 25 + 1, y + 15 +1 + (25), 150, 18, 44, 44, 44, a)
            renderer_text(x + 25 + 8, y + 15 +3 + (25), 147, 147, 147, a, "", 0, content)
        end

        local draw_layer_slider = function(x, y, a, text, slider)
            local r,g,b, alpha = ui_get(reference.menu_color)
            renderer_text(x + 25,y + 30, 205, 205, 205, a,"",0, text)
            renderer_rectangle(x + 25 - 1, y + 45 -1, 150 + 2, 5 + 2, 12, 12, 12, a)
            renderer_rectangle(x + 25, y + 45, 150, 5, 60, 60, 60, a)
            renderer_rectangle(x + 25, y + 45, slider, 4, r, g, b, a)
            render_outline_text(x + 25 + slider,y + 47,205,205,205, a,"bc", slider)
        end

    

        local paint = function()

            local get_menu_x , get_menu_y = ui.menu_position()
            local w,h = 200 , 200
            local x ,y = get_menu_x - (w +10), get_menu_y + 200
            local menu_open = ui_is_menu_open()
            d.m_alpha = lerp(d.m_alpha, menu_open and 255 or 0, 12 * globals.frametime())

            draw_layer_1(x, y, w, h, true, d.m_alpha) 
            draw_layer2(x, y, w, h, d.m_alpha)
            -->> Header
            renderer_text(x + 25 , y + 13, 204, 204, 204, d.m_alpha, "b", nil, "Debug Info")
            local length = ui.get(slider)

            draw_layer_slider(x, y + 1, d.m_alpha, "Mindamage", length)
            draw_layer_boxes(x, y + 35, d.m_alpha, "Hitbox", "Head, Stomach")
            draw_layer_slider(x, y + 68, d.m_alpha, "Hitchance", length)
        end

        client_set_event_callback('paint', paint)
    end
}

handle_draging.container()
handle_draging.text()
handle_draging.debug()
local function setup()

    client.exec("sv_cheats 1;Impulse 101;sv_airaccelerate 9999;bot_stop all;mp_roundtime_defuse 60;sv_infinite_ammo 1;mp_limitteams 0;mp_autoteambalance 0;mp_buytime 100000;mp_freezetime 1")

end
local function setup2()
    client.exec("mp_restartgame 1")

end
local function setup3()
    client.exec("impulse 101")

end
local function setup4()
    client.exec("bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;")
end
local function setup8()
    client.exec("bot_kick")

end
local function setup7()
    client.exec("give weapon_ssg08;give weapon_scar20;give weapon_awp;give weapon_deagle")

end
local function setup9()
    client.exec("give weapon_hegrenade;give weapon_incgrenade;give weapon_smokegrenade;give weapon_flashbang")

end
local function setup10()
    client.exec("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1")
    client.delay_call(5, client.exec, "mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0")

end
local function setup11()
    client.exec("bot_place")

end
local weapons = {
    "Follow Players Movement", 
    "All Freeze",
    "All Crouching", 
    "Not firing", 
    "Ignore Players"
}
local function contains(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

local hide = ui.new_checkbox("AA", "Anti-aimbot angles", "Un-Hide Warmup menu")
local warmup = ui.new_button("AA", "Anti-aimbot angles", "Load Warmup Config", setup)
local warmup2 = ui.new_button("AA", "Anti-aimbot angles", "Restart Game", setup2)
local warmup3 = ui.new_button("AA", "Anti-aimbot angles", "Gain Money", setup3)
local warmup6 = ui.new_button("AA", "Anti-aimbot angles", "Kick All bots", setup8)
local warmup4 = ui.new_button("AA", "Anti-aimbot angles", "Fill Server with bots", setup4)
local warmup8 = ui.new_button("AA", "Anti-aimbot angles", "Give All Sniper Rifles", setup7)
local warmup9 = ui.new_button("AA", "Anti-aimbot angles", "Give All nades", setup9)
local warmup10 = ui.new_button("AA", "Anti-aimbot angles", "Respawn All bots", setup10)
local warmup11 = ui.new_button("AA", "Anti-aimbot angles", "Place a bot", setup11)
local bot_holding = ui.new_multiselect("AA", "Anti-aimbot angles", "Bot Status", weapons)
local function setup13()
    local owo = ui.get(bot_holding)

    if contains(owo, "All Freeze") then
        client.exec("bot_stop 1;")
    else
        client.exec("bot_stop 0;")
    end

    if contains(owo, "All Crouching") then
        client.exec("bot_crouch 1;")
    else
        client.exec("bot_crouch 0;")
    end

    if contains(owo, "Follow Players Movement") then
        client.exec("bot_mimic 1;")
    else
        client.exec("bot_mimic 0;")
    end

    if contains(owo, "Not firing") then
        client.exec("bot_dont_shoot 1;")
    else
        client.exec("bot_dont_shoot 0;")
    end

    if contains(owo, "Ignore Players") then
        client.exec("bot_ignore_players 1 1;")
    else
        client.exec("bot_ignore_players 0 0;")
    end
end
local warmup12 = ui.new_button("AA", "Anti-aimbot angles", "Update Bot Status", setup13)
local function coolsetup()
        ui.set_visible(warmup, ui.get(hide))
        ui.set_visible(warmup2, ui.get(hide))
        ui.set_visible(warmup3, ui.get(hide))
        ui.set_visible(warmup4, ui.get(hide))
        ui.set_visible(warmup6, ui.get(hide))
        ui.set_visible(warmup8, ui.get(hide))
        ui.set_visible(warmup9, ui.get(hide))
        ui.set_visible(warmup10, ui.get(hide))
        ui.set_visible(warmup11, ui.get(hide))
        ui.set_visible(warmup12, ui.get(hide))   
        ui.set_visible(bot_holding, ui.get(hide)) 
end
ui.set_callback(hide, coolsetup) -- trigger while checkbox state has been changed
coolsetup() -- update visibility after load lua
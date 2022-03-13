
client.set_event_callback('aim_fire', function()
    --Check if you are holding zeus
    local local_player = entity.get_local_player()
    local weapon = entity.get_player_weapon(local_player)
    local itemindex = bit.band(entity.get_prop(weapon, "m_iItemDefinitionIndex"), 0xFFFF)
    if itemindex ~= 31 then return end
    --Swap weapon after zeus fire
    client.delay_call( 0.05, client.exec, "slot1")
end)

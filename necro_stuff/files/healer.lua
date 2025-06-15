dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local hooman = GetUpdatedEntityID()
local actual_hooman = get_player()
if( actual_hooman ~= nil ) then
	local damage_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
	local max_hp = ComponentGetValue2( damage_comp, "max_hp" )
	local hp = ComponentGetValue2( damage_comp, "hp" )
	
	local p_damage_comp = EntityGetFirstComponentIncludingDisabled( actual_hooman, "DamageModelComponent" )
	local p_max_hp = ComponentGetValue2( p_damage_comp, "max_hp" )
	local p_hp = ComponentGetValue2( p_damage_comp, "hp" )
	if( hp/max_hp > 0.5 and p_hp < p_max_hp*0.99 ) then
		local amount = max_hp*0.01
		ComponentSetValue2( damage_comp, "hp", hp - amount )
		local p_x, p_y = EntityGetTransform( actual_hooman )
		local x, y, r, s_x, s_y = EntityGetTransform( hooman )
		EntityInflictDamage( actual_hooman, -amount, "DAMAGE_HEALING", "[POWER BEYOND]", "NONE", 0, 0, hooman, p_x, p_y, 0 )
		EntityAddChild( hooman, new_connector( actual_hooman, x, y, "blood", 10 ))
		GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", p_x, p_y )
	end
end
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( projectile_id )
local hooman = ( EntityGetInRadiusWithTag( x, y, 64, "player_unit" ) or {} )[1]
if( hooman ~= nil ) then
	if( EntityGetFirstComponentIncludingDisabled( hooman, "LuaComponent", "tenet" ) == nil ) then
		EntityAddComponent( hooman, "LuaComponent", 
		{
			_tags = "tenet",
			script_damage_received = "mods/necro_stuff/files/spells/tenet/tenet_interface.lua",
			execute_every_n_frame = "-1",
		})
	end
end

local storage_damage = get_storage_old( projectile_id, "damage" )
local current_damage = ComponentGetValue2( storage_damage, "value_float" )
if( current_damage > 0 ) then
	ComponentSetValue2( storage_damage, "value_float", 0 )
	
	local abominations = EntityGetInRadiusWithTag( x, y, 64, "abomination" ) or {}
	if( #abominations > 0 ) then
		local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
		ComponentSetValue2( dmg_comp, "hp", ComponentGetValue2( dmg_comp, "hp" ) + current_damage )
		
		current_damage = current_damage/#abominations
		for i,meat in ipairs( abominations ) do
			local a_x, a_y = EntityGetTransform( meat )
			EntityInflictDamage( meat, current_damage, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, projectile_id, a_x, a_y, 0 )
		end
	end
end
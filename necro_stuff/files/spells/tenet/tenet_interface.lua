dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

function damage_received( damage, message, entity_thats_responsible, is_fatal )
	local hooman = GetUpdatedEntityID()
	local x, y = EntityGetTransform( hooman )
	local tenet = ( EntityGetInRadiusWithTag( x, y, 64, "tenet" ) or {} )[1]
	if( tenet ~= nil ) then
		local storage_damage = get_storage_old( tenet, "damage" )
		ComponentSetValue2( storage_damage, "value_float", ComponentGetValue2( storage_damage, "value_int" ) + damage )
	end
end
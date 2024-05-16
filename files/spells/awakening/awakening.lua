dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local effect_id = GetUpdatedEntityID()
local deadman = EntityGetRootEntity( effect_id )
if( is_sentient( deadman )) then
	local damage_comp = EntityGetFirstComponentIncludingDisabled( deadman, "DamageModelComponent" )
	if( damage_comp ~= nil ) then
		local actual_hooman = get_player()
		local p_x, p_y = EntityGetTransform( actual_hooman )
		local stuff = EntityGetClosestWithTag( p_x, p_y, "necro_stuff" )
		if( stuff ~= nil ) then
			local storage_necro = get_storage_old( stuff, "necro_current" )
			local necro_current = ComponentGetValue2( storage_necro, "value_float" )
			local necro_price = get_necro_current( deadman )
			if( necro_current  - tonumber( GlobalsGetValue( "NECRO_ZERO", "0" )) > necro_price ) then
				ComponentSetValue2( storage_necro, "value_float", necro_current - necro_price )
				EntityInflictDamage( actual_hooman, 66/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, effect_id, p_x, p_y, 0 )
				
				local hp = ComponentGetValue2( damage_comp, "hp" )
				local x, y = EntityGetTransform( deadman )
				local man = EntityLoad( EntityGetFilename( deadman ), x, y )
				ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( man, "DamageModelComponent" ), "hp", hp )
				ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( man, "GenomeDataComponent" ), "herd_id", StringToHerdId( "player" ))
				EntityAddChild( man, EntityLoad( "mods/necro_stuff/files/spells/awakening/charm.xml", x, y ))
				if( EntityHasTag( deadman, "cure_applied" )) then
					EntityAddTag( man, "uncurable" )
					EntityAddChild( man, EntityLoad( "mods/necro_stuff/files/spells/cure/cure.xml", x, y ))
				end
				EntityKill( deadman )
			else
				GamePrint( "Awakening Attempt Failed" )
			end
		end
	end
end
EntityKill( effect_id )
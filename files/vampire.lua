dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local hooman = EntityGetParent( entity_id )
local actual_hooman = get_player()
if( actual_hooman ~= nil ) then
	local damage_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
	local max_hp = ComponentGetValue2( damage_comp, "max_hp" )
	local hp = ComponentGetValue2( damage_comp, "hp" )
	
	local p_damage_comp = EntityGetFirstComponentIncludingDisabled( actual_hooman, "DamageModelComponent" )
	local p_max_hp = ComponentGetValue2( p_damage_comp, "max_hp" )
	local p_hp = ComponentGetValue2( p_damage_comp, "hp" )
	
	local x, y = EntityGetTransform( entity_id )
	local meat = EntityGetInRadiusWithTag( x, y, 100, "enemy" ) or {}
	local sound_played = false
	local sound_played_p = false
	if( #meat > 0 ) then
		for i,deadman in ipairs( meat ) do
			local e_damage_comp = EntityGetFirstComponentIncludingDisabled( deadman, "DamageModelComponent" )
			local e_hp = ComponentGetValue2( e_damage_comp, "hp" )
			
			local amount = math.min( 0.4, e_hp )
			local e_x, e_y = EntityGetTransform( deadman )
			if( hp < max_hp*0.99 ) then
				EntityInflictDamage( deadman, amount, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, entity_id, e_x, e_y, 0 )
				local p_x, p_y = EntityGetTransform( hooman )
				EntityInflictDamage( hooman, -amount, "DAMAGE_HEALING", "[POWER BEYOND]", "NONE", 0, 0, entity_id, p_x, p_y, 0 )
				EntityAddChild( deadman, new_connector( entity_id, e_x, e_y, "blood", 10 ))
				if( not( sound_played )) then
					GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", p_x, p_y )
					sound_played = true
				end
			elseif( p_hp < p_max_hp*0.99 ) then
				EntityInflictDamage( deadman, amount, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, entity_id, e_x, e_y, 0 )
				local p_x, p_y = EntityGetTransform( actual_hooman )
				EntityInflictDamage( actual_hooman, -amount, "DAMAGE_HEALING", "[POWER BEYOND]", "NONE", 0, 0, hooman, p_x, p_y, 0 )
				EntityAddChild( hooman, new_connector( actual_hooman, x, y, "blood", 10 ))
				EntityAddChild( deadman, new_connector( entity_id, e_x, e_y, "blood", 10 ))
				if( not( sound_played_p )) then
					GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", p_x, p_y )
					sound_played_p = true
				end
			end
		end
	end
end
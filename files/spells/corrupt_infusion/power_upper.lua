dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local undead = EntityGetWithTag( "undead" ) or {}
if( #undead > 0 ) then
	local target = 0
	local min_dist = -1
	local values = {
		{ 0, 0, 0, 0, 0, 0, 0, 0, },
		{ 0, 0, 0, 0, },
		{ 0, 0, },
		{ 0, },
	}
	for i,man in ipairs( undead ) do
		if( not( EntityHasTag( man, "corrupt_infusion" ))) then
			local m_x, m_y = EntityGetTransform( man )
			local dist = math.sqrt(( x - m_x )^2 + ( y - m_y )^2 )
			if( min_dist > dist or min_dist == -1 ) then
				target = man
				min_dist = dist
			end
		end
		
		local ai_comp = EntityGetFirstComponentIncludingDisabled( man, "AnimalAIComponent" )
		if( ai_comp ~= nil ) then
			values[1][1] = values[1][1] + 1
			values[1][2] = values[1][2] + ComponentGetValue2( ai_comp, "creature_detection_angular_range_deg" )
			values[1][3] = values[1][3] + ComponentGetValue2( ai_comp, "creature_detection_range_x" )
			values[1][4] = values[1][4] + ComponentGetValue2( ai_comp, "creature_detection_range_y" )
			values[1][5] = values[1][5] + ComponentGetValue2( ai_comp, "aggressiveness_min" )
			values[1][6] = values[1][6] + ComponentGetValue2( ai_comp, "aggressiveness_max" )
			values[1][7] = values[1][7] + 10
			values[1][8] = values[1][8] + 0.5
		end
		
		local phys_comp = EntityGetFirstComponentIncludingDisabled( man, "PhysicsAIComponent" )
		if( phys_comp ~= nil ) then
			values[2][1] = values[2][1] + ComponentGetValue2( phys_comp, "force_balancing_coeff" )
			values[2][2] = values[2][2] + ComponentGetValue2( phys_comp, "force_coeff" )
			values[2][3] = values[2][3] + ComponentGetValue2( phys_comp, "force_max" )
			values[2][4] = values[2][4] + 0.3
		end
		
		local dmg_comp = EntityGetFirstComponentIncludingDisabled( man, "DamageModelComponent" )
		if( dmg_comp ~= nil ) then
			values[3][1] = values[3][1] + ComponentGetValue2( dmg_comp, "max_hp" )
			values[3][2] = values[3][2] + 0.05
		end
		
		local char_comp = EntityGetFirstComponentIncludingDisabled( man, "CharacterPlatformingComponent" )
		if( char_comp ~= nil ) then
			values[4][1] = values[4][1] + ComponentGetValue2( char_comp, "run_velocity" )
		end
	end
	
	if( target ~= 0 ) then
		EntityAddTag( target, "corrupt_infusion" )
		
		edit_component_ultimate( target, "AnimalAIComponent", function(comp,vars)
			ComponentSetValue2( comp, "creature_detection_check_every_x_frames", math.max( ComponentGetValue2( comp, "creature_detection_check_every_x_frames" ) - values[1][1], 5 ))
			ComponentSetValue2( comp, "creature_detection_angular_range_deg", math.min( ComponentGetValue2( comp, "creature_detection_angular_range_deg" ) + math.floor( 0.1*values[1][2] ), 360 ))
			ComponentSetValue2( comp, "creature_detection_range_x", math.min( ComponentGetValue2( comp, "creature_detection_range_x" ) + math.floor( 0.1*values[1][3] ), 500 ))
			ComponentSetValue2( comp, "creature_detection_range_y", math.min( ComponentGetValue2( comp, "creature_detection_range_y" ) + math.floor( 0.1*values[1][4] ), 500 ))
			ComponentSetValue2( comp, "aggressiveness_min", math.min( ComponentGetValue2( comp, "aggressiveness_min" ) + math.floor( 0.1*values[1][5] ), 100 ))
			ComponentSetValue2( comp, "aggressiveness_max", math.min( ComponentGetValue2( comp, "aggressiveness_max" ) + math.floor( 0.1*values[1][6] ), 100 ))
			ComponentSetValue2( comp, "escape_if_damaged_probability", math.max( ComponentGetValue2( comp, "escape_if_damaged_probability" ) - values[1][7], 0 ))
			ComponentSetValue2( comp, "attack_melee_frames_between", math.max( ComponentGetValue2( comp, "attack_melee_frames_between" ) - math.floor( values[1][8] ), 1 ))
		end)
		
		edit_component_ultimate( target, "PhysicsAIComponent", function(comp,vars)
			ComponentSetValue2( comp, "force_balancing_coeff", math.min( ComponentGetValue2( comp, "force_balancing_coeff" ) + 0.1*values[2][1], 1 ))
			ComponentSetValue2( comp, "force_coeff", math.min( ComponentGetValue2( comp, "force_coeff" ) + 0.1*values[2][2], 100 ))
			ComponentSetValue2( comp, "force_max", math.min( ComponentGetValue2( comp, "force_max" ) + 0.1*values[2][3], 200 ))
			-- ComponentSetValue2( comp, "target_vec_max_len", math.max( ComponentGetValue2( comp, "target_vec_max_len" ) - math.floor( values[2][4] ), 1 ))
		end)
		
		edit_component_ultimate( target, "DamageModelComponent", function(comp,vars)
			ComponentSetValue2( comp, "max_hp", math.min( ComponentGetValue2( comp, "max_hp" ) + 0.1*values[3][1], 666 ))
			ComponentSetValue2( comp, "hp", math.min( ComponentGetValue2( comp, "hp" ) + 0.1*values[3][1], 666 ))
			ComponentObjectSetValue2( comp, "damage_multipliers", "explosion", math.max( ComponentObjectGetValue2( comp, "damage_multipliers", "explosion" ) - values[3][2], 0 ))
		end)
		
		edit_component_ultimate( target, "CharacterPlatformingComponent", function(comp,vars)
			ComponentSetValue2( comp, "run_velocity", math.min( ComponentGetValue2( comp, "run_velocity" ) + math.floor( 0.1*values[4][1] ), 200 ))
		end)
	end
end
EntityKill( entity_id )
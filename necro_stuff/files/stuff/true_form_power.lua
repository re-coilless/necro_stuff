dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()

local x, y = EntityGetTransform( entity_id )
local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
if( stuff ~= nil ) then
	local necro_stage = ComponentGetValue2( get_storage_old( stuff, "necro_stage" ), "value_int" )
	
	local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
	if( proj_comp ~= nil ) then
		local bounce = ComponentGetValue2( proj_comp, "bounces_left" )
		if( bounce > 0 or ComponentGetValue2( proj_comp, "bounce_always" )) then
			ComponentGetValue2( proj_comp, "bounces_left", bounce*( 1 + necro_stage*0.1 ))
		else
			ComponentSetValue2( proj_comp, "ground_penetration_coeff", math.min( ComponentGetValue2( proj_comp, "ground_penetration_coeff" ) + necro_stage, 20 ))
		end
		ComponentSetValue2( proj_comp, "lifetime", necro_stage*ComponentGetValue2( proj_comp, "lifetime" ))
		ComponentSetValue2( proj_comp, "never_hit_player", true )
		ComponentObjectSetValue2( proj_comp, "damage_by_type", "curse", ComponentObjectGetValue2( proj_comp, "damage_by_type", "curse" ) + necro_stage/4 )
		ComponentObjectSetValue2( proj_comp, "damage_critical", "chance", math.max( math.min( ComponentObjectGetValue2( proj_comp, "damage_critical", "chance" )*2, 0.5 ), 1 ))
		
		if( necro_stage > 5 ) then
			ComponentSetValue2( proj_comp, "penetrate_entities", true )
			ComponentSetValue2( proj_comp, "penetrate_world", true )
			ComponentSetValue2( proj_comp, "penetrate_world_velocity_coeff", 1 )
			ComponentSetValue2( proj_comp, "friction", 0 )
			ComponentSetValue2( proj_comp, "collide_with_world", false )
		end
	end
	
	local emit_comp = EntityGetFirstComponent( entity_id, "ParticleEmitterComponent", "necro_fx" )
	ComponentSetValue2( emit_comp, "count_min", math.min( necro_stage, 6 ))
	ComponentSetValue2( emit_comp, "count_max", math.min( necro_stage, 6 ))
	ComponentSetValue2( emit_comp, "lifetime_min", 0.05*math.min( necro_stage, 3 ))
	ComponentSetValue2( emit_comp, "lifetime_max", 0.1*math.min( necro_stage, 3 ))
end
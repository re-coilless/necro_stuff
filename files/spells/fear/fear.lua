local entity_id = GetUpdatedEntityID()

local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if( proj_comp ~= nil ) then
	ComponentSetValue2( proj_comp, "ground_penetration_coeff", 20 )
	ComponentSetValue2( proj_comp, "ground_penetration_max_durability_to_destroy", 20 )
	ComponentSetValue2( proj_comp, "penetrate_entities", true )
	ComponentSetValue2( proj_comp, "friction", 0 )
	ComponentSetValue2( proj_comp, "lifetime", math.max( 2*ComponentGetValue2( proj_comp, "lifetime" ), 120 ))
	ComponentSetValue2( proj_comp, "ground_collision_fx", false )
	ComponentSetValue2( proj_comp, "damage_scaled_by_speed", false )
	ComponentSetValue2( proj_comp, "on_collision_die", false )
	ComponentSetValue2( proj_comp, "bounces_left", 0 )
	ComponentSetValue2( proj_comp, "collide_with_world", true )
	ComponentSetValue2( proj_comp, "penetrate_world", false )
end

local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if( vel_comp ~= nil ) then
	ComponentSetValue2( vel_comp, "air_friction", -5 )
	ComponentSetValue2( vel_comp, "mass", 10 )
end
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local children = EntityGetAllChildren( entity_id ) or {}
if( #children > 0 ) then
	local lifetime = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "LifetimeComponent" ), "kill_frame" ) - GameGetFrameNum()
	if( lifetime > 2 ) then
		local x, y = EntityGetTransform( entity_id )
		for i,child in ipairs( children ) do
			EntitySetTransform( child, x, y )
		end
	else
		for i,child in ipairs( children ) do
			EntitySetComponentsWithTagEnabled( child, "necro_flagellation", true )
			EntityRemoveFromParent( child )
			
			edit_component_ultimate( child, "ProjectileComponent", function(comp,vars)
				local life = math.max( ComponentGetValue2( comp, "lifetime" ) + 100, 200 )
				ComponentSetValue2( comp, "lifetime", life )
				edit_component_ultimate( child, "LifetimeComponent", function(comp2,vars) 
					ComponentSetValue2( comp2, "kill_frame", frame_num + life )
				end)
				
				local dmg = ComponentGetValue2( comp, "damage" )
				dmg = dmg + ComponentObjectGetValue2( comp, "damage_by_type", "curse" ) + ComponentObjectGetValue2( comp, "damage_by_type", "drill" ) + ComponentObjectGetValue2( comp, "damage_by_type", "electricity" ) + ComponentObjectGetValue2( comp, "damage_by_type", "explosion" ) + ComponentObjectGetValue2( comp, "damage_by_type", "fire" ) + ComponentObjectGetValue2( comp, "damage_by_type", "healing" ) + ComponentObjectGetValue2( comp, "damage_by_type", "ice" ) + ComponentObjectGetValue2( comp, "damage_by_type", "melee" ) + ComponentObjectGetValue2( comp, "damage_by_type", "overeating" ) + ComponentObjectGetValue2( comp, "damage_by_type", "physics_hit" ) + ComponentObjectGetValue2( comp, "damage_by_type", "poison" ) + ComponentObjectGetValue2( comp, "damage_by_type", "projectile" ) + ComponentObjectGetValue2( comp, "damage_by_type", "radioactive" ) + ComponentObjectGetValue2( comp, "damage_by_type", "slice" )
				dmg = dmg + ComponentObjectGetValue2( comp, "config_explosion", "damage" )
				dmg = dmg + ComponentObjectGetValue2( comp, "config", "damage_curse_add" ) + ComponentObjectGetValue2( comp, "config", "damage_drill_add" ) + ComponentObjectGetValue2( comp, "config", "damage_electricity_add" ) + ComponentObjectGetValue2( comp, "config", "damage_explosion_add" ) + ComponentObjectGetValue2( comp, "config", "damage_fire_add" ) + ComponentObjectGetValue2( comp, "config", "damage_healing_add" ) + ComponentObjectGetValue2( comp, "config", "damage_ice_add" ) + ComponentObjectGetValue2( comp, "config", "damage_melee_add" ) + ComponentObjectGetValue2( comp, "config", "damage_projectile_add" ) + ComponentObjectGetValue2( comp, "config", "damage_slice_add" )
				
				dmg = ( dmg^2 )/14
				ComponentObjectSetValue2( comp, "damage_by_type", "curse", ComponentObjectGetValue2( comp, "damage_by_type", "curse" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "drill", ComponentObjectGetValue2( comp, "damage_by_type", "drill" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "electricity", ComponentObjectGetValue2( comp, "damage_by_type", "electricity" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "explosion", ComponentObjectGetValue2( comp, "damage_by_type", "explosion" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "fire", ComponentObjectGetValue2( comp, "damage_by_type", "fire" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "healing", ComponentObjectGetValue2( comp, "damage_by_type", "healing" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "ice", ComponentObjectGetValue2( comp, "damage_by_type", "ice" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "melee", ComponentObjectGetValue2( comp, "damage_by_type", "melee" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "overeating", ComponentObjectGetValue2( comp, "damage_by_type", "overeating" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "physics_hit", ComponentObjectGetValue2( comp, "damage_by_type", "physics_hit" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "poison", ComponentObjectGetValue2( comp, "damage_by_type", "poison" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "projectile", ComponentObjectGetValue2( comp, "damage_by_type", "projectile" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "radioactive", ComponentObjectGetValue2( comp, "damage_by_type", "radioactive" ) + dmg )
				ComponentObjectSetValue2( comp, "damage_by_type", "slice", ComponentObjectGetValue2( comp, "damage_by_type", "slice" ) + dmg )
				
				ComponentSetValue2( comp, "damage_scaled_by_speed", true )
				ComponentSetValue2( comp, "on_death_explode", true )
				ComponentSetValue2( comp, "on_lifetime_out_explode", true )
				ComponentSetValue2( comp, "ground_penetration_coeff", math.min( ComponentGetValue2( comp, "ground_penetration_coeff" ) + 1, 10 ))
				ComponentSetValue2( comp, "knockback_force", ComponentGetValue2( comp, "knockback_force" ) + 5 )
				
				ComponentObjectSetValue2( comp, "config_explosion", "damage", ComponentObjectGetValue2( comp, "config_explosion", "damage" ) + 2 )
				ComponentObjectSetValue2( comp, "config_explosion", "camera_shake", 8 )
				ComponentObjectSetValue2( comp, "config_explosion", "explosion_radius", ComponentObjectGetValue2( comp, "config_explosion", "explosion_radius" ) + 16 )
				ComponentObjectSetValue2( comp, "config_explosion", "ray_energy", ComponentObjectGetValue2( comp, "config_explosion", "ray_energy" ) + 500000 )
				ComponentObjectSetValue2( comp, "config_explosion", "max_durability_to_destroy", math.min( ComponentObjectGetValue2( comp, "config_explosion", "max_durability_to_destroy" ) + 10, 20 ))
				local phys_min, phys_max = ComponentObjectGetValue2( comp, "config_explosion", "physics_explosion_power" )
				ComponentObjectSetValue2( comp, "config_explosion", "physics_explosion_power", phys_min + 3, phys_max + 5 )
				ComponentObjectSetValue2( comp, "config_explosion", "physics_throw_enabled", true )
				ComponentObjectSetValue2( comp, "config_explosion", "stains_enabled", true )
				ComponentObjectSetValue2( comp, "config_explosion", "stains_radius", ComponentObjectGetValue2( comp, "config_explosion", "stains_radius" ) + 18 )
			end)
			
			edit_component_ultimate( child, "VelocityComponent", function(comp,vars) 
				ComponentSetValue2( comp, "mass", ComponentGetValue2( comp, "mass" ) + 2 )
				
				local v_x, v_y = ComponentGetValue2( comp, "mVelocity" )
				local v_angle = math.atan2( v_y, v_x )
				local vel = math.sqrt( v_x^2 + v_y^2 ) + 3000
				ComponentSetValueVector2( comp, "mVelocity", math.cos( v_angle )*vel, math.sin( v_angle )*vel )
			end)
		end
	end
end
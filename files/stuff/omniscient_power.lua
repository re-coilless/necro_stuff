local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if( proj_comp ~= nil ) then
	ComponentSetValue2( proj_comp, "penetrate_world", true )
	ComponentSetValue2( proj_comp, "penetrate_world_velocity_coeff", 1 )
	ComponentSetValue2( proj_comp, "friction", 0 )
	ComponentSetValue2( proj_comp, "collide_with_world", false )
end
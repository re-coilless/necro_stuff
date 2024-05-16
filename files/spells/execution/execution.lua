dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local poses = {{ -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 },}
local x, y = EntityGetTransform( entity_id )

local target = EntityGetClosestWithTag( x, y, "execution_target" )
if( target == nil or target == 0 ) then
	target = EntityLoad( "mods/necro_stuff/files/spells/execution/execution_target.xml", x, y )
end
local storage_mode = get_storage_old( target, "execution_mode" )
local mode = ComponentGetValue2( storage_mode, "value_int" )%4 + 1
ComponentSetValue2( storage_mode, "value_int", mode )
ComponentSetValue2( get_storage_old( entity_id, "mode" ), "value_int", mode )

local dist = 50
EntitySetTransform( entity_id, x + poses[mode][1]*dist, y + poses[mode][2]*dist )

local vel_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "VelocityComponent" )
ComponentSetValue2( vel_comp, "gravity_x", 0 )
ComponentSetValue2( vel_comp, "gravity_y", 0 )

local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if( proj_comp ~= nil ) then
	ComponentSetValue2( proj_comp, "penetrate_world", true )
	ComponentSetValue2( proj_comp, "penetrate_world_velocity_coeff", 1 )
	ComponentSetValue2( proj_comp, "friction", 0 )
	ComponentSetValue2( proj_comp, "collide_with_world", false )
	ComponentSetValue2( proj_comp, "lifetime", 8 )
end
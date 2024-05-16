dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local mode = ComponentGetValue2( get_storage_old( entity_id, "mode" ), "value_int" )
local poses = {{ -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 },}
if( mode > 0 ) then
	local vel_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "VelocityComponent" )
	local t_v = 1500
	ComponentSetValueVector2( vel_comp, "mVelocity", -poses[mode][1]*t_v, -poses[mode][2]*t_v )
end
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local hooman = GetUpdatedEntityID()
local x, y, r, s_x, s_y = EntityGetTransform( hooman )
local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
if( stuff ~= nil ) then
	local necro_stage = ComponentGetValue2( get_storage_old( stuff, "necro_stage" ), "value_int" )
	local storage_current = get_storage_old( stuff, "necro_current" )
	local value = ComponentGetValue2( storage_current, "value_float" ) + 0.1
	if( D_extractor_old( GlobalsGetValue( "NECRO_LADDER", "0" ))[ necro_stage + 1 ]/2 > value ) then
		ComponentSetValue2( storage_current, "value_float", value )
	end
end
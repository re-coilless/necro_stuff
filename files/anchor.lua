dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
if( not( EntityHasTag( entity_id, "anchored" ))) then
	EntityAddTag( entity_id, "anchored" )
	ComponentSetValue2( get_storage_old( entity_id, "anchor_x" ), "value_float", x )
	ComponentSetValue2( get_storage_old( entity_id, "anchor_y" ), "value_float", y )
end
x = ComponentGetValue2( get_storage_old( entity_id, "anchor_x" ), "value_float" )
y = ComponentGetValue2( get_storage_old( entity_id, "anchor_y" ), "value_float" )
EntitySetTransform( entity_id, x, y )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()

local anim = ComponentGetValue2( get_storage_old( entity_id, "anim_name" ), "value_string" )
if( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent" ), "rect_animation" ) ~= anim ) then
	GamePlayAnimation( entity_id, anim, 0.5 )
end
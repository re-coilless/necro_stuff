dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

function w2i_extra( item ) --fucking thing autoactivates child comps
	world_2_inv( item )
	
	local children = EntityGetAllChildren( item ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			local pic_comp1 = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent", "enabled_in_world" )
			local pic_comp2 = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent", "enabled_in_hand" )
			local itm_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemComponent", "enabled_in_world" )
			if(( pic_comp1 ~= nil and ComponentGetIsEnabled( pic_comp1 )) or ( pic_comp2 ~= nil and ComponentGetIsEnabled( pic_comp2 )) or ( itm_comp ~= nil and ComponentGetIsEnabled( itm_comp ))) then
				w2i_extra( child )
			end
		end
	end
end

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local children = EntityGetAllChildren( entity_id ) or {}
if( #children > 0 ) then
	local storage_tag = ComponentGetValue2( get_storage_old( entity_id, "storage_tag" ), "value_string" )
	for i,child in ipairs( children ) do
		if( EntityHasTag( child, storage_tag )) then
			EntitySetTransform( child, x, y )
			
			local pic_comp1 = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent", "enabled_in_world" )
			local pic_comp2 = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent", "enabled_in_hand" )
			local itm_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemComponent", "enabled_in_world" )
			if(( pic_comp1 ~= nil and ComponentGetIsEnabled( pic_comp1 )) or ( pic_comp2 ~= nil and ComponentGetIsEnabled( pic_comp2 )) or ( itm_comp ~= nil and ComponentGetIsEnabled( itm_comp ))) then
				w2i_extra( child )
			end
		end
	end
end
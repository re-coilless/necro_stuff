local entity_id = GetUpdatedEntityID()

if( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent", "item_bg" ), "z_index" ) == -1 ) then
	local tags = {
		{ "item_identified", -1, },
		{ "item_unidentified", -1, },
		{ "item_bg", -0.99, },
		{ "true_bg", -0.98, },
	}
	for i,tag in ipairs( tags ) do
		local pic_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent", tag[1] )
		ComponentSetValue2( pic_comp, "z_index", tag[2] )
		EntityRefreshSprite( entity_id, pic_comp )
	end
end
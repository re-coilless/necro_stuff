function enabled_changed( entity, is_enabled )
	local x, y, r, s_x, s_y = EntityGetTransform( entity )
	if( r ~= 0 ) then
		EntitySetTransform( entity, x, y, 0, s_y, 1 )
	end
end
function enabled_changed( entity, is_enabled )
	if( not( is_enabled )) then
		local arrows = EntityGetWithTag( "article_arrow" ) or {}
		if( #arrows > 0 ) then
			for i,arw in ipairs( arrows ) do
				EntityKill( arw )
			end
		end
	end
end
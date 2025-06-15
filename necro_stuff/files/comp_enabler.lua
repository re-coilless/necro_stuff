function enabled_changed( entity, is_enabled )
	if( not( is_enabled )) then
		EntitySetComponentIsEnabled( entity, GetUpdatedComponentID(), true )
	end
end
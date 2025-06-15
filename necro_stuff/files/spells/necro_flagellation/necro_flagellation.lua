local projectile_id = GetUpdatedEntityID()
local comps = EntityGetAllComponents( projectile_id ) or {}
if( #comps > 0 ) then
	local this_comp = GetUpdatedComponentID()
	for i,comp in ipairs( comps ) do
		if( comp ~= this_comp ) then
			if( ComponentGetIsEnabled( comp )) then
				ComponentAddTag( comp, "necro_flagellation" )
				EntitySetComponentIsEnabled( projectile_id, comp, false )
			end
		end
	end
	
	local x, y = EntityGetTransform( projectile_id )
	EntityAddChild( EntityLoad( "mods/necro_stuff/files/spells/necro_flagellation/chamber.xml", x, y ), projectile_id )
end
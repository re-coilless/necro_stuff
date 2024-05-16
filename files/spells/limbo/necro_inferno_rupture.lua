local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local n_found, n_x, n_y = GetSurfaceNormal( x, y, 30, 20 )
if( n_found ) then
	EntitySetTransform( EntityLoad( "mods/necro_stuff/files/spells/limbo/necro_inferno_jet.xml", x, y ), x, y, math.atan2( n_y, n_x ))
end
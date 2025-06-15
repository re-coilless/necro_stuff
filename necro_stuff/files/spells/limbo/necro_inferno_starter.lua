local entity_id = GetUpdatedEntityID()

local jets = EntityGetWithTag( "necro_inferno" )
if( #jets < 5 ) then
	local x, y = EntityGetTransform( entity_id )
	EntityLoad( "mods/necro_stuff/files/spells/limbo/necro_inferno_rupture.xml", x, y )
end

EntityKill( entity_id )
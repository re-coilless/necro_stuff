dofile_once( "data/scripts/lib/utilities.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
if( ProceduralRandomf( x, y )) < 0.5 then
	EntitySetTransform( EntityLoad( "mods/necro_stuff/files/spells/machine/core_fruit.xml", x, y ), x, y, ProceduralRandomf( x, y, -math.pi*0.5, math.pi*0.5 ))
else
	EntitySetTransform( EntityLoad( "mods/necro_stuff/files/spells/machine/core_tank.xml", x, y ), x, y, ProceduralRandomf( x, y, math.pi*2 ))
end
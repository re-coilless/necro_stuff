dofile_once( "data/scripts/lib/utilities.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local r = ProceduralRandomf( x, y + GameGetFrameNum())
if( r < 0.01 ) then
	EntityLoad( "mods/necro_stuff/files/spells/machine/core.xml", x + ProceduralRandomf( x - 12, y, -3, 3 ), y + ProceduralRandomf( x, y + 54, -3, 3 ))
elseif( r < 0.4 ) then
	EntityLoad( "mods/necro_stuff/files/spells/machine/core_fragment.xml", x + ProceduralRandomf( x - 7, y, -3, 3 ), y + ProceduralRandomf( x, y, -3, 3 ))
elseif( r < 0.5 ) then
	EntitySetTransform( EntityLoad( "mods/necro_stuff/files/spells/machine/core_tank.xml", x, y ), x, y, ProceduralRandomf( x, y, math.pi*2 ))
end
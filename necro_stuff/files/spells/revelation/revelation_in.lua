dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local effect_id = GetUpdatedEntityID()
local deadman = EntityGetRootEntity( effect_id )
if( is_sentient( deadman )) then
	package_entity( deadman, true, "revelation_extractor" )
	
	local c_x, c_y = GameGetCameraPos()
	local x, y = EntityGetTransform( deadman )
	local frame_num = GameGetFrameNum()
	SetRandomSeed( frame_num, effect_id + deadman + x + y )
	x, y = get_spawn_pos( c_x + ( 1 - 2*( effect_id%2 ))*Random( 1, 100 ), c_y + ( 1 - 2*( deadman%2 ))*Random( 1, 150 ), 10, 100, x, y )
	EntitySetTransform( deadman, x, y )
else
	EntityKill( effect_id )
end
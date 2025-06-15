dofile_once( "data/scripts/lib/utilities.lua" )

local lerp_amount = 0.975
local bob_h = 6
local bob_w = 20
local bob_speed_y = 0.065
local bob_speed_x = 0.01421

local entity_id = GetUpdatedEntityID()
local player = EntityGetWithTag( "player_unit" )[1]
local pos_x, pos_y = EntityGetTransform( entity_id )
if( pos_x == 0 and pos_y == 0 ) then
	pos_x, pos_y = EntityGetTransform( player )
end

local target_x, target_y = EntityGetTransform( player )
if( target_x == nil ) then
	return
end
target_y = target_y - 10

local tm = GameGetFrameNum()
local r = ProceduralRandomf( entity_id, 0, -1, 1 )

tm = tm + r*10000
bob_speed_y = bob_speed_y + r*bob_speed_y*0.1
bob_speed_x = bob_speed_x + r*bob_speed_x*0.1
lerp_amount = lerp_amount - r*lerp_amount*0.01

target_y = target_y + math.sin( tm*bob_speed_y )*bob_h
target_x = target_x + math.sin( tm*bob_speed_x )*bob_w

pos_x, pos_y = vec_lerp( pos_x, pos_y, target_x, target_y, lerp_amount )
EntitySetTransform( entity_id, pos_x, pos_y, 0, ( pos_x - target_x ) > 2 and -1 or 1, 1 )
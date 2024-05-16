dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

edit_component_ultimate( entity_id, "VelocityComponent", function(comp,vars)
	local vel_x, vel_y = ComponentGetValueVector2( comp, "mVelocity" )
	
	local frame_num = GameGetFrameNum()
	if( get_magnitude( vel_x, vel_y ) < 0.01 ) then
		vel_y = random_sign( entity_id + x + y )
		vel_x, vel_y = vec_rotate( vel_x, vel_y, ProceduralRandomf( x, y + 12, math.pi*2 ))
	end
	
	local t = frame_num + entity_id*0.01
	local wobble = (( x%2 )^0.5 )/5 + math.sin( t*0.0394 )/5
	vel_x, vel_y = vec_rotate( vel_x, vel_y, random_sign( entity_id + x + y )*wobble )
	
	ComponentSetValueVector2( comp, "mVelocity", vel_x, vel_y )
	EntitySetTransform( entity_id, x + vel_x*2, y + vel_y*2 )
end)

GameCreateParticle( "necro_current", x, y - 2, 1, 0, 0, false )
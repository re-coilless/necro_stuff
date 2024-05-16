dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )

local range = 1000
local indicator_distance = 20
for i,id in pairs( add_table_old( EntityGetInRadiusWithTag( pos_x, pos_y, range, "item_pickup" ), EntityGetInRadiusWithTag( pos_x, pos_y, range, "item_physics" ))) do
	if( id == EntityGetRootEntity( id ) and not( EntityHasTag( id, "gold_nugget" ))) then
		local x, y = EntityGetTransform( id )
		local dir_x, dir_y = x - pos_x, y - pos_y
		local distance = get_magnitude( dir_x, dir_y )
		
		if( is_in_camera_bounds( x, y, -4 )) then
			y = y - 3
		else
			dir_x, dir_y = vec_normalize( dir_x, dir_y )
			x = pos_x + dir_x*indicator_distance
			y = pos_y + dir_y*indicator_distance
		end
		
		local tp = 3
		if( distance > range*0.5 ) then
			tp = 1
		elseif( distance > range*0.25 ) then
			tp = 2
		end
		GameCreateSpriteForXFrames( "mods/necro_stuff/files/gui/radar_item_"..tp..".png", x, y, true, 0, 0, 1, true )
	end
end

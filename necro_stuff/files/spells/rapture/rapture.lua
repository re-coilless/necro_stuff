dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local c_x, c_y = EntityGetTransform( GetUpdatedEntityID())
local wands = add_table_old( EntityGetInRadiusWithTag( c_x, c_y, 666, "wand" ) or {}, EntityGetInRadiusWithTag( c_x, c_y, 666, "custom_wand" ) or {} )
if( #wands > 0 ) then
	for i,wand_id in ipairs( wands ) do
		if( wand_id == EntityGetRootEntity( wand_id )) then
			local w_x, w_y = EntityGetTransform( wand_id )
			GamePickUpInventoryItem( EntityLoad( "mods/necro_stuff/files/spells/rapture/hallowed.xml", w_x, w_y ), wand_id, false )
		end
	end
end
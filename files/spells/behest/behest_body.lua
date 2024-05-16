dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
--if anchor is lost - go to hidden mode

local entity_id = GetUpdatedEntityID()
local link = ComponentGetValue2( get_storage_old( entity_id, "link" ), "value_int" )
local anchor_id = 0
local anchors = EntityGetWithTag( "behest_anchor" ) or {}
if( #anchors > 0 ) then
	for i,anchor in ipairs( anchors ) do
		if( ComponentGetValue2( get_storage_old( anchor, "link" ), "value_int" ) == link ) then
			anchor_id = anchor
			break
		end
	end
end

local x, y, r = EntityGetTransform( anchor_id )
EntitySetTransform( entity_id, x, y, r )
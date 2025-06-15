dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local item_id = GetUpdatedEntityID()
local i_x, i_y = EntityGetTransform( item_id )
local staff_id = EntityGetClosestWithTag( i_x, i_y, "necro_stuff" )
local s_x, s_y = EntityGetTransform( staff_id )
local hooman = EntityGetRootEntity( item_id )
local h_x, h_y = EntityGetTransform( hooman )

function arrow_killer( target )
	if( target ~= nil ) then
		local arrows = EntityGetWithTag( "article_arrow" ) or {}
		if( #arrows > 0 ) then
			for i,arw in ipairs( arrows ) do
				EntityKill( arw )
			end
		end
	end
end

if(( hooman ~= item_id ) and EntityHasTag( hooman, "weird_dude" )) then
	if( not( GameIsInventoryOpen())) then
		if( arrow == nil or not( EntityGetIsAlive( arrow ))) then
			arrow_killer( true )
			arrow = EntityLoad( "mods/necro_stuff/files/stuff/article_arrow.xml", i_x, i_y )
		end
		
		h_y = h_y - 7
		local min_dist = 100
		local pic_x, pic_y, pic_r = 0, 0, 0	
		local d_x, d_y = s_x - h_x, s_y - h_y
		local dist = math.sqrt( d_x^2 + d_y^2 )
		if( dist > min_dist ) then
			pic_r = math.atan2( d_y, d_x )
			min_dist = 30
			pic_x = h_x + math.cos( pic_r )*min_dist
			pic_y = h_y + math.sin( pic_r )*min_dist
			pic_r = pic_r + math.rad( 90 )
		else
			pic_x = s_x
			pic_y = s_y + 20
		end
		EntitySetTransform( arrow, pic_x, pic_y, pic_r )
	else
		arrow = arrow_killer( arrow )
	end
else
	arrow = arrow_killer( arrow )
end
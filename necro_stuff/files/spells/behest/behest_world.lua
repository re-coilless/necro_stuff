dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local actual_hooman = get_player()
local x, y = EntityGetTransform( entity_id )

local storage_picker = get_storage_old( entity_id, "gonna_pickup" )
local gonna_pickup = ComponentGetValue2( storage_picker, "value_bool" )
if( gonna_pickup ) then
	local storage_count = get_storage_old( entity_id, "count" )
	local count = ComponentGetValue2( storage_count, "value_int" )
	if( count < 4 ) then
		local wands = add_table_old( EntityGetInRadiusWithTag( x, y, 20, "wand" ) or {}, EntityGetInRadiusWithTag( x, y, 20, "custom_wand" ) or {} )
		if( #wands > 0 ) then
			for i,wand_id in ipairs( wands ) do
				if( count < 4 ) then
					if( wand_id == EntityGetRootEntity( wand_id ) and not( EntityHasTag( wand_id, "necro_stuff" ))) then
						if( pick_up_old( entity_id, wand_id ) ~= nil ) then
							count = count + 1
							ComponentSetValue2( storage_count, "value_int", count )
							EntityAddTag( wand_id, "behest_storage" )
						end
					end
				else
					break
				end
			end
		end
	end
end

if( actual_hooman ~= nil ) then
	local p_x, p_y = EntityGetTransform( actual_hooman )
	
	local dist = math.sqrt(( p_x - x )^2 + ( p_y - y )^2 )
	if( dist < 10 and not( GameIsInventoryOpen())) then
		if( gui == nil ) then
			gui = GuiCreate()
		end
		GuiStartFrame( gui )
		
		local clicked, r_clicked, hovered, pic_x, pic_y, pic_z = 0, 0, 0, 0, 0, 0
		local pic, pic_w, pic_h = 0, 0, 0
		local uid = 0
		
		local w, h = GuiGetScreenDimensions( gui )
		local cam_x, cam_y = GameGetCameraPos()
		local shit_from_ass = w/( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_X" ))
		
		pic_x = w/2 + shit_from_ass*( x - cam_x + 1 ) - 0.5
		pic_y = h/2 + shit_from_ass*( y - cam_y - 10 ) - 0.5
		
		local storage = {}
		local children = EntityGetAllChildren( entity_id ) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				if( EntityHasTag( child, "behest_storage" )) then
					table.insert( storage, child )
				end
			end
		end
		
		uid, clicked = new_button_old( gui, uid, pic_x - 8, pic_y - 7, -1, "mods/necro_stuff/files/gui/button_lock.png" )
		if( clicked ) then
			ComponentSetValue2( storage_picker, "value_bool", not( gonna_pickup ))
		end
		
		local offsets = { { -40, -5, }, { -14, -24, }, { 12, -5, }, { -14, 14, }, }
		for i = 1,4 do
			uid = new_window( gui, uid, pic_x + offsets[i][1], pic_y + offsets[i][2], -1, 30, 14 )
			
			if( storage[i] ~= nil ) then
				pic = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( storage[i], "AbilityComponent" ), "sprite_file" )
				if( pic ~= nil and pic ~= "" ) then
					pic = string.sub( pic, 1, string.len( pic ) - 3 ).."png"
					pic_w, pic_h = GuiGetImageDimensions( gui, pic, 1 )
					local new_scale = 28/pic_w
					if( pic_h*new_scale > 12 ) then
						new_scale = 12/pic_h
					end
					uid = new_image_old( gui, uid, pic_x + offsets[i][1] + ( 30 - pic_w*new_scale )/2, pic_y + offsets[i][2] + ( 14 - pic_h*new_scale )/2, -1.1, pic, new_scale, new_scale )
				end
				
				uid, clicked = new_button_old( gui, uid, pic_x + offsets[i][1], pic_y + offsets[i][2], -1.2, "mods/necro_stuff/files/gui/hitbox_wand.png" )
				if( clicked ) then
					drop_down( storage[i] )
					local storage_count = get_storage_old( entity_id, "count" )
					ComponentSetValue2( storage_count, "value_int", ComponentGetValue2( storage_count, "value_int" ) - 1 )
				end
			end
		end
	else
		gui = gui_killer_old( gui )
	end
end
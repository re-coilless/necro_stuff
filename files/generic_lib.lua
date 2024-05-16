dofile_once( "data/scripts/lib/utilities.lua" )

ai_comps = {
	"AIAttackComponent",
	"AdvancedFishAIComponent",
	"AnimalAIComponent",
	"BossDragonComponent",
	"ControllerGoombaAIComponent",
	"CrawlerAnimalComponent",
	"FishAIComponent",
	"PhysicsAIComponent",
	"WormAIComponent",
	"WormComponent",
}

function b2n_old( a )
	return a and 1 or 0
end

function t2l_old( str )
	local t = {}
	
	for line in string.gmatch( str, "([^\r\n]+)" ) do
		table.insert( t, line )
	end
	
	return t
end

function binsearch_old( tbl, value )
	local low = 1
	local high = #tbl
		
	while( high >= low ) do
		local middle = math.floor(( low + high )/2 + 0.5)
		if( tbl[middle] < value ) then
			low = middle + 1
		elseif( tbl[middle] > value ) then
			high = middle - 1
		elseif( tbl[middle] == value ) then
			return middle
		end
	end
	
	return nil
end

function magic_sorter_old( tbl, func )
    local out_tbl = {}
    for n in pairs( tbl ) do
        table.insert( out_tbl, n )
    end
    table.sort( out_tbl, func )
    local i = 0
    local iter = function ()
        i = i + 1
        if out_tbl[i] == nil then
            return nil
        else
            return out_tbl[i], tbl[out_tbl[i]]
        end
    end
    return iter
end

function add_table_old( a, b )
	if( #b > 0 ) then
		table.sort( b )
		if( #a > 0 ) then
			for m,new in ipairs( b ) do 
				if( binsearch_old( a, new ) == nil ) then
					table.insert( a, new )
				end
			end
			
			table.sort( a )
		else
			a = b
		end
	end
	
	return a
end

function is_fucked( value )
	return ( value ~= value or value == math.inf )
end

function limiter_old( value, limit, max_mode )
	max_mode = max_mode or false
	limit = math.abs( limit )

	if(( max_mode and math.abs( value ) < limit ) or ( not( max_mode ) and math.abs( value ) > limit )) then
		return get_sign_old( value )*limit
	end
	
	return value
end

function random_bool( var )
	SetRandomSeed( GameGetFrameNum(), var )
	return Random( 1, 2 ) == 1
end

function random_sign( var )
	return random_bool( var ) and 1 or -1
end

function D_extractor_old( data_raw, use_string )
	if( data_raw == nil ) then
		return nil
	end
	use_string = use_string or false
	
	local data = {}
	
	for value in string.gmatch( data_raw, "([^|]+)" ) do
		if( use_string ) then
			table.insert( data, value )
		else
			table.insert( data, tonumber( value ))
		end
	end
	
	return data
end

function D_packer_old( data )
	if( data == nil ) then
		return nil
	end

	local data_raw = "|"
	
	for i,value in ipairs( data ) do
		data_raw = data_raw..value.."|"
	end
	
	return data_raw
end

function get_unlocks( data_raw )
	if( data_raw == nil ) then
		return nil
	end
	
	local data = {}
	
	for value in string.gmatch( data_raw, "([^|]+)" ) do
		data[value] = true
	end
	
	return data
end

function get_player()
	local players = get_players()
	if( players ) then
		return players[1]
	end
	
	return nil
end

function get_action_with_id( action_id )
	dofile_once( "data/scripts/gun/gun_enums.lua")
	dofile_once( "data/scripts/gun/gun_actions.lua" )
	
	local action_data = nil
	for i,action in ipairs( actions ) do
		if( action.id == action_id ) then
			action_data = action
			break
		end
	end

	return action_data
end

function get_storage_old( hooman, name )
	local comps = EntityGetComponentIncludingDisabled( hooman, "VariableStorageComponent" ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( ComponentGetValue2( comp, "name" ) == name ) then
				return comp
			end
		end
	end
	
	return nil
end

function get_prey( c_x, c_y, r )
	local stuff = {}
	return add_table_old( add_table_old( stuff, EntityGetInRadiusWithTag( c_x, c_y, r, "enemy" ) or {} ), EntityGetInRadiusWithTag( c_x, c_y, r, "helpless_animal" ) or {} )
end

function get_hooman_child_old( hooman, tag, ignore_id )
	local children = EntityGetAllChildren( hooman ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			if( child ~= ignore_id and ( EntityGetName( child ) == tag or EntityHasTag( child, tag ))) then
				return child
			end
		end
	end
	
	return nil
end

function get_matter_old( matters, id )
	local max_matter = { 0, 0 }
	if( #matters > 0 ) then
		for i,matter in ipairs( matters ) do
			if( id ~= nil and id == i - 1 ) then
				return { id, matter }
			elseif( matter > max_matter[2] ) then
				max_matter[1] = i - 1
				max_matter[2] = matter
			end
		end
	end
	return max_matter
end

function get_sign_old( a )
	if( a > 0 ) then
		return 1
	else
		return -1
	end
end

function get_table_count_old( tbl )
	if( tbl == nil or type( tbl ) ~= "table" ) then
		return -1
	end
	
	local table_count = -1
	for i,element in pairs( tbl ) do
		table_count = table_count + 1
	end
	return table_count
end

function get_spawn_pos( x, y, size, min_radius, player_x, player_y )
	local step_a = size/2
	local step_b = 10
	local free = false
	local r = math.min( math.sqrt(( x - player_x )^2 + ( y - player_y )^2 ), min_radius*5 )
	local s_angle = math.atan2(( player_y - y ), ( player_x - x ))
	if( r < min_radius ) then
		r = min_radius
		s_angle = s_angle + math.rad( 180 )
	elseif( RaytracePlatforms( player_x, player_y, player_x, player_y )) then
		r = r + min_radius
	-- else
		-- local hit, pos_x, pos_y = RaytracePlatforms( player_x, player_y, x, y )
		-- if( hit ) then
			-- local length = math.sqrt(( pos_x -  player_x )^2 + ( pos_y - player_y )^2 )/2
			-- return pos_x - math.cos( s_angle )*length, pos_y - math.sin( s_angle )*length
		-- else
			-- return x, y
		-- end
	end
	local d_angle = math.rad( 180 ) - math.acos(( step_b^2 )/( 2*r^2 ) - 1 )
	local angle = s_angle
	while( math.abs( angle - s_angle ) < math.rad( 360 )) do
		local start_x, start_y = x + math.cos( angle )*r, y + math.sin( angle )*r
		local amount = r/step_a
		local d_x, d_y = ( start_x - x )/amount, ( start_y - y )/amount
		for i = 1,amount do
			local pos_x, pos_y = start_x - d_x*( i - 1 ), start_y - d_y*( i - 1 )
			local hit = RaytracePlatforms( pos_x, pos_y, pos_x - d_x, pos_y - d_y )
			-- GameCreateSpriteForXFrames( "mods/Noita40K/files/pics/gui_gfx/fillers/filler_solid_white.png", pos_x, pos_y, true, 0, 0, 1, true )
			if( hit ) then
				free = false
			else
				if( free ) then
					hit = RaytracePlatforms( pos_x, pos_y, pos_x - d_y, pos_y + d_x )
					-- GameCreateSpriteForXFrames( "mods/Noita40K/files/pics/gui_gfx/fillers/filler_solid_red_dark.png", pos_x - d_y, pos_y + d_x, true, 0, 0, 1, true )
					if( not( hit )) then
						hit = RaytracePlatforms( pos_x, pos_y, pos_x + d_y, pos_y - d_x )
						-- GameCreateSpriteForXFrames( "mods/Noita40K/files/pics/gui_gfx/fillers/filler_solid_gray.png", pos_x + d_y, pos_y - d_x, true, 0, 0, 1, true )
						if( not( hit )) then
							return pos_x, pos_y
						end
					end
					free = false
				else
					free = true
				end
			end
		end
		angle = angle - get_sign_old( player_x - x )*d_angle
	end
	
	return x, y
end

function update_gun( wand_id )
	local inv_comp = EntityGetFirstComponentIncludingDisabled( get_wand_owner_old( wand_id ), "Inventory2Component" )
	if( inv_comp ~= nil ) then
		ComponentSetValue2( inv_comp, "mActualActiveItem", 0 )
	end
end

function shoot_projectile_ultimate( who_shot, entity_file, x, y, v_x, v_y, do_thing, proj_mods, custom_values )
	do_thing = do_thing or true
	
	local entity_id = EntityLoad( entity_file, x, y )
	local herd_id = get_herd_id( who_shot )
	
	if( do_thing ) then
		GameShootProjectile( who_shot, x, y, x + v_x, y + v_y, entity_id, false )
	end
	
	edit_component( entity_id, "ProjectileComponent", function(comp,vars)
		vars.mWhoShot = who_shot
		vars.mShooterHerdId = herd_id
	end)
	
	edit_component( entity_id, "VelocityComponent", function(comp,vars)
		ComponentSetValueVector2( comp, "mVelocity", v_x, v_y )
	end)
	
	if( proj_mods ~= nil ) then
		proj_mods( entity_id, custom_values )
	end
	
	return entity_id
end

function too_smart_check( dude, c_value )
	local too_smart_check = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( dude, "DamageModelComponent" ), "hp" )*25
	if( math.abs( too_smart_check - c_value ) < 0.01 ) then
		GamePrintImportant( "[CRITICAL FAILURE]", "COLLAPSE IMMINENT" )
		local x, y = EntityGetTransform( dude )
		EntityLoad( "mods/necro_stuff/files/spells/fault/fault.xml", x, y )
		EntityKill( dude )
	end
end

function matter_fabricator( em_x, em_y, frames, values )
	values = values or {}
	local size = ( values[2] ~= nil and type( values[2] ) == "table" ) and values[2] or { 0, values[2] or 0.5, }
	local count = ( values[3] ~= nil and type( values[3] ) == "table" ) and values[3] or { values[3] or 1, values[3] or 1, }
	local delay = ( values[4] ~= nil and type( values[4] ) == "table" ) and values[4] or { values[4] or 1, values[4] or 1, }
	local lifetime = ( values[5] ~= nil and type( values[5] ) == "table" ) and values[5] or { values[5] or 60, values[5] or 60, }
	
	local mtrr = EntityCreateNew( "matterer" )
	EntitySetTransform( mtrr, em_x, em_y )
	
	local comp = EntityAddComponent( mtrr, "ParticleEmitterComponent", {
		emitted_material_name = values[1] or "blood",
		emission_interval_min_frames = delay[1],
		emission_interval_max_frames = delay[2],
		lifetime_min = lifetime[1],
		lifetime_max = lifetime[2],
		create_real_particles = b2n_old( values[6] or true ),
		emit_real_particles = b2n_old( values[7] or true ),
		emit_cosmetic_particles = b2n_old( values[8] or false ),
		render_on_grid = b2n_old( values[9] or true ),
	})
	ComponentSetValue2( comp, "count_min", count[1] )
	ComponentSetValue2( comp, "count_max", count[2] )
	if( #size < 4 ) then
		ComponentSetValue2( comp, "area_circle_radius", size[1] or 0.5, size[2] or 0.5 )
	else
		ComponentSetValue2( comp, "x_pos_offset_min", size[1] or 0 )
		ComponentSetValue2( comp, "y_pos_offset_min", size[2] or 0 )
		ComponentSetValue2( comp, "x_pos_offset_max", size[3] or 0 )
		ComponentSetValue2( comp, "y_pos_offset_max", size[4] or 0 )
	end
	
	if( frames ~= nil ) then
		EntityAddComponent( mtrr, "LifetimeComponent", {
			lifetime = frames,
		})
	end
end

function edit_component_ultimate( entity_id, type_name, do_what )
	if( entity_id == 0 or entity_id == nil ) then
		return
	end
	
	local comp = EntityGetFirstComponentIncludingDisabled( entity_id, type_name )
	if( comp ~= nil ) then
		local modified_vars = { }
		do_what( comp, modified_vars )
		for key,value in pairs( modified_vars ) do 
			ComponentSetValue( comp, key, to_string(value) )
		end
	end
end

function edit_component_with_tag_ultimate( entity_id, type_name, tag, do_what )
	if( entity_id == 0 or entity_id == nil ) then
		return
	end
	
	local comp = EntityGetFirstComponentIncludingDisabled( entity_id, type_name, tag )
	if( comp ~= nil ) then
		local modified_vars = { }
		do_what( comp, modified_vars )
		for key,value in pairs( modified_vars ) do 
			ComponentSetValue( comp, key, to_string(value) )
		end
	end
end

function world2gui_old( gui, x, y )
	local w, h = GuiGetScreenDimensions( gui )
	local cam_x, cam_y = GameGetCameraPos()
	local shit_from_ass = w/( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_X" ))
	
	return w/2 + shit_from_ass*( x - cam_x ), h/2 + shit_from_ass*( y - cam_y ), shit_from_ass
end

function get_mouse_pos_old( gui )
	local m_x, m_y = DEBUG_GetMouseWorld()
	return world2gui_old( gui, m_x, m_y )
end

function t2w_old( str )
	local t = {}
	
	for word in string.gmatch( str, "([^%s]+)" ) do
		table.insert( t, word )
	end
	
	return t
end

function world_2_inv( item_id )
	local itm_comp = EntityGetFirstComponentIncludingDisabled( item_id, "ItemComponent" )
	if( not( ComponentGetValue2( itm_comp, "has_been_picked_by_player" ))) then
		ComponentSetValue2( itm_comp, "has_been_picked_by_player", true )
		ComponentSetValue2( itm_comp, "play_hover_animation", false )
		ComponentSetValue2( itm_comp, "mFramePickedUp", GameGetFrameNum())
		ComponentSetValue2( itm_comp, "npc_next_frame_pickable", GameGetFrameNum() + 60 )
	end
	
	local comps = EntityGetAllComponents( item_id ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( ComponentHasTag( comp, "enabled_in_inventory" )) then
				EntitySetComponentIsEnabled( item_id, comp, true )
			else
				EntitySetComponentIsEnabled( item_id, comp, false )
			end
		end
	end
end

function inv_2_world( item_id )
	local itm_comp = EntityGetFirstComponentIncludingDisabled( item_id, "ItemComponent" )
	ComponentSetValue2( itm_comp, "npc_next_frame_pickable", GameGetFrameNum() + 60 )
	
	local comps = EntityGetAllComponents( item_id ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( ComponentHasTag( comp, "enabled_in_world" )) then
				EntitySetComponentIsEnabled( item_id, comp, true )
			else
				EntitySetComponentIsEnabled( item_id, comp, false )
			end
		end
	end
	
	EntityRemoveFromParent( item_id )
end

function pick_up_old( hooman, item_id, ignore_checks )
	ignore_checks = ignore_checks or false
	
	local itm_comp = EntityGetFirstComponentIncludingDisabled( item_id, "ItemComponent" )
	if( not( ignore_checks )) then
		if( itm_comp == nil or EntityGetFirstComponentIncludingDisabled( item_id, "ItemCostComponent", "shop_cost" ) ~= nil or ComponentGetValue2( itm_comp, "npc_next_frame_pickable" ) > GameGetFrameNum()) then
			return nil
		end
	end
	
	world_2_inv( item_id )
	
	local h_x, h_y = EntityGetTransform( hooman )
	local i_x, i_y, i_r, i_s_x, i_s_y = EntityGetTransform( item_id )
	EntitySetTransform( item_id, h_x, h_y, i_r, i_s_x, i_s_y )
	EntityAddChild( hooman, item_id )
	
	return item_id
end

function drop_down( item_id )
	if( EntityGetRootEntity( item_id ) == item_id ) then
		return nil
	end

	inv_2_world( item_id )
	local vel_comp = EntityGetFirstComponentIncludingDisabled( item_id, "VelocityComponent" )
	if( vel_comp ~= nil ) then
		ComponentSetValueVector2( vel_comp, "mVelocity", ( 1 - 2*( item_id%2 ))*20, -300 )
	end
	
	return item_id
end

function wand_is_useless_old( wand_id )
	local children = EntityGetAllChildren( wand_id ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			local itm_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemComponent" )
			if( itm_comp ~= nil ) then
				if( ComponentGetValue2( itm_comp, "uses_remaining" ) ~= 0 ) then
					return false
				end
			end
		end
	end
	return true
end

function is_organic( mttr_id )
	local org_stf = {
		{
			"cheese_static",
			"oil",
			"alcohol",
			"honey",
			"glue",
		},
		
		{
			"[slime]",
			"[food]",
			"[blood]",
			"[meat]",
			"[fungus]",
			"[plant]",
		},
	}
	
	local mttr_nm = CellFactory_GetName( mttr_id )
	for k,nm in ipairs( org_stf[1] ) do
		if( mttr_nm == nm ) then
			return true
		end
	end
	
	local mttr_tgs = CellFactory_GetTags( mttr_id )
	for e,mttr_tg in ipairs( mttr_tgs ) do
		for k,tg in ipairs( org_stf[2] ) do
			if( mttr_tg == tg ) then
				return true
			end
		end
	end
	
	return false
end

function get_active_wand_old( hooman )
	local inv_comp = EntityGetFirstComponentIncludingDisabled( hooman, "Inventory2Component" )
	if( inv_comp ~= nil ) then
		return tonumber( ComponentGetValue2( inv_comp, "mActiveItem" ) or 0 )
	end
	
	return 0
end

function get_wand_owner_old( wand_id )
	if( wand_id ~= nil ) then
		local root_man = EntityGetRootEntity( wand_id )
		local parent = wand_id
		while( parent ~= root_man ) do
			parent = EntityGetParent( parent )
			if( get_active_wand_old( parent ) == wand_id ) then
				return parent
			end
		end
	end
	
	return wand_id
end

function get_spell_id()
	local man = GetUpdatedEntityID()
	if( man ~= nil ) then
		local wand_id = get_active_wand_old( man )
		if( wand_id ~= 0 and current_action ~= nil and current_action.deck_index ~= nil ) then
			local index_offset = 1
			local spells = EntityGetAllChildren( wand_id ) or {}
			if( #spells > 0 ) then
				for i,spell_id in ipairs( spells ) do
					local item_comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemComponent" )
					if( item_comp ~= nil and ComponentGetValue2( item_comp, "permanently_attached" )) then
						index_offset = index_offset + 1
					end
				end
				return spells[ current_action.deck_index + index_offset ]
			end
		end
	end
	
	return nil
end

function package_entity( entity_id, go_deeper, ignore_tag )
	ignore_tag = ignore_tag or "<bruh>"
	
	local comps = EntityGetAllComponents( entity_id ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( not( EntityHasTag( entity_id, "player_unit" ) and ComponentGetTypeName( comp ) == "ControlsComponent" )) then
				if( not( ComponentHasTag( comp, ignore_tag )) and ComponentGetIsEnabled( comp )) then
					if( ComponentHasTag( comp, "enabled_in_world" )) then
						ComponentRemoveTag( comp, "enabled_in_world" )
						ComponentAddTag( comp, "_enabled_in_world" )
					end
					EntitySetComponentIsEnabled( entity_id, comp, false )
					ComponentAddTag( comp, "package_comp" )
				end
			end
		end
	end
	
	if( go_deeper ~= nil ) then
		local children = EntityGetAllChildren( entity_id ) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				package_entity( child, true, ignore_tag )
			end
		end
	end
end

function unpackage_entity( entity_id, go_deeper )
	local comps = EntityGetAllComponents( entity_id ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( ComponentHasTag( comp, "package_comp" )) then
				if( ComponentHasTag( comp, "_enabled_in_world" )) then
					ComponentRemoveTag( comp, "_enabled_in_world" )
					ComponentAddTag( comp, "enabled_in_world" )
				end
				EntitySetComponentIsEnabled( entity_id, comp, true )
				ComponentRemoveTag( comp, "package_comp" )
				
				if( ComponentGetTypeName( comp ) == "SpriteComponent" ) then
					EntityRefreshSprite( entity_id, comp )
				end
			end
		end
	end
	
	if( go_deeper ~= nil ) then
		local children = EntityGetAllChildren( entity_id ) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				unpackage_entity( child, true )
			end
		end
	end
end

function scale_emitter( hooman, emit_comp, advanced )
	advanced = advanced or false
	local borders = { 0, 0, 0, 0, }
	local gonna_update = false
	
	local sprite_comp = EntityGetFirstComponentIncludingDisabled( hooman, "SpriteComponent", "character" )
	local char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	if( advanced and sprite_comp ~= nil ) then
		local offset_x = ComponentGetValue2( sprite_comp, "offset_x" )
		local offset_y = ComponentGetValue2( sprite_comp, "offset_y" )
		
		if( char_comp ~= nil ) then
			local temp = {}
			temp[1] = ComponentGetValue2( char_comp, "collision_aabb_min_x" )
			temp[2] = ComponentGetValue2( char_comp, "collision_aabb_max_x" )
			temp[3] = ComponentGetValue2( char_comp, "collision_aabb_min_y" )
			temp[4] = ComponentGetValue2( char_comp, "collision_aabb_max_y" )
			
			local hitboxes = EntityGetComponentIncludingDisabled( hooman, "HitboxComponent" ) or {}
			if( #hitboxes > 0 ) then
				local h_temp = {}
				local max_area = 0
				for i,hb in ipairs( hitboxes ) do
					local ass = {}
					ass[1] = ComponentGetValue2( hb, "aabb_min_x" )
					ass[2] = ComponentGetValue2( hb, "aabb_max_x" )
					ass[3] = ComponentGetValue2( hb, "aabb_min_y" )
					ass[4] = ComponentGetValue2( hb, "aabb_max_y" )
					local area = math.abs(( ass[2] - ass[1] )*( ass[4] - ass[3] ))
					if( area > max_area ) then
						h_temp[1] = ass[1]
						h_temp[2] = ass[2]
						h_temp[3] = ass[3]
						h_temp[4] = ass[4]
						max_area = area
					end
				end
				
				temp[1] = ( temp[1] + 2*h_temp[1] )/3
				temp[2] = ( temp[2] + 2*h_temp[2] )/3
				temp[3] = ( temp[3] + 2*h_temp[3] )/3
				temp[4] = ( temp[4] + 2*h_temp[4] )/3
			end
			
			if( offset_x == 0 ) then
				offset_x = ( math.abs( temp[1] ) + math.abs( temp[2] ))/2
			end
			if( offset_y == 0 ) then
				offset_y = temp[3]
			end
			
			borders[1] = ( -offset_x + temp[1] )/2
			borders[2] = ( offset_x + temp[2] )/2
			borders[3] = ( -offset_y + temp[3] )/2
			borders[4] = ( offset_y + temp[3] )/2
		else
			if( offset_x == 0 ) then
				offset_x = 3
			end
			if( offset_y == 0 ) then
				offset_y = 3
			end
			borders[1] = -offset_x
			borders[2] = offset_x
			borders[3] = -offset_y
			borders[4] = offset_y*0.5
		end
		gonna_update = true
	elseif( char_comp ~= nil ) then
		borders[1] = ComponentGetValue2( char_comp, "collision_aabb_min_x" )
		borders[2] = ComponentGetValue2( char_comp, "collision_aabb_max_x" )
		borders[3] = ComponentGetValue2( char_comp, "collision_aabb_min_y" )
		borders[4] = ComponentGetValue2( char_comp, "collision_aabb_max_y" )
		gonna_update = true
	end
	
	if( gonna_update ) then
		ComponentSetValue2( emit_comp, "x_pos_offset_min", borders[1])
		ComponentSetValue2( emit_comp, "x_pos_offset_max", borders[2])
		ComponentSetValue2( emit_comp, "y_pos_offset_min", borders[3])
		ComponentSetValue2( emit_comp, "y_pos_offset_max", borders[4])
	end
end

function liner_old( gui, text, length, height, length_k, clean_mode, forced_reverse )
	local formated = {}
	if( text ~= nil and text ~= "" ) then
		local length_counter = 0
		if( height ~= nil ) then
			length_k = length_k or 6
			length = math.floor( length/length_k + 0.5 )
			height = math.floor( height/9 )
			local words = t2w_old( text )
			local height_counter = 1
			local rest = ""
			local buffer = ""
			local dont_touch = false
			text = ""
			
			for i,word in ipairs( words ) do
				buffer = word
				local w_length = string.len( buffer ) + 1
				length_counter = length_counter + w_length
				dont_touch = false
				
				if( length_counter > length or buffer == "@" ) then
					if( w_length >= length ) then
						rest = string.sub( buffer, length - ( length_counter - w_length - 1 ), w_length )
						text = text..buffer.." "
					else
						length_counter = w_length
					end
					table.insert( formated, tostring( string.gsub( string.sub( text, 1, length ), "@ ", "" )))
					height_counter = height_counter + 1
					text = ""
					while( rest ~= "" ) do
						w_length = string.len( rest ) + 1
						length_counter = w_length
						buffer = rest
						if( length_counter > length ) then
							rest = string.sub( rest, length + 1, w_length )
							table.insert( formated, tostring( string.sub( buffer, 1, length )))
							dont_touch = true
							height_counter = height_counter + 1
						else
							rest = ""
							length_counter = w_length
						end
						
						if( height_counter > height ) then
							break
						end
					end
				end
				
				if( height_counter > height ) then
					break
				end
				
				text = text..buffer.." "
			end
			
			if( not( dont_touch ) and text ~= "@ " ) then
				table.insert( formated, tostring( string.gsub( string.sub( text, 1, length ), "@", "" )))
			end
		else
			local starter = math.floor( math.abs( length )/7 + 0.5 )
			local total_length = string.len( text )
			if( starter < total_length ) then
				if( length > 0 and forced_reverse == nil ) then
					length = math.abs( length )
					formated = string.sub( text, 1, starter )
					for i = starter + 1,total_length do
						formated = formated..string.sub( text, i, i )
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 1, string.len( formated ) - 1 )
							break
						end
					end
				else
					length = math.abs( length )
					starter = total_length - starter
					formated = string.sub( text, starter, total_length )
					while starter > 0 do
						starter = starter - 1
						formated = string.sub( text, starter, starter )..formated
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 2, string.len( formated ))
							break
						end
					end
				end
			else
				formated = text
			end
		end
	else
		if( clean_mode == nil ) then
			table.insert( formated, "[NIL]" )
		else
			formated = ""
		end
	end
	
	return formated
end

function colourer_old( gui, c_type )
	local color = { r = 0, g = 0, b = 0 }
	if( type( c_type ) == "table" ) then
		color.r = c_type[1]
		color.g = c_type[2]
		color.b = c_type[3]
	else
		if( c_type == nil or c_type == 1 ) then
			color.r = 168
			color.g = 202
			color.b = 88
		elseif( c_type == 2 ) then
			color.r = 207
			color.g = 87
			color.b = 60
		elseif( c_type == 3 ) then
			color.r = 32
			color.g = 46
			color.b = 55
		end
	end
	
	GuiColorSetForNextWidget( gui, color.r/255, color.g/255, color.b/255, 1 )
end

function gui_killer_old( gui )
	if( gui ~= nil ) then
		GuiDestroy( gui )
	end
end

function rgb2hsv( colour )
	local r, g, b, a = colour[1], colour[2], colour[3], colour[4]

	local h = 0
	local s = 0
	local v = math.max( r, g, b )
	local temp = math.min( r, g, b )

	local d = v - temp
	if( v == 0 ) then
		s = 0
	else
		s = d/v
	end
	
	if( v == temp ) then
		h = 0
	else
		if( v == r ) then
			h = ( g - b )/d
			if( g < b ) then
				h = h + 6
			end
		elseif( v == g ) then
			h = ( b - r )/d + 2
		elseif( v == b ) then
			h = ( r - g )/d + 4
		end
		h = h/6
	end
	
	return { h, s, v, a }
end

function hsv2rgb( colour )
	local h, s, v, a = colour[1], colour[2], colour[3], colour[4]
	local r, g, b = 0, 0, 0
	
	local i = math.floor( h*6 )
	local f = h*6 - i
	local p = v*( 1 - s )
	local q = v*( 1 - f*s )
	local t = v*( 1 - ( 1 - f )*s )
	
	i = i%6
	if( i == 0 ) then
		r, g, b = v, t, p
	elseif( i == 1 ) then
		r, g, b = q, v, p
	elseif( i == 2 ) then
		r, g, b = p, v, t
	elseif( i == 3 ) then
		r, g, b = p, q, v
	elseif( i == 4 ) then
		r, g, b = t, p, v
	elseif( i == 5 ) then
		r, g, b = v, p, q
	end
	
	return { r, g, b, a }
end

function new_blinker( gui, colour, freq, amp )
	colour = rgb2hsv( colour )
	local fancy_index = math.abs( math.cos( GameGetFrameNum()*( freq or 0.1 )))*( amp or 1 )
	colour = hsv2rgb( { colour[1], fancy_index*colour[2], math.max( colour[3], ( 1 - fancy_index )), colour[4] } )
	GuiColorSetForNextWidget( gui, colour[1], colour[2], colour[3], colour[4] )
end

function new_text_old( gui, pic_x, pic_y, pic_z, text, colours )
	local out_str = {}
	if( text ~= nil ) then
		if( type( text ) == "table" ) then
			out_str = text
		else
			table.insert( out_str, text )
		end
	else
		table.insert( out_str, "[NIL]" )
	end
	
	for i,line in ipairs( out_str ) do
		colourer_old( gui, colours or 1 )
		GuiZSetForNextWidget( gui, pic_z )
		GuiText( gui, pic_x, pic_y, line )
		pic_y = pic_y + 9
	end
end

function new_image_old( gui, uid, pic_x, pic_y, pic_z, pic, s_x, s_y, alpha, interactive )
	if( s_x == nil ) then
		s_x = 1
	end
	if( s_y == nil ) then
		s_y = 1
	end
	if( alpha == nil ) then
		alpha = 1
	end
	if( interactive == nil ) then
		interactive = false
	end
	
	if( not( interactive )) then
		GuiOptionsAddForNextWidget( gui, 2 ) --NonInteractive
	end
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiImage( gui, uid, pic_x, pic_y, pic, alpha, s_x, s_y )
	return uid
end

function new_button_old( gui, uid, pic_x, pic_y, pic_z, pic )
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiOptionsAddForNextWidget( gui, 6 ) --NoPositionTween
	GuiOptionsAddForNextWidget( gui, 4 ) --ClickCancelsDoubleClick
	GuiOptionsAddForNextWidget( gui, 21 ) --DrawNoHoverAnimation
	GuiOptionsAddForNextWidget( gui, 47 ) --NoSound
	local clicked, r_clicked = GuiImageButton( gui, uid, pic_x, pic_y, "", pic )
	return uid, clicked, r_clicked
end

function new_tooltip_old( gui, uid, pic_z, text, extra_text, custom_func, custom_params )
	-- if( not( tooltip_opened )) then
		local _, _, t_hov = GuiGetPreviousWidgetInfo( gui )
		if( t_hov ) then
			-- tooltip_opened = true
			local w, h = GuiGetScreenDimensions( gui )
			local pic_x, pic_y = get_mouse_pos_old( gui )
			local length, x_offset, y_offset = 0, 0, 0
			
			if( text ~= nil ) then
				pic_x = pic_x + 10
				
				if( text == "" ) then
					return uid
				end
				local temp_text = ( extra_text ~= nil ) and text..( text ~= "" and " @ " or "" )..extra_text.." @" or text
				
				temp_text = liner_old( gui, temp_text, w*0.9, h - 2, 5.8 )
				extra_text = {}
				local extra_start = #liner_old( gui, text, w*0.9, h - 2, 5.8 )
				for i,line in ipairs( temp_text ) do
					local current_length = GuiGetTextDimensions( gui, line, 1, 2 )
					if( current_length > length ) then
						length = current_length
					end
					if( i > extra_start ) then
						table.insert( extra_text, line )
					end
				end
				x_offset = length
				y_offset = 9*#temp_text + 1
				if( w < pic_x + x_offset ) then
					pic_x = w - x_offset
				end
				if( h < pic_y + y_offset ) then
					pic_y = h - y_offset
				end
			end
			
			pic_z = pic_z or -100
			if( custom_func ~= nil ) then
				uid = custom_func( gui, uid, pic_z, pic_x, pic_y, custom_params )
			else
				uid = new_window( gui, uid, pic_x, pic_y, pic_z + 0.01, x_offset + 1, y_offset )
				new_text_old( gui, pic_x + 2, pic_y, pic_z, liner_old( gui, text, w*0.9, h - 2, 5.8 ))
				if( #extra_text > 0 ) then
					local _, _, _, l_x, l_y = GuiGetPreviousWidgetInfo( gui )
					new_text_old( gui, pic_x + 2, l_y + 9, pic_z, extra_text, 2 )
				end
			end
		end
	-- end
	
	return uid
end

function new_bar( gui, uid, pic_x, pic_y, pic_z, max_amount, length, current_amount, style )
	orientation = "horizontal"
	style = orientation.."_"..( style or "necro" )
	
	uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_start.png" )
	local l = math.max( length - 15, 1 )
	uid = new_image_old( gui, uid, pic_x + 6, pic_y, pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_filler.png", l, 1 )
	uid = new_image_old( gui, uid, pic_x + 6 + l, pic_y, pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_end.png" )
	
	pic_x = pic_x + 1
	pic_z = pic_z - 0.01
	local amount = math.min( math.ceil( current_amount/max_amount*length ), length )
	if( amount > 0 ) then
		local normal_l = 0
		for i = 1,amount do
			local gonna_draw = true
			local pic = "mods/necro_stuff/files/gui/bar/"..style
			if( i < 5 ) then
				pic = pic.."_"..i
			elseif( i > length - 4 ) then
				pic = pic.."_"..( length - i + 1 )
			elseif( i == length - 10 ) then
				pic = pic.."_5"
			elseif( i > length - 9 and i < length - 5 ) then
				pic = pic.."_6"
			elseif( i ~= amount ) then
				gonna_draw = false
				normal_l = normal_l + 1
			end
			
			if( gonna_draw ) then
				if( normal_l ~= 0 ) then
					uid = new_image_old( gui, uid, pic_x + i - normal_l, pic_y, pic_z, "mods/necro_stuff/files/gui/bar/"..style..".png", normal_l, 1 )
					normal_l = 0
				end
				
				uid = new_image_old( gui, uid, pic_x + i, pic_y, pic_z, pic..( i == amount and "_special" or "" )..".png" )
			end
		end
	end
	
	return uid
end

function new_column( gui, uid, pic_x, pic_y, pic_z, max_amount, length, current_amount, style )
	orientation = "vertical"
	style = orientation.."_"..( style or "necro" )
	
	pic_y = pic_y - 9
	uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_start.png" )
	local l = math.max( length - 18, 1 )
	uid = new_image_old( gui, uid, pic_x, pic_y - l, pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_filler.png", 1, l )
	uid = new_image_old( gui, uid, pic_x, pic_y - ( 14 + l ), pic_z, "mods/necro_stuff/files/gui/bar/"..orientation.."_end.png" )
	
	pic_y = pic_y + 7
	pic_z = pic_z - 0.01
	local amount = math.min( math.ceil( current_amount/max_amount*length ), length )
	if( amount > 0 ) then
		local normal_l = 0
		for i = 1,amount do
			local gonna_draw = true
			local pic = "mods/necro_stuff/files/gui/bar/"..style
			if( i < 8 ) then
				pic = pic.."_"..i
			elseif( i > length - 2 ) then
				pic = pic.."_"..( 1 - ( length - i ))
			elseif( i == length - 4 ) then
				pic = pic.."_5"
			elseif( i == length - 10 ) then
				pic = pic.."_8"
			elseif( i > length - 9 and i < length - 5 ) then
				pic = pic.."_9"
			elseif( i ~= amount ) then
				gonna_draw = false
				normal_l = normal_l + 1
			end
			
			if( gonna_draw ) then
				if( normal_l ~= 0 ) then
					uid = new_image_old( gui, uid, pic_x, pic_y - i + 1, pic_z, "mods/necro_stuff/files/gui/bar/"..style..".png", 1, normal_l )
					normal_l = 0
				end
				
				uid = new_image_old( gui, uid, pic_x, pic_y - i, pic_z, pic..( i == amount and "_special" or "" )..".png" )
			end
		end
	end
	
	return uid
end

function new_counter( gui, uid, pic_x, pic_y, pic_z, count, limit )
	count = string.sub( tostring( math.min(( 10^limit - 1 ), math.floor( count )) + 10^limit ), -limit )
	
	for ltr in string.gmatch( count, "." ) do
		local pic = "mods/necro_stuff/files/gui/nums/"..ltr..".png"
		uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, pic )
		local pic_w, pic_h = GuiGetImageDimensions( gui, pic, 1 )
		pic_x = pic_x + pic_w + 1
	end

	return uid
end

function new_selector( gui, uid, pic_x, pic_y, pic_z, container, current )
	local elements = container.contents
	
	local clicked, new = 0, current
	local left = ( current - 1 < 1 ) and #elements or ( current - 1 )
	local right = ( current + 1 > #elements ) and 1 or ( current + 1 )
	uid, clicked = new_button_old( gui, uid, pic_x - 17, pic_y, pic_z, elements[left].pic.."_l.png" )
	if( clicked ) then
		new = left
	end
	uid, clicked = new_button_old( gui, uid, pic_x + 17, pic_y, pic_z, elements[right].pic.."_r.png" )
	if( clicked ) then
		new = right
	end
	
	uid = new_button_old( gui, uid, pic_x, pic_y, pic_z, elements[current].pic..".png" )
	
	return uid, new
end

function new_window( gui, uid, pic_x, pic_y, pic_z, width, height, mirrored, special, main_style )
	mirrored = mirrored or false
	main_style = main_style or "A"
	special = ( special == nil ) and "A" or ( special and "C" or "B" )
	
	uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, "mods/necro_stuff/files/gui/window/filler_dark.png", width, height )
	uid = new_image_old( gui, uid, pic_x + 1, pic_y - 1, pic_z, "mods/necro_stuff/files/gui/window/filler_bright.png", width - 2, 1 )
	uid = new_image_old( gui, uid, pic_x - 1, pic_y + 1, pic_z, "mods/necro_stuff/files/gui/window/filler_bright.png", 1, height - 2 )
	uid = new_image_old( gui, uid, pic_x + width, pic_y + 1, pic_z, "mods/necro_stuff/files/gui/window/filler_bright.png", 1, height - 2 )
	uid = new_image_old( gui, uid, pic_x + 1, pic_y + height, pic_z, "mods/necro_stuff/files/gui/window/filler_bright.png", width - 2, 1 )
	
	pic_z = pic_z - 0.01
	uid = new_image_old( gui, uid, pic_x - 2, pic_y - 2, pic_z, "mods/necro_stuff/files/gui/window/module_"..( mirrored and special or main_style ).."_1.png" )
	uid = new_image_old( gui, uid, pic_x + width - 2, pic_y - 2, pic_z, "mods/necro_stuff/files/gui/window/module_"..( mirrored and main_style or special ).."_2.png" )
	uid = new_image_old( gui, uid, pic_x + width - 2, pic_y + height - 2, pic_z, "mods/necro_stuff/files/gui/window/module_"..( mirrored and main_style or special ).."_3.png" )
	uid = new_image_old( gui, uid, pic_x - 2, pic_y + height - 2, pic_z, "mods/necro_stuff/files/gui/window/module_"..( mirrored and special or main_style ).."_4.png" )
	
	return uid
end

function new_anim( gui, uid, auid, pic_x, pic_y, pic_z, path, amount, delay, s_x, s_y, alpha, interactive )
	anims_state = anims_state or {}
	anims_state[auid] = anims_state[auid] or { 1, 0 }
	
	new_image_old( gui, uid, pic_x, pic_y, pic_z, path..anims_state[auid][1]..".png", s_x, s_y, alpha, interactive )
	
	anims_state[auid][2] = anims_state[auid][2] + 1
	if( anims_state[auid][2] > delay ) then
		anims_state[auid][2] = 0
		anims_state[auid][1] = anims_state[auid][1] + 1
		if( anims_state[auid][1] > amount ) then
			anims_state[auid][1] = 1
		end
	end
	
	return uid
end

function new_connector( target_id, x, y, fancy_name, duration )
	fancy_name = fancy_name or "necro_current"
	duration = duration or 5
	
	local connector = EntityLoad( "mods/necro_stuff/files/stuff/connector.xml", x, y )
	edit_component_ultimate( connector, "VariableStorageComponent", function(comp,vars) 
		ComponentSetValue2( comp, "value_int", tonumber( target_id ))
	end)
	edit_component_ultimate( connector, "LifetimeComponent", function(comp,vars) 
		ComponentSetValue2( comp, "lifetime", duration )
	end)
	local children = EntityGetAllChildren( connector )
	if( #children > 0 ) then
		for i,fx_entity in pairs( children ) do
			edit_component_ultimate( fx_entity, "ParticleEmitterComponent", function(comp,vars) 
				ComponentSetValue2( comp, "emitted_material_name", fancy_name )
			end)
		end
	end
	
	return connector
end

function is_sentient( entity_id )
	if( EntityHasTag( entity_id, "player_unit" )) then
		return true
	elseif( EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" ) ~= nil ) then
		for i,comp in ipairs( ai_comps ) do
			if( EntityGetFirstComponentIncludingDisabled( entity_id, comp ) or 0 ~= 0 ) then
				return true
			end
		end
	end
	
	return false
end

function get_necro_current( enemy_id )
	local damage_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "DamageModelComponent" )
	local gene_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "GenomeDataComponent" )
	
	if( EntityGetRootEntity( enemy_id ) ~= enemy_id ) then
		return 0
	elseif( damage_comp == nil or gene_comp == nil ) then
		return 0
	end
	
	local hp = EntityHasTag( enemy_id, "sigil_of_sin" ) and ComponentGetValue2( damage_comp, "max_hp" ) or ComponentGetValue2( damage_comp, "hp" )
	local supremacy = ComponentGetValue2( gene_comp, "food_chain_rank" )
	
	local vulnerability = 0
	local armor_types = { "curse", "drill", "electricity", "explosion", "fire", "ice", "melee", "overeating", "physics_hit", "poison", "projectile", "radioactive", "slice", }
	for i = 1,#armor_types do
		vulnerability = vulnerability + ComponentObjectGetValue2( damage_comp, "damage_multipliers", armor_types[i] )
	end
	
	local violence = 0
	local animal_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "AnimalAIComponent" )
	if( animal_comp ~= nil ) then
		if( ComponentGetValue2( animal_comp, "attack_melee_enabled" )) then
			violence = violence + ( ComponentGetValue2( animal_comp, "attack_melee_damage_min" ) + ComponentGetValue2( animal_comp, "attack_melee_damage_max" ))/2
		end
		if( ComponentGetValue2( animal_comp, "attack_ranged_enabled" )) then
			violence = violence + math.min(( ComponentGetValue2( animal_comp, "attack_ranged_min_distance" ) + ComponentGetValue2( animal_comp, "attack_ranged_max_distance" ))/2, 500 )/200
			violence = violence + 5/math.max( ComponentGetValue2( animal_comp, "attack_ranged_frames_between" ), 1 )
			violence = violence*( 1 + 0.5*b2n_old( ComponentGetValue2( animal_comp, "attack_ranged_predict" )))
		end
	end
	if( EntityHasTag( enemy_id, "boss" ) or EntityHasTag( enemy_id, "miniboss" )) then
		violence = violence + 5
	end
	
	local overall_speed = 0
	local platform_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "CharacterPlatformingComponent" )
	local path_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "PathFindingComponent" )
	if( platform_comp ~= nil and path_comp ~= nil ) then
		if( ComponentGetValue2( path_comp, "can_walk" )) then
			overall_speed = overall_speed + ComponentGetValue2( platform_comp, "run_velocity" )
			if( ComponentGetValue2( path_comp, "can_fly" )) then
				overall_speed = overall_speed + math.max( ComponentGetValue2( platform_comp, "fly_velocity_x" )/5, 10 )
			end
		elseif( ComponentGetValue2( path_comp, "can_fly" )) then
			overall_speed = overall_speed + ComponentGetValue2( platform_comp, "fly_velocity_x" ) + 20
		end
	end
	local fish_comp = EntityGetFirstComponentIncludingDisabled( enemy_id, "AdvancedFishAIComponent" ) or EntityGetFirstComponentIncludingDisabled( enemy_id, "FishAIComponent" )
	if( overall_speed == 0 and fish_comp ~= nil and EntityHasTag( enemy_id, "helpless_animal" )) then
		overall_speed = 300
	end
	
	--hamis at 20m is ~1
	local f_distance = 1 + 4/2^( 20/10 )
	local f_speed = ( overall_speed + 0.01 )/10
	local f_vulner = 0.77 + ( 3 - 0.26 )/( 1 + ( vulnerability/5 )^2.9 )
	local f_supremacy = math.min( supremacy, 20 )/20
	local f_violence = violence*10
	local f_hp = hp*25
	
	local main = f_distance*f_speed*f_vulner*f_hp
	local final_value = 0.25*( 0.08*( main - ( main > f_supremacy and f_supremacy or 0 )) + f_violence )
	return is_fucked( final_value ) and 0 or final_value
end

function wand_rater( wand_id, shuffle, can_reload, capacity, reload_time, cast_delay, mana_max, mana_charge, spell_cast, spread )
	local abil_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "AbilityComponent" )
	
	if( shuffle == nil ) then
		shuffle = b2n_old( ComponentObjectGetValue2( abil_comp, "gun_config", "shuffle_deck_when_empty" ))
	end
	if( can_reload == nil ) then
		can_reload = not( ComponentGetValue2( abil_comp, "never_reload" ))
	end
	if( capacity == nil ) then
		capacity = ComponentObjectGetValue2( abil_comp, "gun_config", "deck_capacity" )
	end
	
	if( reload_time == nil ) then
		reload_time = ComponentObjectGetValue2( abil_comp, "gun_config", "reload_time" )
	end
	if( cast_delay == nil ) then
		cast_delay = ComponentObjectGetValue2( abil_comp, "gunaction_config", "fire_rate_wait" )
	end
	
	if( mana_max == nil ) then
		mana_max = ComponentGetValue2( abil_comp, "mana_max" )
	end
	if( mana_charge == nil ) then
		mana_charge = ComponentGetValue2( abil_comp, "mana_charge_speed" )
	end
	
	if( spell_cast == nil ) then
		spell_cast = ComponentObjectGetValue2( abil_comp, "gun_config", "actions_per_round" )
	end
	if( spread == nil ) then
		spread = ComponentObjectGetValue2( abil_comp, "gunaction_config", "spread_degrees" )
	end
	
	--sollex is 1
	local f_shuffle = 1 - 0.7*shuffle
	local f_reloading = 2
	if( can_reload ) then
		f_reloading = 2 - ( 0.044/0.024 )*( 1 - math.exp( -0.024*reload_time ))
	end
	local f_capacity = 3.47 + ( 0.05 - 3.47 )/( 1 + (( capacity + 3 )/13.67 )^3.05 )
	local f_delay = 2 - ( 0.044/0.024 )*( 1 - math.exp( -0.024*cast_delay ))
	local f_mana_max = 1.5 + ( 0.06 - 1.5 )/( 1 + ( mana_max/6074441 )^1.416 )^237023
	local f_mana_charge = 3.41 + ( 0.07 - 3.41 )/( 1 + ( mana_charge/14641850 )^1.314 )^251693
	local f_multi = 2.58 + ( 1.017 - 2.58 )/( 1 + ( spell_cast/48023 )^1.63 )^983676
	local f_spread = math.rad( 45 - spread )
	
	local final_value = 1500*f_delay*f_reloading*f_mana_max*f_mana_charge*math.sqrt( f_spread*f_multi )*f_shuffle*f_capacity^1.5
	return is_fucked( final_value ) and 0 or final_value
end

function spell_rater( spell_id )
	if( spell_id == nil or spell_id == "" ) then
		return 0	
	end
	
	local t_item_comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemComponent" )
	local t_act_comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemActionComponent" )
	local action_data = get_action_with_id( ComponentGetValue2( t_act_comp, "action_id" ))
	if( action_data == nil ) then
		return 0
	end
	
	local price = action_data.price
	local uses_max = action_data.max_uses or -1
	local mana = math.abs( action_data.mana or 0 )
	local is_perma = b2n_old( ComponentGetValue2( t_item_comp, "permanently_attached" ))
	local uses_left = ComponentGetValue2( t_item_comp, "uses_remaining" )
	
	--sparkbolt is 1
	local f_perma = 1 + 4*is_perma
	local f_price = price/100
	local f_uses = uses_left/uses_max
	if( uses_left < 0 and uses_max > 0 ) then
		f_uses = 2
	end
	local f_mana = 5.4 + ( 0.1 - 5.4 )/( 1 + ( mana/8420.3 )^0.367 )
	
	local final_value = 2.5*f_perma*f_price*f_uses*f_mana
	return is_fucked( final_value ) and 0 or final_value
end

function get_proj_threat( hooman, projectile_id )
	if( EntityGetRootEntity( projectile_id ) ~= projectile_id ) then
		return 0
	end
	
	local proj_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "ProjectileComponent" )
	local char_x, char_y = EntityGetTransform( hooman )
	local proj_x, proj_y = EntityGetTransform( projectile_id )
	
	local proj_vel_x, proj_vel_y = GameGetVelocityCompVelocity( projectile_id )
	local char_vel_x, char_vel_y = GameGetVelocityCompVelocity( hooman )
	local proj_v = math.sqrt( ( char_vel_x - proj_vel_x )^2 + ( char_vel_y - proj_vel_y )^2 )
	
	local d_x = proj_x - char_x
	local d_y = proj_y - char_y
	local direction = math.abs( math.rad( 180 ) - math.abs( math.atan2( proj_vel_x, proj_vel_y ) - math.atan2( d_x, d_y )))
	local distance = math.sqrt(( d_x )^2 + ( d_y )^ 2 )
	
	local is_real = b2n_old( ComponentGetValue2( proj_comp, "collide_with_entities" ))
	local lifetime = ComponentGetValue2( proj_comp, "lifetime" )
	if( lifetime < 2 and lifetime > -1 ) then
		lifetime = 1
	end
	
	local total_damage = 0
	local damage_types = { "curse", "drill", "electricity", "explosion", "fire", "ice", "melee", "overeating", "physics_hit", "poison", "projectile", "radioactive", "slice", }
	for i = 1,#damage_types do
		local dmg = ComponentObjectGetValue2( proj_comp, "damage_by_type", damage_types[i] )
		if( dmg > 0 ) then
			total_damage = total_damage + dmg
		end
	end
	total_damage = total_damage + ComponentGetValue2( proj_comp, "damage" )
	
	local explosion_dmg = ComponentObjectGetValue2( proj_comp, "config_explosion", "damage" )
	local explosion_rad = ComponentObjectGetValue2( proj_comp, "config_explosion", "explosion_radius" )
	if( explosion_dmg > 0 ) then
		explosion_dmg = explosion_dmg + explosion_rad/25
		
		if( distance <= explosion_rad ) then
			explosion_dmg = explosion_dmg + ( explosion_rad - distance + 1 )/25
		end
	end
	total_damage = total_damage + explosion_dmg
	
	--sparkbolt at 20m is ~1
	local f_distance = 1 + 4/2^( distance/10 )
	local f_direction = 0.02 + 1.08/2^( direction/0.6 )
	local f_velocity = 0.1847 + ( 1 - math.exp( -0.0021*proj_v ))
	local f_lifetime = ( 1.8*( lifetime - 1 )/lifetime + 0.3 )/2
	local f_is_real = 0.5 + 0.5*is_real
	local f_damage = total_damage*25
	
	local final_value = 0.15*f_distance*f_direction*f_lifetime*f_is_real*f_velocity*f_damage
	return is_fucked( final_value ) and 0 or final_value
end
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local wand_id = EntityGetParent( entity_id )
local x, y = EntityGetTransform( entity_id )
if( ComponentGetValue2( get_storage_old( entity_id, "count" ), "value_int" ) > 0 ) then
	local anchor_id = get_hooman_child_old( entity_id, "behest_anchor" )
	local storage_link = get_storage_old( anchor_id, "link" )
	local anchor_link = ComponentGetValue2( storage_link, "value_int" )
	local body_id = 0
	if( anchor_link == 0 ) then
		anchor_link = tonumber( anchor_id + entity_id )
		ComponentSetValue2( storage_link, "value_int", anchor_link )
	else
		local bodies = EntityGetWithTag( "behest_body" ) or {}
		if( #bodies > 0 ) then
			for i,body in ipairs( bodies ) do
				if( ComponentGetValue2( get_storage_old( body, "link" ), "value_int" ) == anchor_link ) then
					body_id = body
					break
				end
			end
		end
	end
	if( body_id == 0 ) then
		body_id = EntityLoad( "mods/necro_stuff/files/spells/behest/behest_body.xml", x, y )
		ComponentSetValue2( get_storage_old( body_id, "link" ), "value_int", anchor_link )
	end
	
	local storage_active = get_storage_old( entity_id, "is_active" )
	local activated = ComponentGetValue2( storage_active, "value_bool" )
	if(( EntityHasTag( wand_id, "wand" ) or EntityHasTag( wand, "custom_wand" )) and get_wand_owner_old( wand_id ) ~= wand_id ) then
		if( not( activated )) then
			ComponentSetValue2( storage_active, "value_bool", true )
			
			function animate( entity, index )
				EntityAddTag( entity, "behest_orbit" )
				EntityRemoveTag( entity, "behest_storage" )
				
				inv_2_world( entity )
				ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( entity, "ItemComponent" ), "npc_next_frame_pickable", 1 )
				
				local brain = EntityLoad( "mods/necro_stuff/files/spells/behest/behest_brain.xml", x, y )
				ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( brain, "InheritTransformComponent" ), "parent_hotspot_tag", "pos"..index )
				GamePickUpInventoryItem( brain, entity, false )
				EntityAddChild( body_id, brain )
			end
			
			local children = EntityGetAllChildren( entity_id ) or {}
			if( #children > 0 ) then
				local counter = 1
				for i,child in ipairs( children ) do
					if( EntityHasTag( child, "behest_storage" ) and not( wand_is_useless_old( child ))) then
						animate( child, counter )
						counter = counter + 1
					end
				end
			end
		end
		
		local orbit = {}
		local children = EntityGetAllChildren( body_id ) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				if( EntityHasTag( child, "behest_brain" )) then
					table.insert( orbit, { child, get_active_wand_old( child )})
				end
			end
		end
		
		if( #orbit > 0 ) then
			local h_x, h_y, h_r, h_s_x, h_s_y = EntityGetTransform( EntityGetRootEntity( entity_id ))
			
			local hot_comps = EntityGetComponentIncludingDisabled( body_id, "HotspotComponent", "behest" ) or {}
			if( #hot_comps > 0 ) then
				for i,hot_comp in ipairs( hot_comps ) do
					local enabled = ComponentGetIsEnabled( hot_comp )
					local off_x, off_y = ComponentGetValueVector2( hot_comp, "offset" )
					if(( get_sign_old( h_s_x ) > 0 and not( enabled )) or ( get_sign_old( h_s_x ) < 0 and enabled )) then
						ComponentSetValueVector2( hot_comp, "offset", off_x, -off_y )
						EntitySetComponentIsEnabled( body_id, hot_comp, not( enabled ))
					end
				end
			end
			
			for i,dud in ipairs( orbit ) do
				local b_x, b_y, b_r, b_s_x, b_s_y = EntityGetTransform( dud[1] )
				local ctrl_comp = EntityGetFirstComponentIncludingDisabled( dud[1], "ControlsComponent" )
				local brained = ComponentGetValue2( ctrl_comp, "enabled" )
				if( get_sign_old( b_s_x ) ~= get_sign_old( h_s_x )) then
					if( not( brained )) then
						ComponentSetValue2( ctrl_comp, "enabled", true )
					end
				elseif( brained ) then
					ComponentSetValue2( ctrl_comp, "enabled", false )
					ComponentSetValue2( ctrl_comp, "mButtonDownFire", false )
					ComponentSetValue2( ctrl_comp, "mButtonDownFire2", false )
				end
			end
		end
	elseif( activated ) then
		ComponentSetValue2( storage_active, "value_bool", false )
		
		function inanimate( entity )
			local wand = get_active_wand_old( entity )
			GameDropAllItems( entity )
			pick_up_old( entity_id, wand, true )
			EntityKill( entity )
			
			EntityAddTag( wand, "behest_storage" )
			EntityRemoveTag( wand, "behest_orbit" )
		end
		
		local children = EntityGetAllChildren( body_id ) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				if( EntityHasTag( child, "behest_brain" )) then
					inanimate( child )
				end
			end
		end
	end
end
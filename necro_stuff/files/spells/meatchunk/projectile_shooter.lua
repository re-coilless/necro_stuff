dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( entity_id )

if( hooman ~= entity_id ) then
	local storage_extra = get_storage_old( entity_id, "extra_stuff" )
	local storage_shot = get_storage_old( entity_id, "gonna_shoot" )
	local gonna_shoot = ComponentGetValue2( storage_shot, "value_bool" )
	if( gonna_shoot ) then
		local path = "mods/necro_stuff/files/spells/necro_gaze/necro_gaze.xml"
		local min_pos = { 999, 999, }
		local children = EntityGetAllChildren( get_hooman_child_old( hooman, "inventory_full" )) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				local action_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemActionComponent" )
				local item_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemComponent" )
				if( action_comp ~= nil and item_comp ~= nil ) then
					local inv_x, inv_y = ComponentGetValue2( item_comp, "inventory_slot" )
					if( min_pos[1] > inv_x and min_pos[2] >= inv_y ) then
						local t_path = get_action_with_id( ComponentGetValue2( action_comp, "action_id" )).related_projectiles
						if( t_path ~= nil ) then
							path = t_path[1]
							min_pos[1] = inv_x
							min_pos[2] = inv_y
						end
					end
				end
			end
		end
		
		local x, y = EntityGetTransform( entity_id )
		local ctrl_comp = EntityGetFirstComponentIncludingDisabled( hooman, "ControlsComponent" )
		local aiming_x, aiming_y = ComponentGetValue2( ctrl_comp, "mAimingVector" )
		local angle = math.atan2( aiming_y, aiming_x )
		
		local custom_func = function( entity_id, values )
			if( values ~= "" ) then
				for stuff in string.gmatch( values, "([^,]+)" ) do
					EntityLoadToEntity( stuff, entity_id )
				end
			end
		end
		shoot_projectile_ultimate( hooman, path, x, y, math.cos( angle )*4000, math.sin( angle )*4000, true, custom_func, ComponentGetValue2( storage_extra, "value_string" ))
		
		ComponentSetValue2( storage_shot, "value_bool", false )
		ComponentGetValue2( storage_extra, "value_string", "" )
	end
end
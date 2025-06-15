dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local brains = GetUpdatedEntityID()
local actual_hooman = get_player()
local b_x, b_y, b_r, b_s_x, b_s_y = EntityGetTransform( brains )

local stuff = get_active_wand_old( brains )
if( EntityHasTag( stuff, "necro_stuff" )) then
	local storage_stuff = get_storage_old( stuff, "necro_stage" )
	local storage_brains = get_storage_old( brains, "necro_stage" )
	local stuff_stage = ComponentGetValue2( storage_stuff, "value_int" )
	local brains_stage = ComponentGetValue2( storage_brains, "value_int" )
	if( stuff_stage ~= brains_stage ) then
		ComponentSetValue2( storage_brains, "value_int", stuff_stage )
		
		local necro_evo = {
			{ -- 1
				{ 0.1, 5, 20, 30, },
				{ 20, },
				{ false, 50, 300, 30, false, 20, },
				{ 1, },
				{ 5, },
				{ 3, },
				{ 600, },
			},
			{ -- 2
				{ 0.2, 10, 40, 20, },
				{ 18, },
				{ false, 100, 250, 40, false, 30, },
				{ 1, },
				{ 5, },
				{ 3, },
				{ 550, },
			},
			{ -- 3
				{ 0.3, 20, 80, 15, },
				{ 10, },
				{ false, 200, 150, 50, true, 60, },
				{ 3, },
				{ 7, },
				{ 5, },
				{ 500, },
			},
			{ -- 4
				{ 0.4, 30, 100, 10, },
				{ 8, },
				{ false, 300, 100, 90, true, 80, },
				{ 3, },
				{ 7, },
				{ 5, },
				{ 200, },
			},
			{ -- 5
				{ 0.5, 50, 150, 5, },
				{ 5, },
				{ false, 500, 10, 180, true, 90, },
				{ 3, },
				{ 7, },
				{ 5, },
				{ 100, },
			},
			{ -- 6
				{ 1, 100, 200, 1, },
				{ 1, },
				{ true, 1000, 10, 360, true, 100, },
				{ 6, },
				{ 9, },
				{ 7, },
				{ 3, },
			},
			{ -- 7
				{ 1, 100, 200, 1, },
				{ 1, },
				{ true, 1000, 10, 360, true, 100, },
				{ 6, },
				{ 9, },
				{ 7, },
				{ 3, },
			},
		}
		
		local fragment = necro_evo[stuff_stage]
		local values = fragment[1]
		edit_component_ultimate( brains, "PhysicsAIComponent", function(comp,vars) 
			ComponentSetValue2( comp, "force_balancing_coeff", values[1] )
			ComponentSetValue2( comp, "force_coeff", values[2] )
			ComponentSetValue2( comp, "force_max", values[3] )
			-- ComponentSetValue2( comp, "target_vec_max_len", values[4] )
		end)
		
		values = fragment[2][1]
		edit_component_ultimate( brains, "GenomeDataComponent", function(comp,vars) 
			ComponentSetValue2( comp, "food_chain_rank", values )
		end)
		
		values = fragment[3]
		edit_component_ultimate( brains, "AnimalAIComponent", function(comp,vars) 
			ComponentSetValue2( comp, "sense_creatures_through_walls", values[1] )
			ComponentSetValue2( comp, "creature_detection_range_x", values[2] )
			ComponentSetValue2( comp, "creature_detection_range_y", values[2] )
			ComponentSetValue2( comp, "creature_detection_check_every_x_frames", values[3] )
			ComponentSetValue2( comp, "creature_detection_angular_range_deg", values[4] )
			ComponentSetValue2( comp, "attack_ranged_predict", values[5] )
			ComponentSetValue2( comp, "aggressiveness_max", values[6] )
			ComponentSetValue2( comp, "aggressiveness_min", values[6] )
		end)
		
		values = fragment[4][1]
		edit_component_ultimate( brains, "CharacterDataComponent", function(comp,vars) 
			ComponentSetValue2( comp, "mass", values )
		end)
		
		values = fragment[5][1]
		edit_component_ultimate( brains, "PhysicsShapeComponent", function(comp,vars) 
			ComponentSetValue2( comp, "radius_x", values )
			ComponentSetValue2( comp, "radius_y", values )
		end)
		
		values = fragment[6][1]
		if( values > 0 ) then
			local storage_legs = get_storage_old( brains, "leg_count" )
			local leg_count = ComponentGetValue2( storage_legs, "value_int" )
			
			if( leg_count < values ) then
				for i = 1,( values - leg_count ) do
					EntityAddChild( brains, EntityLoad( "mods/necro_stuff/files/stuff/leg.xml", b_x, b_y ))
				end
				ComponentSetValue2( storage_legs, "value_int", values )
			end
		end
		
		values = fragment[7][1]
		edit_component_ultimate( brains, "DamageNearbyEntitiesComponent", function(comp,vars) 
			ComponentSetValue2( comp, "time_between_damaging", values )
		end)
		
		if( stuff_stage > 4 and EntityGetFirstComponentIncludingDisabled( brains, "CellEaterComponent" ) == nil ) then
			EntityAddComponent( brains, "CellEaterComponent", 
			{
				radius = necro_evo[stuff_stage][5][1] + 2,
				ignored_material_tag = "[indestructible]",
			})
		end
	end
	
	if( actual_hooman ~= nil ) then
		local p_x, p_y, p_r, p_s_x, p_s_y = EntityGetTransform( actual_hooman )
		
		local dist = math.sqrt(( p_x - b_x )^2 + ( p_y - b_y )^2 )
		if( dist < 15 and not( GameIsInventoryOpen())) then
			if( gui == nil ) then
				gui = GuiCreate()
			end
			GuiStartFrame( gui )
			
			local pic_x, pic_y = 0, 0
			
			local w, h = GuiGetScreenDimensions( gui )
			local cam_x, cam_y = GameGetCameraPos()
			local shit_from_ass = w/( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_X" ))
			
			pic_x = w/2 + shit_from_ass*( b_x - cam_x )
			pic_y = h/2 + shit_from_ass*( b_y - cam_y ) + 5
			
			local prompt = "[USE] to pickup."
			local o_x = GuiGetTextDimensions( gui, prompt, 1, 2 )
			GuiZSetForNextWidget( gui, -1 )
			GuiText( gui, pic_x - o_x/2, pic_y, prompt )
			GuiColorSetForNextWidget( gui, 0, 0, 0, 1 )
			GuiZSetForNextWidget( gui, -0.9 )
			GuiText( gui, pic_x - o_x/2 + 1, pic_y + 1, prompt )
			
			local E_down = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( actual_hooman, "ControlsComponent" ), "mButtonDownInteract" )
			if( E_down ) then
				local slots_used = 0
				local children = EntityGetAllChildren( get_hooman_child_old( actual_hooman, "inventory_quick" )) or {}
				if( #children > 0 ) then
					for i,child in ipairs( children ) do
						local abil_comp = EntityGetFirstComponentIncludingDisabled( child, "AbilityComponent" )
						if( abil_comp ~= nil ) then
							if( ComponentGetValue2( abil_comp, "use_gun_script" )) then
								slots_used = slots_used + 1
							end
						end
					end
				end
				
				if( slots_used < 4 ) then
					GameDropAllItems( brains )
					GamePickUpInventoryItem( actual_hooman, stuff, true )
					gui = gui_killer_old( gui )
					EntityKill( brains )
				else
					GamePrint( "Inventory is full!" )
				end
			end
		else
			gui = gui_killer_old( gui )
		end
	end
else
	gui = gui_killer_old( gui )
	
	EntityKill( brains )
end
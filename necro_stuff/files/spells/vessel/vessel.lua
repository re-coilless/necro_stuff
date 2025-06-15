dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local actual_hooman = get_player()
if( actual_hooman ~= nil ) then
	local x, y = EntityGetTransform( entity_id )
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
		
		local storage_mode = get_storage_old( entity_id, "is_wand" )
		local is_wand = ComponentGetValue2( storage_mode, "value_bool" )
		uid, clicked = new_button_old( gui, uid, pic_x - 8, pic_y - 7, -1, "mods/necro_stuff/files/gui/button_trans.png" )
		if( clicked ) then
			local storage_stats = get_storage_old( entity_id, "wand_stats" )
			if( is_wand ) then
				EntityRemoveTag( entity_id, "teleportable_NOT" )
				EntityRemoveTag( entity_id, "item" )
				EntityRemoveTag( entity_id, "wand" )
				EntityAddTag( entity_id, "card_action" )
				
				EntitySetTransform( entity_id, x, y, 0, 1, 1 )
				
				local abil_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "AbilityComponent" )
				ComponentSetValue2( storage_stats, "value_string", D_packer_old({
					ComponentGetValue2( abil_comp, "mana_charge_speed" ),
					ComponentGetValue2( abil_comp, "mana_max" ),
					ComponentObjectGetValue2( abil_comp, "gun_config", "deck_capacity" ),
					ComponentObjectGetValue2( abil_comp, "gun_config", "actions_per_round" ),
					ComponentObjectGetValue2( abil_comp, "gun_config", "reload_time" ),
					ComponentObjectGetValue2( abil_comp, "gunaction_config", "spread_degrees" ),
					ComponentObjectGetValue2( abil_comp, "gunaction_config", "fire_rate_wait" ),
				}))
				EntityRemoveComponent( entity_id, abil_comp )
				EntityAddComponent( entity_id, "ItemActionComponent", 
				{
					_tags = "enabled_in_world",
					action_id = "THE_VESSEL",
				})
				
				EntityRemoveComponent( entity_id, EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent", "item" )) 
				EntityRemoveComponent( entity_id, EntityGetFirstComponentIncludingDisabled( entity_id, "ManaReloaderComponent" ))
				
				local item_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "ItemComponent" )
				ComponentSetValue2( item_comp, "play_spinning_animation", false )
				ComponentSetValue2( item_comp, "preferred_inventory", "FULL" )
				
				local emitters = EntityGetComponentIncludingDisabled( entity_id, "ParticleEmitterComponent" )
				for i,emitter in ipairs( emitters ) do
					ComponentAddTag( emitter, "enabled_in_world" )
					EntitySetComponentIsEnabled( entity_id, emitter, true )
				end
				
				local pics = EntityGetComponentIncludingDisabled( entity_id, "SpriteComponent" )
				for i,pic in ipairs( pics ) do
					ComponentAddTag( pic, "enabled_in_world" )
					EntitySetComponentIsEnabled( entity_id, pic, true )
					EntityRefreshSprite( entity_id, pic )
				end
			else
				local stats = D_extractor_old( ComponentGetValue2( storage_stats, "value_string" ))
				
				EntityRemoveTag( entity_id, "card_action" )
				EntityAddTag( entity_id, "teleportable_NOT" )
				EntityAddTag( entity_id, "item" )
				EntityAddTag( entity_id, "wand" )
				
				EntityRemoveComponent( entity_id, EntityGetFirstComponentIncludingDisabled( entity_id, "ItemActionComponent" ))
				local abil_comp = EntityAddComponent( entity_id, "AbilityComponent", 
				{
					sprite_file = "data/items_gfx/wands/wand_0093.png",
					ui_name = "The Vessel",
					add_these_child_actions = "",
					drop_as_item_on_death = "1",
					entity_count = "1",
					entity_file = "",
					mana_charge_speed = stats[1],
					mana_max = stats[2],
					max_amount_in_inventory = "1",
					shooting_reduces_amount_in_inventory = "0",
					fast_projectile = "0",
					swim_propel_amount = "0",
					throw_as_item = "0",
					amount_in_inventory = "1",
					cooldown_frames = "0",
					use_gun_script = "1",
					item_recoil_offset_coeff = "1",
					item_recoil_rotation_coeff = "5",
					never_reload = "0",
				})
				ComponentObjectSetValue2( abil_comp, "gun_config", "shuffle_deck_when_empty", false )
				ComponentObjectSetValue2( abil_comp, "gun_config", "deck_capacity", stats[3] )
				ComponentObjectSetValue2( abil_comp, "gun_config", "actions_per_round", stats[4] )
				ComponentObjectSetValue2( abil_comp, "gun_config", "reload_time", stats[5] )
				ComponentObjectSetValue2( abil_comp, "gunaction_config", "spread_degrees", stats[6] )
				ComponentObjectSetValue2( abil_comp, "gunaction_config", "fire_rate_wait", stats[7] )
				
				EntityAddComponent( entity_id, "ManaReloaderComponent", 
				{
					_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
				})
				
				local item_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "ItemComponent" )
				ComponentSetValue2( item_comp, "play_spinning_animation", true )
				ComponentSetValue2( item_comp, "preferred_inventory", "QUICK" )
				
				local emitters = EntityGetComponentIncludingDisabled( entity_id, "ParticleEmitterComponent" )
				for i,emitter in ipairs( emitters ) do
					ComponentRemoveTag( emitter, "enabled_in_world" )
					EntitySetComponentIsEnabled( entity_id, emitter, false )
				end
				
				local pics = EntityGetComponentIncludingDisabled( entity_id, "SpriteComponent" )
				for i,pic in ipairs( pics ) do
					ComponentRemoveTag( pic, "enabled_in_world" )
					EntitySetComponentIsEnabled( entity_id, pic, false )
					EntityRefreshSprite( entity_id, pic )
				end
				
				EntityAddComponent( entity_id, "SpriteComponent", 
				{
					_tags = "enabled_in_world,enabled_in_hand,item",
					image_file = "data/items_gfx/wands/wand_0093.png",
					next_rect_animation = "",
					offset_x = "1",
					offset_y = "3",
					rect_animation = "",
					ui_is_parent = "0",
					update_transform = "1",
					update_transform_rotation = "1",
					visible = "1",
					z_index = "-1",
				})
			end
			ComponentSetValue2( storage_mode, "value_bool", not( is_wand ))
		end
	else
		gui = gui_killer_old( gui )
	end
end
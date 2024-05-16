dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

function damage_received( damage, message, entity_thats_responsible, is_fatal )
	if( is_fatal ) then
		local it_is = 0
		if( EntityHasTag( entity_thats_responsible, "necro_stuff" )) then
			it_is = entity_thats_responsible
		else
			local wand_id = get_active_wand_old( entity_thats_responsible )
			if( EntityHasTag( wand_id, "necro_stuff" )) then
				it_is = wand_id
			elseif(( get_hooman_child_old( get_hooman_child_old( EntityGetRootEntity( entity_thats_responsible ), "inventory_full" ), "effigy_card" ) ~= nil ) or ( EntityHasTag( entity_thats_responsible, "abomination" ) or EntityHasTag( entity_thats_responsible, "undead" ) )) then
				local x, y = EntityGetTransform( entity_thats_responsible )
				it_is = EntityGetClosestWithTag( x, y, "necro_stuff" )
			end
		end
		
		if( it_is ~= 0 ) then
			local state = ComponentGetValue2( get_storage_old( it_is, "state" ), "value_int" )
			local necro_stage = ComponentGetValue2( get_storage_old( it_is, "necro_stage" ), "value_int" )
			
			local ladder_table = D_extractor_old( GlobalsGetValue( "NECRO_LADDER", "0" ))
			local k_mercury = GameHasFlagRun( "mercury_enabled" ) and 2 or 1		
			
			local enemy_id = GetUpdatedEntityID()
			local storage_necro = get_storage_old( it_is, "necro_current" )
			local necro_current = ComponentGetValue2( storage_necro, "value_float" )
			local value = necro_current + math.floor( ModSettingGetNextValue( "necro_stuff.NC_SPEED" ) + 0.5 )*k_mercury*math.min( get_necro_current( enemy_id )*( EntityHasTag( enemy_id, "helpless_animal" ) and 5 or 1 )*( 1 + state ), 111*necro_stage^2 )
			if( necro_stage > 6 or necro_current < ladder_table[ necro_stage + 1 ]) then
				ComponentSetValue2( storage_necro, "value_float", necro_stage < 7 and math.min( value, ladder_table[ necro_stage + 1 ]) or value )
				local pos_x, pos_y = EntityGetTransform( enemy_id )
				new_connector( it_is, pos_x, pos_y )
			end
			
			local wand_id = get_active_wand_old( enemy_id ) or 0
			if( wand_id ~= 0 ) then
				local final_cost = wand_rater( wand_id )
				
				local spells = EntityGetAllChildren( wand_id ) or {}
				if( #spells > 0 ) then
					for i,spell in ipairs( spells ) do
						if( EntityHasTag( spell, "card_action" )) then
							final_cost = final_cost + spell_rater( spell )
							
							if( i == 1 ) then
								EntityKill( spell )
							end
						end
					end
				else
					EntityKill( wand_id )
				end
				
				local storage_mana = get_storage_old( it_is, "mana_current" )
				local arcane_cost = math.floor( ModSettingGetNextValue( "necro_stuff.AC_SPEED" ) + 0.5 )*k_mercury*math.min( final_cost, 100*necro_stage^2 )
				ComponentSetValue2( storage_mana, "value_float", ComponentGetValue2( storage_mana, "value_float" ) + math.min( arcane_cost/2, necro_cost ))
				
				local w_x, w_y = EntityGetTransform( wand_id )
				new_connector( wand_id, w_x, w_y, "magic_liquid_mana_regeneration", 5 )
			end
			
			EntityRemoveComponent( enemy_id, GetUpdatedComponentID())
		end
	end
end
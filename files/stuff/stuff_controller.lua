dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
dofile_once( "data/scripts/gun/procedural/gun_action_utils.lua" )

local frame_num = GameGetFrameNum()

local wand_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( wand_id )
local x, y, r, scale_x, scale_y = EntityGetTransform( wand_id )
local h_x, h_y = EntityGetTransform( hooman )

local storage_stage = get_storage_old( wand_id, "necro_stage" )
local necro_stage = ComponentGetValue2( storage_stage, "value_int" )

local ladder_table = D_extractor_old( GlobalsGetValue( "NECRO_LADDER", "0" ))
local price_offset = D_extractor_old( GlobalsGetValue( "PRICE_LADDER", "0" ))[ ModSettingGetNextValue( "necro_stuff.GIVES_A_FUCK" )]

local necro_zero = ladder_table[ necro_stage ]
local necro_one = ladder_table[ necro_stage + 1 ]

local storage_state = get_storage_old( wand_id, "state" )
local storage_gui = get_storage_old( wand_id, "gui_state" )
local storage_page = get_storage_old( wand_id, "page" )
local storage_dormant = get_storage_old( wand_id, "is_dormant" )
local storage_hunter = get_storage_old( wand_id, "is_hunter" )
local storage_killer = get_storage_old( wand_id, "kills_undead" )
local storage_necro = get_storage_old( wand_id, "necro_current" )
local storage_mana = get_storage_old( wand_id, "mana_current" )
local storage_evo = get_storage_old( wand_id, "evo_stage" )
local storage_tree = get_storage_old( wand_id, "tree_unlocks" )
local state = ComponentGetValue2( storage_state, "value_int" )
local gui_active = ComponentGetValue2( storage_gui, "value_bool" )
local page_num = ComponentGetValue2( storage_page, "value_int" )
local is_dormant = ComponentGetValue2( storage_dormant, "value_bool" )
local is_hunter = ComponentGetValue2( storage_hunter, "value_bool" )
local kills_undead = ComponentGetValue2( storage_killer, "value_bool" )
local necro_current = ComponentGetValue2( storage_necro, "value_float" )
local nc_visual = math.max(( necro_current - necro_zero ), 0 )
local mana_current = ComponentGetValue2( storage_mana, "value_float" )
local evo_stage = ComponentGetValue2( storage_evo, "value_int" )
local tree_unlocks = get_unlocks( ComponentGetValue2( storage_tree, "value_string" ))

local trash = EntityGetFirstComponentIncludingDisabled( wand_id, "AudioLoopComponent", "sound_digger" )
if( trash ~= nil ) then
	EntityRemoveComponent( hooman, trash )
	EntityRemoveComponent( hooman, EntityGetFirstComponentIncludingDisabled( wand_id, "AudioLoopComponent", "sound_spray" ))
	EntityRemoveComponent( hooman, EntityGetFirstComponentIncludingDisabled( wand_id, "LightComponent" ))
end

local targets = get_prey( x, y, 1000 )
if( #targets > 0 ) then
	for i,deadman in ipairs( targets ) do
		if( EntityGetFirstComponentIncludingDisabled( deadman, "LuaComponent", "kill_confirmer" ) == nil ) then
			EntityAddComponent( deadman, "LuaComponent", 
			{
				_tags = "enabled_in_world,kill_confirmer",
				script_damage_received = "mods/necro_stuff/files/stuff/kill_confirmer.lua",
				execute_every_n_frame = "-1",
			})
		end
	end
end

evo_ready = evo_ready or false
if( necro_current >= necro_one and necro_stage < 7 ) then
	if( evo_ready == true ) then
		necro_stage = necro_stage + 1
		ComponentSetValue2( storage_stage, "value_int", necro_stage )
	elseif( evo_ready ~= 0 ) then
		evo_ready = 0
	end
elseif( necro_current < necro_zero and necro_stage > 1 ) then
	necro_stage = necro_stage - 1
	ComponentSetValue2( storage_stage, "value_int", necro_stage )
else
	evo_ready = false
end

local drip = EntityGetFirstComponentIncludingDisabled( wand_id, "ParticleEmitterComponent", "drip" )
local is_dripping = ComponentGetValue2( drip, "is_emitting" )
if( is_dripping ~= ( evo_ready ~= false )) then
	ComponentSetValue2( drip, "is_emitting", evo_ready ~= false )
end

if( necro_stage ~= evo_stage ) then
	ComponentSetValue2( storage_evo, "value_int", necro_stage )
	GlobalsSetValue( "NECRO_ZERO", ladder_table[ necro_stage ] )
	evo_ready = false
	
	local necro_evo = {
		{ -- 1
			--particles + light
			{ "mods/necro_stuff/files/stuff/stage1.xml", "mods/necro_stuff/files/stuff/stage1_meat.xml", 12 },
		},
		{ -- 2
			--particles + light
			{ "mods/necro_stuff/files/stuff/stage1.xml", "mods/necro_stuff/files/stuff/stage1_meat.xml", 12 },
		},
		{ -- 3
			{ "mods/necro_stuff/files/stuff/stage3.xml", "mods/necro_stuff/files/stuff/stage3_meat.xml", 13 },
		},
		{ -- 4
			--particles + light
			{ "mods/necro_stuff/files/stuff/stage3.xml", "mods/necro_stuff/files/stuff/stage3_meat.xml", 13 },
		},
		{ -- 5
			{ "mods/necro_stuff/files/stuff/stage5.xml", "mods/necro_stuff/files/stuff/stage5_meat.xml", 14 },
		},
		{ -- 6
			--particles + light
			{ "mods/necro_stuff/files/stuff/stage5.xml", "mods/necro_stuff/files/stuff/stage5_meat.xml", 14 },
		},
		{ -- 7
			--particles + light
			{ "mods/necro_stuff/files/stuff/stage5.xml", "mods/necro_stuff/files/stuff/stage5_meat.xml", 14 },
		},
	}
	
	local fragment = necro_evo[necro_stage]
	local values = fragment[1]
	edit_component_with_tag_ultimate( wand_id, "SpriteComponent", "item", function(comp,vars) 
		ComponentSetValue2( comp, "image_file", values[1] )
		EntityRefreshSprite( wand_id, comp )
	end)
	
	edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
		ComponentSetValue2( comp, "sprite_file", values[1] )
	end)
	
	edit_component_with_tag_ultimate( wand_id, "SpriteComponent", "meat", function(comp,vars) 
		ComponentSetValue2( comp, "image_file", values[2] )
		EntityRefreshSprite( wand_id, comp )
	end)
	
	edit_component_with_tag_ultimate( wand_id, "HotspotComponent", "shoot_pos", function(comp,vars) 
		ComponentSetValue2( comp, "offset", values[3], 0 )
	end)
	
	local spell_tiers = {
		{},
		{{}, { "THE_IRE", "THE_GUILT", "THE_TRUTH", "THE_LIMBO", "THE_TENET", "THE_EXECUTION", }},
		{{ ( not( ModSettingGetNextValue( "necro_stuff.EFFIGY_START" )) and "THE_EFFIGY" or nil ), }, { "ARCANE_INFUSION", "NECRO_INFUSION", "THE_RAPTURE", "THE_HERESY", "NECRO_LIGHTNING", }},
		{{}, { "THE_REVELATION", "THE_WRATH", "THE_CURE", "ABHORRENT_INFUSION", "CORRUPT_INFUSION", "THE_FEAR", }},
		{{ "SIGIL_OF_SIN", }, { "THE_ASCENSION", "THE_AEON", "THE_SCHISM", "FINNISH_INFUSION", { "THE_DREAM", "THE_OBLIVION", }, }},
		{{}, { "THE_VESSEL", "THE_ANSWER", { "THE_TORMENT", "THE_PENANCE", }, "THE_AWAKENING", "NECRO_FLAGELLATION", "THE_PRESENCE", }},
		{{ --[["THE_LAW",]] }, { "THE_BEHEST", "THE_JUDGMENT", "THE_QUESTION", "THE_FAULT", --[["THE_MACHINE",]] }},
	}
	
	if( not( GameHasFlagRun( "TIER_SPELL_COLLECTED_"..necro_stage )) and #spell_tiers[necro_stage] > 0 ) then
		GameAddFlagRun( "TIER_SPELL_COLLECTED_"..necro_stage )
		
		GamePrintImportant( "You've just got a new spell!", "Check the inventory." )
		
		local spell_pool = spell_tiers[necro_stage]
		if( #spell_pool[1] > 0 ) then
			for i,spell in ipairs( spell_pool[1] ) do
				GamePickUpInventoryItem( hooman, CreateItemActionEntity( spell, h_x, h_y ), false )
			end
		end
		
		SetRandomSeed( frame_num, necro_stage*wand_id )
		local amount = Random( 1, 100 ) < ( 90 + necro_stage ) and 1 or ( Random( 1, ( 3 + necro_stage )) == 1 and 3 or 2 )
		for i = 1,amount do
			if( #spell_pool[2] > 0 ) then
				SetRandomSeed( frame_num, amount*( h_x + h_y + i ))
				local num = Random( 1, #spell_pool[2] )
				local id = spell_pool[2][num]
				if( type( id ) == "table" ) then
					for i,spell in ipairs( id ) do
						GamePickUpInventoryItem( hooman, CreateItemActionEntity( spell, h_x, h_y ), false )
					end
				else
					GamePickUpInventoryItem( hooman, CreateItemActionEntity( id, h_x, h_y ), false )
				end
				table.remove( spell_pool[2], num )
			end
		end
	end
	
	if( necro_stage == 7 ) then
		--endgame starts here
		GamePrintImportant( "THANKS FOR PLAYING", "this should be the start of the endgame content that is yet to come", "mods/necro_stuff/files/gui/gameprint.png" )
		GamePrint( "THANKS FOR PLAYING" )
		GamePrint( "this should be the start of the endgame content that is yet to come" )
	end
end

if( is_hunter ) then
	local shard = EntityGetClosestWithTag( x, y, "blasphemy" )
	if( ComponentGetIsEnabled( EntityGetFirstComponentIncludingDisabled( shard, "GenomeDataComponent" ))) then
		local s_x, s_y = EntityGetTransform( shard )
		if( math.sqrt(( s_x - x )^2 + ( s_y - y )^2 ) < 50 ) then
			local shard_connected = false
			local wands = EntityGetInRadiusWithTag( s_x, s_y, 50, "wand" ) or {}
			if( #wands > 0 ) then
				local final_cost = 0
				for i,wand in ipairs( wands ) do
					if( wand == EntityGetRootEntity( wand ) and wand ~= wand_id ) then
						local cost_comp = EntityGetFirstComponentIncludingDisabled( wand, "ItemCostComponent", "shop_cost" )
						if( cost_comp == nil or necro_stage > 2 ) then
							final_cost = final_cost + wand_rater( wand )
							local spells = EntityGetAllChildren( wand ) or {}
							if( #spells > 0 ) then
								for i,spell in ipairs( spells ) do
									if( EntityHasTag( spell, "card_action" )) then
										final_cost = final_cost + spell_rater( spell )
									end
								end
							end
							if( cost_comp ~= nil and hooman ~= nil ) then
								local wallet_comp = EntityGetFirstComponentIncludingDisabled( hooman, "WalletComponent" )
								ComponentSetValue2( wallet_comp, "money", ComponentGetValue2( wallet_comp, "money" ) + math.floor( ComponentGetValue2( cost_comp, "cost" )/3 ))
								EntityAddChild( wand_id, new_connector( hooman, x, y, "gold_molten", 5 ))
							end
							local w_x, w_y = EntityGetTransform( wand )
							new_connector( shard, w_x, w_y, "magic_liquid_mana_regeneration", 5 )
							if( not( shard_connected )) then
								EntityAddChild( shard, new_connector( wand_id, s_x, s_y, "magic_liquid_mana_regeneration", 5 ))
								shard_connected = true
							end
							EntityKill( wand )
						end
					end
				end
				ComponentSetValue2( storage_mana, "value_float", ComponentGetValue2( storage_mana, "value_float" ) + math.floor( ModSettingGetNextValue( "necro_stuff.AC_SPEED" ) + 0.5 )*( GameHasFlagRun( "mercury_enabled" ) and 2 or 1 )*math.min( final_cost, 100*price_offset*necro_stage^2 ))
			end
		end
	end
end

if( wand_id == hooman ) then
	if( state == 0 and not( is_dormant or wand_is_useless_old( wand_id ))) then
		ComponentSetValue2( storage_state, "value_int", 1 )
		
		local pic_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "SpriteComponent", "item" )
		local meat_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "SpriteComponent", "meat" )
		ComponentSetValue2( meat_comp, "visible", true )
		ComponentSetValue2( meat_comp, "z_index", ComponentGetValue2( pic_comp, "z_index" ) - 0.01 )
		EntityRefreshSprite( wand_id, meat_comp )
		
		local itm_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "ItemComponent" )
		ComponentSetValue2( itm_comp, "npc_next_frame_pickable", 1 )
		
		GamePickUpInventoryItem( EntityLoad( "mods/necro_stuff/files/stuff/brain_and_stuff.xml", x, y ), wand_id, false )
	end
elseif( EntityHasTag( hooman, "weird_dude" )) then
	if( state == 1 ) then
		ComponentSetValue2( storage_state, "value_int", 0 )
		
		local meat_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "SpriteComponent", "meat" )
		ComponentSetValue2( meat_comp, "visible", false )
		EntityRefreshSprite( wand_id, meat_comp )
	end
	
	if( not( GameIsInventoryOpen())) then
		if( gui == nil ) then
			gui = GuiCreate()
		end
		GuiStartFrame( gui )
		
		intertier_warning = intertier_warning or false
		intertier_proceed = intertier_proceed or false
		local hooman_hp = math.floor( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" ), "hp" )*25 )
		
		local w, h = GuiGetScreenDimensions( gui )
		local clicked, r_clicked, hovered, pic_x, pic_y, pic_z = 0, 0, 0, 0, 0, -2
		local pic, pic_w, pic_h = 0, 0, 0
		local uid = 0
		if( gui_active ) then
			local global_x, global_y = tonumber( ModSettingGetNextValue( "necro_stuff.WINDOW_POS_X" )), tonumber( ModSettingGetNextValue( "necro_stuff.WINDOW_POS_Y" ))
			local tooltip_x, tooltip_y = global_x + ( ModSettingGetNextValue( "necro_stuff.TOOLTIP_MIRROR" ) and -170 or 163 ), global_y + 2
			pic_x = global_x
			pic_y = global_y
			
			local pages = {
				{
					name = "The Shrine",
					title = "mods/necro_stuff/files/gui/title_general.png",
					background = "mods/necro_stuff/files/gui/background_general.png",
					label = "mods/necro_stuff/files/gui/label_general",
					contents = function( gui, uid, pic_x, pic_y, pic_z )
						tips = tips or {
							{
								"reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @",
								
								"The True Form has several advantages compared to the hand-held state - try unleashing it from time to time.",
								"The Article will guide you to the Staff, don't lose it.",
								
								"The Stuff abhors the Shard of Blasphemy - any of the necro-active beings will attack it on-sight.",
								"The Shard of Blasphemy might be merged with some items to drastically improve their qualities.",
								"The Abhorrent Fetus is a massive pain in the ass, but at least you can make it someone else's problem.",
								"Texts are great. Always read texts.",
								
								"Both Arcane and Necro Current incomes have hard limitation on the simultaneous transmission amount that is being calculated based on the Necro Tier.",
								"Necro Current absorption occurs only when the Staff itself is the cause of death: trick kills, other wands and summons won't count in the most cases.",
								"The Staff will mark wands for consumption only if there's an active (held in hands or dropped in-world) Shard of Blasphemy nearby.",
								"Helpless animals yield 5x the Necro Current.",
								"The True Form kills have double Necro Current harvest efficiency.",
								"If the Necro Current amount goes below a threshold required for the achieved Necro Tier - the Tier Number will go down.",
								
								"To assemble an Abomination you need to have a certain amount of Raw Matter (blood or any organics) within your stomach.",
								"Abominations are disposable - don't hesitate to sacrifice them once your bidding was done.",
								"Master-bound Abominations have their brainpower hindered; free to roam exemplars are smarter but are impossible to control.",
								
								"Several spells have an inherent ability to create the Undead. The more powerful the cast itself is, the higher quality will be the resulting Undead.",
								"Don't forget that you can always sacrifice the Undead you don't need anymore.",
								"Generic Undead are useless in combat unless you'll arm them with a wand. Though, having something ready to take damage for you is rather handy by itself.",
								
								"Ruinous Supremacy branch is well known for its bizarre side effects.",
								"Each of the top Runes from every category (especially Knowledge Ultima) has a unique secondary effect.",
								"Knowledge Ultima is bound to the rest of the Rune tree - the more Runes you'll have, the less expensive this Ultima synthesis will become.",
								
								"Most of the necro-active materials have unique reactions: some are beneficial, and some will ruin the entire world.",
								
								"How to? Kill creatures to earn NC and consume wands to gain AC; spend both on upgrading the Staff, doing the Stuff and stepping up your game.",
								"Certain necro-spells are exceptionally lethal and might end your run instantly no matter the amount of HP you have. Proceed with caution.",
								"The Abominations are the creatures produced from scratch, while the Undead are the corrupted inhabitants of this world.",
								"There are several potentially game-changing options in the settings - be sure to take a look.",
								"There's A LOT of information presented within the tooltips - read all of them.",
								"Necro Tiers won't advance by themselves - you must confirm the transition at the Shrine.",
								"Got confused by terminology? Want to know what does \"Hindrance Factor\" stand for? Just curious about what's going on? Try casting the Lore a couple of times.",
								"The majority of the Stuff is supposed to help you, not to kill. However, sometimes it works both ways.",
							},
							
							{
								"Also try Cortex Command.",
								"This is not what you think it is.",
								"Huh? Are you paying attention at all?",
								"Satan fucking loves cheating."
							},
						}
						
						uid = new_bar( gui, uid, pic_x + 101, pic_y - 1, pic_z, necro_one - necro_zero, 31, nc_visual )
						
						uid = new_button_old( gui, uid, pic_x + 102, pic_y - 1, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_counter_shrine.png" )
						uid = new_tooltip_old( gui, uid, nil, "Evolution Progress: "..math.floor( 100*nc_visual/( necro_one - necro_zero )).."%", "Kill creatures to gain more." )
						
						if( evo_ready == 0 ) then
							new_blinker( gui, { 240/255, 22/255, 152/255, 1 }, 0.08, 1.3 )
						end
						uid, clicked = new_button_old( gui, uid, pic_x + 136, pic_y - 2, pic_z, "mods/necro_stuff/files/gui/sign_stage_"..necro_stage..".png" )
						uid = new_tooltip_old( gui, uid, nil, "Necro Tier: "..necro_stage, evo_ready == 0 and "LMB to advance to the next one." or nil )
						if( evo_ready == 0 and clicked ) then
							evo_ready = true
						end
						
						uid = new_window( gui, uid, pic_x, pic_y + 19, pic_z, 100, 75, false, false )
						k_tt = k_tt or 1
						local tip_table = tips[k_tt]
						if( current_tip == nil ) then
							SetRandomSeed( frame_num, hooman + #tip_table + tonumber( storage_state ))
							current_tip = Random( 1, #tip_table )
							
							--remove later
							if( tip_table[1] == "reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @ reach 7th Necro Tier @" ) then
								current_tip = 1
							end
						end
						next_tip = next_tip or frame_num + 18000
						new_text_old( gui, pic_x + 2, pic_y + 19, pic_z - 0.01, liner_old( gui, tip_table[current_tip], 95, 75, 3.9 ), 1 )
						uid, clicked = new_button_old( gui, uid, pic_x, pic_y + 19, pic_z - 0.02, "mods/necro_stuff/files/gui/hitbox_tip.png" )
						uid = new_tooltip_old( gui, uid, nil, "LMB for the next tip." )
						if( frame_num > next_tip or clicked ) then
							table.remove( tips[k_tt], current_tip )
							if( #tips[1] < 1 ) then
								tips = nil
							end
							
							if( k_tt > 1 ) then
								k_tt = 1
							else
								meme_cooldown = ( meme_cooldown or 0 ) + 1
								if( meme_cooldown > 19 ) then
									meme_cooldown = nil
									
									SetRandomSeed( frame_num, wand_id + tonumber( storage_evo ))
									k_tt = Random( 1, 3 ) == 1 and 2 or 1
									if( #tips[k_tt] < 1 ) then
										k_tt = 1
									end
								end
							end
							
							next_tip = nil
							current_tip = nil
						end
						
						uid = new_window( gui, uid, pic_x + 103, pic_y + 19, pic_z, 48, 93, true, false )
						
						if( ModSettingGetNextValue( "necro_stuff.LESSS_GO" )) then
							uid = new_anim( gui, uid, 1, pic_x + 107, pic_y + 47, pic_z - 0.1, "mods/necro_stuff/files/gui/balls/", 34, 3 )
						end
						
						uid, clicked = new_button_old( gui, uid, pic_x - 2, pic_y + 96, pic_z, "mods/necro_stuff/files/gui/button_dormant_"..( is_dormant and "B" or "A" )..".png" )
						uid = new_tooltip_old( gui, uid, nil, "The True Form is "..( is_dormant and "dis" or "en" ).."abled.", ( not( is_dormant ) and "The Staff will self-animate when is in the world." or nil ))
						if( clicked ) then
							ComponentSetValue2( storage_dormant, "value_bool", not( is_dormant ))
						end
						
						uid, clicked = new_button_old( gui, uid, pic_x + 16, pic_y + 96, pic_z, "mods/necro_stuff/files/gui/button_hunter_"..( is_hunter and "A" or "B" )..".png" )
						uid = new_tooltip_old( gui, uid, nil, "Wand Hunting mode is "..( is_hunter and "en" or "dis" ).."abled.", ( is_hunter and "The Staff will consume inferior wands if there's the Shard of Blasphemy nearby the prey." or nil ))
						if( clicked ) then
							ComponentSetValue2( storage_hunter, "value_bool", not( is_hunter ))
						end
						
						uid, clicked = new_button_old( gui, uid, pic_x + 33, pic_y + 96, pic_z, "mods/necro_stuff/files/gui/button_synth_blasphemy.png" )
						local shard_cost = 500
						uid = new_tooltip_old( gui, uid, nil, "Synthesize the Shard of Blasphemy.", shard_cost.."/"..math.floor( nc_visual ).." NC will be removed.")
						if( clicked ) then
							if( necro_current >= shard_cost ) then
								local going_intertier = nc_visual < shard_cost
								if( going_intertier and not( intertier_proceed )) then
									intertier_warning = true
								else
									if( intertier_proceed ) then
										intertier_proceed = false
									end
									
									ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) - shard_cost )
									EntityLoad( "mods/necro_stuff/files/stuff/shard_of_blasphemy.xml", x, y )
								end
							else
								GamePrint( "Insufficient Resources" )
							end
						end
						
						uid = new_image_old( gui, uid, pic_x + 49, pic_y + 96, pic_z, "mods/necro_stuff/files/gui/button_shrine_ender.png" )
						
						return uid
					end,
				},
				{
					name = "The Crypt",
					title = "mods/necro_stuff/files/gui/title_tree.png",
					background = "mods/necro_stuff/files/gui/background_tree.png",
					label = "mods/necro_stuff/files/gui/label_tree",
					contents = function( gui, uid, pic_x, pic_y, pic_z )
						uid = new_column( gui, uid, pic_x + 136, pic_y + 112, pic_z, 99900, 108, mana_current )
						
						uid = new_counter( gui, uid, pic_x + 105, pic_y - 1, pic_z, mana_current/price_offset, 3 )
						
						uid = new_button_old( gui, uid, pic_x + 103, pic_y - 1, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_counter_crypt_A.png" )
						uid = new_tooltip_old( gui, uid, nil, "Arcane Current: "..math.floor( mana_current )/price_offset, "Consume wands to gain more." )
						
						uid = new_button_old( gui, uid, pic_x + 136, pic_y - 1, pic_z - 0.05, "mods/necro_stuff/files/gui/hitbox_counter_crypt_B.png" )
						uid = new_tooltip_old( gui, uid, nil, "Arcane Current: "..math.floor( mana_current/999 ).."%", "Consume wands to gain more." )
						
						local shared_matrix = {
							{
								name = "[[FALSE MIND]]",
								desc = "Improve the performance by boosting Staff's mental capabilities.",
							},
							{
								name = "||UTMOST MYRIAD||",
								desc = "Multiply the power output by embedding sentient entities within.",
							},
							{
								name = "##PHRENETIC PURPORT##",
								desc = "Perfect the precision by implanting the foreign will into the Staff.",
							},
							{
								name = "++UNFATHOMABLE BLESSING++",
								desc = "Corrupt the projectiles by subjecting them to otherworldly energies.",
							},
							{
								name = "==RUINOUS SUPREMACY==",
								desc = "Expose the Staff to an unnatural influence.",
							},
							{
								name = "((ABYSMAL ENTRAILS))",
								desc = "Empower the mana storage by burrowing it inside an unseen creature.",
							},
							{
								name = "--DIVINE BEYOND--",
								desc = "Increase the capacity by tapping into the higher dimensions.",
							},
						}
						
						function curse_generic( k )
							SetRandomSeed( frame_num, wand_id + selected )
							if( Random( 1, k ) > 1 ) then
								local events = {
									function()
										GameCreateParticle( "blood", x, y, 1000, 0, 0, false )
									end,
									function()
										-- free purchase
										return true
									end,
									function()
										EntityInflictDamage( hooman, tree_matrix[ math.abs( selected )].cost_mc, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, wand_id, x, y, 0 )
									end,
									function()
										EntityIngestMaterial( hooman, CellFactory_GetType( "necro_current" ), 1575 )
									end,
									function()
										-- failure to purchase
										return false
									end,
									function()
										local effects = { "BLINDNESS", "INTERNAL_FIRE", "POISON", "CONFUSION", "FOOD_POISONING", }
										ComponentSetValue2( GetGameEffectLoadTo( hooman, effects[ Random( 1, #effects )], false ), "frames", 600 )
									end,
								}
								return events[ Random( 1, #events )]()
							end
						end
						
						function curse_special()
							SetRandomSeed( frame_num, hooman*math.abs( selected ))
							local events = {
								function()
									matter_fabricator( x, y, 3, { "blood", 50, 1000, })
									matter_fabricator( x, y, 3, { "blood", 50, 1000, })
									matter_fabricator( x, y, 3, { "blood", 50, 1000, })
									matter_fabricator( x, y, 2, { "necro_current", 40, 400, })
								end,
								function()
									local spells = {
										{ "mods/necro_stuff/files/spells/ire/ire.xml", 4, true, },
										{ "mods/necro_stuff/files/spells/necro_gaze/necro_gaze.xml", 8 },
										{ "mods/necro_stuff/files/spells/necro_glance/necro_glance.xml", 8 },
										{ "mods/necro_stuff/files/spells/necro_ray/necro_ray.xml", 10 },
										{ "mods/necro_stuff/files/spells/tenet/tenet.xml", 1, true, },
										-- { "mods/necro_stuff/files/spells/lore/lore.xml", 1 },
									}
									
									local spell = spells[ Random( 1, #spells )]
									local angle = math.rad( Random( 1, 36 )*10 )
									local speed = 1500
									local d_angle = math.rad( 360/spell[2] )
									for i = 1,spell[2] do
										shoot_projectile_ultimate( hooman, spell[1], x, y, speed*math.cos( angle ), speed*math.sin( angle ), false, function( entity_id, values )
											if( spell[3] == nil ) then
												edit_component_ultimate( entity_id, "ProjectileComponent", function(comp,vars)
													ComponentSetValue2( comp, "lifetime", 100 )
												end)
											end
										end)
										angle = angle + d_angle
									end
								end,
								function()
									EntityIngestMaterial( hooman, CellFactory_GetType( "magic_liquid_random_polymorph" ), 1 )
								end,
								-- function()
									-- 
								-- end,
								function()
									shoot_projectile_ultimate( wand_id, "mods/necro_stuff/files/spells/necro_lightning/necro_lightning.xml", x, y, 0, 0, false, function( entity_id, values )
										edit_component_ultimate( entity_id, "ProjectileComponent", function(comp,vars) 
											ComponentSetValue2( comp, "lifetime", 0 )
										end)
									end)
								end,
								-- function()
									-- -- random necro_residue rune is being loaded
								-- end,
							}
							return events[ Random( 1, #events )]()
						end
						
						tree_matrix = {
							{
								id = "A1",
								pos = { -2, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[1].name, ">Mind of Lead <", },
								desc = { shared_matrix[1].desc, "= -0.1667s reload time @ = -0.1667s cast delay @", },
								cost_nc = 0,
								cost_mc = 10,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "reload_time", ComponentObjectGetValue2( comp, "gun_config", "reload_time" ) - 10 )
										ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" ) - 10 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "A2",
								pos = { -2, 67, },
								is_unlocked = tree_unlocks["A1"] ~= nil and necro_stage > 0,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = true,
								name = { shared_matrix[1].name, ">Mind of Brass <", },
								desc = { shared_matrix[1].desc, "= -0.3333s reload time @ = -0.3333s cast delay @", },
								cost_nc = 2,
								cost_mc = 50,
								cost_nt = 0,
								cost_hp = 100,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "reload_time", ComponentObjectGetValue2( comp, "gun_config", "reload_time" ) - 20 )
										ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" ) - 20 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 2 )
								end,
							},
							{
								id = "A3",
								pos = { -2, 50, },
								is_unlocked = tree_unlocks["A2"] ~= nil and necro_stage > 1,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 2 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[1].name, ">Mind of Mercury <", },
								desc = { shared_matrix[1].desc, "= -0.5s reload time @ = -0.5s cast delay @", },
								cost_nc = 4,
								cost_mc = 90,
								cost_nt = 0,
								cost_hp = 140,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "reload_time", ComponentObjectGetValue2( comp, "gun_config", "reload_time" ) - 30 )
										ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" ) - 30 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 3 )
								end,
							},
							{
								id = "A4",
								pos = { -2, 33, },
								is_unlocked = tree_unlocks["A3"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[1].name, ">Mind of Gold <", },
								desc = { shared_matrix[1].desc, "= -0.6667s reload time @ = -0.6667s cast delay @", },
								cost_nc = 6,
								cost_mc = 130,
								cost_nt = 1,
								cost_hp = 180,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "reload_time", ComponentObjectGetValue2( comp, "gun_config", "reload_time" ) - 40 )
										ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" ) - 40 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 4 )
								end,
							},
							{
								id = "A5",
								pos = { -2, 16, },
								is_unlocked = tree_unlocks["A4"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[1].name, ">Mind Ultima <", },
								desc = { shared_matrix[1].desc, "= Always casts \"Speed Up\" @ = Reload time is meaningless @", },
								cost_nc = 15,
								cost_mc = 300,
								cost_nt = 1,
								cost_hp = 260,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "reload_time", ComponentObjectGetValue2( comp, "gun_config", "reload_time" ) - 50 )
										ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" ) - 120 )
										ComponentSetValue2( comp, "never_reload", true )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									AddGunActionPermanent( wand_id, "SPEED" )
								end,
								effect_necro = function()
									return curse_special()
								end,
							},
							
							{
								id = "B1",
								pos = { 18, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[2].name, ">Leaden Myriad <", },
								desc = { shared_matrix[2].desc, "= +1 spell per cast", },
								cost_nc = 0,
								cost_mc = 15,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" ) + 1 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "B2",
								pos = { 18, 67, },
								is_unlocked = tree_unlocks["B1"] ~= nil and necro_stage > 0,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = true,
								name = { shared_matrix[2].name, ">Brass Myriad <", },
								desc = { shared_matrix[2].desc, "= +2 spells per cast", },
								cost_nc = 4,
								cost_mc = 60,
								cost_nt = 0,
								cost_hp = 120,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" ) + 2 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 3 )
								end,
							},
							{
								id = "B3",
								pos = { 18, 50, },
								is_unlocked = tree_unlocks["B2"] ~= nil and necro_stage > 1,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 2 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[2].name, ">Mercurial Myriad <", },
								desc = { shared_matrix[2].desc, "= +3 spells per cast", },
								cost_nc = 6,
								cost_mc = 110,
								cost_nt = 0,
								cost_hp = 180,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" ) + 3 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 4 )
								end,
							},
							{
								id = "B4",
								pos = { 18, 33, },
								is_unlocked = tree_unlocks["B3"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[2].name, ">Golden Myriad <", },
								desc = { shared_matrix[2].desc, "= +4 spells per cast", },
								cost_nc = 8,
								cost_mc = 160,
								cost_nt = 1,
								cost_hp = 240,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" ) + 4 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 5 )
								end,
							},
							{
								id = "B5",
								pos = { 18, 16, },
								is_unlocked = tree_unlocks["B4"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[2].name, ">Myriad Ultima <", },
								desc = { shared_matrix[2].desc, "= Always casts \"Divide by 10\" @ = +5 spells per cast @", },
								cost_nc = 20,
								cost_mc = 400,
								cost_nt = 1,
								cost_hp = 360,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" ) + 5 )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									AddGunActionPermanent( wand_id, "DIVIDE_10" )
								end,
								effect_necro = function()
									return curse_special()
								end,
							},
							
							{
								id = "C1",
								pos = { 38, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[3].name, ">Leaden Purport <", },
								desc = { shared_matrix[3].desc, "= -10 spread @ = +1.5 speed multiplier @ = +0.2s projectile lifetime @", },
								cost_nc = 0,
								cost_mc = 20,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" ) - 10 )
										ComponentObjectSetValue2( comp, "gunaction_config", "speed_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "speed_multiplier" ) + 1.5 )
										ComponentObjectSetValue2( comp, "gunaction_config", "lifetime_add", ComponentObjectGetValue2( comp, "gunaction_config", "lifetime_add" ) + 12 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "C2",
								pos = { 38, 67, },
								is_unlocked = tree_unlocks["C1"] ~= nil and necro_stage > 1,
								unlock_case = "= Previous Rune must be obtained.  @ = Necro Tier of 2 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[3].name, ">Brass Purport <", },
								desc = { shared_matrix[3].desc, "= -20 spread @ = +1 speed multiplier @ = +0.4s projectile lifetime @", },
								cost_nc = 10,
								cost_mc = 80,
								cost_nt = 0,
								cost_hp = 150,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" ) - 20 )
										ComponentObjectSetValue2( comp, "gunaction_config", "speed_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "speed_multiplier" ) + 1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "lifetime_add", ComponentObjectGetValue2( comp, "gunaction_config", "lifetime_add" ) + 24 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 4 )
								end,
							},
							{
								id = "C3",
								pos = { 38, 50, },
								is_unlocked = tree_unlocks["C2"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[3].name, ">Mercurial Purport <", },
								desc = { shared_matrix[3].desc, "= -30 spread @ = +1 speed multiplier @ = +0.6s projectile lifetime @", },
								cost_nc = 12,
								cost_mc = 140,
								cost_nt = 0,
								cost_hp = 230,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" ) - 30 )
										ComponentObjectSetValue2( comp, "gunaction_config", "speed_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "speed_multiplier" ) + 1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "lifetime_add", ComponentObjectGetValue2( comp, "gunaction_config", "lifetime_add" ) + 36 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 5 )
								end,
							},
							{
								id = "C4",
								pos = { 38, 33, },
								is_unlocked = tree_unlocks["C3"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[3].name, ">Golden Purport <", },
								desc = { shared_matrix[3].desc, "= -40 spread @ = +1 speed multiplier @ = +0.8s projectile lifetime @", },
								cost_nc = 14,
								cost_mc = 200,
								cost_nt = 1,
								cost_hp = 310,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" ) - 40 )
										ComponentObjectSetValue2( comp, "gunaction_config", "speed_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "speed_multiplier" ) + 1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "lifetime_add", ComponentObjectGetValue2( comp, "gunaction_config", "lifetime_add" ) + 48 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 6 )
								end,
							},
							{
								id = "C5",
								pos = { 38, 16, },
								is_unlocked = tree_unlocks["C4"] ~= nil and necro_stage > 3,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 4 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[3].name, ">Purport Ultima <", },
								desc = { shared_matrix[3].desc, "= Always casts \"Duplicate\" @ = -50 spread @ = +1 speed multiplier @ = +1s projectile lifetime @", },
								cost_nc = 30,
								cost_mc = 500,
								cost_nt = 1,
								cost_hp = 470,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" ) - 50 )
										ComponentObjectSetValue2( comp, "gunaction_config", "speed_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "speed_multiplier" ) + 1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "lifetime_add", ComponentObjectGetValue2( comp, "gunaction_config", "lifetime_add" ) + 60 )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									AddGunActionPermanent( wand_id, "DUPLICATE" )
								end,
								effect_necro = function()
									return curse_special()
								end,
							},
							
							{
								id = "D1",
								pos = { 58, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[4].name, ">Blessing of Lead <", },
								desc = { shared_matrix[4].desc, "= +2.5 curse damage @ = +5% crit chance @ = +2 crit damage multiplier @", },
								cost_nc = 20,
								cost_mc = 40,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_curse_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_curse_add" ) + 0.1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_chance", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_chance" ) + 0.05 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_multiplier" ) + 2 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "D2",
								pos = { 58, 67, },
								is_unlocked = tree_unlocks["D1"] ~= nil and necro_stage > 1,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 2 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[4].name, ">Blessing of Brass <", },
								desc = { shared_matrix[4].desc, "= +5 curse damage @ = +10% crit chance @ = +0.5 crit damage multiplier @", },
								cost_nc = 30,
								cost_mc = 120,
								cost_nt = 0,
								cost_hp = 300,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_curse_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_curse_add" ) + 0.2 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_chance", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_chance" ) + 0.1 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_multiplier" ) + 0.5 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 5 )
								end,
							},
							{
								id = "D3",
								pos = { 58, 50, },
								is_unlocked = tree_unlocks["D2"] ~= nil and necro_stage > 2,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 3 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[4].name, ">Blessing of Mercury <", },
								desc = { shared_matrix[4].desc, "= +7.5 curse damage @ = +15% crit chance @ = +1 crit damage multiplier @", },
								cost_nc = 40,
								cost_mc = 200,
								cost_nt = 1,
								cost_hp = 400,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_curse_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_curse_add" ) + 0.3 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_chance", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_chance" ) + 0.15 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_multiplier" ) + 1 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 6 )
								end,
							},
							{
								id = "D4",
								pos = { 58, 33, },
								is_unlocked = tree_unlocks["D3"] ~= nil and necro_stage > 3,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 4 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[4].name, ">Blessing of Gold <", },
								desc = { shared_matrix[4].desc, "= +10 curse damage @ = +20% crit chance @ = +1.5 crit damage multiplier @", },
								cost_nc = 50,
								cost_mc = 300,
								cost_nt = 1,
								cost_hp = 500,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_curse_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_curse_add" ) + 0.4 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_chance", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_chance" ) + 0.2 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_multiplier" ) + 1.5 )
									end)
									update_gun( wand_id )
								end,
								effect_necro = function()
									return curse_generic( 7 )
								end,
							},
							{
								id = "D5",
								pos = { 58, 16, },
								is_unlocked = tree_unlocks["D4"] ~= nil and necro_stage > 4,
								unlock_case = "= Previous Rune must be obtained. @ = Necro Tier of 5 and higher is required. @",
								alt_buy = true,
								name = { shared_matrix[4].name, ">Blessing Ultima <", },
								desc = { shared_matrix[4].desc, "= Always casts \"Bloodlust\" @ = +12.5 curse damage @ = +25% crit chance @ = +2 crit damage multiplier @", },
								cost_nc = 100,
								cost_mc = 600,
								cost_nt = 2,
								cost_hp = 700,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_curse_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_curse_add" ) + 0.5 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_chance", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_chance" ) + 0.25 )
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_critical_multiplier", ComponentObjectGetValue2( comp, "gunaction_config", "damage_critical_multiplier" ) + 2 )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									AddGunActionPermanent( wand_id, "BLOODLUST" )
								end,
								effect_necro = function()
									return curse_special()
								end,
							},
							
							{
								id = "E1",
								pos = { 78, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = true,
								name = { shared_matrix[5].name, ">Supremacy of Lead <", },
								desc = { shared_matrix[5].desc, "= +10 bounces", },
								cost_nc = 20,
								cost_mc = 20,
								cost_nt = 1,
								cost_hp = 50,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "bounces", ComponentObjectGetValue2( comp, "gunaction_config", "bounces" ) + 10 )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									--Shard of Epectasy, has projectile gravity and all the projectiles nearby will bounce indefinitely with constatnly replenished bounce count
								end,
								effect_necro = function()
									local amount = 20
									local angle = 0
									local d_angle = math.rad( 360/amount )
									for i = 1,amount do
										shoot_projectile_ultimate( hooman, "mods/necro_stuff/files/spells/necro_dart/necro_dart.xml", x, y, 500*math.cos( angle ), 500*math.sin( angle ), false )
										angle = angle + d_angle
									end
								end,
							},
							{
								id = "E2",
								pos = { 78, 67, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = true,
								name = { shared_matrix[5].name, ">Supremacy of Brass <", },
								desc = { shared_matrix[5].desc, "= Unshuffles the Staff", },
								cost_nc = 50,
								cost_mc = 50,
								cost_nt = 1,
								cost_hp = 250,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "shuffle_deck_when_empty", false )
									end)
									update_gun( wand_id )
								end,
								effect_extra = function()
									--Shard of Expiation, that will make all wands unshuffled when nearby
								end,
								effect_necro = function()
									--all shuffled wands nearby explode with very harmful blast, all unshufled ones get their stats summed together to be compiled into a single staff that will be born from an explosion calculated from the same value
								end,
							},
							{
								id = "E3",
								pos = { 78, 50, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = true,
								name = { shared_matrix[5].name, ">Supremacy of Mercury <", },
								desc = { shared_matrix[5].desc, "= x2 Necro and Arcane income", },
								cost_nc = 250,
								cost_mc = 1000,
								cost_nt = 1,
								cost_hp = 1000,
								effect = function()
									GameAddFlagRun( "mercury_enabled" )
								end,
								effect_extra = function()
									--Shard of Hubris, accumulates the necro current based on global kill count and has to be shattered to obtain the 5x the stuff within but will self crumble with 1x transfer multiplier if player took any damage
								end,
								effect_necro = function()
									--all the enemies nearby get merged into a single NC filled glob that contains 10x their combined cost
								end,
							},
							{
								id = "E4",
								pos = { 78, 33, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = true,
								name = { shared_matrix[5].name, ">Supremacy of Gold <", },
								desc = { shared_matrix[5].desc, "= Upgrades 3 of the closest free-lying Necro Spells", },
								cost_nc = 1000,
								cost_mc = 50,
								cost_nt = 2,
								cost_hp = 500,
								effect = function()
									local spell_evo = {
										NECRO_RAY = "THE_IRE",
										NECRO_LIGHTNING = "THE_FAULT",
										THE_IRE = "THE_WRATH",
										THE_WRATH = "THE_ANSWER",
										THE_GUILT = "THE_TENET",
										THE_ANSWER = "THE_FAULT",
										THE_FAULT = "THE_PRESENCE",
										THE_OBLIVION = "THE_VESSEL",
										THE_PENANCE = "THE_VESSEL",
										THE_TENET = "THE_LORE",
										THE_LORE = "THE_TRUTH",
										
										NECRO_FLAGELLATION = "THE_TORMENT",
										THE_DREAM = "THE_BEHEST",
										THE_TORMENT = "THE_BEHEST",
										THE_FEAR = "NECRO_FLAGELLATION",
										THE_TRUTH = "THE_ANSWER",
										THE_HERESY = "THE_CURE",
										THE_AWAKENING = "THE_FAULT",
										THE_REVELATION = "THE_HERESY",
										THE_MACHINE = "THE_CURE",
										ABHORRENT_INFUSION = "THE_TORMENT",
										CORRUPT_INFUSION = "NECRO_INFUSION",
										ARCANE_INFUSION = "THE_LAW",
										NECRO_INFUSION = "ABHORRENT_INFUSION",
										FINNISH_INFUSION = "ARCANE_INFUSION",
										SIGIL_OF_SIN = "THE_MACHINE",
										THE_CURE = "THE_FAULT",
										
										THE_EXECUTION = "THE_AWAKENING",
										
										THE_SCHISM = "THE_DREAM",
										THE_AEON = "THE_SCHISM",
										THE_LAW = "THE_BEHEST",
										THE_RAPTURE = "THE_JUDGMENT",
										THE_JUDGMENT = "THE_QUESTION",
										THE_ASCENSION = "THE_LAW",
										THE_PRESENCE = "THE_FAULT",
										THE_QUESTION = "THE_LORE",
										THE_BEHEST = "THE_LAW",
										MEATCHUNK = function( actual_spell, spell_x, spell_y )
											EntityAddChild( hooman, EntityLoad( "mods/necro_stuff/files/spells/meatchunk/jimmy.xml", spell_x, spell_y ))
										end,
										THE_VESSEL = "THE_BEHEST",
										THE_LIMBO = "THE_PRESENCE",
										THE_EFFIGY = "THE_LIMBO",
									}
									
									local todo = { { "", 0, 0, }, { "", 0, 0, }, { "", 0, 0, }, }
									for i = 1,3 do
										local arcanes = EntityGetWithTag( "necro_spell" ) or {}
										if( #arcanes == 0 ) then
											break
										end
										
										local arcane = 0
										local min_dist = -1
										for i,spell in ipairs( arcanes ) do
											if( EntityGetRootEntity( spell ) == spell ) then
												local t_x, t_y = EntityGetTransform( spell )
												local t_dist = math.sqrt(( t_x - x )^2 + ( t_y - y )^2 )
												if( min_dist == -1 or t_dist < min_dist ) then
													min_dist = t_dist
													arcane = spell
												end
											end
										end
										if( arcane == 0 ) then
											break
										end
										
										local spell_id = spell_evo[ ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( arcane, "ItemActionComponent" ), "action_id" )] or ""
										local a_x, a_y = EntityGetTransform( arcane )
										todo[i] = { spell_id, a_x, a_y, }
										EntityRemoveTag( arcane, "necro_spell" )
										if( type( spell_id ) == "string" and spell_id ~= "" ) then
											EntityKill( arcane )
										elseif( type( spell_id ) == "function" ) then
											todo[i][4] = arcane
										end
									end
									for i,td in ipairs( todo ) do
										if( type( td[1] ) == "function" ) then
											EntityAddTag( td[4], "necro_spell" )
											td[1]( td[4], td[2], td[3] )
										elseif( td[1] ~= "" ) then
											CreateItemActionEntity( td[1], td[2], td[3] )
										end
									end
								end,
								effect_extra = function()
									--Shard of Impiety, consumes nearby vanilla spells with value calculation on LMB and will create a single random necro spell when is full
								end,
								effect_necro = function()
									--merges all the nearby free-lying spells into an Abhorrent Conglomerate, that will shoot all of them at once on cast
								end,
							},
							{
								id = "E5",
								pos = { 78, 16, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = true,
								name = { shared_matrix[5].name, ">Supremacy Ultima <", },
								desc = { shared_matrix[5].desc, "= +1 Necro Tier", },
								cost_nc = 0,
								cost_mc = 1500,
								cost_nt = 0,
								cost_hp = 1500,
								effect = function()
									ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) + ( necro_one - necro_current ))
								end,
								effect_extra = function()
									if( evo_ready == false ) then
										--Shard of Contrition, players health will be fully restored if it drops below 66 hp and player is holding it in the hand but the item will slowly yet constantly consume NC (percent based, so the rate will remain unchanged) from the stuff's bank and if it drops to 0, then the player will be instakilled with the Answer
									else
										GamePrint( "Error! Necro Tier transition is already pending!" )
										return false
									end
								end,
								effect_necro = function()
									if( evo_ready == false ) then
										--spawns Necro Degree, a physics diploma-looking item that follows the pointer
									else
										GamePrint( "Error! Necro Tier transition is already pending!" )
										return false
									end
								end,
							},
							
							{
								id = "F1",
								pos = { 98, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[6].name, ">Entrails of Lead <", },
								desc = { shared_matrix[6].desc, "= x2 max mana @ = +100 mana charge @", },
								cost_nc = 0,
								cost_mc = 30,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentSetValue2( comp, "mana_max", ComponentGetValue2( comp, "mana_max" )*2 )
										ComponentSetValue2( comp, "mana_charge_speed", ComponentGetValue2( comp, "mana_charge_speed" ) + 100 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "F2",
								pos = { 98, 67, },
								is_unlocked = tree_unlocks["F1"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[6].name, ">Entrails of Brass <", },
								desc = { shared_matrix[6].desc, "= x2 max mana @ = +200 mana charge @", },
								cost_nc = 0,
								cost_mc = 120,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentSetValue2( comp, "mana_max", ComponentGetValue2( comp, "mana_max" )*2 )
										ComponentSetValue2( comp, "mana_charge_speed", ComponentGetValue2( comp, "mana_charge_speed" ) + 200 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "F3",
								pos = { 98, 50, },
								is_unlocked = tree_unlocks["F2"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[6].name, ">Entrails of Mercury <", },
								desc = { shared_matrix[6].desc, "= x2 max mana @ = +300 mana charge @", },
								cost_nc = 0,
								cost_mc = 480,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentSetValue2( comp, "mana_max", ComponentGetValue2( comp, "mana_max" )*2 )
										ComponentSetValue2( comp, "mana_charge_speed", ComponentGetValue2( comp, "mana_charge_speed" ) + 300 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "F4",
								pos = { 98, 33, },
								is_unlocked = tree_unlocks["F3"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[6].name, ">Entrails of Gold <", },
								desc = { shared_matrix[6].desc, "= x2 max mana @ = +400 mana charge @", },
								cost_nc = 0,
								cost_mc = 1920,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentSetValue2( comp, "mana_max", ComponentGetValue2( comp, "mana_max" )*2 )
										ComponentSetValue2( comp, "mana_charge_speed", ComponentGetValue2( comp, "mana_charge_speed" ) + 400 )
									end)
									update_gun( wand_id )
								end,
							},
							
							{
								id = "G1",
								pos = { 118, 84, },
								is_unlocked = true,
								unlock_case = "= Can't be locked.",
								alt_buy = false,
								name = { shared_matrix[7].name, ">Beyond the Lead <", },
								desc = { shared_matrix[7].desc, "= +2 deck capacity", },
								cost_nc = 0,
								cost_mc = 25,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" ) + 2 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "G2",
								pos = { 118, 67, },
								is_unlocked = tree_unlocks["G1"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[7].name, ">Beyond the Brass <", },
								desc = { shared_matrix[7].desc, "= +3 deck capacity", },
								cost_nc = 0,
								cost_mc = 100,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" ) + 3 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "G3",
								pos = { 118, 50, },
								is_unlocked = tree_unlocks["G2"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[7].name, ">Beyond the Mercury <", },
								desc = { shared_matrix[7].desc, "= +4 deck capacity", },
								cost_nc = 0,
								cost_mc = 400,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" ) + 4 )
									end)
									update_gun( wand_id )
								end,
							},
							{
								id = "G4",
								pos = { 118, 33, },
								is_unlocked = tree_unlocks["G3"] ~= nil,
								unlock_case = "= Previous Rune must be obtained.",
								alt_buy = false,
								name = { shared_matrix[7].name, ">Beyond the Gold <", },
								desc = { shared_matrix[7].desc, "= +5 deck capacity", },
								cost_nc = 0,
								cost_mc = 1600,
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" ) + 5 )
									end)
									update_gun( wand_id )
								end,
							},
							
							{
								id = "FG5",
								pos = { 98, 16, },
								is_unlocked = tree_unlocks["F4"] ~= nil and tree_unlocks["G4"] ~= nil,
								unlock_case = "= Both previous Runes must be obtained.",
								alt_buy = false,
								name = { "//KNOWLEDGE ULTIMA\\\\", ">Ultimate Might <", },
								desc = { "Consolidate the fraction of the Power Beyond by forging your own omnipotence.", "= Unlocks the Garden @ = +1 Meatchunk @ = +3 random Greek Letters @ = +25 projectile damage @", },
								cost_nc = 1000,
								cost_mc = 666666 - math.floor( 1.5^get_table_count_old( tree_unlocks ) - 1 ),
								cost_nt = 0,
								cost_hp = 0,
								effect = function()
									edit_component_ultimate( wand_id, "AbilityComponent", function(comp,vars) 
										ComponentObjectSetValue2( comp, "gunaction_config", "damage_projectile_add", ComponentObjectGetValue2( comp, "gunaction_config", "damage_projectile_add" ) + 1 )
									end)
									
									-- local spells = EntityGetAllChildren( wand_id ) or {}
									-- if( #spells > 0 ) then
										-- for e,spell_id in ipairs( spells ) do
											-- local item_comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemComponent" )
											-- if( item_comp ~= nil ) then 
												-- ComponentSetValue2( item_comp, "permanently_attached", true )
											-- end
										-- end
									-- end
									
									local letters = { "ALPHA", "GAMMA", "TAU", "OMEGA", "MU", "PHI", "SIGMA", "ZETA", }
									SetRandomSeed( frame_num, hooman + x + y )
									for i = 1,3 do
										local index = Random( 1, #letters )
										GamePickUpInventoryItem( hooman, CreateItemActionEntity( letters[index], x, y ), false )
										table.remove( letters, index )
									end
									
									EntityAddChild( hooman, EntityLoad( "mods/necro_stuff/files/spells/meatchunk/jimmy.xml", x, y ))
									GamePickUpInventoryItem( hooman, CreateItemActionEntity( "MEATCHUNK", x, y ), false )
									
									update_gun( wand_id )
								end,
							},
						}
						
						selected = selected or 0
						local current = math.abs( selected )
						local is_enough = true
						for i,cell in ipairs( tree_matrix ) do
							local t_x = pic_x + cell.pos[1]
							local t_y = pic_y + cell.pos[2]
							
							local purchased = tree_unlocks[cell.id] ~= nil or ( cell.id == "E2" and not( ComponentObjectGetValue2( EntityGetFirstComponentIncludingDisabled( wand_id, "AbilityComponent"), "gun_config", "shuffle_deck_when_empty" ))) or ( cell.id == "E3" and GameHasFlagRun( "mercury_enabled" ))
							
							if( not( purchased )) then
								uid = new_image_old( gui, uid, t_x, t_y, pic_z, "mods/necro_stuff/files/gui/tree/"..( cell.is_unlocked and "_" or "" )..cell.id..".png" )
							end
							
							uid, clicked, r_clicked = new_button_old( gui, uid, t_x + 1, t_y + 1, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox"..( cell.id == "FG5" and "_large" or "" )..".png" )
							local _, _, hovered = GuiGetPreviousWidgetInfo( gui )
							if( not( purchased )) then
								local txt = ( math.abs( selected ) == i ) and "LMB to purchase. @ RMB to cancel. @" or ( cell.is_unlocked and "LMB to enter Arcane purchase mode."..( cell.alt_buy and " @ RMB to enter Necro purchase mode. @" or "" ) or ( cell.alt_buy and "RMB to enter Necro purchase mode." or "Locked." ))
								uid = new_tooltip_old( gui, uid, nil, txt )
							end
							
							if(( hovered and selected == 0 ) or math.abs( selected ) == i ) then
								local custom_params = {( cell.is_unlocked or purchased ) and cell.name or { ".x.MIGHT INSUFFICIENT.x.", ">Unlock Case <", }, ( cell.is_unlocked or purchased ) and cell.desc or cell.unlock_case, cell.is_unlocked or purchased, }
								local p_x, p_y, p_z = tooltip_x, tooltip_y, -50
								uid = new_window( gui, uid, p_x, p_y, p_z + 0.1, 150, 118, true, false )
								p_x = p_x + 2
								local t_w, t_h = GuiGetTextDimensions( gui, custom_params[1][1], 1 )
								new_text_old( gui, p_x + 73.5 - t_w/2, p_y, p_z, custom_params[1][1] )
								p_y = p_y + 10
								local pic = "mods/necro_stuff/files/gui/colour_green.png"
								uid = new_image_old( gui, uid, p_x, p_y, p_z, pic, 146, 1 )
								p_y = p_y + 1
								t_w, t_h = GuiGetTextDimensions( gui, custom_params[1][2], 1 )
								new_text_old( gui, p_x + 73.5 - t_w/2, p_y, p_z, custom_params[1][2] )
								p_y = p_y + 10
								uid = new_image_old( gui, uid, p_x + 3, p_y, p_z, pic, 140, 1 )
								uid = new_image_old( gui, uid, p_x + 6, p_y + 2, p_z, pic, 134, 1 )
								uid = new_image_old( gui, uid, p_x + 9, p_y + 4, p_z, pic, 128, 1 )
								p_y = p_y + 8
								if( custom_params[3] ) then
									new_text_old( gui, p_x, p_y, p_z, liner_old( gui, custom_params[2][1], 146, 88, 3.9 ), 2 )
									local _, _, _, l_x, l_y = GuiGetPreviousWidgetInfo( gui )
									p_y = l_y + 13
									pic = "mods/necro_stuff/files/gui/tree/divider.png"
									uid = new_image_old( gui, uid, p_x, p_y, p_z, pic )
									p_y = p_y + 3
									new_text_old( gui, p_x + 2, p_y, p_z, liner_old( gui, custom_params[2][2], 146, 88, 3.9 ), 2 )
									local _, _, _, l_x, l_y = GuiGetPreviousWidgetInfo( gui )
									p_y = l_y + 13
									uid = new_image_old( gui, uid, p_x, p_y, p_z, pic, 1, -1 )
								else
									new_text_old( gui, p_x, p_y, p_z, liner_old( gui, custom_params[2], 146, 88, 3.9 ), 2 )
								end
							
								if( selected == 0 and cell.is_unlocked ) then
									current = i
								end
								uid = new_image_old( gui, uid, t_x, t_y - 1, pic_z - 0.05, "mods/necro_stuff/files/gui/tree/"..( math.abs( selected ) == i and "select" or "highlight" )..( cell.id == "FG5" and "_large" or "" )..".png" )
								
								if( selected < 0 ) then
									is_enough = not( hooman_hp < tree_matrix[i].cost_hp or ( necro_stage - 1 ) < tree_matrix[i].cost_nt )
								else
									is_enough = not( mana_current < tree_matrix[i].cost_mc*price_offset or necro_current < tree_matrix[i].cost_nc*price_offset )
								end
								
								if( selected ~= 0 ) then
									local info = {
										{
											name = ">>Arcane Purchase Mode",
											desc = "= Rune must be unlocked before the purchase. @ = Arcane and occasionally Necro Current is being spent. @",
										},
										{
											name = ">>Necro Purchase Mode",
											desc = "= No need to unlock the Runes. @ = HP and occasionally Necro Tiers are being spent. @ = Purchase might have some undesired secondary effects. @",
										},
									}
									
									local w_x, w_y = global_x + 1, global_y + 124
									uid = new_window( gui, uid, w_x, w_y, p_z + 0.1, 159, 59, false, false )
									new_text_old( gui, w_x + 2, w_y + 1, p_z, info[ selected > 0 and 1 or 2 ].name )
									new_text_old( gui, w_x + 2, w_y + 12, p_z, liner_old( gui, info[ selected > 0 and 1 or 2 ].desc, 155, 55, 3.9 ), 2 )
								end
							end
							
							if( not( purchased )) then
								if( clicked ) then
									if( math.abs( selected ) == i ) then
										if( is_enough ) then
											local going_intertier = selected > 0 and nc_visual < tree_matrix[current].cost_nc*price_offset
											if( going_intertier and not( intertier_proceed )) then
												intertier_warning = true
											else
												if( intertier_proceed ) then
													intertier_proceed = false
												end
												
												local status = nil
												if( selected < 0 ) then
													status = tree_matrix[current].effect_necro()
												elseif( tree_matrix[current].effect_extra ~= nil ) then
													status = tree_matrix[current].effect_extra()
												end
												if( status ~= false ) then
													if( tree_matrix[current].effect() ~= false ) then
														ComponentSetValue2( storage_tree, "value_string", ComponentGetValue2( storage_tree, "value_string" )..tree_matrix[current].id.."|" )
														
														if( status ~= true ) then
															if( selected < 0 ) then
																if( tree_matrix[current].cost_hp > 0 ) then
																	EntityInflictDamage( hooman, tree_matrix[current].cost_hp/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, wand_id, h_x, h_y, 0 )
																	too_smart_check( hooman, hooman_hp )
																end
																if( tree_matrix[current].cost_nt > 0 ) then
																	ComponentSetValue2( storage_necro, "value_float", ( necro_stage == 7 ) and math.max(( ComponentGetValue2( storage_necro, "value_float" ) - 10000 ), ladder_table[ 7 ]) or ( ladder_table[ necro_stage - tree_matrix[current].cost_nt ] + nc_visual ))
																end
															else
																if( tree_matrix[current].cost_mc > 0 ) then
																	ComponentSetValue2( storage_mana, "value_float", ComponentGetValue2( storage_mana, "value_float" ) - tree_matrix[current].cost_mc*price_offset )
																end
																if( tree_matrix[current].cost_nc > 0 ) then
																	ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) - tree_matrix[current].cost_nc*price_offset )
																end
															end
														end
													end
												end
												selected = 0
											end
										else
											GamePrint( "Insufficient Resources" )
										end
									elseif( cell.is_unlocked ) then
										selected = i
									end
								end
								if( r_clicked ) then
									if( math.abs( selected ) == i ) then
										selected = 0
									elseif( cell.alt_buy ) then
										selected = -i
									end
								end
							end
						end
						
						if( current > 0 ) then
							local is_active = tree_unlocks[tree_matrix[current].id] ~= nil or ( tree_matrix[current].id == "E2" and not( ComponentObjectGetValue2( EntityGetFirstComponentIncludingDisabled( wand_id, "AbilityComponent" ), "gun_config", "shuffle_deck_when_empty" ))) or ( tree_matrix[current].id == "E3" and GameHasFlagRun( "mercury_enabled" ))
							if( not( is_active )) then
								local text = ( selected < 0 ) and ( "HP: "..tree_matrix[current].cost_hp..( tree_matrix[current].cost_nt > 0 and " | NT: "..tree_matrix[current].cost_nt or "" )) or ( "AC: "..tree_matrix[current].cost_mc..( tree_matrix[current].cost_nc > 0 and " | NC: "..tree_matrix[current].cost_nc or "" ))
								local t_w, t_h = GuiGetTextDimensions( gui, text, 1 )
								new_text_old( gui, pic_x + 67.5 - t_w/2, pic_y + 102, pic_z, text, is_enough and 1 or 2 )
								
								uid = new_button_old( gui, uid, pic_x, pic_y + 102, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_long.png" )
								uid = new_tooltip_old( gui, uid, nil, ".x.Rune Cost.x.", ( selected < 0 ) and ( "Harm Points: "..tree_matrix[current].cost_hp.."/"..hooman_hp..( tree_matrix[current].cost_nt > 0 and " @ Necro Tiers: "..tree_matrix[current].cost_nt.."/"..( necro_stage - 1 ) or "" )) or ( "Arcane Current: "..tree_matrix[current].cost_mc.."/"..( math.floor( mana_current )/price_offset )..( tree_matrix[current].cost_nc > 0 and " @ Necro Current: "..tree_matrix[current].cost_nc.."/"..( math.floor( nc_visual )/price_offset ) or "" )))
							end
						end
						
						return uid
					end,
				},
				{
					name = "The Abyss",
					title = "mods/necro_stuff/files/gui/title_beast.png",
					background = "mods/necro_stuff/files/gui/background_beast.png",
					label = "mods/necro_stuff/files/gui/label_beast",
					contents = function( gui, uid, pic_x, pic_y, pic_z )
						uid = new_image_old( gui, uid, pic_x + 66, pic_y + 14, pic_z - 0.01, "mods/necro_stuff/files/gui/window/fancy.png" )
						uid = new_image_old( gui, uid, pic_x + 83, pic_y + 14, pic_z - 0.01, "mods/necro_stuff/files/gui/window/fancy.png" )
						
						uid = new_counter( gui, uid, pic_x + 108, pic_y - 1, pic_z, nc_visual/price_offset, 4 )
						
						uid = new_button_old( gui, uid, pic_x + 103, pic_y - 1, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_counter_abyss.png" )
						uid = new_tooltip_old( gui, uid, nil, "Necro Current: "..math.floor( nc_visual )/price_offset, "Kill creatures to gain more." )
						
						uid = new_window( gui, uid, pic_x, pic_y + 19, pic_z + 0.01, 49, 75 )
						
						selected_parts = selected_parts or { 1, 1, 1, 1, 1, }
						enders = { "tiny", "medium", "large", }
						local bodyparts = {
							{
								name = "CORE",
								contents = {
									{
										name = "Null",
										desc = "[NONE]",
										stats = function()
											return { 0, 0, 0, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 0,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_null",
										effect = function( aid, spawn_x, spawn_y )
										end,
									},
									{
										name = "Terminated",
										desc = "Boosts the creature's sentience level by interrupting abomination-master mainline interrelation, allowing the beast to engage the threats according to its own will.",
										stats = function()
											return { 0, 0, 0.5, -1, 1, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[4] ~= 3 and true or 1
										end,
										real_case = { "Currently selected Pact requires the creature to be bound to its master.", },
										cost_nc = 1,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_free",
										visual = "mods/necro_stuff/files/gui/abominations/head_free",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/free.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											local charm = get_hooman_child_old( aid, "charm" )
											if( charm ~= nil ) then
												EntityKill( charm )
											end
											
											EntityRemoveTag( aid, "cured" )
											EntityAddTag( aid, "uncurable" )
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "turning_buffer", 0.1 )
											end)
										end,
									},
									{
										name = "Abridged",
										desc = "Performs an act of Continuum Emergence, concentrating entire creature's being into a speckle of former self. The resulting singularity-like structure is then used as a dimensional anchor, that will maintain the existence of the beast no matter the state of the surrounding reality.",
										stats = function()
											return { 0, nil, -1, 0, -2, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[4] ~= 3 and true or 1
										end,
										real_case = { "The nature of the Continuum Emergence will interfere with the selected Pact.", },
										cost_nc = 2,
										cost_mc = 1,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_static",
										visual = "mods/necro_stuff/files/gui/abominations/head_static",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/static.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											EntityAddComponent( aid, "StreamingKeepAliveComponent" )
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "turning_buffer", 0.1 )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "accel_x", 0 )
												ComponentSetValue2( comp, "accel_x_air", 0 )
												ComponentSetValue2( comp, "jump_velocity_x", 0 )
												ComponentSetValue2( comp, "jump_velocity_y", 0 )
												ComponentSetValue2( comp, "fly_speed_mult", 0 )
												ComponentSetValue2( comp, "fly_speed_max_up", 0 )
											end)
											
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", false )
												ComponentSetValue2( comp, "can_walk", false )
												ComponentSetValue2( comp, "attack_dash_enabled", false )
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", false )
												ComponentSetValue2( comp, "can_dive", false )
												ComponentSetValue2( comp, "can_walk", false )
												ComponentSetValue2( comp, "can_jump", false )
												ComponentSetValue2( comp, "can_swim_on_surface", false )
												ComponentSetValue2( comp, "jump_speed", 0 )
											end)
											
											edit_component_ultimate( aid, "PhysicsAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "force_coeff", 0 )
												ComponentSetValue2( comp, "force_max", 0 )
												ComponentSetValue2( comp, "force_balancing_coeff", 0 )
												ComponentSetValue2( comp, "torque_coeff", 0 )
												ComponentSetValue2( comp, "torque_max", 0 )
											end)
											
											EntityAddComponent( aid, "LuaComponent", 
											{
												script_source_file = "mods/necro_stuff/files/anchor.lua",
												execute_every_n_frame = "1",
											})
											
											EntityAddComponent( aid, "VariableStorageComponent", 
											{
												name = "anchor_x",
												value_float = "0",
											})
											
											EntityAddComponent( aid, "VariableStorageComponent", 
											{
												name = "anchor_y",
												value_float = "0",
											})
										end,
									},
									{
										name = "Imperious",
										desc = "Implants an auxiliary consciousness capable of projecting Necro Current based missiles onto the nearby hostiles.",
										stats = function()
											return { 0, 0, selected_parts[5], 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 5,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_combat",
										visual = "mods/necro_stuff/files/gui/abominations/head_combat",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/combat.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											edit_component_ultimate( head, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "attack_ranged_frames_between", ComponentGetValue2( comp, "attack_ranged_frames_between" )/selected_parts[5] )
											end)
										end,
									},
									{
										name = "Entombed",
										desc = "Erects a dimensional tomb around the creature and shifts the crypt walls into the tangible reality, protecting the beast and everything else within from unsynchronized projectiles.",
										stats = function()
											return { 2, 0, 0, 1, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 3,
										cost_mc = 3,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_shield",
										visual = "mods/necro_stuff/files/gui/abominations/head_shield",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/shield.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											local shield = EntityLoad( "mods/necro_stuff/files/abominations/head/shield_field.xml", spawn_x, spawn_y )
											ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( shield, "EnergyShieldComponent" ), "radius", 9*selected_parts[2] )
											ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( shield, "ParticleEmitterComponent" ), "area_circle_radius", 0, 9*selected_parts[2] )
											local comp = EntityGetFirstComponentIncludingDisabled( shield, "ParticleEmitterComponent", "shield_ring" )
											ComponentSetValue2( comp, "area_circle_radius", 9*selected_parts[2], 9*selected_parts[2] )
											-- ComponentSetValue2( comp, "count_min", math.ceil( ComponentGetValue2( comp, "count_min" )/( 4 - selected_parts[2] )))
											-- ComponentSetValue2( comp, "count_max", math.ceil( ComponentGetValue2( comp, "count_max" )/( 4 - selected_parts[2] )))
											comp = EntityGetFirstComponentIncludingDisabled( shield, "ParticleEmitterComponent", "shield_hit" )
											ComponentSetValue2( comp, "area_circle_radius", 9*selected_parts[2], 9*selected_parts[2] )
											-- ComponentSetValue2( comp, "count_min", math.ceil( ComponentGetValue2( comp, "count_min" )/( 4 - selected_parts[2] )))
											-- ComponentSetValue2( comp, "count_max", math.ceil( ComponentGetValue2( comp, "count_max" )/( 4 - selected_parts[2] )))
											EntityAddChild( aid, shield )
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "max_hp", 2*ComponentGetValue2( comp, "max_hp" ))
												ComponentSetValue2( comp, "hp", ComponentGetValue2( comp, "max_hp" ))
											end)
										end,
									},
									{
										name = "Astute",
										desc = "Utilizes advanced Dimensional Assertion Algorithms (DAA) to detect, evaluate and analyze several types of anomalies in the local space.",
										stats = function()
											return { 0, 0, 0, 2, 0.5, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 1,
										cost_mc = 8,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_detector",
										visual = "mods/necro_stuff/files/gui/abominations/head_detector",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/detector.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											EntityAddComponent( aid, "LuaComponent", 
											{
												script_source_file = "mods/necro_stuff/files/radar_wand.lua",
												execute_every_n_frame = "1",
											})
											
											EntityAddComponent( aid, "LuaComponent", 
											{
												script_source_file = "mods/necro_stuff/files/radar_item.lua",
												execute_every_n_frame = "1",
											})
										end,
									},
									{
										name = "Defiled",
										desc = "Generates Praemortem core inside the beast, that will continuously suck Praeanima from the surrounding area, healing the abomination and damaging the foes. Once its structure will be completely restored, the creature will also attempt to mend its master's wounds.",
										stats = function()
											return { 0.5, 0, 1, 3, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 10,
										cost_mc = 0,
										cost_hp = 10,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_vampire",
										visual = "mods/necro_stuff/files/gui/abominations/head_vampire",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/vampire.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
										end,
									},
									{
										name = "Omniscient",
										desc = "Constructs a crude Mors Lignum directly within the creature's consciousness to enable the beast with some of the less advanced powers of the Staff, like enemy detection, all-seeing and an application of a certain effect to every projectile fired.",
										stats = function()
											return { 0, 0, 1, 3, 5, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 15,
										cost_mc = 10,
										cost_hp = 10,
										pic = "mods/necro_stuff/files/gui/bodyparts/head_sight",
										visual = "mods/necro_stuff/files/gui/abominations/head_sight",
										effect = function( aid, spawn_x, spawn_y )
											local head = EntityLoad( "mods/necro_stuff/files/abominations/head/sight.xml", spawn_x, spawn_y )
											EntityAddChild( aid, head )
											
											EntityAddComponent( aid, "LuaComponent", 
											{
												script_source_file = "mods/necro_stuff/files/radar_enemy.lua",
												execute_every_n_frame = "1",
											})
											
											local wander = EntityLoad( "data/entities/buildings/workshop_allow_mods.xml", spawn_x, spawn_y )
											edit_component_ultimate( wander, "HitboxComponent", function(comp,vars) 
												ComponentSetValue2( comp, "aabb_min_x", -20 )
												ComponentSetValue2( comp, "aabb_min_y", -20 )
												ComponentSetValue2( comp, "aabb_max_x", 20 )
												ComponentSetValue2( comp, "aabb_max_y", 20 )
											end)
											EntityAddComponent( wander, "InheritTransformComponent", 
											{
												parent_hotspot_tag = "head_pos",
											})
											EntityAddChild( aid, wander )
											
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "sense_creatures_through_walls", true )
												ComponentSetValue2( comp, "creature_detection_range_x", ComponentGetValue2( comp, "creature_detection_range_x" )*5 )
												ComponentSetValue2( comp, "creature_detection_range_y", ComponentGetValue2( comp, "creature_detection_range_y" )*5 )
											end)
											
											EntityAddComponent( aid, "ShotEffectComponent", 
											{
												extra_modifier = "omniscient_power",
											})
										end,
									},
								},
							},
							{
								name = "SHELL",
								contents = {
									{
										name = "Infirm",
										desc = "Compact yet weak body, designed as a cheap disposable measure. Can be picked up if there's no Core attached and is remarkably hard to hit at range.",
										stats = function()
											return { 0, 2, 1, selected_parts[1] == 1 and 1 or 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 5,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/body_tiny",
										visual = "mods/necro_stuff/files/gui/abominations/body_tiny",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentObjectSetValue2( comp, "damage_multipliers", "projectile", -0.1 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "melee", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "slice", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "drill", 0 )
											end)
											
											if( selected_parts[3] ~= 1 and selected_parts[3] ~= 3 ) then
												edit_component_ultimate( aid, "CharacterDataComponent", function(comp,vars) 
													ComponentSetValue2( comp, "collision_aabb_max_y", 1 )
												end)
												
												edit_component_ultimate( aid, "HitboxComponent", function(comp,vars) 
													ComponentSetValue2( comp, "aabb_max_y", 1 )
												end)
											end
											
											if( selected_parts[1] == 1 and selected_parts[3] ~= 2 and selected_parts[4] ~= 2 ) then
												EntityAddComponent( aid, "ItemComponent", 
												{ 
													_tags = "enabled_in_world",
													item_name = "Abomination",
													max_child_items = "0",
													is_pickable = "1",
													is_equipable_forced = "1",
													uses_remaining = "-1",
													play_spinning_animation = "0",
													ui_sprite = "mods/necro_stuff/files/abominations/body/tiny_icon.png",
													ui_description = "Man-made horror beyond comprehension. \n Throw to let the terror unfold.",
													preferred_inventory = "QUICK",
												})
												
												EntityAddComponent( aid, "InheritTransformComponent",
												{ 
													_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
												})
												
												local abil_comp = EntityAddComponent( aid, "AbilityComponent", 
												{ 
													_tags = "enabled_in_world",
													ui_name = "Abomination",
													throw_as_item = "1",
													use_gun_script = "0",
												})
												ComponentObjectSetValue2( abil_comp, "gun_config", "deck_capacity", 0 )
												
												EntityAddComponent( aid, "LuaComponent", 
												{ 
													_tags = "enabled_in_hand",
													script_source_file = "mods/necro_stuff/files/anim_maintainer.lua",
													execute_every_n_frame = "10",
												})
												
												EntityAddComponent( aid, "LuaComponent", 
												{ 
													_tags = "enabled_in_hand,enabled_in_inventory",
													script_enabled_changed = "mods/necro_stuff/files/handheld_maintainer.lua",
													execute_every_n_frame = "-1",
												})
												
												EntityAddComponent( aid, "VariableStorageComponent", 
												{ 
													name = "anim_name",
													value_string = "stand",
												})
											end
											
											if( selected_parts[1] == 2 ) then
												edit_component_ultimate( aid, "GenomeDataComponent", function(comp,vars) 
													ComponentSetValue2( comp, "herd_id", StringToHerdId( "necro_abomination_tiny" ))
												end)
											end
											
											local ragdoll = "mods/necro_stuff/files/abominations/ragdolls/filenames_tiny"
											if( selected_parts[3] == 1 ) then
												ragdoll = ragdoll.."_legs"
											elseif( selected_parts[3] == 3 ) then
												ragdoll = ragdoll.."_wings"
											end
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars)
												ComponentSetValue2( comp, "ragdoll_filenames_file", ragdoll..".txt" )
												ComponentSetValue2( comp, "ragdoll_offset_x", -2 )
												ComponentSetValue2( comp, "ragdoll_offset_y", 1 )
											end)
										end,
									},
									{
										name = "Adapted",
										desc = "Fully sentient advanced body, developed primarily as an assistance for Mors Lignum operators. Features the most sophisticated secondary processing core amongst all the known abominable Shells, which allows it to pick up and purposefully utilize certain objects.",
										stats = function()
											return { 1, 0, 2, 1.5, 1, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 10,
										cost_mc = 5,
										cost_hp = 1,
										pic = "mods/necro_stuff/files/gui/bodyparts/body_medium",
										visual = "mods/necro_stuff/files/gui/abominations/body_medium",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_with_tag_ultimate( aid, "SpriteComponent", "character", function(comp,vars) 
												ComponentSetValue2( comp, "image_file", "mods/necro_stuff/files/abominations/body/medium.xml" )
												EntityRefreshSprite( aid, comp )
											end)
											
											edit_component_with_tag_ultimate( aid, "AudioComponent", "main", function(comp,vars) 
												ComponentSetValue2( comp, "event_root", "animals/bigbat" )
											end)
											
											edit_component_with_tag_ultimate( aid, "AudioComponent", "wing", function(comp,vars) 
												ComponentSetValue2( comp, "event_root", "animals/wing_flap_skin_big" )
											end)
											
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "attack_dash_enabled", false )
												ComponentSetValue2( comp, "attack_melee_max_distance", 20 )
												ComponentSetValue2( comp, "attack_melee_damage_min", 1 )
												ComponentSetValue2( comp, "attack_melee_damage_max", 1.5 )
												ComponentSetValue2( comp, "attack_melee_impulse_multiplier", 200 )
											end)
											
											edit_component_ultimate( aid, "CharacterDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "mass", 2 )
												ComponentSetValue2( comp, "collision_aabb_max_x", 4 )
												ComponentSetValue2( comp, "collision_aabb_max_y", selected_parts[3] == 1 and 6 or 3 )
												ComponentSetValue2( comp, "collision_aabb_min_x", -4 )
												ComponentSetValue2( comp, "collision_aabb_min_y", -2 )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "accel_x", 0.05 )
												ComponentSetValue2( comp, "accel_x_air", 0.05 )
											end)
											
											edit_component_ultimate( aid, "HitboxComponent", function(comp,vars) 
												ComponentSetValue2( comp, "aabb_max_x", 4 )
												ComponentSetValue2( comp, "aabb_max_y", selected_parts[3] == 1 and 6 or 3 )
												ComponentSetValue2( comp, "aabb_min_x", -4 )
												ComponentSetValue2( comp, "aabb_min_y", -2 )
											end)
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "max_hp", 10 )
												ComponentSetValue2( comp, "hp", 10 )
											end)
											
											edit_component_ultimate( aid, "GenomeDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "food_chain_rank", 10 )
												ComponentSetValue2( comp, "is_predator", true )
											end)
											
											EntityAddComponent( aid, "ItemPickUpperComponent", 
											{ 
												is_immune_to_kicks = "0",
												is_in_npc = "1",
											})
											
											local ragdoll = "mods/necro_stuff/files/abominations/ragdolls/filenames_medium"
											if( selected_parts[3] == 1 ) then
												ragdoll = ragdoll.."_legs"
											elseif( selected_parts[3] == 3 ) then
												ragdoll = ragdoll.."_wings"
											end
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars)
												ComponentSetValue2( comp, "ragdoll_filenames_file", selected_parts[3] == 2 and "" or ragdoll..".txt" )
												ComponentSetValue2( comp, "ragdoll_offset_x", -2 )
												ComponentSetValue2( comp, "ragdoll_offset_y", 0 )
											end)
										end,
									},
									{
										name = "Sublime",
										desc = "Military-grade heavily-armoured and highly-trained body, designed to combat mechanized infantry while keeping the weight low and mobility high. Contains a whole spectrum of bleeding-edge necro-active components with every single one being dedicated to maximising the creature's lethal output.",
										stats = function()
											return { 5, 0.5, 5, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 25,
										cost_mc = 5,
										cost_hp = 5,
										pic = "mods/necro_stuff/files/gui/bodyparts/body_large",
										visual = "mods/necro_stuff/files/gui/abominations/body_large",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_with_tag_ultimate( aid, "SpriteComponent", "character", function(comp,vars) 
												ComponentSetValue2( comp, "image_file", "mods/necro_stuff/files/abominations/body/large.xml" )
												EntityRefreshSprite( aid, comp )
											end)
											
											edit_component_with_tag_ultimate( aid, "AudioComponent", "main", function(comp,vars) 
												ComponentSetValue2( comp, "event_root", "animals/giantshooter" )
											end)
											
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "attack_dash_enabled", false )
												ComponentSetValue2( comp, "attack_melee_max_distance", 30 )
												ComponentSetValue2( comp, "attack_melee_damage_min", 3 )
												ComponentSetValue2( comp, "attack_melee_damage_max", 4 )
												ComponentSetValue2( comp, "attack_melee_impulse_multiplier", 300 )
											end)
											
											edit_component_ultimate( aid, "CharacterDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "mass", 10 )
												ComponentSetValue2( comp, "collision_aabb_max_x", 6 )
												ComponentSetValue2( comp, "collision_aabb_max_y", selected_parts[3] == 1 and 7 or 5 )
												ComponentSetValue2( comp, "collision_aabb_min_x", -6 )
												ComponentSetValue2( comp, "collision_aabb_min_y", -5 )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "accel_x", 0.03 )
												ComponentSetValue2( comp, "accel_x_air", 0.03 )
											end)
											
											edit_component_ultimate( aid, "HitboxComponent", function(comp,vars) 
												ComponentSetValue2( comp, "aabb_max_x", 6 )
												ComponentSetValue2( comp, "aabb_max_y", selected_parts[3] == 1 and 7 or 5 )
												ComponentSetValue2( comp, "aabb_min_x", -6 )
												ComponentSetValue2( comp, "aabb_min_y", -5 )
											end)
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "max_hp", 100 )
												ComponentSetValue2( comp, "hp", 100 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "projectile", 0.5 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "melee", -2 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "slice", 0.5 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "drill", 0.5 )
											end)
											
											edit_component_ultimate( aid, "GenomeDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "food_chain_rank", 1 )
												ComponentSetValue2( comp, "is_predator", true )
											end)
											
											ComponentSetValue2( GetGameEffectLoadTo( aid, "KNOCKBACK_IMMUNITY", true ), "frames", -1 )
											
											local ragdoll = "mods/necro_stuff/files/abominations/ragdolls/filenames_large"
											if( selected_parts[3] == 1 ) then
												ragdoll = ragdoll.."_legs"
											elseif( selected_parts[3] == 2 ) then
												ragdoll = ""
											end
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars)
												ComponentSetValue2( comp, "ragdoll_filenames_file", selected_parts[3] == 2 and "" or ragdoll..".txt" )
												ComponentSetValue2( comp, "ragdoll_offset_x", -2 )
												ComponentSetValue2( comp, "ragdoll_offset_y", 0 )
											end)
										end,
									},
								},
							},
							{
								name = "ESSENCE",
								contents = {
									{
										name = "6th Sigil",
										desc = "Developed primarily as a way of cheap and reliable locomotion, the 6th Sigil procedure results in grows of multiple distinct leg-like structures from the creature it was applied to.",
										stats = function()
											return { 0, 1, 0, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 1,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/movement_legs",
										visual = {
											"mods/necro_stuff/files/gui/abominations/legs_tiny.png",
											"mods/necro_stuff/files/gui/abominations/legs_medium.png",
											"mods/necro_stuff/files/gui/abominations/legs_large.png",
										},
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "keyboard_look", true )
											end)
										
											EntityAddComponent( aid, "SpriteComponent", 
											{ 
												_tags = "enabled_in_world,character",
												image_file = "mods/necro_stuff/files/abominations/legs/"..enders[selected_parts[2]]..".xml",
												rect_animation = "walk",
												z_index = "-1.005",
											})
											
											if( selected_parts[2] == 3 ) then
												edit_component_with_tag_ultimate( aid, "SpriteComponent", "character", function(comp,vars) 
													ComponentSetValue2( comp, "image_file", "mods/necro_stuff/files/abominations/body/large_alt.xml" )
													EntityRefreshSprite( aid, comp )
												end)
											end
										end,
									},
									{
										name = "5th Sigil",
										desc = "Mostly put into service throughout the law-and-order sector, the 5th Sigil procedure enables the abomination with high-speed all-terrain mobility, broad climbing capabilities in urban environments and rudimentary offensive measures, while still maintaining quite an affordable price.",
										stats = function()
											return { 0, 2, 0.5, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[2] ~= 1 and true or 1
										end,
										real_case = { "Selected Shell is too primitive for the ritual to succeed.", },
										cost_nc = 3,
										cost_mc = 2,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/movement_lukki",
										visual = {
											nil,
											"mods/necro_stuff/files/gui/abominations/lukki_medium.png",
											"mods/necro_stuff/files/gui/abominations/lukki_large.png",
										},
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_walk", true )
												ComponentSetValue2( comp, "attack_dash_enabled", false )
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_dive", true )
												ComponentSetValue2( comp, "can_walk", true )
												ComponentSetValue2( comp, "can_jump", false )
												ComponentSetValue2( comp, "jump_speed", 0 )
												ComponentSetValue2( comp, "cost_of_flying", 0 )
											end)
											
											edit_component_ultimate( aid, "PathFindingGridMarkerComponent", function(comp,vars) 
												ComponentSetValue2( comp, "marker_offset_y", 0 )
												ComponentSetValue2( comp, "marker_work_flag", 16 )
											end)
											
											edit_component_ultimate( aid, "CharacterDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "effect_hit_ground", false )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "pixel_gravity", 0 )
											end)
											
											EntityAddComponent( aid, "LimbBossComponent", 
											{ 
												state = "1",
											})
											
											EntityAddComponent( aid, "IKLimbsAnimatorComponent", 
											{ 
												no_ground_attachment_penalty_coeff = "0.5",
												leg_velocity_coeff = "15",
											})
											
											for i = 1,3 do
												EntityAddChild( aid, EntityLoad( "mods/necro_stuff/files/stuff/leg.xml", spawn_x, spawn_y ))
											end
											EntityAddChild( aid, EntityLoad( "mods/necro_stuff/files/stuff/leg_attacker.xml", spawn_x, spawn_y ))
											
											EntityAddComponent( aid, "PhysicsShapeComponent", 
											{ 
												is_circle = "1",
												radius_x = 2*selected_parts[2],
												radius_y = selected_parts[2],
												friction = "0.0",
												restitution = "0.3",
											})
											
											EntityAddComponent( aid, "PhysicsBodyComponent", 
											{ 
												force_add_update_areas = "1",
												allow_sleep = "1", 
												angular_damping = "0.02", 
												fixed_rotation = "1", 
												is_bullet = "0", 
												linear_damping = "0",
											})
											
											EntityAddComponent( aid, "PhysicsAIComponent", 
											{ 
												target_vec_max_len = "10",
												force_coeff = "5",
												force_balancing_coeff = "0.1",
												force_max = "20",
												torque_coeff = "50",
												torque_balancing_coeff = "4",
												torque_max = "50.0",
												damage_deactivation_probability = "0",
												free_if_static = "1",
											})
										end,
									},
									{
										name = "4th Sigil",
										desc = "Incredibly efficient but sadly not all that reliable, the 4th Sigil procedure results in the formation of the wing-like appendages, capable of achieving high speeds and possessing remarkable yet still limited cargo lifting capacities.",
										stats = function()
											return { 0, selected_parts[2] == 1 and 2.5 or 2, 0, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[2] ~= 3 and true or 1
										end,
										real_case = { "Selected Shell can't be lifted by wings.", },
										cost_nc = 2,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/movement_wings",
										visual = {
											"mods/necro_stuff/files/gui/abominations/wings_tiny.png",
											"mods/necro_stuff/files/gui/abominations/wings_medium.png",
										},
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_walk", selected_parts[2] == 1 )
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_walk", selected_parts[2] == 1 )
												ComponentSetValue2( comp, "can_jump", selected_parts[2] == 1 )
												ComponentSetValue2( comp, "cost_of_flying", 10 )
											end)
										
											EntityAddComponent( aid, "SpriteComponent", 
											{ 
												_tags = "enabled_in_world,character",
												image_file = "mods/necro_stuff/files/abominations/wings/"..enders[selected_parts[2]]..".xml",
												rect_animation = "walk",
												z_index = "-1.01",
											})
											
											if( selected_parts[2] == 1 ) then
												edit_component_with_tag_ultimate( aid, "HotspotComponent", "head_pos", function(comp,vars) 
													ComponentSetValue2( comp, "sprite_hotspot_name", "head_root_wings" )
												end)
												
												EntityAddComponent( aid, "SpriteComponent", 
												{ 
													_tags = "enabled_in_world,character",
													image_file = "mods/necro_stuff/files/abominations/legs/tiny.xml",
													rect_animation = "walk",
													z_index = "-1.005",
												})
											end
										end,
									},
									{
										name = "3rd Sigil",
										desc = "Being the most advanced mobility ritual available to the public, the 3rd Sigil implementation not only doesn't feature any lifting weight limitations but also is prominent for its outstanding trust-to-weight ratio, as well as for its equally astonishing power-hunger on the industrial scale beasts.",
										stats = function()
											return { 0, 3, 0, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 5,
										cost_mc = 2,
										cost_hp = 1,
										pic = "mods/necro_stuff/files/gui/bodyparts/movement_hover",
										visual = {},
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_walk", true )
												ComponentSetValue2( comp, "attack_dash_enabled", false )
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "can_fly", true )
												ComponentSetValue2( comp, "can_dive", true )
												ComponentSetValue2( comp, "can_walk", true )
												ComponentSetValue2( comp, "can_jump", false )
												ComponentSetValue2( comp, "jump_speed", 0 )
												ComponentSetValue2( comp, "cost_of_flying", 0 )
											end)
											
											edit_component_ultimate( aid, "PathFindingGridMarkerComponent", function(comp,vars) 
												ComponentSetValue2( comp, "marker_offset_y", 0 )
												ComponentSetValue2( comp, "marker_work_flag", 16 )
											end)
											
											edit_component_ultimate( aid, "CharacterDataComponent", function(comp,vars) 
												ComponentSetValue2( comp, "effect_hit_ground", false )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "pixel_gravity", 0 )
											end)
											
											EntityAddComponent( aid, "PhysicsShapeComponent", 
											{ 
												_tags = "enabled_in_world",
												is_circle = "1",
												radius_x = 2*selected_parts[2],
												radius_y = selected_parts[2],
												friction = "0.0",
												restitution = "0.3",
											})
											
											EntityAddComponent( aid, "PhysicsBodyComponent", 
											{ 
												_tags = "enabled_in_world",
												force_add_update_areas = "1",
												allow_sleep = "1", 
												angular_damping = "0.02", 
												fixed_rotation = "1", 
												is_bullet = "0", 
												linear_damping = "0",
											})
											
											EntityAddComponent( aid, "PhysicsAIComponent", 
											{ 
												_tags = "enabled_in_world",
												target_vec_max_len = "10",
												force_coeff = "5",
												force_balancing_coeff = "0.1",
												force_max = "20",
												torque_coeff = "50",
												torque_balancing_coeff = "4",
												torque_max = "50.0",
												damage_deactivation_probability = "0",
												free_if_static = "1",
											})
										end,
									},
								},
							},
							{
								name = "PACT",
								contents = {
									{
										name = "Null",
										desc = "[NONE]",
										stats = function()
											return { 0, 0, 0, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 0,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_null",
										effect = function( aid, spawn_x, spawn_y )
										end,
									},
									{
										name = "Tempestuous",
										desc = "Heavy-duty Nobilis Animae armour plating infused with compacted reality pockets brings the abomination onto the new level of resilience with the added benefit of being fully tangible.",
										stats = function()
											return { 3, 1, 1, 1, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[3] == 4 and true or 1
										end,
										real_case = { "This Pact requires the 3rd Sigil to sustain the weight of all the armouring.", },
										cost_nc = 5,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_physics",
										effect = function( aid, spawn_x, spawn_y )
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "PhysicsShapeComponent" ))
											local pics = EntityGetComponent( aid, "SpriteComponent" ) or {}
											if( #pics > 0 ) then
												for i,pic in ipairs( pics ) do
													EntityRemoveComponent( aid, pic )
												end
											end
											
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "path_distance_to_target_node_to_turn_around", 9999999 )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "mouse_look", false )
												ComponentSetValue2( comp, "keyboard_look", false )
												ComponentSetValue2( comp, "turning_buffer", 99999 )
												ComponentSetValue2( comp, "turn_animation_frames_between", -1 )
											end)
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "physics_objects_damage", false )
												ComponentSetValue2( comp, "ragdoll_filenames_file", "mods/necro_stuff/files/abominations/ragdolls/filenames_"..enders[selected_parts[2]].."_phys.txt" )
												ComponentSetValue2( comp, "ragdoll_material", "necrostate_box2d" )
												ComponentSetValue2( comp, "ragdoll_offset_x", 0 )
												ComponentSetValue2( comp, "ragdoll_offset_y", 0 )
											end)
											
											local ofsts = { -3, -7, -14, }
											edit_component_ultimate( aid, "HitboxComponent", function(comp,vars) 
												ComponentSetValue2( comp, "aabb_max_x", 1 )
												ComponentSetValue2( comp, "aabb_max_y", 1 + ofsts[selected_parts[2]] )
												ComponentSetValue2( comp, "aabb_min_x", -1 )
												ComponentSetValue2( comp, "aabb_min_y", -2 + ofsts[selected_parts[2]] )
											end)
											
											edit_component_ultimate( aid, "PhysicsBodyComponent", function(comp,vars) 
												ComponentSetValue2( comp, "fixed_rotation", true )
												ComponentSetValue2( comp, "on_death_leave_physics_body", false )
											end)
											
											EntityAddComponent( aid, "PhysicsImageShapeComponent", 
											{ 
												_tags = "enabled_in_world",
												image_file = "mods/necro_stuff/files/abominations/body/"..enders[selected_parts[2]].."_phys.png",
												centered = "1",
												material = "necrostate_box2d",
												offset_x = "0",
												offset_y = "0",
											})
											
											local phys_ass = EntityLoad( "mods/necro_stuff/files/abominations/body/"..enders[selected_parts[2]].."_phys.xml", spawn_x, spawn_y )
											EntityAddChild( aid, phys_ass )
											
											local shape_comp = EntityGetFirstComponentIncludingDisabled( phys_ass, "PhysicsImageShapeComponent" )
											local hot_comp = EntityAddComponent( aid, "HotspotComponent", 
											{ 
												_tags = "enabled_in_world,phys_pos",
												transform_with_scale = "0",
											})
											ComponentSetValue2( hot_comp, "offset", -ComponentGetValue2( shape_comp, "offset_x" ), -ComponentGetValue2( shape_comp, "offset_y" ))
											
											edit_component_with_tag_ultimate( aid, "HotspotComponent", "head_pos", function(comp,vars) 
												ComponentSetValue2( comp, "sprite_hotspot_name", "" )
												ComponentSetValue2( comp, "offset", 0, -2^( selected_parts[2] + 1 ))
											end)
										end,
									},
									{
										name = "Excised",
										desc = "Several cycles of Shell depletion turn the abomination into a ghost-like being with drastically weakened resilience but complete insusceptibility to the vast majority of the physical influences, remaining sensitive only to rapid air pressure changes.",
										stats = function()
											return { -2, 2, 0, 0.5, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return selected_parts[3] == 4 and true or 1
										end,
										real_case = { "This Pact requires the 3rd Sigil to be present, since the creature will have no proper physical interaction with this world to maintian mobility.", },
										cost_nc = 0,
										cost_mc = 5,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_ghost",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "never_consider_line_of_sight", true )
											end)
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "ragdoll_material", "necro_current" )
												ComponentSetValue2( comp, "ragdoll_filenames_file", "mods/necro_stuff/files/abominations/ragdolls/filenames_"..enders[selected_parts[2]].."_trans.txt" )
											end)
											
											EntityAddComponent( aid, "LuaComponent", 
											{ 
												_tags = "enabled_in_world",
												script_source_file = "mods/necro_stuff/files/follower.lua",
												execute_every_n_frame = "1",
											})
											
											EntityAddComponent( aid, "LuaComponent", 
											{ 
												_tags = "enabled_in_world",
												script_source_file = "mods/necro_stuff/files/hoverman_maintainer.lua",
												execute_every_n_frame = "30",
											})
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars) 
												ComponentSetValue2( comp, "max_hp", ComponentGetValue2( comp, "max_hp" )/10 )
												ComponentSetValue2( comp, "hp", ComponentGetValue2( comp, "max_hp" ))
												ComponentObjectSetValue2( comp, "damage_multipliers", "curse", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "drill", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "electricity", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "fire", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "healing", 2 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "ice", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "melee", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "overeating", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "physics_hit", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "poison", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "projectile", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "radioactive", 0 )
												ComponentObjectSetValue2( comp, "damage_multipliers", "slice", 0 )
											end)
											
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "CharacterCollisionComponent" ))
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "CharacterDataComponent" ))
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "CharacterPlatformingComponent" ))
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "PhysicsShapeComponent" ))
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "PhysicsBodyComponent" ))
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "PhysicsAIComponent" ))
											
											local pics = EntityGetComponent( aid, "SpriteComponent" ) or {}
											if( #pics > 0 ) then
												for i,pic in ipairs( pics ) do
													ComponentSetValue2( pic, "alpha", 0.5 )
												end
											end
											local children = EntityGetAllChildren( aid ) or {}
											if( #children > 0 ) then
												for i,child in ipairs( children ) do
													local pics = EntityGetComponent( child, "SpriteComponent" ) or {}
													if( #pics > 0 ) then
														for i,pic in ipairs( pics ) do
															ComponentSetValue2( pic, "alpha", 0.5 )
														end
													end
												end
											end
										end,
									},
									{
										name = "Adroit",
										desc = "An enterprise-class training program based on the Widrow-Hoff principle enables the creature with advanced offensive techniques at melee range.",
										stats = function()
											return { 0, 0, 3, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 2,
										cost_mc = 1,
										cost_hp = 1,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_melee",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "attack_melee_max_distance", ComponentGetValue2( comp, "attack_melee_max_distance" ) + 10 )
												ComponentSetValue2( comp, "attack_melee_damage_min", ComponentGetValue2( comp, "attack_melee_damage_min" )*2 )
												ComponentSetValue2( comp, "attack_melee_damage_max", ComponentGetValue2( comp, "attack_melee_damage_max" )*2 )
											end)
										end,
									},
									{
										name = "Rigorous",
										desc = "A tiny ocellus is being perforated in the abominable essence to let the Divinity Conglomerate Apparatus peek through and burn the hostiles with its gaze alone.",
										stats = function()
											return { 0.5, 0, 3, 0, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 3,
										cost_mc = 3,
										cost_hp = 2,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_range",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "attack_ranged_min_distance", 30 )
												ComponentSetValue2( comp, "attack_ranged_max_distance", 90 )
												ComponentSetValue2( comp, "attack_ranged_frames_between", 1 )
												ComponentSetValue2( comp, "attack_ranged_aim_rotation_enabled", false )
												ComponentSetValue2( comp, "attack_ranged_aim_rotation_shooting_ok_angle_deg", 10 )
												ComponentSetValue2( comp, "attack_ranged_offset_y", 0 )
												ComponentSetValue2( comp, "attack_ranged_offset_x", 1.5*selected_parts[2] )
												ComponentSetValue2( comp, "attack_ranged_enabled", false )
												ComponentSetValue2( comp, "attack_ranged_action_frame", 0 )
											end)
											
											EntityAddComponent( aid, "AIAttackComponent", 
											{ 
												_tags = "enabled_in_world,enabled_in_inventory,enabled_in_hand",
												min_distance = "30",
												max_distance = "90",
												frames_between = "0",
												frames_between_global = "0",
												attack_ranged_aim_rotation_shooting_ok_angle_deg = "10",
												attack_ranged_root_offset_y = "0",
												attack_ranged_offset_y = "0",
												attack_ranged_offset_x = 1.5*selected_parts[2],
												animation_name = selected_parts[3] == 1 and "stand" or "fly_idle",
												attack_ranged_entity_file = "mods/necro_stuff/files/spells/necro_gaze/necro_gaze.xml", 
												angular_range_deg = "360",
											})
											
											edit_component_ultimate( aid, "DamageModelComponent", function(comp,vars)
												ComponentObjectSetValue2( comp, "damage_multipliers", "electricity", 0 )
											end)
										end,
									},
									{
										name = "Benign",
										desc = "The majority of abominable internal organs are replaced with a unified tumour-like growth that converts its own matter into raw Necro Current and attempts to mend its master's wounds with it. At least 50% of the creature's body must remain intact for reliable operation.",
										stats = function()
											return { 0, 0, 0, 4, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 5,
										cost_mc = 0,
										cost_hp = 10,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_healing",
										effect = function( aid, spawn_x, spawn_y )
											EntityAddComponent( aid, "LuaComponent", 
											{ 
												_tags = "enabled_in_world,enabled_in_inventory,enabled_in_hand",
												script_source_file = "mods/necro_stuff/files/healer.lua",
												execute_every_n_frame = "30",
											})
										end,
									},
									{
										name = "Accrued",
										desc = "A disturbed concoction consisting of fully sentient essences is being embedded inside a horrific perpetually rotting protrusion within the creature. Their unending suffering is then used to produce pure Necro Current to be translated into the closest Mors Lignum (up to 50% of storage capacity).",
										stats = function()
											return { 0, 0, 0, 5, 0, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 20,
										cost_mc = 5,
										cost_hp = 5,
										pic = "mods/necro_stuff/files/gui/bodyparts/special_factory",
										effect = function( aid, spawn_x, spawn_y )
											EntityAddComponent( aid, "LuaComponent", 
											{ 
												_tags = "enabled_in_world,enabled_in_inventory,enabled_in_hand",
												script_source_file = "mods/necro_stuff/files/fabricator.lua",
												execute_every_n_frame = "30",
											})
										end,
									},
								},
							},
							{
								name = "ARRAY",
								contents = {
									{
										name = "Null",
										desc = "[NONE]",
										stats = function()
											return { 0, nil, selected_parts[1] == 4 and 0 or nil, 0, nil, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return ( not( selected_parts[3] == 2 or selected_parts[3] == 4 ) or selected_parts[4] == 3 ) and true or 1
										end,
										real_case = { "Advanced mobility Essences require an Array present.", },
										cost_nc = 0,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/brain_null",
										effect = function( aid, spawn_x, spawn_y )
											EntityRemoveComponent( aid, EntityGetFirstComponentIncludingDisabled( aid, "AnimalAIComponent" ))
										end,
									},
									{
										name = "Inferior",
										desc = "Low-cost, primitive and underpowered sentience array, designed as a self-sufficient missile autopilot or reliable cargo vessel controller. This type is usually made from the higher tier leftovers.",
										stats = function()
											return { 0, 0, 0, 0, 1, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 3,
										cost_mc = 0,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/brain_basic",
										effect = function( aid, spawn_x, spawn_y )
										end,
									},
									{
										name = "Exquisite",
										desc = "Top-of-the-line, fine and masterful sentience array, primarily used as an automatization tool in places too dangerous for humans to exist. Only 1 out of 10 units is usually perfect enough to be given such a high certification, so the rest is being scrapped to later become Inferior type.",
										stats = function()
											return { 0, 1, 1, 0, 2, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 5,
										cost_mc = 2,
										cost_hp = 0,
										pic = "mods/necro_stuff/files/gui/bodyparts/brain_advanced",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "dont_counter_attack_own_herd", true )
												ComponentSetValue2( comp, "creature_detection_check_every_x_frames", math.ceil( ComponentGetValue2( comp, "creature_detection_check_every_x_frames" )/2 ))
												ComponentSetValue2( comp, "creature_detection_range_x", ComponentGetValue2( comp, "creature_detection_range_x" ) + 100 )
												ComponentSetValue2( comp, "creature_detection_range_y", ComponentGetValue2( comp, "creature_detection_range_y" ) + 100 )
												ComponentSetValue2( comp, "aggressiveness_min", ComponentGetValue2( comp, "aggressiveness_min" )*4 )
												ComponentSetValue2( comp, "aggressiveness_max", ComponentGetValue2( comp, "aggressiveness_max" )*4 )
												ComponentSetValue2( comp, "escape_if_damaged_probability", ComponentGetValue2( comp, "escape_if_damaged_probability" )/3 )
												ComponentSetValue2( comp, "creature_detection_angular_range_deg", math.min( ComponentGetValue2( comp, "creature_detection_angular_range_deg" )*2, 360 ))
												ComponentSetValue2( comp, "attack_melee_frames_between", math.ceil( ComponentGetValue2( comp, "attack_melee_frames_between" )/2 ))
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "accel_x", math.min( ComponentGetValue2( comp, "accel_x" )*3, 1 ))
												ComponentSetValue2( comp, "accel_x_air", math.min( ComponentGetValue2( comp, "accel_x_air" )*3, 1 ))
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "frames_between_searches", math.ceil( ComponentGetValue2( comp, "frames_between_searches" )/2 ))
											end)
											
											if( selected_parts[3] == 2 or selected_parts[3] == 4 ) then
												edit_component_ultimate( aid, "PhysicsAIComponent", function(comp,vars) 
													ComponentSetValue2( comp, "force_balancing_coeff", ComponentGetValue2( comp, "force_balancing_coeff" ) + 0.2 )
													ComponentSetValue2( comp, "force_coeff", ComponentGetValue2( comp, "force_coeff" )*4 )
													ComponentSetValue2( comp, "force_max", ComponentGetValue2( comp, "force_max" )*4 )
												end)
											end
										end,
									},
									{
										name = "Apex",
										desc = "A true marvel of necro-active engineering, Turing-corrected and Blasphemy-powered sentience array, developed as an attempt to construct the being to rival the True Form. It takes several years of semi-sentient essence amalgamation of the Exquisite type core to achieve such remarkable results.",
										stats = function()
											return { 0, 3, 2, 0, 5, }
										end,
										is_unlocked = function()
											return true
										end,
										is_real = function()
											return true
										end,
										real_case = "",
										cost_nc = 10,
										cost_mc = 5,
										cost_hp = 3,
										pic = "mods/necro_stuff/files/gui/bodyparts/brain_apex",
										effect = function( aid, spawn_x, spawn_y )
											edit_component_ultimate( aid, "AnimalAIComponent", function(comp,vars) 
												ComponentSetValue2( comp, "dont_counter_attack_own_herd", true )
												ComponentSetValue2( comp, "creature_detection_check_every_x_frames", 5 )
												ComponentSetValue2( comp, "creature_detection_angular_range_deg", 360 )
												ComponentSetValue2( comp, "creature_detection_range_x", ComponentGetValue2( comp, "creature_detection_range_x" ) + 100 )
												ComponentSetValue2( comp, "creature_detection_range_y", ComponentGetValue2( comp, "creature_detection_range_y" ) + 100 )
												ComponentSetValue2( comp, "aggressiveness_min", 100 )
												ComponentSetValue2( comp, "aggressiveness_max", 100 )
												ComponentSetValue2( comp, "escape_if_damaged_probability", 0 )
												ComponentSetValue2( comp, "attack_melee_frames_between", math.ceil( ComponentGetValue2( comp, "attack_melee_frames_between" )/10 ))
												ComponentSetValue2( comp, "attack_ranged_predict", true )
											end)
											
											edit_component_ultimate( aid, "CharacterPlatformingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "accel_x", 1 )
												ComponentSetValue2( comp, "accel_x_air", 1 )
											end)
											
											edit_component_ultimate( aid, "PathFindingComponent", function(comp,vars) 
												ComponentSetValue2( comp, "frames_between_searches", math.ceil( ComponentGetValue2( comp, "frames_between_searches" )/2 ))
											end)
											
											if( selected_parts[3] == 2 or selected_parts[3] == 4 ) then
												edit_component_ultimate( aid, "PhysicsAIComponent", function(comp,vars) 
													ComponentSetValue2( comp, "force_balancing_coeff", 1 )
													ComponentSetValue2( comp, "force_coeff", 100 )
													ComponentSetValue2( comp, "force_max", 200 )
												end)
											end
										end,
									},
								},
							},
						}
						
						selected_line = selected_line == nil and 0 or ( selected_line > 0 and 0 or selected_line )
						clicked, hovered = false, false
						local is_real = true
						local is_unlocked = true
						for i,bodypart in ipairs( bodyparts ) do
							local this_one = bodypart.contents[selected_parts[i]]
							local this_real = this_one.is_real() == true
							local this_unlocked = this_one.is_unlocked()
							is_real = is_real and this_real
							is_unlocked = is_unlocked and this_unlocked
							
							if( not( this_unlocked and this_real )) then
								uid = new_image_old( gui, uid, pic_x + 68, pic_y + 16 + 17*( i - 1 ), pic_z - 0.01, this_one.pic..( is_unlocked and ( is_real and "" or "_X" ) or "_" )..".png" )
							end
							
							uid, selected_parts[i] = new_selector( gui, uid, pic_x + 68, pic_y + 16 + 17*( i - 1 ), pic_z, bodypart, selected_parts[i] )
							clicked, _, hovered = GuiGetPreviousWidgetInfo( gui )
							local txt = this_unlocked and ( this_real and bodypart.name..":"..this_one.name or ( math.abs( selected_line ) == i and ( selected_line < 0 and "LMB for warning." or "LMB for info." ) or "LMB for info." )) or "Locked."
							uid = new_tooltip_old( gui, uid, nil, txt )
							if(( hovered and selected_line >= 0 ) or selected_line == -i ) then
								uid = new_image_old( gui, uid, pic_x + 67, pic_y + 15 + 17*( i - 1 ), pic_z - 0.025, "mods/necro_stuff/files/gui/tree/"..( selected_line == -i and "select" or "highlight" )..".png" )
							end
							
							is_real = is_real and bodypart.contents[selected_parts[i]].is_real() == true
							is_unlocked = is_unlocked and bodypart.contents[selected_parts[i]].is_unlocked()
							
							if( clicked ) then
								if( selected_line == -i ) then
									selected_line = hovered and i or 0
								else
									selected_line = -i
								end
							elseif( selected_line >= 0 and hovered ) then
								selected_line = i
							end
						end
						
						local price = { 0, 0, 0, 0, }
						local full_price = {}
						local rmtr_tbl = { 100, 200, 500, }
						local noice_tbl = { tonumber( wand_id )%5 + 1, tonumber( hooman )%5 + 1, tonumber( storage_necro )%5 + 1, tonumber( storage_mana )%5 + 1, tonumber( storage_stage )%5 + 1, }
						local units = { 
							{
								--resilience
								n = "dpf",
								t = { "DuPont Foot", "An estimate of how many feet of the subjected matter thickness is required to stop the standard Ire Ray.", },
							},
							{
								--mobility
								n = "mxd",
								t = { "Matrix Density", "A minimal complexity of the Impedance Manifold Network (also known as the Trenchwire) required to immobilise the testee.", },
							},
							{
								--combat power
								n = "ufn",
								t = { "Microfortnight", "A measure of how long it takes for the abomination to extract a heart from the Class A soldier.", },
							},
							{
								--utility grade
								n = "aln",
								t = { "Allen", "An established industrial score of how beneficial the abomination is.", },
							},
							{
								--intelligence
								n = "sps",
								t = { "[Trillions of Array] Shifts Per Second", "A unit of the DAA-specific computing hardware efficiency.", },
							},
						}
						if( selected_line ~= 0 ) then
							function formater( k )
								local symbol = k > 0 and "^" or "v"
								local out = ""
								
								for i = 1,math.abs( k ) do
									out = out..symbol
								end
								
								return out
							end
							
							local current_line = bodyparts[ math.abs( selected_line )]
							local current_part = current_line.contents[selected_parts[ math.abs( selected_line )]]
							local current_stats = current_part.stats()
							
							price[1] = current_part.cost_nc
							price[2] = current_part.cost_mc
							price[4] = current_part.cost_hp
							
							new_text_old( gui, pic_x + 2, pic_y + 19, pic_z, "Part stats:" )
							local counter = 1
							for i = 1,5 do
								local value = math.floor( current_stats[i] or 0 )
								if( value ~= 0 ) then
									new_text_old( gui, pic_x + 2, pic_y + 19 + counter*9, pic_z, formater( value ).." "..units[i].n, 2 )
									uid = new_button_old( gui, uid, pic_x + 1, pic_y + 21 + counter*9, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_stat.png" )
									uid = new_tooltip_old( gui, uid, nil, units[i].t[1], units[i].t[2] )
									counter = counter + 1
								end
							end
							
							local p_x, p_y, p_z = tooltip_x, tooltip_y, -50
							uid = new_window( gui, uid, p_x, p_y, p_z + 0.1, 150, 118, true, false )
							p_x = p_x + 2
							local nme = "[["..current_line.name.."]]"
							local t_w, t_h = GuiGetTextDimensions( gui, nme, 1 )
							new_text_old( gui, p_x + 73.5 - t_w/2, p_y, p_z, nme )
							p_y = p_y + 10
							local pic = "mods/necro_stuff/files/gui/colour_green.png"
							uid = new_image_old( gui, uid, p_x, p_y, p_z, pic, 146, 1 )
							p_y = p_y + 1
							nme = ">"..current_part.name.." <"
							t_w, t_h = GuiGetTextDimensions( gui, nme, 1 )
							new_text_old( gui, p_x + 73.5 - t_w/2, p_y, p_z, nme )
							p_y = p_y + 10
							uid = new_image_old( gui, uid, p_x + 3, p_y, p_z, pic, 140, 1 )
							uid = new_image_old( gui, uid, p_x + 6, p_y + 2, p_z, pic, 134, 1 )
							uid = new_image_old( gui, uid, p_x + 9, p_y + 4, p_z, pic, 128, 1 )
							p_y = p_y + 8
							local actually_real = current_part.is_real()
							if( actually_real == true or selected_line < 0 ) then
								new_text_old( gui, p_x, p_y, p_z, liner_old( gui, current_part.desc, 146, 88, 3.9 ), 2 )
							else
								new_text_old( gui, p_x, p_y, p_z, liner_old( gui, "[WARNING] @ "..current_part.real_case[actually_real].." @ Abhorrent Fetus will be created instead. @", 146, 88, 3.9 ), 2 )
							end
						else
							function get_dpf( value )
								value = value or 0
								value = 0.5948 + 1.1464*value - 0.1374*value^2 + 0.1571*value^3 - 0.0105*value^4
								return value
							end
							
							function get_brd( value )
								if( value == nil ) then
									return 0
								end
								value = -53.8086 + 92.1704*value - 46.1431*value^2 + 8.857*value^3 - 0.461*value^4
								return value
							end
							
							function get_ufn( value )
								value = value or 0
								if( value == 0 ) then
									return 10^666
								end
								value = 0.1 + ( 979 + 0.3442 )/( 1 + ( math.abs( value )/1.7118 )^6.8676 )
								return value
							end
							
							function get_aln( value )
								value = value or 0
								local temp1 = math.floor( 8.5865*value - 3.1703*value^2 + 0.5212*value^3 - 0.0266*value^4 + 0.5 )
								local temp2 = math.floor( 9.83 + 1.4058*value - 1.6746*value^2 + 0.3242*value^3 - 0.0154*value^4 + 0.5 )
								local temp3 = math.floor( 1.9442 + 8.7585*value - 5.8551*value^2 + 1.9678*value^3 - 0.3077*value^4 + 0.0175*value^5 )
								value = temp1*100 + math.min( temp2, 9 )*10 + math.min( temp3, 9 )
								return value
							end
							
							function get_sps( value )
								if( value == nil ) then
									return 0
								end
								value = -1.1133 + 2.0817*value - 1.085*value^2 + 0.2146*value^3 - 0.0106*value^4
								return value
							end
							
							function noise( value, tbl )
								value = value or 0
								if( value == 0 ) then
									return 0
								end
								
								local percent = math.abs( tbl[1] or 1 )/100
								local sign = ( tbl[2] or 1 )%2 == 0 and 1 or -1
								local modifier = 3*math.sin((( tbl[3] or 1 )*10 + ( tbl[4] or 1 ) - ( tbl[5] or 1 )*2 )^2 )
								
								return math.floor( value*( 1 + sign*percent*modifier )*100 + 0.5 )/100
							end
							
							local full_stats = { 0, 0, 0, 0, 0, }
							if( is_real ) then
								for i,bodypart in ipairs( bodyparts ) do
									local current_part = bodypart.contents[ selected_parts[i]]
									local current_stats = current_part.stats()
									for e,stat in ipairs( full_stats ) do
										if( current_stats[e] == nil ) then
											full_stats[e] = nil
										elseif( stat ~= nil ) then
											full_stats[e] = stat + current_stats[e]
										end
									end
									
									price[1] = price[1] + current_part.cost_nc
									price[2] = price[2] + current_part.cost_mc
									price[4] = price[4] + current_part.cost_hp
									
									if( i == 2 ) then
										price[3] = math.floor( noise( rmtr_tbl[selected_parts[2]], noice_tbl ))
									end
								end
								full_price = price
							else
								full_stats = { 0, nil, nil, 3, nil, }
							end
							
							local calc = { 
								function( k )
									return math.max( get_dpf( k ), 0 )
								end,
								function( k )
									return math.max( get_brd( k ), 0 )
								end,
								function( k )
									return math.max( get_ufn( k ), 0 )
								end,
								function( k )
									return get_aln( k )
								end,
								function( k )
									return math.max( get_sps( k ), 0 )
								end,
							}
							
							new_text_old( gui, pic_x + 2, pic_y + 19, pic_z, "Full stats:" )
							for i = 1,5 do
								local value = noise( calc[i]( full_stats[i] ), full_stats )
								if( math.abs( value ) > 100 ) then
									value = math.floor( value )
								end
								new_text_old( gui, pic_x + 2, pic_y + 19 + i*9, pic_z, value.." "..units[i].n, 2 )
								uid = new_button_old( gui, uid, pic_x + 1, pic_y + 21 + i*9, pic_z - 0.01, "mods/necro_stuff/files/gui/hitbox_stat.png" )
								uid = new_tooltip_old( gui, uid, nil, units[i].t[1], units[i].t[2] )
							end
						end
						
						local stomach_comp = EntityGetFirstComponentIncludingDisabled( hooman, "MaterialInventoryComponent" )
						local stomach = ComponentGetValue2( stomach_comp, "count_per_material_type" )
						local mttrs = {}
						local got_some = 0
						for i,mttr in ipairs( stomach ) do
							if( mttr > 0 ) then
								if( is_organic( i - 1 )) then
									mttrs[ i - 1 ] = mttr
									got_some = got_some + mttr
								end
							end
						end
						
						local price_text = { "", "", }
						local price_info = {
							{ "nc", "Necro Current - the foundation of the entire beast.", },
							{ "ac", "Arcane Current - enables the creature with abilities specific to this realm.", },
							{ "rm", "Raw Matter - filler-matter of various organic compounds extracted from the master's stomach.", },
							{ "hp", "Harm Points - fragments of master's flesh that are required for extra complex organs.", },
						}
						local full_amount = { math.floor( nc_visual )/price_offset, math.floor( mana_current )/price_offset, got_some, hooman_hp, }
						local dvd_buffer = 0
						local is_enough = true
						local going_intertier = false
						if( #full_price == 0 ) then
							if( is_real ) then
								full_price = { 0, 0, 0, 0, }
								for i,bodypart in ipairs( bodyparts ) do
									local current_part = bodypart.contents[ selected_parts[i]]
									
									full_price[1] = full_price[1] + current_part.cost_nc
									full_price[2] = full_price[2] + current_part.cost_mc
									full_price[4] = full_price[4] + current_part.cost_hp
									
									if( i == 2 ) then
										full_price[3] = math.floor( noise( rmtr_tbl[ selected_parts[2]], noice_tbl ))
									end
								end
							else
								full_price = { 0, 0, 10, 1, }
								if( selected_line == 0 ) then
									price = full_price
								end
							end
						end
						for i = 1,4 do
							if( price[i] ~= 0 ) then
								price_text[1] = price_text[1]..( dvd_buffer > 0 and ":" or "" )..price[i]..price_info[i][1]
								price_text[2] = price_text[2]..( dvd_buffer > 0 and " @ " or "" )..price[i].."/"..full_amount[i].." "..price_info[i][2]
								dvd_buffer = dvd_buffer + 1
							end
							if( full_price[i] ~= 0 ) then
								if( full_price[i] > full_amount[i] ) then
									if( i > 1 or necro_current/price_offset < full_price[1] ) then
										is_enough = false
									else
										going_intertier = true
									end
								end
							end
						end
						local t_w, t_h = GuiGetTextDimensions( gui, price_text[1], 1 )
						new_text_old( gui, pic_x + 75.5 - t_w/2, pic_y + 102, pic_z, price_text[1], ( is_unlocked and is_enough ) and 1 or 2 )
						uid = new_tooltip_old( gui, uid, nil, price_text[2].." @" )
						
						if( is_unlocked ) then
							if( is_real ) then
								local pic = bodyparts[2].contents[selected_parts[2]].visual
								if( pic ~= nil ) then
									uid = new_image_old( gui, uid, pic_x + 103, pic_y + 19, pic_z - 0.02, pic..( selected_parts[4] == 2 and "_phys" or "" )..".png" )
								end
								
								pic = bodyparts[3].contents[selected_parts[3]].visual[selected_parts[2]]
								if( pic ~= nil ) then
									uid = new_image_old( gui, uid, pic_x + 103, pic_y + 19, pic_z + ( selected_parts[3] == 2 and 0.001 or -0.03 ), pic )
									if( selected_parts[2] == 1 and selected_parts[3] == 3 ) then
										uid = new_image_old( gui, uid, pic_x + 103, pic_y + 19, pic_z - 0.03, bodyparts[3].contents[1].visual[1] )
									end
								end
								
								pic = bodyparts[1].contents[selected_parts[1]].visual
								if( pic ~= nil ) then
									uid = new_image_old( gui, uid, pic_x + 103, pic_y + 19, pic_z - 0.04, pic.."_"..( selected_parts[4] == 2 and "phys" or ( enders[selected_parts[2]]..(( selected_parts[2] == 1 and selected_parts[3] == 3 ) and "_wings" or "" )))..".png" )
								end
							else
								uid = new_image_old( gui, uid, pic_x + 103, pic_y + 19, pic_z - 0.02, "mods/necro_stuff/files/gui/abominations/abhorrent_fetus.png" )
							end
						end
						
						uid, clicked, r_clicked = new_button_old( gui, uid, pic_x - 2, pic_y + 96, pic_z, "mods/necro_stuff/files/gui/button_sacrifice_"..( kills_undead and "B" or "A" )..".png" )
						uid = new_tooltip_old( gui, uid, nil, "Sacrifice the closest "..( kills_undead and "Undead" or "Abomination" )..".", ( kills_undead and "Half of" or "Full" ).." Necro Current Cost will be obtained. @ (RMB to change the mode)" )
						if( clicked ) then
							local shard = EntityGetWithName( "Blasphemy" )
							if( shard ~= nil ) then
								local s_x, s_y = EntityGetTransform( shard )
								local meats = EntityGetWithTag( kills_undead and "undead" or "abomination" ) or {}
								local meat = 0
								if( #meats > 0 ) then
									local min_dist = -1
									for i,dud in ipairs( meats ) do
										if( EntityGetRootEntity( dud ) == dud ) then
											local t_x, t_y = EntityGetTransform( dud )
											local t_dist = math.sqrt(( t_x - s_x )^2 + ( t_y - s_y )^2 )
											if( min_dist == -1 or t_dist < min_dist ) then
												min_dist = t_dist
												meat = dud
											end
										end
									end
								end
								if( meat ~= 0 ) then
									local lua_comp = EntityGetFirstComponentIncludingDisabled( meat, "LuaComponent", "kill_confirmer" )
									if( lua_comp ~= nil ) then
										EntityRemoveComponent( meat, lua_comp )
									end
									
									local cost_comp = get_storage_old( meat, "cost" )
									if( cost_comp ~= nil ) then
										ComponentSetValue2( storage_necro, "value_float", necro_current + price_offset*ComponentGetValue2( cost_comp, "value_int" ))
										ComponentSetValue2( cost_comp, "value_int", 0 )
									else
										ComponentSetValue2( storage_necro, "value_float", necro_current + get_necro_current( meat )*0.5 )
									end
									
									edit_component_ultimate( meat, "DamageModelComponent", function(comp,vars) 
										ComponentSetValue2( comp, "max_hp", 0 )
										ComponentSetValue2( comp, "hp", 0 )
									end)
									local m_x, m_y = EntityGetTransform( meat )
									EntityInflictDamage( meat, 111*necro_stage/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, wand_id, m_x, m_y, 0 )
									
									new_connector( wand_id, m_x, m_y )
								else
									GamePrint( "Error! None of Thy Monstroucities are present." )
								end
							else
								GamePrint( "Error! Thy Shard has been consumed." )
							end
						end
						if( r_clicked ) then
							ComponentSetValue2( storage_killer, "value_bool", not( kills_undead ))
						end
						
						uid, clicked = new_button_old( gui, uid, pic_x + 135, pic_y + 96, pic_z - 0.02, "mods/necro_stuff/files/gui/button_spawn_"..( not( is_enough and is_unlocked ) and "B" or ( not( is_real ) and "C" or "A" ))..".png" )
						uid = new_tooltip_old( gui, uid, nil, is_unlocked and ( is_enough and "Assemble the "..( is_real and "Abomination" or "Fetus" ).."." or "[INSUFFICIENT RESOURCES]" ) or "[FORBIDDEN]" )
						if( clicked and is_unlocked and is_enough ) then
							if( going_intertier and not( intertier_proceed )) then
								intertier_warning = true
							else
								if( intertier_proceed ) then
									intertier_proceed = false
								end
								
								if( full_price[1] > 0 ) then
									ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) - full_price[1]*price_offset )
								end
								if( full_price[2] > 0 ) then
									ComponentSetValue2( storage_mana, "value_float", ComponentGetValue2( storage_mana, "value_float" ) - full_price[2]*price_offset )
								end
								if( full_price[3] > 0 ) then
									for i,mttr in ipairs( stomach ) do
										if( mttr > 0 ) then
											if( is_organic( i - 1 )) then
												AddMaterialInventoryMaterial( hooman, CellFactory_GetName( i - 1 ), math.max( mttr - full_price[3], 0 ))
												full_price[3] = full_price[3] - mttr
												
												if( full_price[3] <= 0 ) then
													break
												end
											end
										end
									end
								end
								if( full_price[4] > 0 ) then
									EntityInflictDamage( hooman, full_price[4]/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, wand_id, h_x, h_y, 0 )
									too_smart_check( hooman, hooman_hp )
								end
								
								local total_cost = 0
								for i,part in ipairs( selected_parts ) do
									total_cost = total_cost + bodyparts[i].contents[part].cost_nc
								end
								
								local spawn_x, spawn_y = x, y
								if( is_real ) then
									if( selected_parts[4] == 2 ) then
										spawn_x, spawn_y = GameGetCameraPos()
										spawn_x, spawn_y = get_spawn_pos( spawn_x, spawn_y, selected_parts[2]*5, selected_parts[2]*20, x, y )
									end
									
									local aid = EntityLoad( "mods/necro_stuff/files/abominations/base.xml", spawn_x, spawn_y )
									
									bodyparts[2].contents[selected_parts[2]].effect( aid, spawn_x, spawn_y )
									bodyparts[3].contents[selected_parts[3]].effect( aid, spawn_x, spawn_y )
									bodyparts[5].contents[selected_parts[5]].effect( aid, spawn_x, spawn_y )
									bodyparts[1].contents[selected_parts[1]].effect( aid, spawn_x, spawn_y )
									bodyparts[4].contents[selected_parts[4]].effect( aid, spawn_x, spawn_y )
									
									ComponentSetValue2( get_storage_old( aid, "parts" ), "value_string", D_packer_old( selected_parts ))
									ComponentSetValue2( get_storage_old( aid, "cost" ), "value_int", total_cost )
								else
									EntityLoad( "mods/necro_stuff/files/stuff/abhorrent_fetus.xml", spawn_x, spawn_y )
								end
							end
						end
						
						return uid
					end,
				},
			}
			
			if( intertier_warning ) then
				uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, "mods/necro_stuff/files/gui/background_warning.png" )
				
				uid, clicked = new_button_old( gui, uid, pic_x + 10, pic_y + 94, pic_z - 0.01, "mods/necro_stuff/files/gui/button_warning_abort.png" )
				if( clicked ) then
					intertier_warning = false
				end
				
				uid, clicked = new_button_old( gui, uid, pic_x + 101, pic_y + 94, pic_z - 0.01, "mods/necro_stuff/files/gui/button_warning_proceed.png" )
				if( clicked ) then
					intertier_warning = false
					intertier_proceed = true
				end
			else
				uid = new_image_old( gui, uid, pic_x, pic_y, pic_z, pages[page_num].background )
			end
			
			pic_z = pic_z - 0.01
			uid, clicked = new_button_old( gui, uid, pic_x - 15, pic_y + 4, pic_z, "mods/necro_stuff/files/gui/button_close.png" )
			uid = new_tooltip_old( gui, uid, nil, "Close the CNC Interface." )
			if( clicked ) then
				ComponentSetValue2( storage_gui, "value_bool", false )
			end
			
			pic_x = pic_x + 5
			pic_y = pic_y + 5
			if( not( intertier_warning )) then
				uid = new_window( gui, uid, pic_x, pic_y, pic_z, 100, 14, false, true )
				uid = new_image_old( gui, uid, pic_x, pic_y, pic_z - 0.03, pages[page_num].title )
				uid = pages[page_num].contents( gui, uid, pic_x, pic_y, pic_z - 0.01 )
			end
			
			pic_x = pic_x - 21
			pic_y = pic_y + 115 - 19*#pages
			local new_page = page_num
			for i,p in ipairs( pages ) do
				uid, clicked = new_button_old( gui, uid, pic_x, pic_y + 19*( i - 1 ), pic_z, p.label..( page_num == i and "_" or "" )..".png" )
				uid = new_tooltip_old( gui, uid, nil, p.name )
				if( clicked and not( intertier_warning )) then
					new_page = i
					intertier_proceed = false
				end
			end
			
			if( page_num ~= new_page ) then
				ComponentSetValue2( storage_page, "value_int", new_page )
			end
		else
			pic_x, pic_y = tonumber( ModSettingGetNextValue( "necro_stuff.BUTTON_POS_X" )), tonumber( ModSettingGetNextValue( "necro_stuff.BUTTON_POS_Y" ))
			uid, clicked = new_button_old( gui, uid, pic_x, pic_y, pic_z, "mods/necro_stuff/files/gui/button_main.png" )
			uid = new_tooltip_old( gui, uid, nil, "Access the CNC Interface." )
			if( clicked ) then
				ComponentSetValue2( storage_gui, "value_bool", true )
			end
		end
	else
		gui = gui_killer_old( gui )
	end
end
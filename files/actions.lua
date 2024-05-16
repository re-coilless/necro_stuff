dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

function draw_actions_fancy( how_many, instant_reload_if_empty, extra_action )
	if( not( dont_draw_actions )) then
		c.action_draw_many_count = how_many
		
		if( playing_permanent_card and ( how_many == 1 )) then
			return
		end
		
		for i = 1,how_many do
			if( extra_action ~= nil ) then
				extra_action( i )
			end
			
			local ok = draw_action( instant_reload_if_empty )
			if( not( ok )) then
				while #deck > 0 do
					if( draw_action( instant_reload_if_empty )) then
						break
					end
				end
			end

			if( reloading ) then
				return
			end
		end
	end
end

--projectiles
table.insert( actions,
{
	id = "NECRO_RAY",
	name = "Necro Ray",
	description = "A weak Necro Current beam that ignores physical matter and causes essence bleeding, animating the corpse.",
	sprite = "mods/necro_stuff/files/spells/necro_ray/necro_ray.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/necro_ray/necro_ray.xml" },
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 150,
	mana = ModSettingGetNextValue( "necro_stuff.GIVES_A_FUCK" ),
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		c.game_effect_entities = c.game_effect_entities.."mods/necro_stuff/files/spells/necro_ray/necromancy.xml,"
		add_projectile( "mods/necro_stuff/files/spells/necro_ray/necro_ray.xml" )
		current_reload_time = current_reload_time - ACTION_DRAW_RELOAD_TIME_INCREASE - 10
	end,
})

table.insert( actions,
{
	id = "NECRO_LIGHTNING",
	name = "Necro Lightning",
	description = "An extremely volatile Praeanima discharge with a Blasphemy crystal at its epicentre, that nearly\n                                          immediately collapses on itself causing a gravitational ripple.",
	sprite = "mods/necro_stuff/files/spells/necro_lightning/necro_lightning.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/necro_lightning/necro_lightning.xml" },
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 750,
	mana = 80,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.game_effect_entities = c.game_effect_entities.."mods/necro_stuff/files/spells/necro_lightning/necromancy.xml,"
		add_projectile( "mods/necro_stuff/files/spells/necro_lightning/necro_lightning.xml" )
		c.fire_rate_wait = c.fire_rate_wait + 66
		shot_effects.recoil_knockback = 66.0
	end,
})

table.insert( actions,
{
	id = "THE_IRE",
	name = "The Ire",
	description = "An unnaturally perfect rod that was spontaneously self-assembled from pure Necrostate and is being propelled\n                                          by an unstable Blasphemy-based compound at the very tip.",
	sprite = "mods/necro_stuff/files/spells/ire/ire_icon.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/ire/ire.xml" },
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 440,
	mana = 30,
	max_uses = 66,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/ire/ire.xml" )
		-- c.fire_rate_wait = c.fire_rate_wait + 66
		shot_effects.recoil_knockback = 100.0
	end,
})

--LORE

--static
table.insert( actions,
{
	id = "THE_OBLIVION",
	name = "The Oblivion",
	description = "A powerful gravitational oscillator that tears the space-time wall between the Dream and reality,\n                                          releasing every single one of the concealed projectiles.",
	sprite = "mods/necro_stuff/files/spells/oblivion/oblivion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/oblivion/oblivion.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 875,
	mana = 100,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/oblivion/oblivion.xml" )
	end,
})

table.insert( actions,
{
	id = "THE_PENANCE",
	name = "The Penance",
	description = "An on-the-spot generated warden spirit, that randomly selects one of the prisoners of the Torment\n                                          dimension, does all the required paperwork, ensures that the victim\n                                          was brainwashed into serving its master, applies sentence length\n                                          sensitive buffs and finally releases it, not forgetting to commit\n                                          self-termination.",
	sprite = "mods/necro_stuff/files/spells/penance/penance.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/penance/penance.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 1050,
	mana = 150,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/penance/penance.xml" )
	end,
})

table.insert( actions,
{
	id = "THE_GUILT",
	name = "The Guilt",
	description = "A speck of Blasphemy-Necrostate compound that is well known for its unbelievable space-time stability.\n                                          There can be only one.",
	sprite = "mods/necro_stuff/files/spells/guilt/guilt.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/guilt/guilt.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 400,
	mana = 99,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/guilt/guilt.xml" )
		c.fire_rate_wait = c.fire_rate_wait + 66
	end,
})

table.insert( actions,
{
	id = "THE_TENET",
	name = "The Tenet",
	description = "A purposefully-generated location-sensitive testimony that dynamically alters owner-abomination relations.\n                                          In this case, all the damage that the owner receives will be instantly\n                                          recuperated at the cost of collective abominable lifeforce contained within.",
	sprite = "mods/necro_stuff/files/spells/tenet/tenet.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/tenet/tenet.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 320,
	mana = 20,
	max_uses = 13,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/tenet/tenet.xml" )
	end,
})

table.insert( actions,
{
	id = "THE_WRATH",
	name = "The Wrath",
	description = "A momentary portal to an unknown location that unleashes a plethora of the Wrath Rays.",
	sprite = "mods/necro_stuff/files/spells/wrath/wrath.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/wrath/wrath.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 800,
	mana = 150,
	max_uses = 66,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/wrath/wrath.xml" )
		-- c.fire_rate_wait = c.fire_rate_wait + 66
	end,
})

table.insert( actions,
{
	id = "THE_ANSWER",
	name = "The Answer",
	description = "A lab-produced audio sequence, proven to be lethal to the majority of known life forms, manifested in\n                                          a physical state through a solid Summum Animae sculpture. It will kill.",
	sprite = "mods/necro_stuff/files/spells/answer/answer.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/answer/answer.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 2400,
	mana = 500,
	max_uses = 5,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/answer/answer.xml" )
		c.fire_rate_wait = c.fire_rate_wait + 66
	end,
})

table.insert( actions,
{
	id = "THE_FAULT",
	name = "The Fault",
	description = "A purposefully botched at the worst possible moment artificial god creation ritual, historically\n                                          used as a civilization-ending measure.",
	sprite = "mods/necro_stuff/files/spells/fault/fault.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	related_projectiles	= { "mods/necro_stuff/files/spells/fault/fault.xml" },
	type = ACTION_TYPE_STATIC_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 5600,
	mana = 6666,
	max_uses = 1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/fault/fault.xml" )
		c.fire_rate_wait = c.fire_rate_wait + 66
	end,
})

--misc "projectiles"
table.insert( actions,
{
	id = "MEATCHUNK",
	name = "Meatchunk",
	description = "Controls a ghost-like semi-sentient abomination (name's Jimmy) that attempts to shoot the first spell in\n                                          the caster's inventory and sometimes converts hostile projectiles into the\n                                          pure Arcane Current.",
	sprite = "mods/necro_stuff/files/spells/meatchunk/meatchunk.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 6666,
	mana = 10,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		local children = EntityGetAllChildren( GetUpdatedEntityID()) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				if( EntityHasTag( child, "meatchunk" )) then
					local comp = get_storage_old( child, "gonna_shoot" )
					if( comp ~= nil ) then
						ComponentSetValue2( comp, "value_bool", true )
						ComponentSetValue2( get_storage_old( child, "extra_stuff" ), "value_string", c.extra_entities )
					end
				end
			end
		end
		
		c.fire_rate_wait = c.fire_rate_wait + 66
	end,
})

table.insert( actions,
{
	id = "THE_VESSEL",
	name = "The Vessel",
	description = "Turns from a spell into a wand. Its sapience level remains unchanged throughout the entire transformation,\n                                          so the entity inside constantly experiences unimaginable suffering, used\n                                          as an energy source.",
	sprite = "mods/necro_stuff/files/spells/vessel/vessel.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 900,
	mana = 120,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/vessel/vessel_card.xml",
	action = function()
		local spell_id = get_spell_id()
		if( spell_id ~= nil and not( reflecting )) then
			function vessel_extractor( vessel_id )
				local spell_list = {}
				
				local children = EntityGetAllChildren( vessel_id ) or {}
				if( #children > 0 ) then
					for i,child in ipairs( children ) do
						if( EntityHasTag( child, "card_action" )) then
							if( EntityHasTag( child, "vessel" )) then
								local spells = vessel_extractor( child )
								if( #spells > 0 ) then
									for e,spl in ipairs( spells ) do
										table.insert( spell_list, spl )
									end
								end
							else
								table.insert( spell_list, child )
							end
						end
					end
				end
				
				return spell_list
			end
			
			for i,spell in ipairs( vessel_extractor( spell_id )) do
				local action_id = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( spell, "ItemActionComponent" ), "action_id" )
				local item_comp = EntityGetFirstComponentIncludingDisabled( spell, "ItemComponent" )
				local inventoryitem_id = ComponentGetValue2( item_comp, "mItemUid" )
				local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
				_add_card_to_deck( action_id, inventoryitem_id, uses_remaining, true )
			end
		end
	end,
})

table.insert( actions,
{
	id = "THE_BEHEST",
	name = "The Behest",
	description = "Manifests the master's will in a physical form, allowing to control multiple armaments at the same time.\n                                          Order for action will be sent each time the card is activated; some\n                                          modifiers will be brought through accordingly.",
	sprite = "mods/necro_stuff/files/spells/behest/behest.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_PROJECTILE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 2940,
	mana = 30,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/behest/behest_card.xml",
	action = function()
		local spell_id = get_spell_id()
		if( spell_id ~= nil and not( reflecting )) then
			local storage = get_storage_old( spell_id, "extra_stuff" )
			if( storage ~= nil ) then
				ComponentSetValue2( storage, "value_string", c.extra_entities )
				
				local anchor_link = ComponentGetValue2( get_storage_old( get_hooman_child_old( spell_id, "behest_anchor" ), "link" ), "value_int" )
				if( anchor_link ~= 0 ) then
					local body_id = 0
					local bodies = EntityGetWithTag( "behest_body" ) or {}
					if( #bodies > 0 ) then
						for i,body in ipairs( bodies ) do
							if( ComponentGetValue2( get_storage_old( body, "link" ), "value_int" ) == anchor_link ) then
								body_id = body
								break
							end
						end
					end
					
					if( body_id ~= 0 ) then
						local children = EntityGetAllChildren( body_id ) or {}
						if( #children > 0 ) then
							for i,child in ipairs( children ) do
								if( EntityHasTag( child, "behest_brain" )) then
									ComponentSetValue2( get_storage_old( child, "gonna_shoot" ), "value_bool", true )
								end
							end
						end
					end
				end
			end
		end
	end,
})

--LAW

--modifiers
table.insert( actions,
{
	id = "SIGIL_OF_SIN",
	name = "Sigil of Sin",
	description = "Applies a dormant sigil to the projectile to be transferred to the hit enemy, changing its Necro Current\n                                          worth from body-bound to essence-bound, resulting in 100% efficiency.",
	sprite = "mods/necro_stuff/files/spells/sin_sigil/sin_sigil.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/sin_sigil/sin_sigil_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 600,
	mana = 0,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/sin_sigil/sin_sigil_projectile.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_DREAM",
	name = "The Dream",
	description = "Creates a self-sustaining reality clot, commonly known as the Dream, around the projectile, suspending\n                                          it within indefinitely.",
	sprite = "mods/necro_stuff/files/spells/dream/dream.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/dream/dream.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 875,
	mana = 10,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/dream/dream.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_TORMENT",
	name = "The Torment",
	description = "Attempts to capture a sentient target it hit into the torment dimension with success chance being dependent\n                                          on how powerful the creature has been moments before.",
	sprite = "mods/necro_stuff/files/spells/torment/torment.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/torment/torment_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 1050,
	mana = 15,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/torment/torment_projectile.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_TRUTH",
	name = "The Truth",
	description = "Establishes temporal tunnel between Mors Lignum in its True Form in the past and the projectile in present,\n                                          resulting in the effect akin to the one that the Form applies to each shot.",
	sprite = "mods/necro_stuff/files/spells/truth/truth.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/stuff/true_form_power.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 560,
	mana = 40,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card.xml",
	action = function()
		local x, y = EntityGetTransform( GetUpdatedEntityID())
		local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
		if( stuff ~= nil and not( reflecting )) then
			local necro_stage = ComponentGetValue2( get_storage_old( stuff, "necro_stage" ), "value_int" )
			if( necro_stage ~= nil ) then
				c.extra_entities = c.extra_entities.."mods/necro_stuff/files/stuff/true_form_power.xml,"
				c.fire_rate_wait = c.fire_rate_wait + necro_stage*10
				c.damage_projectile_add = c.damage_projectile_add + necro_stage/7
			end
		end
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "FINNISH_INFUSION",
	name = "Kolminkertaisesti Viehättävä",
	description = "Channels the energy of this realm into the next spell card, attaching one trigger per every three cards\n                                          in the deck.",
	sprite = "mods/necro_stuff/files/spells/finnish_infusion/finnish_infusion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 750,
	mana = 10,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		local power = #deck
		c.child_speed_multiplier = c.child_speed_multiplier + 1 + power/10
		c.damage_critical_chance = math.min( c.damage_critical_chance + power/20, 1 )
		c.damage_critical_multiplier = c.damage_critical_multiplier + power/10
		c.lifetime_add = c.lifetime_add*math.max( power/2, 1 )
		c.screenshake = power
		
		local data = {}
		if( #deck > 0 ) then
			data = deck[1]
		else
			data = nil
		end
		
		if( power > 2 and data ~= nil ) then
			local how_many = 1
			while(( #deck >= how_many ) and (( data.type == ACTION_TYPE_MODIFIER ) or ( data.type == ACTION_TYPE_PASSIVE ) or ( data.type == ACTION_TYPE_OTHER ) or ( data.type == ACTION_TYPE_DRAW_MANY ))) do
				if((( data.uses_remaining == nil ) or ( data.uses_remaining ~= 0 )) and ( data.id ~= "ADD_TRIGGER" ) and ( data.id ~= "ADD_TIMER" ) and ( data.id ~= "ADD_DEATH_TRIGGER" ) and ( data.id ~= "FINNISH_INFUSION" )) then
					if( data.type == ACTION_TYPE_MODIFIER ) then
						dont_draw_actions = true
						data.action()
						dont_draw_actions = false
					end
				end
				how_many = how_many + 1
				data = deck[how_many]
			end
			
			if(( data ~= nil ) and ( data.related_projectiles ~= nil ) and (( data.uses_remaining == nil ) or ( data.uses_remaining ~= 0 ))) then
				local target = data.related_projectiles[1]
				local count = data.related_projectiles[2] or 1
				
				for i = 1,how_many do
					data = deck[1]
					table.insert( discarded, data )
					table.remove( deck, 1 )
				end
				
				local valid = false
				
				for i = 1,#deck do
					local check = deck[i]
					
					if(( check ~= nil ) and (( check.type == ACTION_TYPE_PROJECTILE ) or ( check.type == ACTION_TYPE_STATIC_PROJECTILE ) or ( check.type == ACTION_TYPE_MATERIAL ) or ( check.type == ACTION_TYPE_UTILITY ))) then
						valid = true
						break
					end
				end
				
				if(( data.uses_remaining ~= nil ) and ( data.uses_remaining > 0 )) then
					data.uses_remaining = data.uses_remaining - 1
					
					local reduce_uses = ActionUsesRemainingChanged( data.inventoryitem_id, data.uses_remaining )
					if( not( reduce_uses )) then
						data.uses_remaining = data.uses_remaining + 1
					end
				end
				
				if( valid ) then
					for i = 1,count do
						add_projectile_trigger_death( target, math.floor( power/3 ))
					end
				else
					dont_draw_actions = true
					data.action()
					dont_draw_actions = false
				end
			end
		else
			draw_actions( 1, true )
		end
	end,
})

table.insert( actions,
{
	id = "NECRO_INFUSION",
	name = "Necro Infusion",
	description = "Turns the projectile into a necro anomaly at the cost of 10 Necro Current units. All the enemies that\n                                          will end up inside the field will be damaged and some of their Necro\n                                          Current will be extracted. The more Necro Current is present, the\n                                          stronger the anomaly will become.",
	sprite = "mods/necro_stuff/files/spells/necro_infusion/necro_infusion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/necro_infusion/necro_infusion.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 420,
	mana = 100,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		local entity_id = GetUpdatedEntityID()
		local x, y = EntityGetTransform( entity_id )
		local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
		if( stuff ~= nil and not( reflecting )) then
			local storage_necro = get_storage_old( stuff, "necro_current" )
			if( storage_necro ~= nil ) then
				local necro_current = ComponentGetValue2( storage_necro, "value_float" )
				if( necro_current - tonumber( GlobalsGetValue( "NECRO_ZERO", "0" )) > 10 ) then
					ComponentSetValue2( storage_necro, "value_float", necro_current - 10 )
				else
					local damage_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
					EntityInflictDamage( entity_id, math.floor( ComponentGetValue2( damage_comp, "hp" )/10 ), "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, stuff, x, y, 0 )
				end
				c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/necro_infusion/necro_infusion.xml,"
			end
		end
		c.fire_rate_wait = c.fire_rate_wait + 60
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "ARCANE_INFUSION",
	name = "Arcane Infusion",
	description = "Turns the projectile into an arcane anomaly at the cost of 10 Arcane Current units. All the spell cards\n                                          that will end up inside the field will be cast by the projectile itself.\n                                          The more Arcane Current is present, the stronger the anomaly will\n                                          become.",
	sprite = "mods/necro_stuff/files/spells/arcane_infusion/arcane_infusion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/arcane_infusion/arcane_infusion.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 450,
	mana = 100,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		local entity_id = GetUpdatedEntityID()
		local x, y = EntityGetTransform( entity_id )
		local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
		if( stuff ~= nil and not( reflecting )) then
			local storage_mana = get_storage_old( stuff, "mana_current" )
			if( storage_mana ~= nil ) then
				local mana_current = ComponentGetValue2( storage_mana, "value_float" )
				if( mana_current > 10 ) then
					ComponentSetValue2( storage_mana, "value_float", mana_current - 10 )
				else
					local damage_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
					EntityInflictDamage( entity_id, ComponentGetValue2( damage_comp, "hp" )/10, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, stuff, x, y, 0 )
				end
				c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/arcane_infusion/arcane_infusion.xml,"
			end
		end
		c.fire_rate_wait = c.fire_rate_wait + 60
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "ABHORRENT_INFUSION",
	name = "Abhorrent Infusion",
	description = "Channels the collective abominable essence through the closest abomination, killing the creature and\n                                          improving the projectile's characteristics based on the stats of\n                                          the abominable herd overall.",
	sprite = "mods/necro_stuff/files/spells/abhorrent_infusion/abhorrent_infusion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/abhorrent_infusion/abhorrent_infusion.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 600,
	mana = 50,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/abhorrent_infusion/abhorrent_infusion.xml,"
		c.fire_rate_wait = c.fire_rate_wait + 60
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "CORRUPT_INFUSION",
	name = "Corrupt Infusion",
	description = "Grows a tiny Blasphemy crystal directly on the projectile to be deposited on the hit creature. When the\n                                          carrier dies, the crystal shatters and reinforces the essence of the\n                                          closest undead based on the power level of the entire undead army.",
	sprite = "mods/necro_stuff/files/spells/corrupt_infusion/corrupt_infusion.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/corrupt_infusion/corrupt_infusion_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 600,
	mana = 120,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/corrupt_infusion/corrupt_infusion_projectile.xml,"
		c.fire_rate_wait = c.fire_rate_wait + 60
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "NECRO_FLAGELLATION",
	name = "Necro Flagellation",
	description = "Captures the projectile into the dimensional torture pocket, assigns a sentient soul to it, flagellates\n                                          it for aeons with time drastically accelerated, uses extracted energy\n                                          of pain and suffering to noticeably improve the performance and then\n                                          finally unleashes the persecuted.",
	sprite = "mods/necro_stuff/files/spells/necro_flagellation/necro_flagellation.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/necro_flagellation/necro_flagellation.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 900,
	mana = 9,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/necro_flagellation/necro_flagellation.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_HERESY",
	name = "The Heresy",
	description = "Infuses the projectile with a ready-to-use abominable compound that will embed itself into the hit enemy\n                                          and self-activate on one's death.",
	sprite = "mods/necro_stuff/files/spells/heresy/heresy.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 480,
	mana = 30,
	max_uses = 13,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		c.game_effect_entities = c.game_effect_entities.."mods/necro_stuff/files/spells/heresy/heresy.xml,"
		draw_actions( 1, true )
	end,
})

-- table.insert( actions,
-- {
	-- id = "THE_MACHINE",
	-- name = "The Machine",
	-- description = "Attaches a self-spreading Machine Essence Emitter to the projectile.",
	-- sprite = "mods/necro_stuff/files/spells/machine/machine.png",
	-- sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	-- type = ACTION_TYPE_MODIFIER,
	-- related_extra_entities = { "mods/necro_stuff/files/spells/machine/machine_trail.xml" },
	-- spawn_requires_flag = "never_fucking_spawn",
	-- spawn_level = "",
	-- spawn_probability = "",
	-- price = 420,
	-- mana = 6,
	-- max_uses = 13,
	-- custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	-- action = function()
		-- c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/machine/machine_trail.xml,"
		-- draw_actions( 1, true )
	-- end,
-- })

table.insert( actions,
{
	id = "THE_CURE",
	name = "The Cure",
	description = "Infects the projectile with a military-grade combat-ready strain of the Cure well known for its terrifying\n                                          lethality and remarkable volatility.",
	sprite = "mods/necro_stuff/files/spells/cure/cure.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/cure/cure_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 720,
	mana = 40,
	max_uses = 6,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/cure/cure_projectile.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_FEAR",
	name = "The Fear",
	description = "Imbues the projectile with sentient mind and primal dread, forcing it to flee no matter what stands on\n                                          its path.",
	sprite = "mods/necro_stuff/files/spells/fear/fear.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/fear/fear.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 760,
	mana = 180,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/fear/fear.xml,"
		c.fire_rate_wait = c.fire_rate_wait + 30
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_REVELATION",
	name = "The Revelation",
	description = "Quickly shifts and returns the hit enemy to and from another plane of existence. Momentary transition is\n                                          too fast to kill the poor bastard but severe enough to permanently\n                                          taint its body with a random status effect.",
	sprite = "mods/necro_stuff/files/spells/revelation/revelation.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/revelation/revelation_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 540,
	mana = 30,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/revelation/revelation_projectile.xml,"
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_AWAKENING",
	name = "The Awakening",
	description = "Reborns the hit creature into an absolute slave by replacing its brain matter with 66hp of master's flesh\n                                          and consuming its full Necro Current worth from the Mors Lignum's bank.",
	sprite = "mods/necro_stuff/files/spells/awakening/awakening.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_MODIFIER,
	related_extra_entities = { "mods/necro_stuff/files/spells/awakening/awakening_projectile.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 1320,
	mana = 100,
	max_uses = 13,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card1.xml",
	action = function()
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/awakening/awakening_projectile.xml,"
		draw_actions( 1, true )
	end,
})

--multi
table.insert( actions,
{
	id = "THE_EXECUTION",
	name = "The Execution",
	description = "Positions next 4 spells in the Guillotine formation, a shape originally developed as a more humane method\n                                          of execution for non-humanoid life forms.",
	sprite = "mods/necro_stuff/files/spells/execution/execution.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_DRAW_MANY,
	related_extra_entities = { "mods/necro_stuff/files/spells/execution/execution.xml" },
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 360,
	mana = 8,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card0.xml",
	action = function()
		c.speed_multiplier = 0
		c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/execution/execution.xml,"
		draw_actions_fancy( 4, true )
	end,
})

--misc
table.insert( actions,
{
	id = "THE_AEON",
	name = "The Aeon",
	description = "Creates a temporal feedback loop that repeatedly casts the entire wand's deck. It is maintained by raw\n                                          Arcane Current, so each iteration will consume 10 units, and is\n                                          exceptionally lasting, so it will only stop when there's not enough\n                                          stabilizing agent.",
	sprite = "mods/necro_stuff/files/spells/aeon/aeon.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 600,
	mana = 5,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		local x, y = EntityGetTransform( GetUpdatedEntityID())
		local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
		if( stuff ~= nil and not( reflecting )) then
			local storage_mana = get_storage_old( stuff, "mana_current" )
			local mana_current = ComponentGetValue2( storage_mana, "value_float" )
			if( mana_current ~= nil and mana_current > 10 ) then
				ComponentSetValue2( storage_mana, "value_float", mana_current - 10 )
				
				dont_draw_actions = true
				for i,v in ipairs( hand ) do
					if( i <= #hand ) then
						v.action()
					end
				end
				
				for i,v in ipairs( deck ) do
					if( i <= #deck ) then
						v.action()
					end
				end
				
				for i,v in ipairs( discarded ) do
					if( i <= #discarded ) then
						v.action()
					end
				end
				dont_draw_actions = false
			end
		end
	end,
})

table.insert( actions,
{
	id = "THE_SCHISM",
	name = "The Schism",
	description = "Uses unique abominable essence signatures as a foundation for the projectile's dividers. The more there\n                                          are essences, the more there will be dividers.",
	sprite = "mods/necro_stuff/files/spells/schism/schism.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 1000,
	mana = 100,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function( recursion_level, iteration )
		local data = {}
		
		local iter = iteration or 1
		local iter_max = iteration or 1
		
		if( #deck > 0 ) then
			data = deck[iter] or nil
		else
			data = nil
		end
		
		local count = math.max( #( EntityGetWithTag( "abomination" ) or {}), 2 )
		
		local rec = check_recursion( data, recursion_level )
		
		if(( data ~= nil ) and ( rec > -1 ) and (( data.uses_remaining == nil ) or ( data.uses_remaining ~= 0 ))) then
			local firerate = c.fire_rate_wait
			local reload = current_reload_time
			
			for i = 1,count do
				if( i == 1 ) then
					dont_draw_actions = true
				end
				local imax = data.action( rec, iter + 1 )
				dont_draw_actions = false
				if( imax ~= nil ) then
					iter_max = imax
				end
			end
			
			if(( data.uses_remaining ~= nil ) and ( data.uses_remaining > 0 )) then
				data.uses_remaining = data.uses_remaining - 1
				
				local reduce_uses = ActionUsesRemainingChanged( data.inventoryitem_id, data.uses_remaining )
				if( not( reduce_uses )) then
					data.uses_remaining = data.uses_remaining + 1
				end
			end
			
			if( iter == 1 ) then
				c.fire_rate_wait = firerate
				current_reload_time = reload
				
				for i = 1,iter_max do
					if( #deck > 0 ) then
						local d = deck[1]
						table.insert( discarded, d )
						table.remove( deck, 1 )
					end
				end
			end
		end
		
		return iter_max
	end,
})

table.insert( actions,
{
	id = "THE_ASCENSION",
	name = "The Ascention",
	description = "Extracts all the spells available to the combined abominable consciousness and projects them on top of one\n                                          another to then cast as a unified projectile.",
	sprite = "mods/necro_stuff/files/spells/ascention/ascention.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 750,
	mana = 200,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card2.xml",
	action = function()
		local build = {}
		
		local meats = EntityGetWithTag( "abomination" ) or {}
		if( #meats > 0 ) then
			local c_x, c_y = EntityGetTransform( GetUpdatedEntityID())
			for i,meat in ipairs( meats ) do
				local inv_comp = EntityGetFirstComponentIncludingDisabled( meat, "Inventory2Component" )
				if( inv_comp ~= nil ) then
					local deck = {}
					local wand_id = tonumber( ComponentGetValue( inv_comp, "mActiveItem" ) or 0 )
					if( wand_id ~= 0 ) then
						local spells = EntityGetAllChildren( wand_id ) or {}
						if( #spells > 0 ) then
							for e,spell_id in ipairs( spells ) do
								local comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemActionComponent" )
								if( comp ~= nil ) then
									table.insert( deck, ComponentGetValue2( comp, "action_id" ))
								end
							end
						end
					end
					local m_x, m_y = EntityGetTransform( meat )
					local build_id = math.sqrt(( c_x - m_x )^2 + ( c_y - m_y )^2 )*1000000
					while( build[build_id] ~= nil ) do
						build_id = build_id + 1
					end
					build[build_id] = deck
				end
			end
		end
		
		actual_add_projectile = add_projectile
		add_projectile = function( entity_filename )
			c.extra_entities = c.extra_entities..entity_filename..","
		end
		actual_add_projectile_trigger_timer = add_projectile_trigger_timer
		add_projectile_trigger_timer = function( entity_filename, delay_frames, action_draw_count )
			c.extra_entities = c.extra_entities..entity_filename..","
		end
		actual_add_projectile_trigger_hit_world = add_projectile_trigger_hit_world
		add_projectile_trigger_hit_world = function( entity_filename, action_draw_count )
			c.extra_entities = c.extra_entities..entity_filename..","
		end
		actual_add_projectile_trigger_death = add_projectile_trigger_death
		add_projectile_trigger_death = function( entity_filename, action_draw_count )
			c.extra_entities = c.extra_entities..entity_filename..","
		end
		
		if( current_action ~= nil and current_action.deck_index ~= nil )then
			for i,spell_ids in magic_sorter_old( build ) do
				for e,spell_id in ipairs( spell_ids ) do
					for k,spell in ipairs( actions )do
						if( spell.id == spell_id )then
							dont_draw_actions = true
							spell.action()
							dont_draw_actions = false
						end
					end
				end
			end
		end
		
		add_projectile = actual_add_projectile
		add_projectile_trigger_timer = actual_add_projectile_trigger_timer
		add_projectile_trigger_hit_world = actual_add_projectile_trigger_hit_world
		add_projectile_trigger_death = actual_add_projectile_trigger_death
		
		c.fire_rate_wait = c.fire_rate_wait + 666
		
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_PRESENCE",
	name = "The Presence",
	description = "Purposefully fine-tunes fundamental constants of this universe to shift the contents of the random flask\n                                          in the caster's inventory (default: blood) to the contents of one's\n                                          stomach (default: Necro Current).",
	sprite = "mods/necro_stuff/files/spells/presence/presence.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 2100,
	mana = 250,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		local hooman = GetUpdatedEntityID()
		local flasks = {}
		local children = EntityGetAllChildren( get_hooman_child_old( hooman, "inventory_quick" )) or {}
		if( #children > 0 ) then
			for i,child in ipairs( children ) do
				if( EntityGetFirstComponentIncludingDisabled( child, "PotionComponent" ) ~= nil and EntityGetFirstComponentIncludingDisabled( child, "MaterialInventoryComponent" ) ~= nil ) then
					table.insert( flasks, child )
				end
			end
			
			SetRandomSeed( GameGetFrameNum(), hooman + #children )
			local flask = #flasks > 0 and flasks[Random( 1, #flasks )] or 0
			local mtr_flask = flask ~= 0 and get_matter_old( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( flask, "MaterialInventoryComponent" ), "count_per_material_type" ) or {})[1] or 0
			if( mtr_flask ~= 0 ) then
				AddMaterialInventoryMaterial( flask, CellFactory_GetName( mtr_flask ), 0 )
			else
				mtr_flask = CellFactory_GetType( "blood" )
			end
			
			local mtr_stomach = get_matter_old( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( hooman, "MaterialInventoryComponent" ), "count_per_material_type" ) or {})[1]
			if( mtr_stomach ~= 0 ) then
				AddMaterialInventoryMaterial( hooman, CellFactory_GetName( mtr_stomach ), 0 )
			else
				mtr_stomach = CellFactory_GetType( "necro_current" )
			end
			
			-- GamePrint( CellFactory_GetUIName( mtr_flask ))
			-- GamePrint( CellFactory_GetUIName( mtr_stomach ))
			
			if( mtr_flask ~= mtr_stomach ) then
				ConvertMaterialEverywhere( mtr_flask, mtr_stomach )
			end
		end
		
		c.fire_rate_wait = c.fire_rate_wait + 666
	end,
})

table.insert( actions,
{
	id = "THE_RAPTURE",
	name = "The Rapture",
	description = "Manipulates the rules of the living, causing all the independent wands nearby to spontaneously self animate.",
	sprite = "mods/necro_stuff/files/spells/rapture/rapture.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 900,
	mana = 50,
	max_uses = 3,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/rapture/rapture.xml" )
		
		c.fire_rate_wait = c.fire_rate_wait + 666
	end,
})

table.insert( actions,
{
	id = "THE_JUDGMENT",
	name = "The Judgment",
	description = "Assembles and extinguishes a makeshift god to project its will on the nearby enemies. Every wand-holder\n                                          gets turned into the Judge, the rest gets turned into the Judged.",
	sprite = "mods/necro_stuff/files/spells/judgment/judgment.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 4200,
	mana = 66,
	max_uses = 3,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/judgment/judgment.xml" )
		
		c.fire_rate_wait = c.fire_rate_wait + 666
	end,
})

table.insert( actions,
{
	id = "THE_QUESTION",
	name = "The Question",
	description = "Bombards the consciousness of all the entities nearby with billions of questions far beyond mortal's\n                                          comprehension, which results in sapience collapse, leaving just empty\n                                          husks behind.",
	sprite = "mods/necro_stuff/files/spells/question/question.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_OTHER,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 4200,
	mana = 666,
	max_uses = 3,
	custom_xml_file = "mods/necro_stuff/files/spells/base_card3.xml",
	action = function()
		add_projectile( "mods/necro_stuff/files/spells/question/question.xml" )
		
		c.fire_rate_wait = c.fire_rate_wait + 666
	end,
})

--passive
table.insert( actions,
{
	id = "THE_EFFIGY",
	name = "The Effigy",
	description = "Serves as a beacon-conduit combo for the Mors Lignum's essence collectors, enabling them to successfully\n                                          extract the Necro Current from the corpses even if the Staff itself\n                                          wasn't directly related to their demise.\n                                          Works only while in inventory.",
	sprite = "mods/necro_stuff/files/spells/effigy/effigy.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_PASSIVE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 360,
	mana = 0,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/effigy/effigy_card.xml",
	action = function()
		draw_actions( 1, true )
	end,
})

table.insert( actions,
{
	id = "THE_LIMBO",
	name = "The Limbo",
	description = "Extracts residual matter (Necro Inferno) from the localized entropy field fluctuations (usually the death\n                                          of an enemy) and carefully stores it inside of empty flasks in the caster's\n                                          inventory.",
	sprite = "mods/necro_stuff/files/spells/limbo/limbo.png",
	sprite_unidentified = "data/ui_gfx/gun_actions/light_bullet_trigger_unidentified.png",
	type = ACTION_TYPE_PASSIVE,
	spawn_requires_flag = "never_fucking_spawn",
	spawn_level = "",
	spawn_probability = "",
	price = 480,
	mana = 0,
	max_uses = -1,
	custom_xml_file = "mods/necro_stuff/files/spells/limbo/limbo_card.xml",
	action = function()
		draw_actions( 1, true )
	end,
})
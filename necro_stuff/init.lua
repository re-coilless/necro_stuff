ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/necro_stuff/files/actions.lua" )
ModLuaFileAppend( "data/scripts/gun/gun_extra_modifiers.lua", "mods/necro_stuff/files/stuff/extra_modifiers.lua" )
ModLuaFileAppend( "data/scripts/status_effects/status_list.lua", "mods/necro_stuff/files/status_effects.lua" )
ModMaterialsFileAdd( "mods/necro_stuff/files/matters.xml" )
--WARNING: IF YOU ARE USING THIS MOD AS AN EXAMPLE - DON'T. IT CONTAINS EXEPTIONALLY SHITTY CODING PRACTICES, SO BETTER TRY LITERALY ANY OTHER MOD ON THE WORKSHOP.
function OnModInit()
	dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

	local herd_relations = {
		{ 
			name = "necro_bait", 
			default_value = 0,
			vanilla_vertical = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
			vanilla_horizontal = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
			custom_vertical = {},
			custom_horizontal = { 0, },
		},
		{ 
			name = "necro_abomination_tiny", 
			default_value = 100,
			vanilla_vertical = { 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, },
			vanilla_horizontal = { 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
			custom_vertical = { 100, },
			custom_horizontal = { 0, 100, },
		},
		{ 
			name = "necro_abomination", 
			default_value = 0,
			vanilla_vertical = { 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
			vanilla_horizontal = { 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
			custom_vertical = { 0, 100, },
			custom_horizontal = { 0, 100, 100, },
		},
	}

	--Herd relations
	local herd_relations_old = "data/genome_relations.csv"
	
	file = t2l_old( ModTextFileGetContent( herd_relations_old ))
	local _,count = string.gsub( file[1], ",", "" )
	
	for i,herd in ipairs( herd_relations ) do
		file[1] = file[1]..","..herd.name
		for e = 2,( count + i ) do
			if( e < 37 ) then
				file[e] = file[e]..","..herd.vanilla_vertical[ e - 1 ]
			elseif( e > count - #herd_relations + i and herd.custom_vertical ~= nil ) then
				local value = herd.custom_vertical[ e - ( count + 1 ) ] or herd.default_value
				file[e] = file[e]..","..value
			else
				file[e] = file[e]..","..herd.default_value
			end
		end
		
		local new_line = herd.name
		for e = 1,( count + i ) do
			if( e < 36 ) then
				new_line = new_line..","..herd.vanilla_horizontal[e]
			elseif( e > count - #herd_relations and herd.custom_horizontal ~= nil ) then
				local value = herd.custom_horizontal[ e - count ] or herd.default_value
				new_line = new_line..","..value
			else
				new_line = new_line..","..herd.default_value
			end
		end
		table.insert( file, new_line )
	end
	
	local herd_relations_new = ""
	for i,line in ipairs( file ) do
		herd_relations_new = herd_relations_new..line.."\n"
	end
	ModTextFileSetContent( herd_relations_old, herd_relations_new )
end

function OnWorldPreUpdate()
	-- dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
	
	if( HasFlagPersistent( "never_fucking_spawn" )) then
		RemoveFlagPersistent( "never_fucking_spawn" )
		-- print( "I hate this so much." )
	end
	
	-- local hooman = get_player()
	-- local ctrl_comp = EntityGetFirstComponentIncludingDisabled( hooman, "ControlsComponent" )
	-- if( ComponentGetValue2( ctrl_comp, "mButtonDownDown" )) then
		-- local m_x, m_y = DEBUG_GetMouseWorld()
		-- local dud = EntityGetRootEntity( EntityGetClosest( m_x, m_y ))
		-- print( tostring( dud ).."|"..tostring( EntityGetName( dud )).."|"..get_necro_current( dud ) )
	-- end
end

function OnPlayerSpawned( hooman )
	dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
	
	local initer = "NECRO_STUFF_INDEED"
	if( GameHasFlagRun( initer )) then
		return
	end
	GameAddFlagRun( initer )
	
	GlobalsSetValue( "NECRO_LADDER", "|0|666|1664|2664|5664|16664|66666|666666|" )
	GlobalsSetValue( "PRICE_LADDER", "|1|5|10|50|100|" )
	
	local x, y = EntityGetTransform( hooman )
	EntityAddTag( hooman, "weird_dude" )
	EntityAddTag( hooman, "cured" )
	GamePickUpInventoryItem( hooman, EntityLoad( "mods/necro_stuff/files/stuff/article.xml", x, y ), false )
	GamePickUpInventoryItem( hooman, EntityLoad( "mods/necro_stuff/files/stuff/shard_of_blasphemy.xml", x, y ), false )
	EntityLoad( "mods/necro_stuff/files/stuff/stuff.xml", x, y )
	
	if( ModSettingGetNextValue( "necro_stuff.EFFIGY_START" )) then
		GamePickUpInventoryItem( hooman, CreateItemActionEntity( "THE_EFFIGY", x, y ), false )
	end
	
	GamePrintImportant( "WELCOME TO ALPHA RELEASE", "reach 7th Necro Tier to proceed", "mods/necro_stuff/files/gui/gameprint.png" )
	
	-- CreateItemActionEntity( "THE_TORMENT", x, y )
	-- ComponentSetValue2( GetGameEffectLoadTo( hooman, "EDIT_WANDS_EVERYWHERE", true ), "frames", -1 )
	
	-- EntityLoad( "mods/necro_stuff/files/spells/machine/core.xml", x, y - 30 )
end
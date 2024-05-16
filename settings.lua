dofile( "data/scripts/lib/mod_settings.lua" ) 

function mod_setting_fucker( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ))
	
	local clicked, r_clicked = GuiButton( gui, im_id, mod_setting_group_x_offset, 0, setting.ui_name..": "..setting.values[value] )
	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
	if( clicked ) then
		ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), ( value == #setting.values ) and 1 or ( value + 1 ), false )
	end
	if( r_clicked and setting.value_default ) then
		ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), setting.value_default, false )
	end
end

function mod_setting_layouter( mod_id, gui, in_main_menu, im_id, setting )
	if( not( ModIsEnabled( "necro_stuff" ))) then
		return
	end
	
	local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ))
	local new_value = value
	
	local clicked = GuiButton( gui, im_id, mod_setting_group_x_offset, 0, setting.ui_name )
	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
	if( clicked ) then
		new_value = not( value )
		local set_table = {
			{ 2, 22, 19, 40, false, },
			{ 540, 28, 396, 27, true, },
		}
		local set_value = set_table[ new_value and 2 or 1 ]
		ModSettingSetNextValue( "necro_stuff.BUTTON_POS_X", tostring( set_value[1] ), false )
		ModSettingSetNextValue( "necro_stuff.BUTTON_POS_Y", tostring( set_value[2] ), false )
		ModSettingSetNextValue( "necro_stuff.WINDOW_POS_X", tostring( set_value[3] ), false )
		ModSettingSetNextValue( "necro_stuff.WINDOW_POS_Y", tostring( set_value[4] ), false )
		ModSettingSetNextValue( "necro_stuff.TOOLTIP_MIRROR", set_value[5], false )
	end
	
	if( value ~= new_value ) then
		ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), new_value, false )
	end
end

-- function mod_setting_balancer( mod_id, gui, in_main_menu, im_id, setting )
	-- local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ))
	
	-- GuiLayoutBeginHorizontal( gui, 0, 0 )
	-- local new_value_A = GuiSlider( gui, im_id, mod_setting_group_x_offset, 5, setting.ui_name, value, setting.value_min, setting.value_max, setting.value_default, setting.value_display_multiplier or 1, setting.value_display_formatting or "", 64 )
	-- local new_value_B = tonumber( GuiTextInput( gui, im_id, mod_setting_group_x_offset + 50, 2, tostring( value ), 30, 7, "1234567890." ))
	-- mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
	
	-- local true_value = ( value ~= new_value_A ) and new_value_A or (( value ~= new_value_B ) and new_value_B or 0 )
	-- if( true_value ~= 0 ) then
		-- ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), true_value, false )
	-- end
	-- GuiLayoutEnd( gui )
-- end

function mod_setting_cheater( mod_id, gui, in_main_menu, im_id, setting )
	if( not( ModIsEnabled( "necro_stuff" ))) then
		return
	end
	
	if( GameHasFlagRun( "NECRO_CHEAT_ACTIVE" )) then
		GuiButton( gui, im_id, mod_setting_group_x_offset, 0, "PROJECTION WAS COMPLETED" )
	else
		local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ))
		
		GuiLayoutBeginHorizontal( gui, 0, 0 )
		local clicked, r_clicked = GuiButton( gui, im_id, mod_setting_group_x_offset, 0, setting.ui_name )
		mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
		local new_value = GuiTextInput( gui, im_id, mod_setting_group_x_offset, 0, value, 30, 7, "askoldjftuwbcqpxn1234567890 " )
		if( clicked ) then
			if( value == "666" ) then -- 104.18.13.16
				dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
				local stuff = EntityGetClosestWithTag( 0, 0, "necro_stuff" ) or 0
				if( stuff ~= 0 ) then
					GameAddFlagRun( "NECRO_CHEAT_ACTIVE" )
					ComponentSetValue2( get_storage_old( stuff, "necro_current" ), "value_float", 666666 )
					ComponentSetValue2( get_storage_old( stuff, "mana_current" ), "value_float", 666666 )
				else
					new_value = "no stuf"
				end
			else
				new_value = "too bad"
			end
		end
		if( r_clicked ) then
			new_value = ""
		end
		GuiLayoutEnd( gui )
		
		if( value ~= new_value ) then
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), new_value, false )
		end
	end
end

local mod_id = "necro_stuff"
mod_settings_version = 1
mod_settings = 
{
	{
		category_id = "GUI_STUFF",
		ui_name = "[GUI STUFF]",
		ui_description = "",
		foldable = true,
		_folded = true,
		settings = {
			{
				id = "LAYOUTER",
				ui_name = "[Click Here to Quickly Swap the UI Layout]",
				ui_description = "Custom values will be overwritten.",
				hidden = false,
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
				ui_fn = mod_setting_layouter,
			},
			{
				id = "BUTTON_POS_X",
				ui_name = "Interface Button Position X:",
				ui_description = "",
				value_default = "2",
				text_max_length = 5,
				allowed_characters = "-0123456789.",
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				id = "BUTTON_POS_Y",
				ui_name = "Interface Button Position Y:",
				ui_description = "",
				value_default = "22",
				text_max_length = 5,
				allowed_characters = "-0123456789.",
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				id = "WINDOW_POS_X",
				ui_name = "Window Position X:",
				ui_description = "",
				value_default = "19",
				text_max_length = 5,
				allowed_characters = "-0123456789.",
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				id = "WINDOW_POS_Y",
				ui_name = "Window Position Y:",
				ui_description = "",
				value_default = "40",
				text_max_length = 5,
				allowed_characters = "-0123456789.",
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				id = "TOOLTIP_MIRROR",
				ui_name = "Mirror Major Tooltips Position",
				ui_description = "",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				ui_fn = mod_setting_vertical_spacing,
				not_setting = true,
			},
			{
				id = "LESSS_GO",
				ui_name = "You Know What This Is",
				ui_description = "Do it",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
		},
	},
	
	{
		category_id = "BALANCING",
		ui_name = "[BALANCING]",
		ui_description = "",
		foldable = true,
		_folded = true,
		settings = {
			{
				id = "GIVES_A_FUCK",
				ui_name = "Global Balance Mode",
				ui_description = "Offsets the prices.",
				value_default = 3,
				values = { "who asked (x0.01)", "grill (x0.05)", "casul (x0.1)", "blance (x0.4)", "git gud (x1)", },
				scope = MOD_SETTING_SCOPE_RUNTIME,
				ui_fn = mod_setting_fucker,
			},
			{
				id = "NC_SPEED",
				ui_name = "Necro Progression Speed",
				ui_description = "Multiplies all the Necro Current incomes.",
				value_default = 1,
				value_min = 1,
				value_max = 5,
				value_display_multiplier = 1,
				value_display_formatting = " $0 ",
				scope = MOD_SETTING_SCOPE_RUNTIME,
				-- ui_fn = mod_setting_nc_balancer,
			},
			{
				id = "AC_SPEED",
				ui_name = "Arcane Progression Speed",
				ui_description = "Multiplies all the Arcane Current incomes.",
				value_default = 1,
				value_min = 1,
				value_max = 5,
				value_display_multiplier = 1,
				value_display_formatting = " $0 ",
				scope = MOD_SETTING_SCOPE_RUNTIME,
				-- ui_fn = mod_setting_ac_balancer,
			},
			{
				id = "EFFIGY_START",
				ui_name = "Start With Effigy",
				ui_description = "You'll be able to consume NC even if the Staff wasn't the direct cause of death.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "CHEAT_MODE",
				ui_name = "Actual Cheating",
				ui_description = "LMB to confirm the input.",
				hidden = false,
				value_default = nil,
				scope = MOD_SETTING_SCOPE_RUNTIME,
				ui_fn = mod_setting_cheater,
			},
		},
	},
}

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
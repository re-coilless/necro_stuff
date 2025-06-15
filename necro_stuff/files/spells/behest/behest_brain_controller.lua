dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local brain = GetUpdatedEntityID()

local link = ComponentGetValue2( get_storage_old( EntityGetRootEntity( brain ), "link" ), "value_int" )
local anchor_id = 0
local anchors = EntityGetWithTag( "behest_anchor" ) or {}
if( #anchors > 0 ) then
	for i,anchor in ipairs( anchors ) do
		if( ComponentGetValue2( get_storage_old( anchor, "link" ), "value_int" ) == link ) then
			anchor_id = anchor
			break
		end
	end
end
local hooman = EntityGetRootEntity( anchor_id )

local aim_x, aim_y = ComponentGetValueVector2( EntityGetFirstComponentIncludingDisabled( hooman, "ControlsComponent" ), "mAimingVector" )
if( EntityHasTag( hooman, "player_unit" )) then
	local x, y = EntityGetTransform( brain )
	local m_x, m_y = DEBUG_GetMouseWorld()
	aim_x, aim_y = m_x - x, m_y - y
end
ComponentSetValueVector2( EntityGetFirstComponentIncludingDisabled( brain, "ControlsComponent" ), "mAimingVector", aim_x, aim_y )

local storage_trigger = get_storage_old( brain, "gonna_shoot" )
if( ComponentGetValue2( storage_trigger, "value_bool" )) then
	ComponentSetValue2( EntityGetFirstComponentIncludingDisabled( brain, "PlatformShooterPlayerComponent" ), "mForceFireOnNextUpdate", true )
	ComponentSetValue2( storage_trigger, "value_bool", false )
end
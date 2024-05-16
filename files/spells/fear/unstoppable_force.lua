local entity_id = GetUpdatedEntityID()

local vel_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "VelocityComponent" )
if( vel_comp ~= nil ) then
	local v_x, v_y = ComponentGetValue2( vel_comp, "mVelocity" )
	
	local t_v = math.max( ComponentGetValue2( vel_comp, "terminal_velocity" ), 1000 )
	
	if( v_angle == nil ) then
		local shooter = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "ProjectileComponent" ), "mWhoShot" )
		local ctrl_comp = EntityGetFirstComponentIncludingDisabled( shooter, "ControlsComponent" )
		if( ctrl_comp ~= nil ) then
			v_x, v_y = ComponentGetValue2( ctrl_comp, "mAimingVector" )
		end
	end

	v_angle = v_angle or math.atan2( v_y, v_x )
	v_x = math.cos( v_angle )*t_v
	v_y = math.sin( v_angle )*t_v
	
	ComponentSetValueVector2( vel_comp, "mVelocity", v_x, v_y )
end
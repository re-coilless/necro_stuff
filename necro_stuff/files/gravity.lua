dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y, rot = EntityGetTransform( entity_id )

local distance_full = ComponentGetValue2( get_storage_old( entity_id, "event_horizon" ), "value_float" )
local gravity_coeff = ComponentGetValue2( get_storage_old( entity_id, "gravity_coef" ), "value_float" )

function calculate_force_at( body_x, body_y )
	local distance = math.sqrt(( x - body_x )^2 + ( y - body_y )^2 )
	local direction = 0 - math.atan2(( y - body_y ), ( x - body_x ))
	
	local gravity_percent = ( distance_full - distance )/distance_full
	
	local fx = math.cos( direction )*gravity_coeff*gravity_percent
	local fy = -math.sin( direction )*gravity_coeff*gravity_percent

    return fx,fy
end

local entities = EntityGetInRadiusWithTag( x, y, distance_full, "projectile" )
for i,id in ipairs( entities ) do	
	local phys_comp = EntityGetFirstComponent( id, "PhysicsBody2Component" ) or EntityGetFirstComponent( id, "PhysicsBodyComponent" )
	if( phys_comp == nil and not( EntityHasTag( id, "black_hole" ))) then
		local px, py = EntityGetTransform( id )
		if( EntityGetFirstComponent( id, "VelocityComponent" ) ~= nil ) then
			local fx, fy = calculate_force_at( px, py )
			edit_component( id, "VelocityComponent", function(comp,vars)
				local vel_x, vel_y = ComponentGetValue2( comp, "mVelocity" )
				vel_x = vel_x + fx*2
				vel_y = vel_y + fy*2
				ComponentSetValue2( comp, "mVelocity", vel_x, vel_y )
			end)
		end
	end
end

function calculate_force_for_body( entity, body_mass, body_x, body_y, body_vel_x, body_vel_y, body_vel_angular )
	local fx, fy = calculate_force_at( body_x, body_y )
	
	fx = fx*body_mass
	fy = fy*body_mass

    return body_x, body_y, fx, fy, 0
end

local size = distance_full*0.5
PhysicsApplyForceOnArea( calculate_force_for_body, entity_id, x - size, y - size, x + size, y + size )
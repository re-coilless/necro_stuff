dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( projectile_id )
local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
if( stuff ~= nil ) then
	local storage_necro = get_storage_old( stuff, "necro_current" )
	local necro_current = math.abs( ComponentGetValue2( storage_necro, "value_float" ) - tonumber( GlobalsGetValue( "NECRO_ZERO", "0" )))
	
	local size = math.floor( 548 + ( 1.024 - 548 )/( 1 + ( necro_current/422181 )^0.394 ))
	local pic_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "SpriteComponent", "necro_infusion" )
	if( ComponentGetValue2( pic_comp, "special_scale_x" ) ~= size/16 ) then
		ComponentSetValue2( pic_comp, "special_scale_x", size/16 )
		ComponentSetValue2( pic_comp, "special_scale_y", size/16 )
	end
	
	local efficiency = 0.838 + ( 0.00583 - 0.838 )/( 1 + ( necro_current/41270 )^0.4977 )
	local meat = EntityGetInRadiusWithTag( x, y, size, "enemy" ) or {}
	if( #meat > 0 ) then
		for i,deadman in ipairs( meat ) do
			local necro_price = math.max( get_necro_current( deadman )*efficiency, 1 )
			EntityInflictDamage( deadman, necro_price/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, projectile_id, x, y, 0 )
			ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) + necro_price )
		end
	end
	
	local rate = math.ceil( -0.231 + ( 2625 + 0.231 )/( 1 + ( necro_current/278825400000 )^0.08461 )^25.5654 )
	local comp_id = GetUpdatedComponentID() or 0 --why the fuck
	if( comp_id ~= 0 ) then
		ComponentSetValue2( comp_id, "execute_every_n_frame", rate )
	end
end
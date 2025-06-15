dofile_once( "data/scripts/lib/utilities.lua" )

local entity_id = GetUpdatedEntityID()
local target = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "VariableStorageComponent" ), "value_int" )
if( target > 0 and EntityGetIsAlive( target )) then
	local pos_x, pos_y = EntityGetTransform( entity_id )
	local target_x, target_y = EntityGetTransform( target )
	local tm = GameGetFrameNum()
	
	local children = EntityGetAllChildren( entity_id )
	if( #children > 0 ) then
		target_x = target_x + 5*( 1 - 2*ProceduralRandomf( tm, pos_y ))
		target_y = target_y + 5*( 1 - 2*ProceduralRandomf( tm, pos_x ))
		for i,fx_entity in pairs( children ) do
			local x, y = pos_x, pos_y
			local pos = ProceduralRandomf( tm, fx_entity )
			local amount = -math.abs( pos*2 - 1 ) + 1
			local distort_x = math.sin(( x + tm )*0.03 )*8*amount
			local distort_y = math.sin(( y + tm )*0.05734 + 40 )*4*amount
			x, y = vec_lerp( target_x, target_y, x, y, pos )
			EntitySetTransform( fx_entity, x + distort_x, y + distort_y )
		end
	end
end
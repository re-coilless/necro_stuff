dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( projectile_id )
local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
if( stuff ~= nil ) then
	local mana_current = ComponentGetValue2( get_storage_old( stuff, "mana_current" ), "value_float" )
	
	local size = 1570 + ( 12.528 - 1570 )/( 1 + ( mana_current/1211 )^0.522 )^0.286
	local pic_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "SpriteComponent", "arcane_infusion" )
	if( ComponentGetValue2( pic_comp, "special_scale_x" ) ~= size/16 ) then
		ComponentSetValue2( pic_comp, "special_scale_x", size/16 )
		ComponentSetValue2( pic_comp, "special_scale_y", size/16 )
	end
	
	local shit = -6.019 + ( 262 + 6.018509 )/( 1 + ( mana_current/884557600000 )^0.1496 )^31.7656
	local spells = EntityGetInRadiusWithTag( x, y, size, "card_action" ) or {}
	local wands = add_table_old( EntityGetInRadiusWithTag( x, y, size, "wand" ) or {}, EntityGetInRadiusWithTag( x, y, size, "custom_wand" ) or {} )
	if( #wands > 0 ) then
		for i,wand_id in ipairs( wands ) do
			local wand_spells = EntityGetAllChildren( wand_id ) or {}
			if( #wand_spells > 0 ) then
				local temp_spells = {}
				for e,spell_id in ipairs( wand_spells ) do
					if( EntityGetFirstComponentIncludingDisabled( spell_id, "ItemActionComponent" ) ~= nil ) then
						table.insert( temp_spells, spell_id )
					end
				end
				spells = add_table_old( spells, temp_spells )
			end
		end
	end
	if( #spells > 0 ) then
		local deck = {}
		for i,spell_id in ipairs( spells ) do
			local comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemActionComponent" )
			if( comp ~= nil ) then
				local t_path = get_action_with_id( ComponentGetValue2( comp, "action_id" )).related_projectiles
				if( t_path ~= nil ) then
					table.insert( deck, t_path[1] )
				end
			end
		end
		
		if( #deck > 0 ) then
			SetRandomSeed( GameGetFrameNum(), x + y + #spells )
			local rnd = Random( 1, #deck )
			
			local main_path = deck[rnd]
			local extra_stuff = {}
			if( #deck > 1 ) then
				table.remove( deck, rnd )
				local amount = Random( 1, 3 )
				while( #deck > 0 and #extra_stuff < amount ) do
					rnd = Random( 1, #deck )
					table.insert( extra_stuff, deck[rnd] )
					table.remove( deck, rnd )
				end
			end
			
			local vel_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "VelocityComponent" )
			local v_x, v_y = ComponentGetValue2( vel_comp, "mVelocity" )
			local angle = math.atan2( v_y, v_x ) + math.rad( Random( -shit, shit ))
			local speed = math.sqrt( v_x^2 + v_y^2 )*2
			
			local custom_func = function( entity_id, values )
				if( #values > 0 ) then
					for i,value in ipairs( values ) do
						local p_x, p_y = EntityGetTransform( entity_id )
						local child = EntityLoad( value, p_x, p_y )
						if( EntityGetFirstComponent( child, "InheritTransformComponent" ) == nil ) then
							EntitySetComponentIsEnabled( child, EntityAddComponent( child, "InheritTransformComponent" ), true )
						end
						EntityAddChild( entity_id, child )
					end
				end
			end
			shoot_projectile_ultimate( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( projectile_id, "ProjectileComponent" ), "mWhoShot" ), main_path, x, y, math.cos( angle )*speed, math.sin( angle )*speed, true, custom_func, extra_stuff )
		end
	end
	
	local rate = math.ceil( -0.782 + ( 30 + 0.782 )/( 1 + ( mana_current/2587 )^0.5038 )^0.897 )
	local comp_id = GetUpdatedComponentID() or 0 --why the fuck
	if( comp_id ~= 0 ) then
		ComponentSetValue2( comp_id, "execute_every_n_frame", rate )
	end
end
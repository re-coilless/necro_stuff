dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local effect_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( effect_id )
local hb_x, hb_y = EntityGetFirstHitboxCenter( hooman )

local storage_scale = get_storage_old( effect_id, "scaled" )
local scaled = ComponentGetValue2( storage_scale, "value_bool" )

if( effect_id == hooman or EntityHasTag( hooman, "cured" )) then
	EntityKill( effect_id )
else
	if( not( scaled )) then
		scale_emitter( hooman, EntityGetFirstComponentIncludingDisabled( effect_id, "ParticleEmitterComponent", "cure" ), true )
		ComponentSetValue2( storage_scale, "value_bool", true )
	end
	
	local immunity_supreme = GameGetGameEffect( hooman, "PROTECTION_ALL" )
	if( immunity_supreme ~= 0 and ComponentGetValue2( immunity_supreme, "effect" ) ~= "NONE" ) then
		ComponentSetValue2( immunity_supreme, "effect", "NONE" )
	end
	local immunity_poly = GameGetGameEffect( hooman, "PROTECTION_POLYMORPH" )
	if( immunity_poly ~= 0 and ComponentGetValue2( immunity_poly, "effect" ) ~= "NONE" ) then
		ComponentSetValue2( immunity_poly, "effect", "NONE" )
	end
	local immunity_damage = GameGetGameEffect( hooman, "SAVING_GRACE" )
	if( immunity_damage ~= 0 and ComponentGetValue2( immunity_damage, "effect" ) ~= "NONE" ) then
		ComponentSetValue2( immunity_damage, "effect", "NONE" )
	end
	local immunity_death = GameGetGameEffect( hooman, "RESPAWN" )
	if( immunity_death ~= 0 and ComponentGetValue2( immunity_death, "effect" ) ~= "NONE" ) then
		ComponentSetValue2( immunity_death, "effect", "NONE" )
	end
	
	local radius = 10
	local char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	if( char_comp ~= nil ) then
		radius = radius + math.abs( ComponentGetValue2( char_comp, "collision_aabb_min_x" ))
	end
	
	local lead = EntityGetInRadiusWithTag( hb_x, hb_y, radius, "projectile" ) or {}
	if( #lead > 0 ) then
		for i,bullet in ipairs( lead ) do
			if( not( EntityHasTag( bullet, "cure_applied" ))) then
				EntityAddTag( bullet, "cure_applied" )
				EntityLoadToEntity( "mods/necro_stuff/files/spells/cure/cure_projectile.xml", bullet )
			end
		end
	end
	
	local meat = add_table_old( EntityGetInRadiusWithTag( hb_x, hb_y, radius, "mortal" ) or {}, EntityGetInRadiusWithTag( hb_x, hb_y, radius, "hittable" ) or {})
	if( #meat > 0 ) then
		for i,deadman in ipairs( meat ) do
			local dam_comp = EntityGetFirstComponentIncludingDisabled( deadman, "DamageModelComponent" )
			if( not( EntityHasTag( deadman, "cured" )) and not( EntityHasTag( deadman, "cure_applied" ))) then
				EntityAddTag( deadman, "cure_applied" )
				EntityAddChild( deadman, EntityLoad( "mods/necro_stuff/files/spells/cure/cure.xml", hb_x, hb_y ))
			end
		end
	end
	
	local damage_comp = EntityGetFirstComponent( hooman, "DamageModelComponent" )
	if( damage_comp ~= nil and not( EntityHasTag( hooman, "uncurable" ))) then
		local current_hp = ComponentGetValue2( damage_comp, "hp" )
		if( current_hp > 0.01 ) then
			ComponentSetValue2( damage_comp, "hp", current_hp*0.99 )
		end
	end
end
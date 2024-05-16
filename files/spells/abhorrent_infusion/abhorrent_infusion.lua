dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local main_id = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform( entity_id )

local add_life = 0
local add_dmg = 0
local add_edmg = 0
local add_eng = 0
local add_pierce = 0
local add_speed = 0
local add_mass = 0
local add_esize = 0

local meats = EntityGetWithTag( "abomination" ) or {}
local meat = 0
if( #meats > 0 ) then
	local min_dist = -1
	for i,dud in ipairs( meats ) do
		local ai_comp = EntityGetFirstComponentIncludingDisabled( dud, "AnimalAIComponent" )
		local plat_comp = EntityGetFirstComponentIncludingDisabled( dud, "CharacterPlatformingComponent" )
		local char_comp = EntityGetFirstComponentIncludingDisabled( dud, "CharacterDataComponent" )
		local part_comp = get_storage_old( dud, "parts" )
		local parts = part_comp == nil and { 0, 0, 0, 0, 1, } or D_extractor_old( ComponentGetValue2( part_comp, "value_string" ))
		
		add_life = add_life + ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( dud, "DamageModelComponent" ), "hp" )
		if( ComponentGetValue2( ai_comp, "attack_melee_enabled" )) then
			add_dmg = add_dmg + ( ComponentGetValue2( ai_comp, "attack_melee_damage_min" ) + ComponentGetValue2( ai_comp, "attack_melee_damage_max" ))/2
		end
		if( ComponentGetValue2( ai_comp, "attack_ranged_enabled" )) then
			add_edmg = add_edmg + 20/ComponentGetValue2( ai_comp, "attack_ranged_frames_between" )
		end
		add_eng = add_eng + ( parts[5] - 1 )
		if( parts[4] == 2 ) then
			add_pierce = add_pierce + 2
		end
		if( parts[3] == 1 ) then
			add_speed = add_speed + ComponentGetValue2( plat_comp, "accel_x" )*500
		end
		add_mass = add_mass + ComponentGetValue2( char_comp, "mass" )/10
		add_esize = add_esize + parts[2]*5
		
		if( EntityGetRootEntity( dud ) == dud ) then
			local t_x, t_y = EntityGetTransform( dud )
			local t_dist = math.sqrt(( t_x - x )^2 + ( t_y - y )^2 )
			if( min_dist == -1 or t_dist < min_dist ) then
				min_dist = t_dist
				meat = dud
			end
		end
	end
	
	local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
	if( proj_comp ~= nil ) then
		ComponentSetValue2( proj_comp, "lifetime", ComponentGetValue2( proj_comp, "lifetime" ) + add_life )
		ComponentSetValue2( proj_comp, "damage", ComponentGetValue2( proj_comp, "damage" ) + add_dmg )
		ComponentSetValue2( proj_comp, "ground_penetration_coeff", math.min( ComponentGetValue2( proj_comp, "ground_penetration_coeff" ) + math.floor( add_eng/3 ), 20 ))
		ComponentSetValue2( proj_comp, "ground_penetration_max_durability_to_destroy", math.min( ComponentGetValue2( proj_comp, "ground_penetration_max_durability_to_destroy" ) + add_pierce, 20 ))
		
		local zap_comp = EntityGetFirstComponent( entity_id, "LightningComponent" )
		if( zap_comp ~= nil ) then
			proj_comp = zap_comp
		end
		ComponentObjectSetValue2( proj_comp, "config_explosion", "damage", ComponentObjectGetValue2( proj_comp, "config_explosion", "damage" ) + add_edmg )
		ComponentObjectSetValue2( proj_comp, "config_explosion", "ray_energy", ComponentObjectGetValue2( proj_comp, "config_explosion", "ray_energy" ) + 50000*add_eng )
		ComponentObjectSetValue2( proj_comp, "config_explosion", "max_durability_to_destroy", math.min( ComponentObjectGetValue2( proj_comp, "config_explosion", "max_durability_to_destroy" ) + add_pierce, 20 ))
		ComponentObjectSetValue2( proj_comp, "config_explosion", "explosion_radius", math.min( ComponentObjectGetValue2( proj_comp, "config_explosion", "explosion_radius" ) + add_esize, 666 ))
	end
	
	local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
	if( vel_comp ~= nil ) then
		local v_x, v_y = ComponentGetValueVector2( vel_comp, "mVelocity" )
		local speed = math.min( math.sqrt( v_x^2 + v_y^2 ) + add_speed, 6666 )
		local v_angle = math.atan2( v_y, v_x )
		ComponentSetValueVector2( vel_comp, "mVelocity", math.cos( v_angle )*speed, math.sin( v_angle )*speed )
		
		ComponentSetValue2( vel_comp, "mass", math.min( ComponentGetValue2( vel_comp, "mass" ) + add_mass, 666 ))
	end
end
if( meat ~= 0 ) then
	edit_component_ultimate( meat, "DamageModelComponent", function(comp,vars) 
		ComponentSetValue2( comp, "max_hp", 0 )
		ComponentSetValue2( comp, "hp", 0 )
	end)
	local m_x, m_y = EntityGetTransform( meat )
	EntityInflictDamage( meat, 666/25, "DAMAGE_MATERIAL", "[POWER BEYOND]", "NONE", 0, 0, entity_id, m_x, m_y, 0 )
end

-- local effect_id = EntityLoad("data/entities/particles/tinyspark_red_large.xml", x, y)
-- EntityAddChild( root_id, effect_id )
-- edit_component( effect_id, "ParticleEmitterComponent", function(comp3,vars)
	-- local part_min = math.min( math.floor( totalcount * 0.5 ), 100 )
	-- local part_max = math.min( totalcount + 1, 120 )
	
	-- ComponentSetValue2( comp3, "count_min", part_min )
	-- ComponentSetValue2( comp3, "count_max", part_max )
-- end)
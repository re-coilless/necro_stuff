dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local effect_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( effect_id )

local storage_scale = EntityGetFirstComponentIncludingDisabled( effect_id, "VariableStorageComponent", "scaled" )
local scaled = ComponentGetValue2( storage_scale, "value_bool" )

if( not( scaled )) then
	scale_emitter( hooman, EntityGetFirstComponentIncludingDisabled( effect_id, "ParticleEmitterComponent", "emitter" ), true )
	ComponentSetValue2( storage_scale, "value_bool", true )
	
	if( is_sentient( hooman ) and get_hooman_child_old( hooman, "undeader" ) == nil ) then
		LoadGameEffectEntityTo( hooman, "mods/necro_stuff/files/spells/limbo/necromancy.xml" )
	end
end

EntityAddRandomStains( hooman, CellFactory_GetType( "necro_inferno" ), 66 )

local damage_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
if( damage_comp ~= nil ) then
	local max_hp = ComponentGetValue2( damage_comp, "max_hp" )
	local current_hp = ComponentGetValue2( damage_comp, "hp" )
	if( current_hp < max_hp ) then
		ComponentSetValue2( damage_comp, "hp", math.min( math.floor(( current_hp + 0.1 )*10000 )/10000, max_hp ))
	end
end
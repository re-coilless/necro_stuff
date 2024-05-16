dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local meats = EntityGetWithTag( "enemy" ) or {}
if( #meats > 0 ) then
	for i,meat in ipairs( meats ) do
		if( is_sentient( meat )) then
			LoadGameEffectEntityTo( meat, "mods/necro_stuff/files/spells/fault/necromancy.xml" )
		end
	end
end
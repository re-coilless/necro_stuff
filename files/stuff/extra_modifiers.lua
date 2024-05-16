extra_modifiers["true_form_power"] = function()
	c.extra_entities = c.extra_entities.."mods/necro_stuff/files/stuff/true_form_power.xml,"
end

extra_modifiers["omniscient_power"] = function()
	c.extra_entities = c.extra_entities.."mods/necro_stuff/files/stuff/omniscient_power.xml,"
end

extra_modifiers["behest_power"] = function()
	c.extra_entities = c.extra_entities.."mods/necro_stuff/files/spells/behest/behest_power.xml,"
end

extra_modifiers["judge_power"] = function()
	SetRandomSeed( GameGetFrameNum() + #deck, #actions )
	
	local data = actions[Random( 1, #actions )]
	local safety = 0
	while( safety < 666 ) do
		if( data.type == 2 or data.type == 5 ) then
			break
		end
		data = actions[Random( 1, #actions )]
		
		safety = safety + 1
	end
	
	data.action( rec )
end
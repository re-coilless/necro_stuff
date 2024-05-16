dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local c_x, c_y = EntityGetTransform( GetUpdatedEntityID())
local wands = add_table_old( EntityGetInRadiusWithTag( c_x, c_y, 666, "wand" ) or {}, EntityGetInRadiusWithTag( c_x, c_y, 666, "custom_wand" ) or {} )
if( #wands > 0 ) then
	for i,wand_id in ipairs( wands ) do
		local owner = EntityGetRootEntity( wand_id )
		if( wand_id ~= owner and ( EntityHasTag( owner, "enemy" ) or EntityGetName( owner ) == "Hallowed" )) then
			local o_x, o_y = EntityGetTransform( owner )
			GameDropAllItems( owner )
			EntityKill( owner )
			GamePickUpInventoryItem( EntityLoad( "mods/necro_stuff/files/spells/judgment/judge.xml", o_x, o_y ), wand_id, false )
		end
	end
end

local meat = EntityGetInRadiusWithTag( c_x, c_y, 200, "enemy" ) or {}
if( #meat > 0 ) then
	for i,deadman in ipairs( meat ) do
		local d_x, d_y = EntityGetTransform( deadman )
		local tier = math.floor( 8.038 + ( -0.0515 - 8.038 )/( 1 + ( math.min( math.max( get_necro_current( deadman ), 0 ), 2000 )/107 )^0.704 ) + 0.5 )
		if( tier > 0 ) then
			local wands = {
				{ "wand_level_01", "wand_level_01_better", "wand_unshuffle_01", },
				{ "wand_level_02", "wand_level_02_better", "wand_unshuffle_02", },
				{ "wand_level_03", "wand_level_03_better", "wand_unshuffle_03", },
				{ "wand_level_04", "wand_level_04_better", "wand_unshuffle_04", },
				{ "wand_level_05", "wand_level_05_better", "wand_unshuffle_05", },
				{ "wand_level_06", "wand_level_06_better", "wand_unshuffle_06", },
				{ "wand_level_10", "wand_unshuffle_10", "wand_valtikka", "wand_varpuluuta", "wand_vasta", "wand_vihta", "wand_ruusu", "wand_petri", "wand_kiekurakeppi", "wand_arpaluu", "wands/experimental/experimental_wand_1", "wands/experimental/experimental_wand_2", "wands/experimental/experimental_wand_3", },
			}
			SetRandomSeed( GameGetFrameNum(), deadman + tier + d_x + d_y )
			EntityLoad( "data/entities/items/"..wands[tier][Random( 1, #wands[tier] )]..".xml", d_x, d_y )
		end
		EntityKill( deadman )
	end
end
local id = EntityGetWithTag( "guilt" ) or {}
if( #id > 1 ) then
	table.sort( id )
	for i = 1,#id-1 do
		EntityKill( id[i] )
	end
end
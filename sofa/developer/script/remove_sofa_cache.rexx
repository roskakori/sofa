/* remove_sofa_directory.rexx -- Remove sofa cache directory */
list_temp = 't:remove_sofa_directory.list'
execute_temp = 't:remove_sofa_directory.execute'

exit_code = 0

Address Command

/* remove /sofa stuff */
Say 'sofa cache directories'
Say '   search'
'list >' || list_temp || ' all dirs pat=sofa lformat="delete quiet force all *"%p%n*""'
Say '   remove'
if Open('list', list_temp, 'read') then do
	do while ~eof('list')
		line = ReadLn('list')
		Parse Var line . '"' name '"'
		if (Right(name, 5) = '/sofa') & (exists(name || '/short')) then do
			if name ~= 'library/sofa' then do
				Say '      ' || name
				/* line */
			end
		end
	end
	Call Close('list')
end
else do
	Say 'cannot read temporary file "' || list_temp || '"'
	exit_code = 10
end

/* clean eiffel programs */
if exit_code = 0 then do
	Say 'eiffel root classes'
	Say '   search'
	'list >' || list_temp || ' all pat=#?.e lformat=%p%n'
	 if Open('list', list_temp, 'read') then do
		do while ~eof('list')
			line = ReadLn('list')
			if line ~= '' then do
				base_name = Left(line, Length(line)-2)
				if exists(base_name || '.make') then do
					command = 'clean ' || base_name
					Say '   ' || command
					command
				end
				if exists(base_name) then do
					command = 'delete quiet ' || base_name
					Say '      remove ' || base_name
					command
				end
			end
		end
		Call Close('list')
	 end
	 else do
		Say 'cannot read temporary file "' || list_temp || '"'
		exit_code = 10
	 end
end

/* remove remaining linker and object files */
if exit_code = 0 then do
	Say 'linker and object files'
	Say '   search'
	'list >' || list_temp || ' all pat=#?.(make|lnk|o|exe) lformat="delete quiet *"%p%n*""'
	Say '   remove'
	'execute ' || list_temp
end

exit exit_code

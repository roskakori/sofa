/* recursive_remove_pattern.rexx -- Recursively remove files matching a pattern.
 *
 * Note: This is quite destinct from the normal `delete' command
 * because it removes *all* files matching the patter in *all*
 * directories relative to the current directory.
 *
 * WARNING: This script is rather violent. Be sure that PATTERN makes
 * sense, that backup of your data exist. Also note that even delete
 * protected files are removed without questions asked.
 *
 * $VER: recursive_remove_pattern.rexx 1.0 (9.10.99)
 */
AddLib('rexxsupport.library', 0, -30, 0)
AddLib('rexxdossupport.library', 0, -30, 2)

temp_file = 't:remove_pattern_' || Pragma('ID') || '.tmp'
exit_code = 0

/* Parse CLI arguments */
Parse Arg arguments

template = "Directory/A,Pattern/A/K"
if ~ReadArgs(arguments, template) then do
   Say 'error in arguments: ' || Fault(RC)
   exit 10
end

old_directory = Pragma('Directory', directory)

Address Command 'list all files pat="' || pattern || '" lformat="%p%n" >' || temp_file
if ~Open('list', temp_file, 'read') then do
   Say 'Cannot read file list from "' || temp_file || '"'
   exit_code = 10
end
else do
   do while ~eof('list')
      file = ReadLn('list')
      if file ~= '' then do
         Say '   ' || file
         if Delete(file) = 0 then do
            /* Try to unprotect file */
            Address Command 'protect "' || file || '" RWED add'
            if Delete(file) = 0 then do
               Say '      not deleted'
               exit_code = 10
            end
         end
      end
   end
   call Close('list')
end

call Delete(temp_file)

Pragma('Directory', old_directory)

exit exit_code

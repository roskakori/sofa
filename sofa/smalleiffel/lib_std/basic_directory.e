-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT 
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of 
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr 
--                       http://SmallEiffel.loria.fr
--
expanded class BASIC_DIRECTORY
--
-- NOTE: THIS IS AN ALPHA VERSION. THIS CLASS IS NOT STABLE AT ALL AND 
-- MIGHT EVEN CHANGE COMPLETELY IN THE NEXT RELEASE !
-- 
-- Very low-level basic tools for file-system directory handling and file 
-- path manipulation. This class is intended to be platform independant as 
-- much as possible. In order to remove from the client side the burden of 
-- file path computation, this class tries to compute automatically the 
-- system file notation using argument(s) of some of the very first call(s). 
-- As soon as the system notation has been properly detected, the result is 
-- internally memorized for all objects of type BASIC_DIRECTORY in a common 
-- private buffer. Besides the low-level nature of operations one can found 
-- in this class, all file path manipulations are done in a smart way 
-- (except when the system file path notation has not been detected 
-- automatically, which is quite uncommon). As an example, even if the 
-- directory separator is internally detected, this information is 
-- _intentionaly_ kept private to avoid low-level manipulation from the 
-- client side. Finally, this class is expanded in order to avoid as much as 
-- possible memory allocations.
--
-- Also consider hight level facade class DIRECTORY if you don't want 
-- to deal directly with low level directory streams.
--
   
feature {NONE}
   
   directory_stream: POINTER;
         -- This pointer memorize the current directory stream being
         -- scanned (used to compute `is_connected').

   current_entry: POINTER;
         -- When `is_connected', memorize the current entry in the 
         -- current  `directory_stream'.

feature -- State of `Current' basic directory stream :
   
   is_connected: BOOLEAN is
         -- Is `Current' connected to some directory stream ?
      do
         Result := directory_stream.is_not_null;
      end;
   
   end_of_input: BOOLEAN is
         -- Is end of input reached ?
      require
         is_connected
      do
         Result := current_entry.is_null;
      end;
   
feature -- Connect and disconnect :
   
   connect_to(directory_path: STRING) is
         -- Try to connect `Current' to some existing `directory_path'. After 
         -- this call, the client is supposed to use `is_connected' to check 
         -- that the stream is ready to be used.
      require
         not is_connected;
         not directory_path.is_empty;
         common_buffer_protection: last_entry /= directory_path
      local
         path_pointer: POINTER;
      do
         path_pointer := directory_path.to_external;
         directory_stream := basic_directory_open(path_pointer);
         current_entry := directory_stream;
         last_entry.clear;
      ensure
         is_connected implies not end_of_input
      end;
   
   connect_with(some_path: STRING) is
         -- Try to connect `Current' to some directory using `some_path' which
         -- may  be either an existing directory path or some arbitrary 
         -- file path name. When `some_path' is the path of some readable 
         -- existing directory, this directory is opened and the effect of 
         -- `connect_with' is equivalent to `connect_to'. When `some_path' is not an 
         -- existing readable directory path, `connect_with' tries to open the 
         -- directory which may contains `some_path' viewed as a file path 
         -- name. After this call, the client is supposed to use `is_connected' 
         -- to check that the stream is ready to be used and the `last_entry' 
         -- buffer to know about the corresponding opened directory path. 
         -- Whatever the result, `some_path' is left unchanged.
      require
         not is_connected;
         not some_path.is_empty;
         common_buffer_protection: last_entry /= some_path
      local
         p: POINTER;
      do
         connect_to(some_path);
         if is_connected then
            last_entry.copy(some_path);
         else
            compute_parent_directory_of(some_path);
            if last_entry.count > 0 then
               p := last_entry.to_external;
               directory_stream := basic_directory_open(p);
               current_entry := directory_stream;
               if directory_stream.is_null then
                  last_entry.clear;
               end;
            else
               last_entry.clear;
            end;
         end;
      ensure
         is_connected implies not end_of_input
      end;
   
   connect_to_current_working_directory is
         -- Try to connect `Current' to the current working directory.
         -- After this call, the client is supposed to use `is_connected' 
         -- to check that the stream is ready to be used and the `last_entry' 
         -- buffer to know about the name of the current working directory.
      require
         not is_connected
      local
         path: POINTER;
      do
         path := basic_directory_current_working_directory;
         if path.is_not_null then
            last_entry.from_external_copy(path);
            directory_stream := basic_directory_open(path);
            current_entry := directory_stream;
            if directory_stream.is_null then
               last_entry.clear;
            end;
         else
            last_entry.clear;
         end;
      ensure
         is_connected implies not end_of_input
      end;
   
   disconnect is
         -- Do not forget to call this feature when you have finished 
         -- with some previously opened directory stream.
      require
         is_connected
      local
         null: POINTER;
      do
         if basic_directory_close(directory_stream) then
            directory_stream := null;
            current_entry := null;
         end;
      ensure
         not is_connected
      end;

feature -- Scanning :

   last_entry: STRING is
         -- Unique global buffer (once object) to get the last information 
         -- computed by many routines of this class: `read_entry', `connect_with'
         -- `connect_to_current_working_directory', `compute_parent_directory_of', ...
      once
         !!Result.make(256);
      end;
   
   read_entry is
         -- Read the next entry name and update `last_entry' and `end_of_input'
         -- accordingly.
      require
         is_connected;
         not end_of_input
      local
         name: POINTER;
      do
         current_entry := basic_directory_read_entry(directory_stream);
         if current_entry.is_not_null then
            name := basic_directory_get_entry_name(current_entry);
            last_entry.from_external_copy(name);
         end;
      end;

feature -- File path handling tools :
   
   compute_parent_directory_of(some_path: STRING) is
         -- Using `some_path' (which may be either a file path or a directory 
         -- path) tries to compute in the `last_entry' buffer the parent 
         -- directory of `some_path'. When `some_path' is a path with no parent 
         -- directory, the `last_entry' buffer `is_empty' after this call. This 
         -- operation does not perform any disk access.
      require
         not some_path.is_empty;
         common_buffer_protection: last_entry /= some_path
      do
         last_entry.copy(some_path);
         if unix_like_notation then
            from
               if last_entry.count > 0 then
                  last_entry.remove_last(1);
               end;
            until
               last_entry.is_empty or else last_entry.last = '/'
            loop
               last_entry.remove_last(1);
            end;
	 elseif windows_like_notation then
            from
               if last_entry.count > 0 then
                  last_entry.remove_last(1);
               end;
            until
               last_entry.is_empty or else last_entry.last = '\'
            loop
               last_entry.remove_last(1);
            end;
         elseif amiga_like_notation then
            from
               if last_entry.last /= ':' then
                  last_entry.remove_last(1);
               end;
            until
               last_entry.is_empty or else
               last_entry.last = '/' or else
               last_entry.last = ':'
            loop
               last_entry.remove_last(1);
            end;
         elseif macintosh_like_notation then
            from
               if last_entry.last = ':' then
                  last_entry.remove_last(1);
               end;
            until
               last_entry.is_empty or else last_entry.last = ':'
            loop
               last_entry.remove_last(1);
            end;
         elseif vms_like_notation then
            if last_entry.last = ']' then
               from
                  last_entry.remove_last(1);
               until
                  last_entry.is_empty or else 
                  last_entry.last = '.' or else
                  last_entry.last = '['
               loop
                  last_entry.remove_last(1);
               end;
               if last_entry.count > 0 then
                  inspect
                     last_entry.last
                  when '.' then
                     last_entry.remove_last(1);
                     last_entry.extend(']');
                  when '[' then
                     if some_path.count > 2 then
                        last_entry.extend(']');
                     else
                        last_entry.clear;
                     end;
                  end;
               end;
            else
               from
                  last_entry.remove_last(1);
               until
                  last_entry.is_empty or else 
                  last_entry.last = '.' or else 
                  last_entry.last = ']'
               loop
                  last_entry.remove_last(1);
               end;
               if last_entry.count > 0 then
                  last_entry.remove_last(1);
                  last_entry.extend(']');
               end;
            end;
         elseif system_notation_detected then
            last_entry.clear;
         else 
            try_to_compute_notation(some_path);
            if system_notation_detected then
               compute_parent_directory_of(some_path);
            else
               last_entry.clear;
            end;
         end;
      end;
   
   compute_subdirectory_with(parent_path, entry_name: STRING) is
         -- Try to compute in the `last_entry' buffer the new subdirectory 
         -- path obtained when trying to concatenate smartly `parent_path' 
         -- whith some `entry_name'. When this fails the `last_entry' buffer `is_empty' 
         -- after this call. This operation does not perform any disk access.
         -- Whatever the result, `parent_path' and  `entry_name' are left unchanged.
      require
         not parent_path.is_empty;
         not entry_name.is_empty;
         common_buffer_protection1: last_entry /= parent_path;
         common_buffer_protection2: last_entry /= entry_name
      do
         last_entry.copy(parent_path);
         if unix_like_notation then
            if (".").is_equal(entry_name) then
               -- Because you would get the same directory as `parent_path' and 
               -- not a new subdirectory as explained before.
               last_entry.clear;
            elseif ("..").is_equal(entry_name) then
               -- Because you would not get a subdirectory of `parent_path'.
               last_entry.clear;
            else
               last_entry.extend_unless('/');
               if entry_name.first = '/' then
                  last_entry.remove_last(1);
               end;
               last_entry.append(entry_name);
               last_entry.extend_unless('/');
            end;
         elseif windows_like_notation then
            if (".").is_equal(entry_name) then
               -- Because you would get the same directory as `parent_path' and 
               -- not a new subdirectory as explained before.
               last_entry.clear;
            elseif ("..").is_equal(entry_name) then
               -- Because you would not get a subdirectory of `parent_path'.
               last_entry.clear;
            else
               last_entry.extend_unless('\');
               if entry_name.first = '\' then
                  last_entry.remove_last(1);
               end;
               last_entry.append(entry_name);
               last_entry.extend_unless('\');
            end;
         elseif amiga_like_notation then
            inspect 
               last_entry.last
            when '/' then
               if entry_name.first = '/' then
                  last_entry.remove_last(1);
               end;
            when ':' then
            else
               if entry_name.first /= '/' then
                  last_entry.add_last('/');
               end;
            end;
            last_entry.append(entry_name);
            last_entry.extend_unless('/');
         elseif macintosh_like_notation then
            last_entry.extend_unless(':');
            if entry_name.first = ':' then
               last_entry.remove_last(1);
            end;
            last_entry.append(entry_name);
            last_entry.extend_unless(':');
         elseif vms_like_notation then
            if ("[]").is_equal(entry_name) then
               -- Because you would get the same directory as `parent_path' and 
               -- not a new subdirectory as explained before.
               last_entry.clear;
            elseif ("[-]").is_equal(entry_name) then
               -- Because you would not get a subdirectory of `parent_path'.
               last_entry.clear;
            else
               inspect
                  last_entry.last
               when ']' then
                  last_entry.remove_last(1);
                  last_entry.extend('.');
               when '.' then
               else
                  last_entry.extend('.');
               end;
               last_entry.append(entry_name);
               inspect
                  last_entry.last
               when ']' then
               when '.' then
                  last_entry.remove_last(1);
                  last_entry.extend(']');
               else
                  last_entry.extend(']');
               end;
            end;
         elseif system_notation_detected then
            last_entry.clear;
         else 
            try_to_compute_notation(parent_path);
            if system_notation_detected then
               compute_subdirectory_with(parent_path,entry_name);
            else
               last_entry.clear;
            end;
         end;
      end;
   
   compute_file_path_with(parent_path, file_name: STRING) is
         -- Try to compute in the `last_entry' buffer the new file path obtained 
         -- when trying to concatenate smartly `parent_path' whith some 
         -- `file_name'. When this fails the `last_entry' buffer `is_empty' after 
         -- this call. This operation does not perform any disk access.
         -- Whatever the result, `parent_path' and `file_name' are left unchanged.
      require
         not parent_path.is_empty;
         not file_name.is_empty;
         common_buffer_protection1: last_entry /= parent_path;
         common_buffer_protection2: last_entry /= file_name
      do
         last_entry.copy(parent_path);
         if unix_like_notation then
            last_entry.extend_unless('/');
            if file_name.first = '/' then
               last_entry.remove_last(1);
            end;
            last_entry.append(file_name);
         elseif windows_like_notation then
            last_entry.extend_unless('\');
            if file_name.first = '\' then
               last_entry.remove_last(1);
            end;
            last_entry.append(file_name);
         elseif amiga_like_notation then
            inspect
               last_entry.last
            when ':' then
            when '/' then
               if file_name.first = '/' then
                  last_entry.remove_last(1);
               end;
            else
               if file_name.first /= '/' then
                  last_entry.extend('/');
               end;
            end;
            last_entry.append(file_name);
         elseif macintosh_like_notation then
            last_entry.extend_unless(':');
            if file_name.first = ':' then
               last_entry.remove_last(1);
            end;
            last_entry.append(file_name);
         elseif vms_like_notation then
            inspect
               last_entry.last
            when ']' then
            when '.' then
               last_entry.remove_last(1);
               last_entry.extend(']');
            else
               last_entry.extend(']');
            end;
            if file_name.first = ']' then
               last_entry.remove_last(1);
            end;
            last_entry.append(file_name);
         elseif system_notation_detected then
            last_entry.clear;
         else 
            try_to_compute_notation(parent_path);
            if system_notation_detected then
               compute_file_path_with(parent_path,file_name);
            else
               last_entry.clear;
            end;
         end;
      end;

   change_current_working_directory(directory_path: STRING) is
         -- Try to change the current working directory using some 
         -- `directory_path'. When the operation is possible, the `last_entry' buffer 
         -- is updated with the new current working directory path, 
         -- otherwise, when the modification is not possible the `last_entry' 
         -- buffer `is_empty' after this call. Whatever the result, 
         -- `directory_path' is left unchanged.
      require
         not is_connected;
         common_buffer_protection1: last_entry /= directory_path
      local
         p: POINTER;
      do
         p := directory_path.to_external;
         if basic_directory_chdir(p) then
            connect_to_current_working_directory;
            if is_connected then
               disconnect;
               check not last_entry.is_empty end;
            else
               last_entry.clear;
            end;
         else
            last_entry.clear;
         end;
      ensure
         not is_connected
      end;
         
feature -- Disk modification :

   create_new_directory(directory_path: STRING): BOOLEAN is
         -- Try to create a new directory using the `directory_path' name.
         -- Returns true on success.
      require
         not is_connected
      local
         p: POINTER;
      do
         p := directory_path.to_external;
         Result := basic_directory_mkdir(p);
      ensure
         not is_connected
      end;
   
   remove_directory(directory_path: STRING): BOOLEAN is
         -- Try to remove directory `directory_path' which must be empty.
         -- Returns true on success.
      require
         not is_connected
      local
         p: POINTER;
      do
         p := directory_path.to_external;
         Result := basic_directory_rmdir(p);
      ensure
         not is_connected
      end;

   remove_files_of(directory_path: STRING) is
         -- Try to remove all files (not subdirectories) of directory 
         -- specified by `directory_path'.
      require
         not is_connected
      do
         connect_to(directory_path);
         if is_connected then
            from
               read_entry;
            until
               end_of_input
            loop
               tmp_path.copy(last_entry);
               compute_file_path_with(directory_path,tmp_path);
               tmp_path.copy(last_entry);
               remove_file(tmp_path);
               read_entry;
            end;
            disconnect;
         end;
      ensure
         not is_connected
      end;

feature {NONE} 

   notation: STRING is "?";
         -- Unique common buffer to memorize the system path name 
         -- notation.

   system_notation_detected: BOOLEAN is
      do
         Result := notation.first /= '?';
      end;
         
   unix_like_notation: BOOLEAN is
      do
         Result := notation.first = 'U';
      end;

   windows_like_notation: BOOLEAN is
      do
         Result := notation.first = 'W';
      end;

   amiga_like_notation: BOOLEAN is
         -- The Amiga file path notation looks like:
         --   DEV:directory1/directory2/filename
      do
         Result := notation.first = 'A';
      end;

   macintosh_like_notation: BOOLEAN is
         -- The Macintosh file path notation looks like:
         --   :directory1:directory2:filename
      do
         Result := notation.first = 'M';
      end;

   vms_like_notation: BOOLEAN is
         -- The VMS file path notation looks like:
         --    [directory1.directory2.directory3]filename
         -- The current working directory notation is:
         --    []
         -- The equivalent of Unix .. is :
         --    [-]
         -- The equivalent of Unix ../.. is :
         --    [-.-]
         --
      do
         Result := notation.first = 'V';
      end;

   try_to_compute_notation(some_path: STRING) is
      require
         not system_notation_detected
      do
         if file_exists(some_path) then
            if some_path.has('/') then
               notation.put('U',1);
            elseif some_path.has('\') then
               notation.put('W',1);
            elseif some_path.has(':') then
               notation.put('M',1);
            elseif some_path.has('[') then
               notation.put('V',1);
            else
               last_attempt_to_compute_notation;
            end;
         else
            last_attempt_to_compute_notation;
         end;
      end;
   
   last_attempt_to_compute_notation is
      require
         not system_notation_detected
      do
         if file_exists("s:startup-sequence") then
            notation.put('A',1);
         elseif file_exists("/bin/ls") then
            notation.put('U',1);
         elseif file_exists("C:\AUTOEXEC.BAT") then
            notation.put('W',1);
         end;
      end;

   tmp_path: STRING is
      once
         !!Result.make(256);
      end;

feature {NONE} 
   -- Following functions external "SmallEiffel" functions (only 
   -- functions, no procedure) are automatically detected by the 
   -- compiler. The C runtime is defined in files basic_"directory.h" and 
   -- "basic_directory.c" of "SmallEiffel/sys/runtime/". The Java runtime 
   -- is not yet implemented. In the futur, this will be done in file 
   -- "SmallEiffel/sys/runtime/SmallEiffelRuntime.java".
   --

   basic_directory_open(path_pointer: POINTER): POINTER is
         -- Try to open some existing directory using `path'. When `Result'
         -- `is_not_null', the directory is correctly opened and `Result' is
         -- a valid handle for this directory. Using `Result', one can 
         -- then scan the content of the directory using function 
         -- `basic_directory_read_entry' and `basic_directory_get_entry_name'. Finally, 
         -- a `is_not_null' directory must be closed using function
         -- `basic_directory_close'.
      require
         path_pointer.is_not_null
      external "SmallEiffel"
      end;

   basic_directory_read_entry(dirstream: POINTER): POINTER is
         -- Read an return a new entry using the directory handle `dirstream'
         -- obtained with function `basic_directory_open'. When there is no more 
         -- entry, the `Result' becomes `is_null'.
      require
         dirstream.is_not_null
      external "SmallEiffel"
      end;

   basic_directory_get_entry_name(entry: POINTER): POINTER is
         -- Read an return a new entry using the directory handle `dirstream'
         -- obtained with function `basic_directory_open'.
         -- When there is no more entry, the `Result' becomes `is_null'.
      require
         entry.is_not_null
      external "SmallEiffel"
      end;

   basic_directory_close(dirstream: POINTER): BOOLEAN is
         -- Try to close some opened `dirstream' directory.
         -- A true result indicates that the directory is correctly
         -- closed.
      require
         dirstream.is_not_null
      external "SmallEiffel"
      end;

   basic_directory_current_working_directory: POINTER is
         -- Try to get the current working directory path.
      external "SmallEiffel"
      end;

   basic_directory_chdir(destination: POINTER): BOOLEAN is
         -- Try to change the current working directory using `destination'.
      external "SmallEiffel"
      end;

   basic_directory_mkdir(directory_path: POINTER): BOOLEAN is
         -- Try to create a new directory using `directory_path'.
      external "SmallEiffel"
      end;

   basic_directory_rmdir(directory_path: POINTER): BOOLEAN is
         -- Try to remove `directory_path'.
      external "SmallEiffel"
      end;

end -- BASIC_DIRECTORY

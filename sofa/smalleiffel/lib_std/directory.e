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
class DIRECTORY
   --
   -- NOTE: THIS IS AN ALPHA VERSION. THIS CLASS IS NOT STABLE AT ALL AND 
   -- MIGHT EVEN CHANGE COMPLETELY IN THE NEXT RELEASE !
   -- 
   --
   -- Tools for file-system directory handling.
   -- Hight-level facade for class BASIC_DIRECTORY.
   --
creation make, scan, scan_with, scan_current_working_directory
   
feature
   
   path: STRING;
         -- The directory path in use (see `scan').
   
   last_scan_status: BOOLEAN;
         -- True when last `scan' (or last `re_scan') has sucessfully 
         -- read some existing directory using `path'.
   
feature {NONE}
   
   basic_directory: BASIC_DIRECTORY;
         -- Provide low level access to directories.
   
   name_list: FIXED_ARRAY[STRING];
         -- Actual list of entries (files or subdirectories)..
   
   make is
         -- Make a new not assigned one.
      do
         if name_list = Void then
            !!name_list.with_capacity(32);
         else
            name_list.clear;
         end;
      ensure
         is_empty
      end;
   
feature -- Disk access :
   
   scan(directory_path: STRING) is
         -- Try to scan some existing `directory_path' which is 
         -- supposed to be a correctly spelled directory path.
         -- Afetr this call the client is supposed to check `last_scan_status'
         -- to know.
         -- So, when `last_scan_status' is true after this call, the entire 
         -- directory has been read.
      require
         not directory_path.is_empty
      local
         entry: STRING;
      do
         if name_list = Void then
            make;
         end;
         path := directory_path;
         basic_directory.connect_to(path);
         if basic_directory.is_connected then
            from
               basic_directory.read_entry;
            until
               basic_directory.end_of_input
            loop
               entry := basic_directory.last_entry.twin;
               name_list.add_last(entry);
               basic_directory.read_entry;
            end;
            basic_directory.disconnect;
            last_scan_status := true;
         else
            name_list.clear;
            last_scan_status := false;
         end;
      end;
   
   scan_with(some_path: STRING) is
         -- Try to scan `Current' using `some_path' where `some_path' can be
         -- either a file path or an existing directory path.
         -- When `some_path' is a directory path, the behavior is equivalent 
         -- to `connect_to'.
         -- When `some_path' is the path of an existing file, the directory
         -- which contains this file is scanned.
      require
         not some_path.is_empty
      do
         scan(some_path);
         if not last_scan_status then
            basic_directory.connect_with(some_path);
            if basic_directory.is_connected then
               path := basic_directory.last_entry.twin;
               basic_directory.disconnect;
               scan(path);
            end;
         end;
      end;

   re_scan is
         -- Update internal information by reloading all the information 
         -- about the `path' directory from the disk.
         -- Update `last_scan_status', `count', and all `item's.
      require
         path /= void
      local
         entry: STRING;
         i: INTEGER;
      do
         check 
            not name_list.empty
         end;
         basic_directory.connect_to(path);
         if basic_directory.is_connected then
            from
               basic_directory.read_entry;
            until
               basic_directory.end_of_input
            loop
               if name_list.valid_index(i) then
                  entry := name_list.item(i);
                  if not basic_directory.last_entry.is_equal(entry) then
                     entry := basic_directory.last_entry.twin;
                     name_list.put(entry,i);
                  end;
               else
                  entry := basic_directory.last_entry.twin;
                  name_list.add_last(entry);
               end;
               basic_directory.read_entry;
               i := i + 1;
            end;
            basic_directory.disconnect;
            name_list.resize(i);
            last_scan_status := true;
         else
            name_list.clear;
            last_scan_status := false;
         end;
      end;

   scan_current_working_directory is
      local
         entry: STRING;
      do
         if name_list = Void then
            make;
         end;
         name_list.clear;
         basic_directory.connect_to_current_working_directory;
         if basic_directory.is_connected then
            path := basic_directory.last_entry.twin;
            from
               basic_directory.read_entry;
            until
               basic_directory.end_of_input
            loop
               entry := basic_directory.last_entry.twin;
               name_list.add_last(entry);
               basic_directory.read_entry;
            end;
            basic_directory.disconnect;
            last_scan_status := true;
         else
            last_scan_status := false;
         end;
      end;

feature -- Access :
   
   lower: INTEGER is 1;
         -- Index of the first item.
   
   upper: INTEGER is
         -- Index of the last item.
      do
         Result := name_list.upper + 1;
      end;
   
   count: INTEGER is
         -- Number of items (files or directories) in Current.
      do
         Result := name_list.count;
      ensure
         Result >= 0
      end;

   is_empty: BOOLEAN is
      do
         Result := count = 0;
      ensure
         definition: Result = (count = 0)
      end;
   
   valid_index(index: INTEGER): BOOLEAN is
      do
         if index >= 1 then
            Result := index <= name_list.upper + 1;
         end;
      ensure
         Result = (lower <= index and index <= upper)
      end;
   
   name(index: INTEGER): STRING is
         -- Return the name of entry (file or subdirectory) at `index'.
      require
         valid_index(index)
      do
         Result := name_list.item(index - 1);
      ensure
         has(Result)
      end;

   has(entry_name: STRING): BOOLEAN is
         -- Does Current contain the `entry_name' (file or subdirectory) ?
      require
         not entry_name.is_empty
      do
         if name_list.upper >= 0 then
            Result := name_list.has(entry_name);
         end;
     end;

end -- DIRECTORY


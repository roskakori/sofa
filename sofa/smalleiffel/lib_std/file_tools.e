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
expanded class FILE_TOOLS

inherit ANY;

feature

   same_files(path1, path2: STRING): BOOLEAN is
         -- True if the `path1' file exists and has the very same content 
         -- as file `path2'.
      require else
         path1 /= Void;
         path2 /= Void
      do
         std_fr1.connect_to(path1);
         if std_fr1.is_connected then
            std_fr2.connect_to(path2);
            if std_fr2.is_connected then
               Result := std_fr1.same_as(std_fr2);
	    else
	       std_fr1.disconnect;
            end;
         end;
      end;

   is_readable(path: STRING): BOOLEAN is
         -- True if `path' file exists and is a readable file.
      require
         path /= Void
      do
         std_fr1.connect_to(path);
         Result := std_fr1.is_connected;
         if Result then
            std_fr1.disconnect;
         end;
      end;

   is_empty(path: STRING): BOOLEAN is
         -- True if `path' file exists, is readable and is an empty file.
      do
         std_fr1.connect_to(path);
         if std_fr1.is_connected then
            std_fr1.read_character;
            Result := std_fr1.end_of_input;
            std_fr1.disconnect;
         end;
      end;

   rename_to(old_path, new_path: STRING) is
         -- Try to change the name or the location of a file.
      require
         old_path /= Void;
         new_path /= Void
      local
         p1, p2: POINTER;
      do
         if file_exists(new_path) then
            delete(new_path);
         end;
         p1 := old_path.to_external;
         p2 := new_path.to_external;
         se_rename(p1,p2);
      end;

   delete(path: STRING) is
         -- Try to delete the given `path' file.
      require
         path /= Void
      local
         p: POINTER;
      do
         p := path.to_external;
         se_remove(p);
      end;

   mkdir(name: STRING) is
      obsolete "This feature will be soon removed (see work in progress%N%
               %in class BASIC_DIRECTORY)." 
      local
         p: POINTER;
      do
         p := name.to_external;
         c_inline_c("mkdir((char*)_p,511);");
      end;

feature {NONE}

   se_remove(path: POINTER) is
         -- To implement `delete'.
      external "SmallEiffel"
      end;

   se_rename(old_path, new_path: POINTER) is
      external "SmallEiffel"
      end;

   std_fr1: STD_FILE_READ is
      once
         !!Result.make;
      end;

   std_fr2: STD_FILE_READ is
      once
         !!Result.make;
      end;
   
   tmp_string: STRING is
      once
         !!Result.make(256);
      end;

end -- FILE_TOOLS


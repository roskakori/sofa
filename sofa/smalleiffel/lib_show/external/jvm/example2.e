class EXAMPLE2
   --
   -- Some examples to call a virtual Java function using
   -- external "JVM_invokevirtual"
   --

creation make

feature

   make is
      local
         p: POINTER;
         i: INTEGER;
      do
         io.put_string("Calling java.lang.Double.toString(1.0);%N");
         p := java_lang_double_to_string(1.0);
         -- Local `p' is a Java String.

         io.put_string("Calling java/lang/String.length();%N");
         i := java_lang_string_length(p);
         io.put_string("Result = ");
         io.put_integer(i);
         io.put_new_line;
      end;

feature {NONE}

   java_lang_double_to_string(d: DOUBLE): POINTER is
      external "JVM_invokestatic"
      alias "java/lang/Double.toString (D)Ljava/lang/String;"
      end;

   java_lang_string_length(p: POINTER): INTEGER is
      external "JVM_invokevirtual"
      alias "java/lang/String.length ()I"
      end;

end

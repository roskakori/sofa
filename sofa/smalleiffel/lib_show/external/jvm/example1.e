class EXAMPLE1
   --
   -- Some examples to call static Java function using
   -- external "JVM_invokestatic"
   --

creation make

feature

   make is
      local
         i: INTEGER;
         r: REAL;
         d: DOUBLE;
      do
         io.put_string("Calling java/lang/Math.max : Math.max(1,2);%N");
         i := java_lang_math_max1(1,2);
         io.put_string("Result = ");
         io.put_integer(i);
         io.put_new_line;

         io.put_string("Calling java/lang/Math.max : Math.max(1.0,2.0);%N");
         r := java_lang_math_max2(1.0,2.0);
         io.put_string("Result = ");
         io.put_real(r);
         io.put_new_line;

         io.put_string("Calling java/lang/Math.max : Math.max(1.0,2.0);%N");
         d := java_lang_math_max3(1.0,2.0);
         io.put_string("Result = ");
         io.put_double(d);
         io.put_new_line;
      end;

feature {NONE}

   java_lang_math_max1(i1, i2: INTEGER): INTEGER is
      external "JVM_invokestatic"
      alias "java/lang/Math.max (II)I"
      end;

   java_lang_math_max2(r1, r2: REAL): REAL is
      external "JVM_invokestatic"
      alias "java/lang/Math.max (FF)F"
      end;

   java_lang_math_max3(d1, d2: DOUBLE): DOUBLE is
      external "JVM_invokestatic"
      alias "java/lang/Math.max (DD)D"
      end;

end

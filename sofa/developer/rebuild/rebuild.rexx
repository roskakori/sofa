/*
 * rebuild.rexx - Rebuild optimized SmallEiffel binaries with SAS/c.
 *
 * Supports to compile "small" programs with near code and data model,
 * while "big" programs use far model. For that, the SCOPTIONS file is
 * composed of various #?.with files:
 *
 * - general.with contains options used with both small and big programs
 * - small.with contains options used only for small programs
 * - big.with contains options only for big programs
 *
 * Furthermore, small programs are compiled using the SE's "-no_split",
 * making things a it a lot easier for the C optimizer.
 *
 * $VER: rebuild.rexx 1.1 (12.10.2000)
 */

NoClean = 0
NoCompile = 0
NoCompile_to_c = 0
NoCompile_to_jvm = 0
NoFinder = 0
NoPretty = 0
NoShort = 0

/* paths of .with files */
with_path = 'sofa:developer/rebuild/'
general_with = with_path || 'general.with'
small_with = with_path || 'small.with'
big_with = with_path || 'big.with'

Address Command

call compile_small('clean', NoClean)
call compile_small('compile', NoCompile)
call compile_big('compile_to_c', NoCompile_to_c)
call compile_big('compile_to_jvm', NoCompile_to_jvm)
call compile_small('finder', NoFinder)
call compile_big('pretty', NoPretty)
call compile_big('short', NoShort)

'delete quiet SCOPTIONS #?.o'

exit 0

/* subroutines */

compile_small:
   Parse Arg target, skip
   call compile(1)
   return

compile_big:
   Parse Arg target, skip
   call compile(0)
   return

compile:
   Parse Arg is_small

   if skip then do
      Say target || ' skipped'
   end
   else do
      compile = 'compile -boost -no_gc '
      if is_small then do
         compile = compile || '-no_split '
         'echo >SCOPTIONS "WITH=' || general_with || ' *NWITH=' || small_with || '"'
      end
      else do
         'echo >SCOPTIONS "WITH=' || general_with || ' *NWITH=' || big_with || '"'
      end
      compile = compile || target
      Say compile
      compile
      'clean ' || target
   end

   return

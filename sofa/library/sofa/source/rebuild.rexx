/* rebuild.rexx -- Rebuild sofa.lib depending on SmallEiffel's compiler.se
 *
 * $VER: rebuild.rexx 1.0 (4.4.00)
 */

FailAt 1

Call AddLib('rexxsupport.library', 0, -30, 0)
Pragma('directory', 'sofa:library/sofa/source')
Address Command

/* filenames */
lib_def = 'lib.def'
temp_yes = 't:rebuild_yes_' || Pragma('id') || '.tmp'
temp_run = 't:rebuild_' || Pragma('id') || '.tmp'
sofa_lib = 'sofa:lib/sofa.lib'

/* find out which C compiler to use */
compiler_se = 'sofa:SmallEiffel/sys/compiler.se'
if ~Open('compiler', compiler_se, 'read') then do
	Say 'Cannot read C compiler specification from "' || compiler_se || '"'
	Exit 10
end
compiler = ReadLn('compiler')
Call Close('compiler')

'delete quiet #?.o sofa:lib/sofa#?.lib'

select
	when compiler = 'dice' then do
		'echo >' || lib_def || ' "@Type l -mD -mC -lm"'
		'echo >>' || lib_def || ' "@Library sofa ' || sofa_lib || '"'
		'list >>' || lib_def || ' #?.c lformat="%p%n +sofa"'
		'lbmake l sofa'
	end
	when compiler = 'sc' then do
		'list >' || temp_run || ' #?.c lformat="echo sc %p%n*Nsc %p%n"'
		'execute ' || temp_run
		'list >' || temp_run || ' #?.o lformat=%p%n'
		'oml ' || sofa_lib || ' r @' || temp_run
	end
	when compiler = 'vbcc' then do
		'list >' || temp_run || ' #?.c lformat="echo vc %p%n -c -o %p%m.o -lmieee*Nvc %p%n -c -o %p%m.o -lmieee"'
		'execute ' || temp_run
		'list >' || temp_run || ' #?.o lformat=%p%n'
		'echo >' || temp_yes || ' "Y"'
		'alib <' || temp_yes || ' R ' || sofa_lib || ' `type ' || temp_run || '`'
	end
	otherwise do
		Say 'Cannot rebuild sofa.lib with compiler="' || compiler || '"'
		Say '(Compiler must be one of: dice, sc, vbcc)'
		Exit 10
	end
end

/* cleanup */
'delete quiet #?.o ' || temp_run || ' ' || lib_def || ' ' temp_yes
Say
'list nohead sofa:lib/sofa#?.lib'

Exit 0


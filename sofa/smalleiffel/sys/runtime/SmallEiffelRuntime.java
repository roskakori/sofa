/*
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
*/

import java.io.*;
import java.util.*;

/**
 * The SmallEiffelRuntime class implements some external "SmallEiffel"
 * features. This class must be present to execute the Java byte-code
 * generated by command `compile_to_jvm'.
 * Do not forget to add this class in your CLASSPATH system
 * environment variable.
 * You can also move this class file in an appropriate directory.
 */
public final class SmallEiffelRuntime {

    /**
     * To implement Eiffel GENERAL.se_getenv
     */
    public static String se_getenv (Object bytes) {
	String name = NullTerminatedBytesToString(bytes);
	return System.getProperty(name);
    }

    /**
     * To implement Eiffel GENERAL.print_run_time_stack
     */
    public static void print_run_time_stack () {
	Throwable stack = new Throwable();
	System.err.println("Printing the JVM stack:");
	stack.printStackTrace();
    }

    /**
     * To implement Eiffel GENERAL.die_with_code
     */
    public static void die_with_code (int code) {
	// System.exit(code);
	throw( new Error( "die with code: " + code ) );
    }

    /**
     * To implement Eiffel GENERAL.se_system
     */
    public static void se_system (Object system_command_line) {
	String scl = NullTerminatedBytesToString(system_command_line);
	Process process;

	try {
	    process = Runtime.getRuntime().exec(scl);

	    process.waitFor();
	    }
	catch (Exception e) {
	    System.err.print("SmallEiffelRuntime: se_system(\"");
	    System.err.print(scl);
	    System.err.println("\") failed.");
	    print_run_time_stack();
	    System.err.println("Try to continue execution.");
	}
    }

    /**
     * To implement Eiffel FILE_TOOLS.se_remove
     */
    public static void se_remove (Object bytes) {
	String name = NullTerminatedBytesToString(bytes);
	File file = new File(name);
	file.delete();
    }

    /**
     * To implement the Eiffel FILE_TOOLS.se_rename
     */
    public static void se_rename (Object old_path, Object new_path) {
	String oldPath = NullTerminatedBytesToString(old_path);
	String newPath = NullTerminatedBytesToString(new_path);
	File oldFile = new File(oldPath);
	File newFile = new File(newPath);

	oldFile.renameTo(newFile);
    }

    /**
     * To implement the Eiffel STD_FILE_READ.sfr_open
     */
    public static Object sfr_open (Object bytes) {
	String name = NullTerminatedBytesToString(bytes);
	File file = new File(name);

	try {
	    return new FileInputStream (file);
	} catch (FileNotFoundException e) {
	    return null;
	}
    }

    /**
     * To implement the Eiffel STD_FILE_WRITE.sfw_open
     */
    public static Object sfw_open (Object bytes) {
	String name = NullTerminatedBytesToString(bytes);
	File file = new File(name);

	try {
	    return new FileOutputStream (file);
	} catch (IOException e) {
	    return null;
	}
    }

    /**
     * To implement the Eiffel STRING.se_string2double
     */
    public static double se_string2double (Object number_view) {
	String number = NullTerminatedBytesToString(number_view);

	return Double.valueOf(number).doubleValue();
    }

    /**
     * To implement the Eiffel DOUBLE.sprintf_double
     */
    public static void sprintf_double (double d, byte buffer[], int f) {
	String s = Double.toString(d);
	int ib = 0;
	int is = 0;
	int iE;
	int idot;
	int exp;
	int i;

	if (s.charAt(is) == '-') {
	    buffer[ib++] = '-';
	    s = s.substring(1,s.length());
	}
	iE = s.indexOf('E');
	idot = s.indexOf('.');
	if (iE < 0) {
	    /* ddd.ddd notation. */
	    for (; is < idot ; is++) {
		buffer[ib++] = ((byte)(s.charAt(is)));
	    }
	    if (f > 0) {
		buffer[ib++] = '.';
		is++;
	    }
	    for (; ((f > 0) && (is < s.length())) ; f--) {
		buffer[ib++] = ((byte)(s.charAt(is++)));
	    }
	    for (; f > 0 ; f--) {
		buffer[ib++] = '0';
	    }
	    buffer[ib] = 0;
	}
	else {
	    /* m.ddddE-xx notation. */
	    exp = Integer.parseInt(s.substring(iE+1,s.length()));
	    if (exp >= 0) {
		for (; is < idot ; is++) {
		    buffer[ib++] = ((byte)(s.charAt(is)));
		}
		is++;
		for (; exp > 0 ; exp--) {
		    if (is < iE) {
			buffer[ib++] = ((byte)(s.charAt(is++)));
		    }
		    else {
			buffer[ib++] = '0';
		    }
		}
		if (f > 0) {
		    buffer[ib++] = '.';
		}
		for (; f > 0 ; f--) {
		    if (is < iE) {
			buffer[ib++] = ((byte)(s.charAt(is++)));
		    }
		    else {
			buffer[ib++] = '0';
		    }
		}
		buffer[ib] = 0;
	    }
	    else {
		System.out.println(s);
		i = idot + exp;
		if (i <= 0) {
		    buffer[ib++] = '0';
		}
		else {
		    for (; is < i ; is++) {
			buffer[ib++] = ((byte)(s.charAt(is++)));
		    }
		}
		if (f > 0) {
		    buffer[ib++] = '.';
		}
		for (; f > 0 ; f--) {
		    if (i < 0) {
			buffer[ib++] = '0';
			i++;
		    }
		    else if (is < iE) {
			if (is == idot) is++;
			buffer[ib++] = ((byte)(s.charAt(is++)));
		    }
		    else {
			buffer[ib++] = '0';
		    }
		}
		buffer[ib] = 0;
	    }
	}
    }

    /**
     * Convert <code>bytes</code> as a <code>String </code>.
     * Assume <code>bytes</code> is a C like string (ie. with a
     * null character is the end).
     */
    public static String NullTerminatedBytesToString (Object bytes) {
	int i = 0;
	byte b [] = ((byte[])bytes);
	while ( b[i] != 0 ) {
	    i++;
	}
	return (new String(b,0,i));
    }

    /**
     * Convert <code>string</code> as a C like null terminated
     * <code>byte[]</code> array.
     */
    public static Object StringToNullTerminatedBytes (String string) {
	byte result [] = new byte[string.length() + 1];
	int i = 0;
	for (; i < string.length() ; i++) {
	    result[i] = (byte)string.charAt(i);
	}
	result[result.length - 1] = 0;
	return result;
    }

    public static int internal_exception_number = 3;

    public static void runtime_error(int line,
				     int column,
				     String path,
				     String type,
				     String message) {
        System.err.println("Run-time Eiffel error.");
	if (message != null) {
	    System.err.println(message);
	}
	if (type != null) {
	    System.err.print("Eiffel type: \"");
	    System.err.print(type);
	    System.err.println("\".");
	}
	if (line != 0) {
	    System.err.print("Error occurs at line ");
	    System.err.print(line);
	    System.err.print(" column ");
	    System.err.print(column);
	    System.err.print(" in \"");
	    System.err.print(path);
	    System.err.println("\".");
	}
	print_run_time_stack();
	System.exit(1);
    }

    public static void runtime_error_bad_target(Object target,
						int line,
						int column,
						String path,
						String type,
						String message) {

	if (target == null) {
	    System.err.println("Void (null) target for a call.");
	}
	else {
	    System.err.println("Bad target for a call.");
	    System.err.print("Target is \"");
	    System.err.print(target.toString());
	    System.err.println("\"");
	}
	runtime_error(line,column,path,type,message);
    }

    public static int runtime_error_inspect(int inspect_value,
					    int line,
					    int column,
					    String path) {
	System.err.print("Bad inspect value = ");
	System.err.println(inspect_value);
	runtime_error(line,column,path,null,
		      "Invalid inspect (nothing selected).");
	return inspect_value;
    }

    public static int runtime_check_loop_variant(int loop_counter,
						 int prev_variant,
						 int next_variant,
						 int line,
						 int column,
						 String path) {
	if (next_variant < 0) {
	    bad_loop_variant(loop_counter,
			     prev_variant,
			     next_variant,
			     line,column,path);
	    return 0;
	}
	else if (loop_counter == 0) {
	    return next_variant;
	}
	else if (next_variant < prev_variant) {
	    return next_variant;
	}
	else {
	    bad_loop_variant(loop_counter,
			     prev_variant,
			     next_variant,
			     line,column,path);
	    return 0;
	}
    }

    private static void bad_loop_variant(int loop_counter,
					int prev_variant,
					int next_variant,
					int line,
					int column,
					String path) {
	System.err.print("Loop body counter = ");
	System.err.print(loop_counter);
	System.err.println(" (done)");
	if (loop_counter > 0) {
	    System.err.print("Previous variant = ");
	    System.err.println(prev_variant);
	}
	System.err.print("Current variant = ");
	System.err.print(next_variant);
	if (next_variant < 0) {
	    System.err.println(" (Bad Negative value)");
	}
	else {
	    System.err.println(" (must be less than previous)");
	}
	runtime_error(line,column,path,null,"Loop variant violation.");
    }

    /**
     * For -trace flag (this is a new undocumented stuff).
     */
    public static void se_trace(Object target,
				int line,
				int column,
				String path) {
	se_trace_show(line,column,path);
    }

    public static void se_trace(boolean target,
				int line,
				int column,
				String path) {
	if (target) {
	    System.out.print("Current = true ");
	}
	else {
	    System.out.print("Current = false ");
	}
	se_trace_show(line,column,path);
    }

    public static void se_trace(byte target,
				int line,
				int column,
				String path) {
	System.out.print("Current = ");
	System.out.print(target);
	System.out.print(" ");
	se_trace_show(line,column,path);
    }

    public static void se_trace(int target,
				int line,
				int column,
				String path) {
	System.out.print("Current = ");
	System.out.print(target);
	System.out.print(" ");
	se_trace_show(line,column,path);
    }

    public static void se_trace_show(int line,
				     int column,
				     String path) {
	System.out.print(path);
	System.out.print(" l=");
	System.out.print(line);
	System.out.print(" c=");
	System.out.print(column);
	System.out.println();
	System.out.flush();
    }

class DirectoryStream {
    /* To simulate a BASIC_DIRECTORY stream. */
    File directory;
    String[] list;
    int index;

    public DirectoryStream read_entry() {
	if (++index < list.length) {
	    return this;
	}
	else {
	    return null;
	}

    }

    public Object get_entry_name() {
	String entry;
	if (index == -2) {
	    entry = ".";
	}
	else if (index == -1) {
	    entry = "..";
	}
	else {
	    entry = list[index];
	}
	return StringToNullTerminatedBytes(entry);
    }

}
    public static Object basic_directory_current_working_directory() {
	String cwd = System.getProperty("user.dir");
	return StringToNullTerminatedBytes(cwd);
    }

    public static Object basic_directory_open(Object path_pointer) {
	String path = new String((byte[])path_pointer);
	File directory = new File(path);
	if (directory.isDirectory()) {
	    SmallEiffelRuntime dummy = new SmallEiffelRuntime();
	    DirectoryStream dirstream = dummy. new DirectoryStream();
	    dirstream.directory = directory;
	    dirstream.list = directory.list();
	    dirstream.index = -3;
	    return dirstream;
	}
	else {
	    return null;
	}
    }

    public static Object basic_directory_read_entry(Object dirstream_pointer) {
	DirectoryStream dirstream = ((DirectoryStream)dirstream_pointer);
	return dirstream.read_entry();
    }

    public static Object basic_directory_get_entry_name(Object dirstream_pointer) {
	DirectoryStream dirstream = ((DirectoryStream)dirstream_pointer);
	return dirstream.get_entry_name();
    }

    public static boolean basic_directory_close(Object stream) {
	return true;
    }

    public static boolean basic_directory_mkdir(Object dirpath_pointer) {
	String name = NullTerminatedBytesToString(dirpath_pointer);
	File directory = new File(name);
	directory.mkdir();
	return true;
    }

    public static boolean basic_directory_rmdir(Object dirpath_pointer) {
	String name = NullTerminatedBytesToString(dirpath_pointer);
	File directory = new File(name);
	directory.delete();
	return true;
    }

    public static boolean basic_directory_chdir(Object dirpath_pointer) {
	String path = new String((byte[])dirpath_pointer);
	File directory = new File(path);
	if (directory.isDirectory()) {
	    Properties p = System.getProperties();
	    p.put("user.dir",path);
	    return true;
	}
	else {
	    return false;
	}
    }

}


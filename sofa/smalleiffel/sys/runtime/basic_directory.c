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
/*
  This file (SmallEiffel/sys/runtime/basic_directory.c) is automatically
  included when some external "SmallEiffel" feature of class BASIC_DIRECTORY
  is live.
*/

#ifdef WIN32
#define SIMULATED_MODE
/* The simulated mode for WIN32.
*/
typedef struct _SIMULATED_DIR {
  HANDLE handle;
  WIN32_FIND_DATA data;
  int entry_used;
} SIMULATED_DIR;

static SIMULATED_DIR* simulated_opendir(char* path) {
  int len = strlen((char*)path);
  char* pattern = malloc(len + 5);
  SIMULATED_DIR* result = malloc(sizeof(SIMULATED_DIR));

  pattern = strcpy(pattern,(char*)path);
  if (pattern[len - 1] != '\\') pattern[len++] = '\\';
  pattern[len++] = '*';
  pattern[len++] = '.';
  pattern[len++] = '*';
  pattern[len++] = 0;
  result->handle = FindFirstFile(pattern,&(result->data));
  if (result->handle == INVALID_HANDLE_VALUE) {
    free(pattern);
    free(result);
    return NULL;
  }
  result->entry_used = 0;
  return result;
}

static void* simulated_readdir(SIMULATED_DIR* dirstream) {
  if (dirstream->entry_used) {
    if (FindNextFile(dirstream->handle,&(dirstream->data))) {
      dirstream->entry_used = 1;
      return dirstream;
    }
    else {
      return NULL;
    }
  }
  else {
    dirstream->entry_used = 1;
    return dirstream;
  }
}

#define simulated_get_entry_name(x) ((x)->data.cFileName)

static int simulated_closedir(SIMULATED_DIR* dirstream) {
  FindClose(dirstream->handle);
  free(dirstream);
  return 0;
}

int getcwd(char* buffer, size_t maxlen);
#define simulated_getcwd(x, y) getcwd(x, y)
int chdir(char* buffer);
#define simulated_chdir(x) chdir(x)

int mkdir(char* directory_path);
int simulated_mkdir(char* directory_path, int perm) {

  mkdir(directory_path);
  return 0;
}

int rmdir(char* directory_path);
#define simulated_rmdir(x) rmdir(x)
#endif  /* WIN32 */


#ifdef AMIGA
#define SIMULATED_MODE
/* The simulated mode for AmigaOS 2.04+
   Author: Thomas Aglassinger <agi@rieska.oulu.fi>

   Normally this shouldn't be necessary as all compilers include a
   simulation of the Un*x directory API. However, they differ in
   certain details, often resulting into compiler errors. Thus a
   implementation using native AmigaDOS calls seems preferable.

   Note that many of the happenings below have to deal with the
   various idiosyncracies of the "dos.library", which are not all
   documented clearly in the Autodocs. The biggest surprises should
   be reflected in comments. But consider reading chapter 17 of
   Ralph Babel's "Amiga Guru Book" before changing anything.
*/
#include <exec/types.h>
#include <dos/dos.h>
#include <dos/dostags.h>

#include <proto/exec.h>
#include <proto/dos.h>

typedef struct _SIMULATED_DIR {
  struct FileInfoBlock *info;
  BPTR lock;
} SIMULATED_DIR;

/* Results of OS functions returning a BPTR should be compared with ZERO
   rather than NULL, as BPTR is internally an integer type (despite its
   name).
*/
#ifndef ZERO
#define ZERO 0L
#endif

static void strip_trailing_slash(char *path, size_t *length,
             BOOL * stripped) {
  /* Used in `simulated_mkdir' and `simulated_rmdir' to temporarily
     blank out a possible traling slash (/) in the directory path.
     `restore_trailing_slash' puts it back in place afterwards.
  */
  *length = strlen(path);
  if ((*length > 0) && (path[*length - 1] == '/')) {
    *stripped = TRUE;
    path[*length - 1] = '\0';
  } else {
    *stripped = FALSE;
  }
}

static void restore_trailing_slash(char *path, size_t *length,
               BOOL * stripped) {
  if (*stripped) {
    path[*length - 1] = '/';
  }
}

/* Release all resources allocated during `simulated_opendir'; also
   works correctly if structure was only partially initialized.
*/
static void free_simulated_dir(SIMULATED_DIR * dir) {
  if (dir != NULL) {
    if (dir->lock != ZERO) {
      UnLock(dir->lock);
    }
    if (dir->info != NULL) {
      FreeDosObject(DOS_FIB, dir->info);
    }
    free(dir);
  }
}

static SIMULATED_DIR * simulated_opendir(char *path) {
  BOOL ok = FALSE;
  SIMULATED_DIR *result = malloc(sizeof(SIMULATED_DIR));

  if (result != NULL) {
    result->lock = ZERO;
    result->info = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL);
    if (result->info != NULL) {
      result->lock = Lock(path, ACCESS_READ);
      if (result->lock != ZERO) {
   ok = (Examine(result->lock, result->info) != DOSFALSE);
   if (ok) {
     /* Ensure we are scanning a directory, not a file */
     ok = (result->info->fib_DirEntryType >= 0)
       && (result->info->fib_DirEntryType != ST_SOFTLINK);
   }
      }
    }
  }
  if (!ok) {
    free_simulated_dir(result);
    result = NULL;
  }
  return result;
}

static void * simulated_readdir(SIMULATED_DIR * dirstream) {
  BOOL ok;
  SIMULATED_DIR *result = NULL;

  ok = (ExNext(dirstream->lock, dirstream->info) != DOSFALSE);

  if (ok) {
    result = dirstream;
  }
  return (void *) result;
}

#define simulated_get_entry_name(entry) ((entry)->info->fib_FileName)

static int simulated_closedir(SIMULATED_DIR * dirstream) {
  free_simulated_dir(dirstream);
  return 0;
}

static int simulated_getcwd(char *buffer, size_t maximum_length) {
  int result = 0;
  BPTR lock = Lock("", ACCESS_READ);
  if (lock != ZERO) {
    if (NameFromLock(lock, buffer, maximum_length) != DOSFALSE) {
      result = 1;
    }
    UnLock(lock);
  }
  return result;
}

static int simulated_chdir(char *name) {
   int result = -1;
   size_t name_length;
   BOOL slash_stripped;
   BPTR lock;

   strip_trailing_slash(name, &name_length, &slash_stripped);
   lock = Lock(name, ACCESS_READ);
   if (lock != ZERO) {
      /* Change the current working directory (CWD) of the task
       */
      BPTR old_lock = CurrentDir(lock);

      /* Now the trouble starts: if the task is a DOS process, its internal
       * buffer storing the name of the CWD has to be updated. Below you
       * will probably find the sickest piece of code ever necessary to
       * change the directory under any OS.
       */

      /* Find out if the task is a DOS process */
      struct Task *das_ich = FindTask(NULL);
      BOOL is_process = das_ich->tc_Node.ln_Type != NT_TASK;

      if (is_process) {
         /* Resolve a possible assign in `name' by re-querying it
          * from `lock'. (This is to clone the behavior of CLI,
          * where "cd" also resolves assigns.)
          */
         char *resolved_path = NULL;
         size_t resolved_length = 8; /* FIXME */
         do {
            resolved_path = (char *) malloc(resolved_length);
            if (resolved_path != NULL) {
               if (NameFromLock(lock, resolved_path, resolved_length) == DOSFALSE) {
                  free(resolved_path);
                  resolved_path = NULL;
                  resolved_length = 2 * resolved_length;
               }
            } else {
               SetIoErr(ERROR_NO_FREE_STORE);
            }
         } while ((resolved_path == NULL) && (IoErr() == ERROR_LINE_TOO_LONG));

         /* Actually update the process' buffer */
         if (resolved_path != NULL) {
            if (SetCurrentDirName(resolved_path)) {
               /* If this was successful, unlock `old_lock' because we
                * are not going to restore it later; this routine is one
                * of the few cases where such behavior is appropriate.
                */
               UnLock(old_lock);
               result = 0;
            }
         }
         free(resolved_path);
         if (result != 0) {
            /* If the process' CWD could not be changed, restore the
             * task's CWD to `old_lock'.
             */
            UnLock(lock);
            CurrentDir(old_lock);
         }
      }
   }
   restore_trailing_slash(name, &name_length, &slash_stripped);
   return result;
}
static int simulated_mkdir(char *directory_path, int permission) {
  BPTR lock;
  int result = -1;
  size_t path_length;
  BOOL slash_stripped;

  strip_trailing_slash(directory_path, &path_length, &slash_stripped);
  lock = CreateDir(directory_path);
  if (lock != ZERO) {
    UnLock(lock);
    result = 0;
  }
  restore_trailing_slash(directory_path, &path_length, &slash_stripped);
  return result;
}

static int simulated_rmdir(char *directory_path) {
  int result = -1;
  size_t path_length;
  BOOL slash_stripped;

  strip_trailing_slash(directory_path, &path_length, &slash_stripped);
  if (DeleteFile(directory_path)) {
    result = 0;
  }
  restore_trailing_slash(directory_path, &path_length, &slash_stripped);
  return result;
}
#endif /* AMIGA */

/*--------------------------------------------------------------------
  At his point, either this is a Linux/POSIX platform or some
  SIMULATED_MODE is defined. Unsupported platform should add their own
  SIMULATED_MODE before.
*/

EIF_POINTER basic_directory_open(EIF_POINTER path) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_open' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
#ifndef SIMULATED_MODE
  return (opendir(((char*) path)));
#else
  return (simulated_opendir(((char*) path)));
#endif
}

EIF_POINTER basic_directory_read_entry(EIF_POINTER dirstream) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_read_entry' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
#ifndef SIMULATED_MODE
  return readdir((DIR*)dirstream);
#else
  return simulated_readdir((SIMULATED_DIR*)dirstream);
#endif
}

EIF_POINTER basic_directory_get_entry_name(EIF_POINTER entry) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_get_entry_name' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
#ifndef SIMULATED_MODE
  return (((struct dirent*)entry)->d_name);
#else
  return simulated_get_entry_name((SIMULATED_DIR*)entry);
#endif
}

EIF_BOOLEAN basic_directory_close(EIF_POINTER dirstream) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_close' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
  int status;
#ifndef SIMULATED_MODE
  status = (closedir((DIR*)dirstream) == 0);
#else
  status = (simulated_closedir((SIMULATED_DIR*)dirstream) == 0);
#endif
  return (EIF_BOOLEAN) (status ? 1 : 0);
}

EIF_POINTER basic_directory_current_working_directory(void) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_current_working_directory' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
  static char* buf = NULL;
  static size_t size = 0;
  int status;
  if (buf == NULL) {
    size = 256;
    buf = (char*)malloc(size);
  }
#ifndef SIMULATED_MODE
  status = (getcwd(buf,size) != NULL);
#else
  status = simulated_getcwd(buf,size);
#endif
  if (status) {
    return buf;
  }
  else {
    free(buf);
    size = size * 2;
    buf = (char*)malloc(size);
    return basic_directory_current_working_directory();
  }
}

EIF_BOOLEAN basic_directory_chdir(EIF_POINTER destination) {
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_chdir' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
  int status;
#ifndef SIMULATED_MODE
  status = (chdir((char*)destination));
#else
  status = simulated_chdir((char*)destination);
#endif
  return (EIF_BOOLEAN) (status == 0 ? 1 : 0);
}

EIF_BOOLEAN basic_directory_mkdir(EIF_POINTER directory_path){
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_mkdir' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
  int status;
#ifndef SIMULATED_MODE
  status = (mkdir((char*)directory_path,0777));
#else
  status = simulated_mkdir((char*)directory_path,0777);
#endif
  return (EIF_BOOLEAN) (status == 0 ? 1 : 0);
}

EIF_BOOLEAN basic_directory_rmdir(EIF_POINTER directory_path){
  /*
     This is the implementation of the Eiffel external feature
     `basic_directory_rmdir' from class BASIC_DIRECTORY.
     See Eiffel source file for additional information.
  */
  int status;
#ifndef SIMULATED_MODE
  status = rmdir((char*)directory_path);
#else
  status = simulated_rmdir((char*)directory_path);
#endif
  return (EIF_BOOLEAN) (status == 0 ? 1 : 0);
}


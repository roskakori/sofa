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
  This file (SmallEiffel/sys/runtime/basic_gui.c) is automatically
  included when some external "SmallEiffel" feature of the Graphic User
  Interface (i.e. lib_gui) is live.
*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <X11/Intrinsic.h>
#ifndef X_GETTIMEOFDAY
#define X_GETTIMEOFDAY(tv)  gettimeofday (tv, NULL)
#endif /* X_GETTIMEOFDAY */

static Display *gdk_display = NULL;
static char *gdk_display_name = NULL;
static char *g_get_prgname = NULL;
static int gdk_use_xshm = TRUE;
char *gdk_progclass = NULL;
int gdk_screen;
Window gdk_root_window;
Window gdk_leader_window;
Atom gdk_wm_delete_window;
Atom gdk_wm_take_focus;
Atom gdk_wm_protocols;
Atom gdk_wm_window_protocols[2];
Atom gdk_selection_property;
static struct timeval timer; /* Timeout interval to use in the call
			      *	to "select". This is used in
			      *	conjunction with "timerp" to create
			      *	a maximum time to wait for an event
			      *	to arrive.
			      */
static struct timeval *timerp; /* The actual timer passed to "select"
				*	This may be NULL, in which case
				*	"select" will block until an event
				*	arrives.
				*/
static int timer_val; /* The timeout length as specified by
			  *	the user in milliseconds.
			  */
static int autorepeat;

static struct timeval start; /* The time at which the library was
			      *	last initialized.
			      */

static int connection_number = 0;
/* The file descriptor number of our connection to the X server. This
 * is used so that we may determine when events are pending by using
 * the "select" system call.
 */

char* basic_gui_strerror (int errnum) {
  char *msg;

#ifdef HAVE_STRERROR
  return strerror (errnum);
#elif NO_SYS_ERRLIST
  switch (errnum)
    {
#ifdef E2BIG
    case E2BIG: return "argument list too long";
#endif
#ifdef EACCES
    case EACCES: return "permission denied";
#endif
#ifdef EADDRINUSE
    case EADDRINUSE: return "address already in use";
#endif
#ifdef EADDRNOTAVAIL
    case EADDRNOTAVAIL: return "can't assign requested address";
#endif
#ifdef EADV
    case EADV: return "advertise error";
#endif
#ifdef EAFNOSUPPORT
    case EAFNOSUPPORT: return "address family not supported by protocol family";
#endif
#ifdef EAGAIN
    case EAGAIN: return "try again";
#endif
#ifdef EALIGN
    case EALIGN: return "EALIGN";
#endif
#ifdef EALREADY
    case EALREADY: return "operation already in progress";
#endif
#ifdef EBADE
    case EBADE: return "bad exchange descriptor";
#endif
#ifdef EBADF
    case EBADF: return "bad file number";
#endif
#ifdef EBADFD
    case EBADFD: return "file descriptor in bad state";
#endif
#ifdef EBADMSG
    case EBADMSG: return "not a data message";
#endif
#ifdef EBADR
    case EBADR: return "bad request descriptor";
#endif
#ifdef EBADRPC
    case EBADRPC: return "RPC structure is bad";
#endif
#ifdef EBADRQC
    case EBADRQC: return "bad request code";
#endif
#ifdef EBADSLT
    case EBADSLT: return "invalid slot";
#endif
#ifdef EBFONT
    case EBFONT: return "bad font file format";
#endif
#ifdef EBUSY
    case EBUSY: return "mount device busy";
#endif
#ifdef ECHILD
    case ECHILD: return "no children";
#endif
#ifdef ECHRNG
    case ECHRNG: return "channel number out of range";
#endif
#ifdef ECOMM
    case ECOMM: return "communication error on send";
#endif
#ifdef ECONNABORTED
    case ECONNABORTED: return "software caused connection abort";
#endif
#ifdef ECONNREFUSED
    case ECONNREFUSED: return "connection refused";
#endif
#ifdef ECONNRESET
    case ECONNRESET: return "connection reset by peer";
#endif
#if defined(EDEADLK) && (!defined(EWOULDBLOCK) || (EDEADLK != EWOULDBLOCK))
    case EDEADLK: return "resource deadlock avoided";
#endif
#ifdef EDEADLOCK
    case EDEADLOCK: return "resource deadlock avoided";
#endif
#ifdef EDESTADDRREQ
    case EDESTADDRREQ: return "destination address required";
#endif
#ifdef EDIRTY
    case EDIRTY: return "mounting a dirty fs w/o force";
#endif
#ifdef EDOM
    case EDOM: return "math argument out of range";
#endif
#ifdef EDOTDOT
    case EDOTDOT: return "cross mount point";
#endif
#ifdef EDQUOT
    case EDQUOT: return "disk quota exceeded";
#endif
#ifdef EDUPPKG
    case EDUPPKG: return "duplicate package name";
#endif
#ifdef EEXIST
    case EEXIST: return "file already exists";
#endif
#ifdef EFAULT
    case EFAULT: return "bad address in system call argument";
#endif
#ifdef EFBIG
    case EFBIG: return "file too large";
#endif
#ifdef EHOSTDOWN
    case EHOSTDOWN: return "host is down";
#endif
#ifdef EHOSTUNREACH
    case EHOSTUNREACH: return "host is unreachable";
#endif
#ifdef EIDRM
    case EIDRM: return "identifier removed";
#endif
#ifdef EINIT
    case EINIT: return "initialization error";
#endif
#ifdef EINPROGRESS
    case EINPROGRESS: return "operation now in progress";
#endif
#ifdef EINTR
    case EINTR: return "interrupted system call";
#endif
#ifdef EINVAL
    case EINVAL: return "invalid argument";
#endif
#ifdef EIO
    case EIO: return "I/O error";
#endif
#ifdef EISCONN
    case EISCONN: return "socket is already connected";
#endif
#ifdef EISDIR
    case EISDIR: return "illegal operation on a directory";
#endif
#ifdef EISNAME
    case EISNAM: return "is a name file";
#endif
#ifdef ELBIN
    case ELBIN: return "ELBIN";
#endif
#ifdef EL2HLT
    case EL2HLT: return "level 2 halted";
#endif
#ifdef EL2NSYNC
    case EL2NSYNC: return "level 2 not synchronized";
#endif
#ifdef EL3HLT
    case EL3HLT: return "level 3 halted";
#endif
#ifdef EL3RST
    case EL3RST: return "level 3 reset";
#endif
#ifdef ELIBACC
    case ELIBACC: return "can not access a needed shared library";
#endif
#ifdef ELIBBAD
    case ELIBBAD: return "accessing a corrupted shared library";
#endif
#ifdef ELIBEXEC
    case ELIBEXEC: return "can not exec a shared library directly";
#endif
#ifdef ELIBMAX
    case ELIBMAX: return "attempting to link in more shared libraries than system limit";
#endif
#ifdef ELIBSCN
    case ELIBSCN: return ".lib section in a.out corrupted";
#endif
#ifdef ELNRNG
    case ELNRNG: return "link number out of range";
#endif
#ifdef ELOOP
    case ELOOP: return "too many levels of symbolic links";
#endif
#ifdef EMFILE
    case EMFILE: return "too many open files";
#endif
#ifdef EMLINK
    case EMLINK: return "too many links";
#endif
#ifdef EMSGSIZE
    case EMSGSIZE: return "message too long";
#endif
#ifdef EMULTIHOP
    case EMULTIHOP: return "multihop attempted";
#endif
#ifdef ENAMETOOLONG
    case ENAMETOOLONG: return "file name too long";
#endif
#ifdef ENAVAIL
    case ENAVAIL: return "not available";
#endif
#ifdef ENET
    case ENET: return "ENET";
#endif
#ifdef ENETDOWN
    case ENETDOWN: return "network is down";
#endif
#ifdef ENETRESET
    case ENETRESET: return "network dropped connection on reset";
#endif
#ifdef ENETUNREACH
    case ENETUNREACH: return "network is unreachable";
#endif
#ifdef ENFILE
    case ENFILE: return "file table overflow";
#endif
#ifdef ENOANO
    case ENOANO: return "anode table overflow";
#endif
#if defined(ENOBUFS) && (!defined(ENOSR) || (ENOBUFS != ENOSR))
    case ENOBUFS: return "no buffer space available";
#endif
#ifdef ENOCSI
    case ENOCSI: return "no CSI structure available";
#endif
#ifdef ENODATA
    case ENODATA: return "no data available";
#endif
#ifdef ENODEV
    case ENODEV: return "no such device";
#endif
#ifdef ENOENT
    case ENOENT: return "no such file or directory";
#endif
#ifdef ENOEXEC
    case ENOEXEC: return "exec format error";
#endif
#ifdef ENOLCK
    case ENOLCK: return "no locks available";
#endif
#ifdef ENOLINK
    case ENOLINK: return "link has be severed";
#endif
#ifdef ENOMEM
    case ENOMEM: return "not enough memory";
#endif
#ifdef ENOMSG
    case ENOMSG: return "no message of desired type";
#endif
#ifdef ENONET
    case ENONET: return "machine is not on the network";
#endif
#ifdef ENOPKG
    case ENOPKG: return "package not installed";
#endif
#ifdef ENOPROTOOPT
    case ENOPROTOOPT: return "bad proocol option";
#endif
#ifdef ENOSPC
    case ENOSPC: return "no space left on device";
#endif
#ifdef ENOSR
    case ENOSR: return "out of stream resources";
#endif
#ifdef ENOSTR
    case ENOSTR: return "not a stream device";
#endif
#ifdef ENOSYM
    case ENOSYM: return "unresolved symbol name";
#endif
#ifdef ENOSYS
    case ENOSYS: return "function not implemented";
#endif
#ifdef ENOTBLK
    case ENOTBLK: return "block device required";
#endif
#ifdef ENOTCONN
    case ENOTCONN: return "socket is not connected";
#endif
#ifdef ENOTDIR
    case ENOTDIR: return "not a directory";
#endif
#ifdef ENOTEMPTY
    case ENOTEMPTY: return "directory not empty";
#endif
#ifdef ENOTNAM
    case ENOTNAM: return "not a name file";
#endif
#ifdef ENOTSOCK
    case ENOTSOCK: return "socket operation on non-socket";
#endif
#ifdef ENOTTY
    case ENOTTY: return "inappropriate device for ioctl";
#endif
#ifdef ENOTUNIQ
    case ENOTUNIQ: return "name not unique on network";
#endif
#ifdef ENXIO
    case ENXIO: return "no such device or address";
#endif
#ifdef EOPNOTSUPP
    case EOPNOTSUPP: return "operation not supported on socket";
#endif
#ifdef EPERM
    case EPERM: return "not owner";
#endif
#ifdef EPFNOSUPPORT
    case EPFNOSUPPORT: return "protocol family not supported";
#endif
#ifdef EPIPE
    case EPIPE: return "broken pipe";
#endif
#ifdef EPROCLIM
    case EPROCLIM: return "too many processes";
#endif
#ifdef EPROCUNAVAIL
    case EPROCUNAVAIL: return "bad procedure for program";
#endif
#ifdef EPROGMISMATCH
    case EPROGMISMATCH: return "program version wrong";
#endif
#ifdef EPROGUNAVAIL
    case EPROGUNAVAIL: return "RPC program not available";
#endif
#ifdef EPROTO
    case EPROTO: return "protocol error";
#endif
#ifdef EPROTONOSUPPORT
    case EPROTONOSUPPORT: return "protocol not suppored";
#endif
#ifdef EPROTOTYPE
    case EPROTOTYPE: return "protocol wrong type for socket";
#endif
#ifdef ERANGE
    case ERANGE: return "math result unrepresentable";
#endif
#if defined(EREFUSED) && (!defined(ECONNREFUSED) || (EREFUSED != ECONNREFUSED))
    case EREFUSED: return "EREFUSED";
#endif
#ifdef EREMCHG
    case EREMCHG: return "remote address changed";
#endif
#ifdef EREMDEV
    case EREMDEV: return "remote device";
#endif
#ifdef EREMOTE
    case EREMOTE: return "pathname hit remote file system";
#endif
#ifdef EREMOTEIO
    case EREMOTEIO: return "remote i/o error";
#endif
#ifdef EREMOTERELEASE
    case EREMOTERELEASE: return "EREMOTERELEASE";
#endif
#ifdef EROFS
    case EROFS: return "read-only file system";
#endif
#ifdef ERPCMISMATCH
    case ERPCMISMATCH: return "RPC version is wrong";
#endif
#ifdef ERREMOTE
    case ERREMOTE: return "object is remote";
#endif
#ifdef ESHUTDOWN
    case ESHUTDOWN: return "can't send afer socket shutdown";
#endif
#ifdef ESOCKTNOSUPPORT
    case ESOCKTNOSUPPORT: return "socket type not supported";
#endif
#ifdef ESPIPE
    case ESPIPE: return "invalid seek";
#endif
#ifdef ESRCH
    case ESRCH: return "no such process";
#endif
#ifdef ESRMNT
    case ESRMNT: return "srmount error";
#endif
#ifdef ESTALE
    case ESTALE: return "stale remote file handle";
#endif
#ifdef ESUCCESS
    case ESUCCESS: return "Error 0";
#endif
#ifdef ETIME
    case ETIME: return "timer expired";
#endif
#ifdef ETIMEDOUT
    case ETIMEDOUT: return "connection timed out";
#endif
#ifdef ETOOMANYREFS
    case ETOOMANYREFS: return "too many references: can't splice";
#endif
#ifdef ETXTBSY
    case ETXTBSY: return "text file or pseudo-device busy";
#endif
#ifdef EUCLEAN
    case EUCLEAN: return "structure needs cleaning";
#endif
#ifdef EUNATCH
    case EUNATCH: return "protocol driver not attached";
#endif
#ifdef EUSERS
    case EUSERS: return "too many users";
#endif
#ifdef EVERSION
    case EVERSION: return "version mismatch";
#endif
#if defined(EWOULDBLOCK) && (!defined(EAGAIN) || (EWOULDBLOCK != EAGAIN))
    case EWOULDBLOCK: return "operation would block";
#endif
#ifdef EXDEV
    case EXDEV: return "cross-domain link";
#endif
#ifdef EXFULL
    case EXFULL: return "message tables full";
#endif
    }
#else /* NO_SYS_ERRLIST */
  extern int sys_nerr;

  if ((errnum > 0) && (errnum <= sys_nerr))
    return ((char*)sys_errlist [errnum]);
#endif /* NO_SYS_ERRLIST */

  msg = se_calloc(64,1);
  sprintf (msg, "unknown error (%d)", errnum);

  return msg;
}

static int gui_x_error (Display	 *display, XErrorEvent *error) {
  /*
   *   The X error handling routine.
   *
   * Arguments:
   *   "display" is the X display the error orignated from.
   *   "error" is the XErrorEvent that we are handling.
   *
   * Results:
   *   Either we were expecting some sort of error to occur,
   *   in which case we set the "gdk_error_code" flag, or this
   *   error was unexpected, in which case we will print an
   *   error message and exit. (Since trying to continue will
   *   most likely simply lead to more errors).
   */
  if (error->error_code) {
      {
	char buf[64];
	XGetErrorText(display, error->error_code, buf, 63);
	fprintf(SE_ERR,
		"%s\n  serial %ld error_code %d request_code %d minor_code %d\n",
		buf,
		error->serial,
		error->error_code,
		error->request_code,
		error->minor_code);

      }
#ifdef SE_NO_CHECK
      error0("gui_x_error.", NULL);
#endif
      return 0;
  }
}

static int gui_x_io_error (Display *display) {
  /*
   *   The X I/O error handling routine.
   *
   * Arguments:
   *   "display" is the X display the error orignated from.
   *
   * Results:
   *   An X I/O error basically means we lost our connection
   *   to the X server. There is not much we can do to
   *   continue, so simply print an error message and exit.
   *
   */

  /* This is basically modelled after the code in XLib. We need
   * an explicit error handler here, so we can disable our atexit()
   * which would otherwise cause a nice segfault.
   */
  if (errno == EPIPE) {
    fprintf(SE_ERR,
    "GUI-ERROR **: X connection to %s broken (explicit kill or server shutdown).\n",
	    gdk_display ? DisplayString(gdk_display) : gdk_display_name);
  }
  else {
    fprintf(SE_ERR,
	    "Gdk-ERROR **: Fatal IO error %d (%s) on X server %s.\n",
	    errno, basic_gui_strerror(errno),
	    gdk_display ? DisplayString(gdk_display) : gdk_display_name);
    }

#ifdef SE_NO_CHECK
  error0("gui_x_io_error.", NULL);
#endif
  exit(1);
}

void gdk_events_init (void) {
  connection_number = ConnectionNumber(gdk_display);
}

EIF_BOOLEAN basic_gui_initialize(EIF_POINTER display_name,
				 EIF_BOOLEAN sync,
				 EIF_BOOLEAN no_xshm,
				 EIF_POINTER name,
				 EIF_POINTER progclass,
				 EIF_POINTER gxid_host,
				 EIF_INTEGER gxid_port) {
  /*
     Called only once at the very beginning to initialize the Window Manager.
  */
  int synchronize = sync;
  XKeyboardState keyboard_state;
  XClassHint *class_hint;
  X_GETTIMEOFDAY (&start);
  gdk_display_name = display_name;
  XSetErrorHandler (gui_x_error);
  XSetIOErrorHandler (gui_x_io_error);
  g_get_prgname = name;
  gdk_display_name = display_name;
  if (no_xshm) gdk_use_xshm = FALSE;
  gdk_progclass = progclass;
#ifdef XINPUT_GXI
  gdk_input_gxid_host = gxid_host;
  gdk_input_gxid_port = gxid_port;
#endif

  gdk_display = XOpenDisplay (gdk_display_name);
  if (!gdk_display)
    return FALSE;

  if (synchronize)
    XSynchronize (gdk_display, True);

  gdk_screen = DefaultScreen (gdk_display);

  gdk_root_window = RootWindow (gdk_display, gdk_screen);

  gdk_leader_window = XCreateSimpleWindow(gdk_display, gdk_root_window,
					  10, 10, 10, 10, 0, 0 , 0);
  class_hint = XAllocClassHint();
  class_hint->res_name = g_get_prgname;
  if (gdk_progclass == NULL) {
    gdk_progclass = g_get_prgname;
  }
  class_hint->res_class = gdk_progclass;
  XmbSetWMProperties (gdk_display, gdk_leader_window,
		      NULL, NULL, se_argv, se_argc,
		      NULL, NULL, class_hint);
  XFree (class_hint);
  gdk_wm_delete_window = XInternAtom (gdk_display, "WM_DELETE_WINDOW", False);
  gdk_wm_take_focus = XInternAtom (gdk_display, "WM_TAKE_FOCUS", False);
  gdk_wm_protocols = XInternAtom (gdk_display, "WM_PROTOCOLS", False);
  gdk_wm_window_protocols[0] = gdk_wm_delete_window;
  gdk_wm_window_protocols[1] = gdk_wm_take_focus;
  gdk_selection_property = XInternAtom (gdk_display, "GDK_SELECTION", False);

  XGetKeyboardControl (gdk_display, &keyboard_state);

  autorepeat = keyboard_state.global_auto_repeat;

  timer.tv_sec = 0;
  timer.tv_usec = 0;
  timerp = NULL;

  /* @@@ Keep This ?:
     gdk_events_init ();
     gdk_visual_init ();
     gdk_window_init ();
     gdk_image_init ();
     gdk_input_init ();
     gdk_dnd_init ();

#ifdef USE_XIM
  gdk_im_open ();
#endif
  */
  return 1;
}

void gdk_key_repeat_restore (void) {
  if (autorepeat)
    XAutoRepeatOn (gdk_display);
  else
    XAutoRepeatOff (gdk_display);
}

EIF_BOOLEAN basic_gui_exit(void) {
  /* Restores the library to an un-itialized state.
   */
#ifdef USE_XIM
  /* cleanup IC */
  gdk_ic_cleanup ();
  /* close IM */
  gdk_im_close ();
#endif
  /* gdk_image_exit (); @@@ Keep This ? */
  /* gdk_input_exit (); @@@ Keep This ? */
  gdk_key_repeat_restore ();

  XCloseDisplay (gdk_display);
  return 0;
}

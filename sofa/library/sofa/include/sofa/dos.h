/* dos.h - Sofa dos.library functions */
#ifndef SOFA_AMIGA_DOS_H
#define SOFA_AMIGA_DOS_H 1

#ifndef ZERO
#define ZERO 0L
#endif

struct dos_pattern_context {
	char *pattern;               /* parsed pattern passed to MatchPattern() */
	EIF_INTEGER has_wild_card;   /* result of ParsePattern: -1, 0 or 1 */
	EIF_BOOLEAN case_sensitive;  /* case sensitive pattern ? */
};

/* TODO: use it */
struct file_info_context {
	struct FileInfoBlock *fib;   /* detailed file information */
	char *full_name;             /* name of file, expanded to full path */
	void *lock;                  /* lock to file */
};

#endif                          /* SOFA_AMIGA_DOS_H */

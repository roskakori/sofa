/* assert.c -- simple assertion handling */

#include <stdio.h>
#include "global.h"

export void
sofa_assert(int expression, char *expression_text, char *assertion_description, char *file, int line)
{
	if (!expression) {
		printf("\n\nProgram terminated because %s failed\n%s (%d): %s\n",
				 assertion_description, file, line, expression_text);
		abort();
	}
}

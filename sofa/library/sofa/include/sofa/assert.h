/* sofa/assert.h */
#ifndef SOFA_ASSERT_H
#define SOFA_ASSERT_H

#ifdef NDEBUG

#define assert(expression) /* do nothing */
#define require(expression) /* do nothing */
#define ensure(expression) /* do nothing */

#else

#define assert(expression) sofa_assert((expression), #expression, "assertion", __FILE__, __LINE__)
#define require(expression) sofa_assert((expression), #expression, "precondition", __FILE__, __LINE__)
#define ensure(expression) sofa_assert((expression), #expression, "postcondition", __FILE__, __LINE__)

#endif

/* demand basic requirement */
#define demand(expression) sofa_assert((expression), #expression, "basic requirement"__FILE__, __LINE__)

#endif /* SOFA_ASSERT_H */


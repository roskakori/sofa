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
  This file (SmallEiffel/sys/runtime/deep_twin.c) contains the basic
  runtime support for the GENERAL.deep_twin feature as well as the basic
  runtime support for the GENERAL.is_deep_equal feature.
  This file is automatically included in the header when `deep_twin' or
  `is_deep_equal' is in the live code of the system.
*/

/* To count level of nested `deep_twin' calls:
 */
static int se_deep_twin_start_counter = 0;

/* Memory buffer to retrieve already `deep_twin'ed objects:
 */
static void** se_deep_twin_memory1 = NULL;
static void** se_deep_twin_memory2 = NULL;
static size_t se_deep_twin_memory_sizeof = 0;
static int    se_deep_twin_memory_last = -1;

#define SE_DEEP_TWIN_BUFFER_SIZE 128

void se_deep_twin_start(void) {
  if (se_deep_twin_start_counter == 0) {
    if (se_deep_twin_memory_sizeof == 0) {
      int s;
      se_deep_twin_memory_sizeof = SE_DEEP_TWIN_BUFFER_SIZE;
      s = (se_deep_twin_memory_sizeof * sizeof(void*));
      se_deep_twin_memory1 = ((void**)se_malloc(s));
      se_deep_twin_memory2 = ((void**)se_malloc(s));
    }
  }
  se_deep_twin_start_counter++;
}

void* se_deep_twin_search(void* object) {
  int i = se_deep_twin_memory_last;
  for (i = se_deep_twin_memory_last; i >= 0; i--) {
    if (object == se_deep_twin_memory1[i]) {
      return (se_deep_twin_memory2[i]);
    }
  }
  return NULL;
}

void se_deep_twin_register(void* object, void* deep_twin) {
  if (object != NULL) {
    if (se_deep_twin_search(object) == NULL) {
      se_deep_twin_memory_last++;
      if (se_deep_twin_memory_last == se_deep_twin_memory_sizeof) {
	int s;
	se_deep_twin_memory_sizeof *= 2;
	s = (se_deep_twin_memory_sizeof * sizeof(void*));
	se_deep_twin_memory1 = ((void**)realloc(se_deep_twin_memory1,s));
	se_deep_twin_memory2 = ((void**)realloc(se_deep_twin_memory2,s));
      }
      se_deep_twin_memory1[se_deep_twin_memory_last] = object;
      se_deep_twin_memory2[se_deep_twin_memory_last] = deep_twin;
    }
  }
}

void* se_deep_twin_trats(void* object) {
  se_deep_twin_start_counter--;
  if (se_deep_twin_start_counter == 0) {
    se_deep_twin_memory_last = -1;
    if (se_deep_twin_memory_sizeof > SE_DEEP_TWIN_BUFFER_SIZE) {
      free(se_deep_twin_memory1);
      free(se_deep_twin_memory2);
      se_deep_twin_memory1 = NULL;
      se_deep_twin_memory2 = NULL;
      se_deep_twin_memory_sizeof = 0;
    }
  }
  return object;
}


/* To count level of nested `deep_equal' calls:
 */
static int se_deep_equal_start_counter = 0;

/* Memory buffer to retrieve already `deep_equal'ed objects:
 */
static void** se_deep_equal_memory1 = NULL;
static void** se_deep_equal_memory2 = NULL;
static size_t se_deep_equal_memory_sizeof = 0;
static int    se_deep_equal_memory_last = -1;

void se_deep_equal_start(void) {
  if (se_deep_equal_start_counter == 0) {
    if (se_deep_equal_memory_sizeof == 0) {
      int s;
      se_deep_equal_memory_sizeof = SE_DEEP_TWIN_BUFFER_SIZE;
      s = (se_deep_equal_memory_sizeof * sizeof(void*));
      se_deep_equal_memory1 = ((void**)se_malloc(s));
      se_deep_equal_memory2 = ((void**)se_malloc(s));
    }
  }
  se_deep_equal_start_counter++;
}

static void se_deep_equal_register(void* object, void* deep) {
  se_deep_equal_memory_last++;
  if (se_deep_equal_memory_last == se_deep_equal_memory_sizeof) {
    int s;
    se_deep_equal_memory_sizeof *= 2;
    s = (se_deep_equal_memory_sizeof * sizeof(void*));
    se_deep_equal_memory1 = ((void**)realloc(se_deep_equal_memory1,s));
    se_deep_equal_memory2 = ((void**)realloc(se_deep_equal_memory2,s));
  }
  se_deep_equal_memory1[se_deep_equal_memory_last] = object;
  se_deep_equal_memory2[se_deep_equal_memory_last] = deep;
}

int se_deep_equal_search(void* object,void* deep) {
  int i;
  if (object == deep) return 1;
  if ((object != NULL) && (deep != NULL)) {
    for (i = se_deep_equal_memory_last; i >= 0; i--) {
      if (object == se_deep_equal_memory1[i]) {
	if (deep == se_deep_equal_memory2[i]) {
	  return 1;
	}
      }
    }
    se_deep_equal_register(object,deep);
  }
  return 0;
}

void se_deep_equal_trats(void) {
  se_deep_equal_start_counter--;
  if (se_deep_equal_start_counter == 0) {
    se_deep_equal_memory_last = -1;
    if (se_deep_equal_memory_sizeof > SE_DEEP_TWIN_BUFFER_SIZE) {
      free(se_deep_equal_memory1);
      free(se_deep_equal_memory2);
      se_deep_equal_memory1 = NULL;
      se_deep_equal_memory2 = NULL;
      se_deep_equal_memory_sizeof = 0;
    }
  }
}

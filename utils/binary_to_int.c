#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1
#include <assert.h>
#include <stdlib.h>

static void binary_to_int(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){

  if (sqlite3_value_type(argv[0]) == SQLITE_NULL) return;

  const char *zIn = (const char*) sqlite3_value_text(argv[0]);

  sqlite3_result_int64(context, strtol(zIn, NULL, 2));
}

int sqlite3_binarytoint_init(
  sqlite3 *db,
  char **pzErrMsg,
  const sqlite3_api_routines *pApi
){
  SQLITE_EXTENSION_INIT2(pApi);
  (void) pzErrMsg;
  return sqlite3_create_function(
    db, "binary_to_int", 1, SQLITE_UTF8, 0, binary_to_int, 0, 0);
}
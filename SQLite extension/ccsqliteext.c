#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1

static void replicatingNodeFunc(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){
  sqlite3_result_null(context);
}

/* SQLite invokes this routine once when it loads the extension.
** Create new functions, collating sequences, and virtual table
** modules here.  This is usually the only exported symbol in
** the shared library.
*/
int sqlite3_extension_init(
  sqlite3 *db,
  char **pzErrMsg,
  const sqlite3_api_routines *pApi
){
  SQLITE_EXTENSION_INIT2(pApi)
  sqlite3_create_function(db, "replicating_node", 0, SQLITE_ANY, 0, &replicatingNodeFunc, 0, 0);
  return 0;
}
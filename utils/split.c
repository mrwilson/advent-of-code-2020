#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#ifndef SQLITE_OMIT_VIRTUALTABLE

#ifndef SQLITE_SPLIT_CONSTRAINT_VERIFY
# define SQLITE_SPLIT_CONSTRAINT_VERIFY 0
#endif

typedef struct split_cursor split_cursor;

struct split_cursor {
  sqlite3_vtab_cursor base;
  char* current;
  char* rest;
  char* delimiter;
  bool finished;
  sqlite3_int64 rowid;
};

// For debugging
static void printState(split_cursor *pCur) {
  //printf("***\nDelimiter = %s\n", pCur->delimiter);
  //printf("Current = %s\n", pCur->current);
  //printf("Rest = %s\n", pCur->rest);
  //printf("Finished = %d\n***\n", pCur->finished);
}

static int splitConnect(
    sqlite3 *db, void *pUnused, int argcUnused,
    const char *const*argvUnused, sqlite3_vtab **ppVtab, char **pzErrUnused
) {
  sqlite3_vtab *pNew;
  int rc;

/* Column numbers */
#define SPLIT_COLUMN_VALUE       0
#define SPLIT_COLUMN_STRING      1
#define SPLIT_COLUMN_DELIMITER   2

  (void)pUnused;
  (void)argcUnused;
  (void)argvUnused;
  (void)pzErrUnused;
  rc = sqlite3_declare_vtab(db,"CREATE TABLE x(value,string hidden,delimiter hidden)");

  if( rc==SQLITE_OK ){
    pNew = *ppVtab = sqlite3_malloc( sizeof(*pNew) );
    if( pNew==0 ) return SQLITE_NOMEM;
    memset(pNew, 0, sizeof(*pNew));
    sqlite3_vtab_config(db, SQLITE_VTAB_INNOCUOUS);
  }
  return rc;
}

static int splitDisconnect(sqlite3_vtab *pVtab){
  sqlite3_free(pVtab);
  return SQLITE_OK;
}

static int splitOpen(sqlite3_vtab *pUnused, sqlite3_vtab_cursor **ppCursor){
  split_cursor *pCur;
  (void)pUnused;
  pCur = sqlite3_malloc( sizeof(*pCur) );
  if( pCur==0 ) return SQLITE_NOMEM;
  memset(pCur, 0, sizeof(*pCur));
  *ppCursor = &pCur->base;
  return SQLITE_OK;
}

static int splitClose(sqlite3_vtab_cursor *cur){
  sqlite3_free(cur);
  return SQLITE_OK;
}

static int splitNext(sqlite3_vtab_cursor *cur) {
  split_cursor *pCur = (split_cursor*)cur;

  char* ptr;

printState(pCur);

       char *token = strsep(&pCur->rest, pCur->delimiter);
       if (token == NULL) {
           pCur->finished = true;
           return SQLITE_OK;
       }

       pCur->current = token;
    pCur->rowid++;

  printState(pCur);

  return SQLITE_OK;
}

static int splitColumn(sqlite3_vtab_cursor *cur, sqlite3_context *ctx, int i){
  split_cursor *pCur = (split_cursor*)cur;

  sqlite3_result_text(ctx, pCur->current, -1, SQLITE_TRANSIENT);

  return SQLITE_OK;
}

static int splitRowid(sqlite3_vtab_cursor *cur, sqlite_int64 *pRowid){
  split_cursor *pCur = (split_cursor*)cur;
  *pRowid = pCur->rowid;
  return SQLITE_OK;
}

static int splitEof(sqlite3_vtab_cursor *cur){
  split_cursor *pCur = (split_cursor*)cur;

  return pCur->finished;
}

static int splitFilter(
  sqlite3_vtab_cursor *pVtabCursor,
  int idxNum, const char *idxStrUnused,
  int argc, sqlite3_value **argv
){
  split_cursor *pCur = (split_cursor *) pVtabCursor;

   if (argc != 2) {
    return SQLITE_ERROR;
   }

    pCur->rest = (char*) sqlite3_value_text(argv[0]);
    pCur->delimiter = (char *) sqlite3_value_text(argv[1]);
    pCur->finished = false;

    pCur->rowid = 0;

  return splitNext(pVtabCursor);
}

// Shamelessly borrowed
// no_idea_dog.png
static int splitBestIndex(sqlite3_vtab *tabUnused, sqlite3_index_info *pIdxInfo){
int i, j;
  int idxNum = 0;
  int unusableMask = 0;
  int nArg = 0;
  int aIdx[3];
  const struct sqlite3_index_constraint *pConstraint;

  (void)tabUnused;
  aIdx[0] = aIdx[1] = aIdx[2] = -1;
  pConstraint = pIdxInfo->aConstraint;
  for(i=0; i<pIdxInfo->nConstraint; i++, pConstraint++){
    int iCol;    /* 0 for string, 1 for delimiter */
    int iMask;   /* bitmask for those column */
    if( pConstraint->iColumn < SPLIT_COLUMN_STRING ) continue;
    iCol = pConstraint->iColumn - SPLIT_COLUMN_STRING;
    iMask = 1 << iCol;
    if( pConstraint->usable==0 ){
      unusableMask |=  iMask;
      continue;
    }else if ( pConstraint->op==SQLITE_INDEX_CONSTRAINT_EQ ){
      idxNum |= iMask;
      aIdx[iCol] = i;
    }
  }

  for(i=0; i<3; i++){
    if( (j = aIdx[i])>=0 ){
      pIdxInfo->aConstraintUsage[j].argvIndex = ++nArg;
      pIdxInfo->aConstraintUsage[j].omit = !SQLITE_SPLIT_CONSTRAINT_VERIFY;
    }
  }

  if( (unusableMask & ~idxNum)!=0 ){
    return SQLITE_CONSTRAINT;
  }

  if( (idxNum & 3)==3 ){
    pIdxInfo->estimatedCost = (double)(2 - ((idxNum&4)!=0));
    pIdxInfo->estimatedRows = 1000;
    if( pIdxInfo->nOrderBy==1 ){
      if( pIdxInfo->aOrderBy[0].desc ){
        idxNum |= 8;
      }else{
        idxNum |= 16;
      }
      pIdxInfo->orderByConsumed = 1;
    }
  }else{
    pIdxInfo->estimatedRows = 2147483647;
  }
  pIdxInfo->idxNum = idxNum;
  return SQLITE_OK;
}

static sqlite3_module splitModule = {
  0,                         /* iVersion */
  0,                         /* xCreate */
  splitConnect,             /* xConnect */
  splitBestIndex,           /* xBestIndex */
  splitDisconnect,          /* xDisconnect */
  0,                         /* xDestroy */
  splitOpen,                /* xOpen - open a cursor */
  splitClose,               /* xClose - close a cursor */
  splitFilter,              /* xFilter - configure scan constraints */
  splitNext,                /* xNext - advance a cursor */
  splitEof,                 /* xEof - check for end of scan */
  splitColumn,              /* xColumn - read data */
  splitRowid,               /* xRowid - read data */
  0,                         /* xUpdate */
  0,                         /* xBegin */
  0,                         /* xSync */
  0,                         /* xCommit */
  0,                         /* xRollback */
  0,                         /* xFindMethod */
  0,                         /* xRename */
  0,                         /* xSavepoint */
  0,                         /* xRelease */
  0,                         /* xRollbackTo */
  0                          /* xShadowName */
};

#endif /* SQLITE_OMIT_VIRTUALTABLE */

int sqlite3_split_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
  int rc = SQLITE_OK;
  SQLITE_EXTENSION_INIT2(pApi);
#ifndef SQLITE_OMIT_VIRTUALTABLE
  rc = sqlite3_create_module(db, "split", &splitModule, 0);
#endif
  return rc;
}
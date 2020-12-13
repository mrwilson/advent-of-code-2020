#include "sqlite3ext.h"
#include <assert.h>
#include <stdio.h>
#include <math.h>

SQLITE_EXTENSION_INIT1

typedef struct {
    int count;
    double fProd;
    long long iProd;
}
productCtx;

void validateTypes(sqlite3_context *context, int a) {
    if (a == SQLITE_NULL) {
        sqlite3_result_error(context, "Null type.", -1);
    }

    if (a != SQLITE_INTEGER && a != SQLITE_FLOAT) {
        sqlite3_result_error(context, "Incompatible type.", -1);
    }
}

void productStep(sqlite3_context *context, int argc, sqlite3_value **argv) {
    productCtx *p;
    int valueType;

    p = sqlite3_aggregate_context(context, sizeof(*p));

    valueType = sqlite3_value_numeric_type(argv[0]);

    validateTypes(context, valueType);

    if (p) {

        if (valueType == SQLITE_INTEGER) {
            int value = sqlite3_value_int64(argv[0]);

            if (p->iProd == 0) {
                p->iProd = value;
            } else {
                p->iProd *= value;
            }
        } else {
            double value = sqlite3_value_double(argv[0]);

            if (p->fProd == 0.0) {
                p->fProd = value;
            } else {
                p->fProd *= value;
            }
        }

        p->count++;
    }
}

void productFinalize(sqlite3_context *context) {
    productCtx *p;
    p = sqlite3_aggregate_context(context, 0);

    if (!p || p->count <= 0) {
        sqlite3_result_error(context, "Error calculating value.", -1);
    }

    if (p->iProd != 0) {
        sqlite3_result_int64(context, p->iProd);
    } else {
        sqlite3_result_double(context, p->fProd);
    }
}

int sqlite3_extension_init(
    sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi
) {
    (void) pzErrMsg;
    SQLITE_EXTENSION_INIT2(pApi);

    sqlite3_create_function(
        db, "product", 1, SQLITE_UTF8, NULL, NULL, &productStep, &productFinalize
    );

    return SQLITE_OK;
}
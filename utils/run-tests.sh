#!/usr/bin/env bash

function run_test() {
    TEST_FILE=$1
    EXPECTED_OUTPUT=$2

    ACTUAL_OUTPUT=$(sqlite3 < "$TEST_FILE" | tr -d '\r')

    if [[ "$ACTUAL_OUTPUT" = "$EXPECTED_OUTPUT" ]]; then
      echo "Test passed: ${TEST_FILE}"
    else
      echo "Test failed: ${TEST_FILE}. Expected \"${EXPECTED_OUTPUT}\" but was \"${ACTUAL_OUTPUT}\""
    fi
}

for lib in *.c; do
  echo "Compiling ${lib}"
  gcc \
    -dynamiclib \
    -lsqlite3 \
    -DSQLITE_VTAB_INNOCUOUS=0 \
    ${lib} \
    -o $(echo $lib | sed 's/\.c/.dylib/')
done

run_test test_binary_to_int.sql "10|26|0|511"
run_test test_split.sql "a|b|c"
run_test test_product.sql "120|120.0"
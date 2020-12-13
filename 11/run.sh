#!/usr/bin/env bash

rm -rf aoc.db

sqlite3 aoc.db < 11_initialise.sql

STEPS=0

while true; do
    echo ${STEPS}

  NEXT=$(sqlite3 aoc.db < 11_next_generation.sql | tail -n 1)

  if [[ ${STEPS} -eq ${NEXT} ]]; then
    break;
  fi

  STEPS=${NEXT}
done
#!/bin/bash

API_URL="http://127.0.0.1:3000"
DURATION="10s"
CURRENT=5000
PASSED=0
FAILED=0

echo "Phase 1: Doubling to find upper bound"
while [ $FAILED -eq 0 ]; do
  echo "Testing $CURRENT users..."
  k6 run --vus $CURRENT --duration $DURATION -e API_URL=$API_URL load-test.js > k6.log 2>&1
  
  if [ $? -eq 0 ]; then
    echo "Success at $CURRENT"
    PASSED=$CURRENT
    CURRENT=$((CURRENT * 2))
  else
    echo "Failed at $CURRENT"
    FAILED=$CURRENT
  fi
done

echo "Phase 2: Binary search between $PASSED and $FAILED"

while [ $((FAILED - PASSED)) -gt 50 ]; do
  MID=$(( (PASSED + FAILED) / 2 ))
  echo "Testing $MID users..."
  k6 run --vus $MID --duration $DURATION -e API_URL=$API_URL load-test.js > k6.log 2>&1
  
  if [ $? -eq 0 ]; then
    echo "Success at $MID"
    PASSED=$MID
  else
    echo "Failed at $MID"
    FAILED=$MID
  fi
done

echo "Max supported users: $PASSED"
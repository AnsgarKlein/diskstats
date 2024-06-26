#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

# Change directory to project root
cd "$PROJECT_ROOT" || exit 1

RESOURCE_DIR='tests/resources'
COMPARISON_CHECKER='tests/compare.py'
PYTHON_BINARY='diskstats.py'
BASH_BINARY='diskstats.sh'


# Compare script output for every file
for resource in "$RESOURCE_DIR/"*; do
    $COMPARISON_CHECKER \
      --cmd1 "./${PYTHON_BINARY}" "$resource" \
      --cmd2 "./${BASH_BINARY}" "$resource" \
      2> /dev/null > /dev/null
    result=$?

    test_failed='false'
    if [[ "$result" -eq 0 ]] ;then
        printf "%-75s\e[0;32m%s\e[0m\n" "Testing file ${resource} ..." "OK"
    else
        printf "%-75s\e[0;31m%s\e[0m\n" "Testing file ${resource} ..." "FAIL"
        test_failed='true'
    fi

done


# Exit with error code if a single comparison test failed
if [[ "$test_failed" = 'true' ]]; then
    exit 1
fi

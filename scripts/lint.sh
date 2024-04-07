#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
cd "$PROJECT_ROOT" || exit 1

PYTHON_BINARY='diskstats.py'
BASH_BINARY='diskstats.sh'


if ! command -v mypy > /dev/null 2> /dev/null; then
    echo 'Error: Can not run mypy!' > /dev/stderr
    echo 'mypy is not installed!' > /dev/stderr
else
    echo 'Running mypy...'
    mypy $PYTHON_BINARY
fi
echo ''
echo ''


if ! command -v pylint > /dev/null 2> /dev/null; then
    echo 'Error: Can not run pylint!' > /dev/stderr
    echo 'pylint is not installed!' > /dev/stderr
else
    echo 'Running pylint...'
    pylint $PYTHON_BINARY
fi
echo ''
echo ''


if ! command -v pydoclint > /dev/null 2> /dev/null; then
    echo 'Error: Can not run pydoclint!' > /dev/stderr
    echo 'pydoclint is not installed!' > /dev/stderr
else
    echo 'Running pydoclint...'
    pydoclint $PYTHON_BINARY
fi
echo ''
echo ''


if ! command -v shellcheck > /dev/null 2> /dev/null; then
    echo 'Error: Can not run shellcheck!' > /dev/stderr
    echo 'shellcheck is not installed!' > /dev/stderr
else
    echo 'Running shellcheck...'
    shellcheck $BASH_BINARY
fi
echo ''
echo ''

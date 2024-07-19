#!/bin/bash
set -e

target='./tags'

if [ -z "$*" ]; then
    echo "usage: $0 <file_lists>"
    exit 1
fi

ctags -R --languages=C++ --fields=+aiKS --c-kinds=+p --extras=+q -o $target $*

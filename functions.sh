#!/bin/bash

export PYTHON_EGG_CACHE="/home/`whoami`/.python-eggs"

function refreshTable {
    local v_table=$1
    impala-shell -q "
    refresh $v_table;
    compute stats $v_table;
    " ||
    impala-shell -q "
    invalidate metadata $v_table;
    compute stats $v_table;
    "
}

function invalidateMetadata {
    impala-shell -q "invalidate metadata;"
}

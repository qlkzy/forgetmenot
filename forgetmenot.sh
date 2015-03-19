#!/bin/bash -e

checks='untracked'

function indent {
    sed -e 's/^/\t/'
}

function untracked {
    git ls-files --others --exclude-standard | indent
}

function status {
    if [[ "$checks" == *"untracked"* ]]; then
        untracked
    fi
}

find ~ -name '.git' -type d |
    sed -e 's/\.git$//' |
    while read x; do
        cd "$x"
        status=`status`
        if [ -n "$status" ]; then
            echo -e "$x\n$status"
        fi
    done

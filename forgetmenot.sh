#!/bin/bash -e

checks='^\(??\|A\| M| D\)'

function indent {
    sed -e 's/^/\t/'
}
p
function status {
    git status --porcelain --short | (grep "$checks" || true)
}

find ~ -name '.git' -type d |
    sed -e 's/\.git$//' |
    while read x; do
        cd "$x"
        status=`status | indent`
        if [ -n "$status" ]; then
            echo -e "$x\n$status"
        fi
    done

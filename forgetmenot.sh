#!/bin/bash -e

# checks='^\(??\|A\| M| D\)'

checks=$1
if [ -z "$checks" ]; then
    checks='untracked,added,modified,deleted'
fi

function indent {
    sed -e 's/^/\t/'
}

function status {
    git status --porcelain --short | (grep "$regex" || true)
}

function addalt {
    local re="$1"
    if [ -n "$re" ]; then
        re="$re\|"
    fi
    echo "$re$2"
}

regex=''

case $checks in
    *untracked*)
        regex=`addalt "$regex" '??'`
    ;;&
    *added*)
        regex=`addalt "$regex" 'A'`
    ;;&
    *modified*)
        regex=`addalt "$regex" ' M'`
    ;;&
    *deleted*)
        regex=`addalt "$regex" ' D'`
    ;;&
esac

regex="^\\($regex\\)"

find ~ -name '.git' -type d |
    sed -e 's/\.git$//' |
    while read x; do
        cd "$x"
        status=`status | indent`
        if [ -n "$status" ]; then
            echo -e "$x\n$status"
        fi
    done

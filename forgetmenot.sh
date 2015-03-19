#!/bin/bash -e

# checks='^\(??\|A\| M| D\)'

checks=$1
if [ -z "$checks" ]; then
    checks='untracked,added,modified,deleted,unpushed'
fi

function indent {
    sed -e 's/^/\t/'
}

function status {
    git status --porcelain --short | (grep "$regex" || true)
}

function unpushed {
    case $checks in
        *unpushed*)
            (git cherry 2>/dev/null || true) |
                cut -d' ' -f2 |
                xargs git show --oneline --quiet
            ;;
    esac
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
        status=`(status; unpushed) | indent`
        if [ -n "$status" ]; then
            echo -e "$x\n$status"
        fi
    done

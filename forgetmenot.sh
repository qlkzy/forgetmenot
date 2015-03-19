#!/bin/bash -e

checks=''
exclude=''
regex=''

while getopts c:e: opt; do
    case "$opt" in
        c)
            checks="$OPTARG"
            ;;
        e)
            exclude="$OPTARG"
            ;;
    esac
done

function main {

    if [ -z "$checks" ] || [ "$checks" == 'all' ]; then
        checks='untracked,added,modified,deleted,unpushed'
    fi

    # our default exclude pattern is 'blank lines', which won't
    # hurt anything interesting
    if [ -z "$exclude" ]; then
        exclude='^$'
    fi

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
        grep -v "$exclude" |
        while read x; do
            cd "$x"
            status=`(status; unpushed) | indent`
            if [ -n "$status" ]; then
                echo -e "$x\n$status"
            fi
        done
}


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

main

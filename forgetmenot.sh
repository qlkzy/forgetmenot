#!/bin/bash -e

function usage {
    cat <<EOF
Options:
    -c <checks>     List of checks to run, options are:
                    - 'all' [default]
                    - 'untracked'
                    - 'added'
                    - 'modified'
                    - 'deleted'
                    - 'unpushed'

                    Checks should be separated with commas or given as separate
                    -c arguments.


    -e <pattern>    Pattern for directories to exclude.
                    Should work with 'grep'.
                    Defaults to '^$' (i.e., exclude nothing)

    -d <directory>  Root directory to check from.
                    Defaults to the value of HOME.
EOF
}

checks=''
exclude=''
regex=''
dir=$HOME

while getopts :c:e:d:h opt; do
    case "$opt" in
        c)
            checks="$checks,$OPTARG"
            ;;
        e)
            exclude="$OPTARG"
            ;;
        d)
            dir="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            case "$OPTARG" in
                c)
                    echo "'-c' option requires an argument."
                    ;;
                e)
                    echo "'-e' option requires an argument."
                    ;;
                d)
                    echo "'-d' option requires an argument."
                    ;;
                *)
                    echo "Unexpected option '-$OPTARG'."
                    ;;
            esac
            usage
            exit 1
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

    if [  "x$regex" == "x" ]; then
        regex='^$'
    else
        regex="^\\($regex\\)"
    fi

    find $dir -name '.git' -type d |
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

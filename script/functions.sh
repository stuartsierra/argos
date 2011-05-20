#!/usr/bin/env bash

NETWORK="true"
WORK_DIR="./work"

function echodo {
    echo "$@"
    "$@"
    if [ "$?" != "0" ]; then
        echo "ERROR: return value $?"
    fi
}

function clone_project {
    local username="$1"
    local project="$2"
    (
        cd "$WORK_DIR"
        if [ ! -d "$project" ]; then
            echodo git clone "git://github.com/${username}/${project}.git"
        fi
    )
}

function update_git_in_project {
    git checkout master
    git pull
}

function update_deps_in_project {
    if [ -e project.clj -a "$NETWORK" = "true" ]; then
        echodo lein clean
        echodo lein deps
    fi
}

function run_tests_in_project {
    local this_dir=$(basename $(pwd))
    local mvn_opts=""
    if [ "$NETWORK" = "false" ]; then
        mvn_opts="-o"
    fi
    
    if [ -e project.clj ]; then
        echodo lein test
    elif [ -e pom.xml ]; then
        echodo mvn $mvn_opts test
    else
        echo "WARNING: Don't know how to test $this_dir"
    fi
}

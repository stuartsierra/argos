#!/usr/bin/env bash

OFFLINE="false"
WORK_DIR="./work"

function die {
    echo "$@"
    exit 1
}

function echodo {
    local cwd=$(pwd)
    echo "In $cwd"
    echo "$@"
    "$@"
    local rv="$?"
    if [ "$rv" != "0" ]; then
        echo "ERROR: exit status $? from '$@'"
    fi
    return $rv
}

function clone_project {
    local project="$1"
    local userdir=$(dirname $project)
    local my_dir="$WORK_DIR/$userdir"
    mkdir -p "$my_dir"
    (
        cd "$my_dir"
        if [ ! -d "$project" ]; then
            echodo git clone "git://github.com/${project}.git"
        fi
    )
}

function update_git {
    local project="$1"
    (
        cd "$WORK_DIR/$project"
        if [ "$OFFLINE" = "false" ]; then
            git checkout -q master
            git pull -q
        fi
    )
}

function update_deps {
    local project="$1"
    (
        cd "$WORK_DIR/$project"
        if [ -e project.clj -a "$OFFLINE" = "false" ]; then
            echodo lein clean
            echodo lein deps
        fi
    )
}

function run_tests {
    local project="$1"
    local clojure_jar="$2"
    local mvn_opts="-q"
    local rv=""

    if [ ! -z "$clojure_jar" ]; then
        mvn_opts="${mvn_opts} -Dclojure.jar=${clojure_jar}"
    fi
    if [ "$OFFLINE" = "true" ]; then
        mvn_opts="${mvn_opts} -o"
    fi

    (
        cd "$WORK_DIR/$project"
        if [ -e project.clj ]; then
            cd lib
            rm -f clojure.jar \
                clojure-?.?.?.jar \
                clojure-?.?.?-alpha?.jar \
                clojure-?.?.?-beta?.jar \
                clojure-?.?.?-master-SNAPSHOT.jar \
                clojure-?.?.?-SNAPSHOT.jar
            ln -s "${clojure_jar}" lib/clojure.jar
            echodo lein test
            rv="$?"
        elif [ -e pom.xml ]; then
            echodo mvn $mvn_opts test
            rv="$?"
        else
            echo "WARNING: Don't know how to test $project"
        fi
    )
    return $rv
}

function do_argos_project {
    local project="$1"
    update_git "$project"
    update_deps "$project"
    run_tests "$project"
}

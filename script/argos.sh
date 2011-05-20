#!/usr/bin/env bash

cd `dirname $0`/..
source script/functions.sh

function print_usage {
    cat <<EOF
Usage: $0 [options]
Options:
 -h       Print help
 -o       Offline mode; do not update dependencies
 -j file  Use file as the clojure.jar

 -p user/project
      Test only project identified by GitHub username/project-name.
      May be supplied multiple times.
EOF
}

DEFAULT_PROJECTS=$(cat projects.txt)

while getopts ":ohj:p:" opt; do
    case $opt in
        o)
            echo "OFFLINE MODE"
            OFFLINE="true"
            ;;
        j)
            CLOJURE_JAR="$OPTARG"
            ;;
        p)
            PROJECTS="$PROJECTS $OPTARG"
            ;;
        h)
            print_usage
            exit 1
            ;;
        \?)
            die "Invalid option: -$OPTARG"
            ;;
    esac
done

if [ -z "$PROJECTS" ]; then
    PROJECTS="$DEFAULT_PROJECTS"
fi

mkdir -p "$WORK_DIR"

project_count=0
failure_count=0
failed_projects=""

for project in $PROJECTS; do
    project_count=$(( $project_count + 1 ))
    echo -e "\n\n============================================================"
    clone_project "$project"
    do_argos_project "$project" "$CLOJURE_JAR"
    if [ "$?" != "0" ]; then
        failure_count=$(( $failure_count + 1 ))
        failed_projects="$failed_projects $project"
    fi
done

echo -e "\n\n============================================================"
echo "SUMMARY"
echo "Tested $project_count projects"
echo "$failure_count failures"

for project in $failed_projects; do
    echo "    $project"
done

#!/usr/bin/env bash
set -e
#corpus-drupal
PROJECTS="
corpus-django
corpus-flask
corpus-lizmap
corpus-mumble
corpus-mysql
corpus-osmdb
corpus-pgsql
corpus-zope
corpus-tilemill
corpus-tilestream
"
W=$(dirname $0)
cd $W
W=$PWD

STEPS="archive fixperms rollback notify"
MS_URL="https://raw.githubusercontent.com/makinacorpus/makina-states/stable/files/projects/2/salt"
for step in $STEPS;do
    wget --no-check-certificate "${MS_URL}/${step}.sls" -O -|grep -v "{%\s*raw"|grep -v "{%\s*endraw" > "$W/${step}.sls"
#    python -c "import time;time.sleep(0.5)"
done
for project in $PROJECTS;do
    p="$W/$project"
    echo $p
    cd "$W"
    if [ ! -d "$project" ];then
        git clone git@github.com:makinacorpus/${project}.git
    fi
    cd "$p"
    if [ -z $NO_SYNC ];then
        git fetch --all
        git reset --hard origin/master
    fi
    for step in $STEPS;do
        skip=""
        if [ "x${step}" = "fixperms" ];then
            if [ "x${project}" = "xcorpus-lizmap" ];then
                skip="1"
            fi
            if [ "x${project}" = "xcorpus-drupal" ];then
                skip="1"
            fi
        fi
        pwd
        if [ "x${skip}" = "x" ];then
            cp -fv "$W/${step}.sls" ".salt/${step}.sls"
        fi
    done
done
# vim:set et sts=4 ts=4 tw=80:

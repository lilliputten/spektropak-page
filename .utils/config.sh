#!/bin/sh
# vim: ft=sh
# @desc Config variables (common version -- stored in repository)
# @changed 2024.12.11, 03:57

IS_WINDOWS=`echo "${OS}" | grep -i windows`
IS_CYGWIN=`uname | grep -i "CYGWIN"`

# Project structure setup
BUILD_FOLDER="build"
# PUBLIC_FOLDER="public"
PUBLISH_FOLDER="publish"
PUBLISH_BRANCH="publish"
# DIST_REPO comes from the actual git configuration

VERSION_FILE="project-version.txt"
PROJECT_INFO_FILE="public/project-info.txt"
PROJECT_HASH_FILE="public/project-hash.txt"
PROJECT_INFO_JSON_FILE="src/project-info.json"
PROJECT_INFO_SCSS_FILE="src/project-info.scss"

# TODO: To use generic `init-crossplatform-command-names.sh`?
FINDCMD="find"
SORTCMD="sort"
GREPCMD="grep"
RMCMD="rm"
# # Override posix commands for cygwin or/and windows (may be overrided in `config-local.sh`, see `config-local.sh.TEMPLATE`)...
if [ "$IS_CYGWIN" ]; then
    # Don't use windows' own native commands
    which find_ > /dev/null 2>&1 && FINDCMD="find_"
    which sort_ > /dev/null 2>&1 && SORTCMD="sort_"
    which grep_ > /dev/null 2>&1 && GREPCMD="grep_"
    which rm_ > /dev/null 2>&1 && RMCMD="rm_"
fi

# Timezone for timestamps (GMT, Europe/Moscow, Asia/Bangkok, Asia/Tashkent, etc)
TIMEZONE="Europe/Moscow"

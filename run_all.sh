#!/usr/bin/env bash

blue() {
  printf "\033[94m$1\033[0m"
}

cyan() {
  printf "\033[96m$1\033[0m"
}

green() {
  printf "\033[1;32m$1\033[0m"
}

red() {
  printf "\033[31m$1\033[0m"
}

yellow() {
  printf "\033[33m$1\033[0m"
}

if [ "$1" = "-h" ]; then
  echo $(red "** Usage **")
  echo "This script will find all git repositories within the specified 'FOLDER' (defaults to current dir)"
  echo "filtered by 'FILTER' (defaults to empty string; accepts regex) and for a minimum depth of 'MINDEPTH'"
  echo "(optional; defaults to 1) and a maximum depth of 'MAXDEPTH' (optional; defaults to 3);"
  echo "and then runs the specified commands in each of those git repos."
  echo "This script is not limited to only running 'git' commands!"
  echo ""
  echo "For eg:"
  echo "   FOLDER=dev MINDEPTH=2 run_all.sh git status"
  echo "   FOLDER=dev MINDEPTH=2 run_all.sh git branch -vv"
  echo "   FOLDER=dev MINDEPTH=2 run_all.sh ls -l"
  echo "   FILTER=oss run_all.sh ls -l"
  echo "   FILTER='asdf|zsh' run_all.sh git fo"
  exit 1
fi

MINDEPTH=${MINDEPTH:-1}
MAXDEPTH=${MAXDEPTH:-3}
FOLDER=${FOLDER:-.}
FILTER=${FILTER:-}

date

echo $(yellow "Finding git repos starting in folder '${FOLDER}' for a min depth of ${MINDEPTH} and max depth of ${MAXDEPTH}")
if [ "${FILTER}" != "" ]; then
  echo $(yellow "Filtering with: ${FILTER}")
fi

# TODO: Tried to use -regex to filter out folders, but "run from any direcctory for any combination of FILTER and FOLDER is not working"
# \( ! -regex "${HOME}/.git" \) \( ! -regex "${HOME}/Library/.git" \) \( ! -regex "${HOME}/.vscode/.git" \) \( ! -regex "${HOME}/tmp/.git" \)
DIRECTORIES=$(find "${FOLDER}" -mindepth "${MINDEPTH}" -maxdepth "${MAXDEPTH}" -name ".git" -type d -prune -exec dirname {} \; 2>/dev/null | grep -iE "${FILTER}" | sort)

# I have some special repos that should not show up in this list for processing - removing them
if [[ "${FOLDER}" == "." ]] && [[ "$PWD" == "${HOME}" ]] || [[ "${FOLDER}" == "${HOME}" ]]; then
  # Note: This line will remove my repo in '~' folder
  # DIRECTORIES=$(echo "${DIRECTORIES}" | sed -E "s|^${HOME}$||" | sed -E "s|^${HOME}\/$||")
  # Note: This line will remove any entry with 'tmp' or 'Library/Cache' in the path
  DIRECTORIES=$(echo "${DIRECTORIES}" | grep -v -e tmp -e "Library/Cache")
fi

TOTAL_COUNT=$(echo "${DIRECTORIES}" | wc -w)

COUNT=1
for dir in ${DIRECTORIES}; do
  if [ -d "$dir" ] && [ ! -h "$dir" ]; then
    echo $(green ">>>>>>>>>>>>>>>>>>>>> [${COUNT} of ${TOTAL_COUNT}] '$*' (in '$dir') <<<<<<<<<<<<<<<<<<<<")
    bash -c "cd $dir; $*"
    COUNT=$((COUNT + 1))
  fi
done

date

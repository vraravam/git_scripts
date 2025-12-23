#!/usr/bin/env bash

colorize() {
  printf "\x1b[${1}m"
}

NC=$(colorize '0') # No Color
RED=$(colorize '0;31')
GREEN=$(colorize '0;32')
YELLOW=$(colorize '1;33')
BLUE=$(colorize '0;34')
CYAN=$(colorize '0;36')

blue() {
  printf "${BLUE}${1}${NC}"
}

cyan() {
  printf "${CYAN}${1}${NC}"
}

green() {
  printf "${GREEN}${1}${NC}"
}

red() {
  printf "${RED}${1}${NC}"
}

yellow() {
  printf "${YELLOW}${1}${NC}"
}

if [ "$1" = "-h" ]; then
  cat << EOF
$(red "** Usage **")
This script will find all git repositories within the specified 'FOLDER' (defaults to current dir)
filtered by 'FILTER' (defaults to empty string; accepts regex) and for a minimum depth of 'MINDEPTH'
(optional; defaults to 1) and a maximum depth of 'MAXDEPTH' (optional; defaults to 3);
and then runs the specified commands in each of those git repos.
This script is not limited to only running 'git' commands!

For eg:
  FOLDER=dev MINDEPTH=2 run_all.sh git status
  FOLDER=dev MINDEPTH=2 run_all.sh git branch -vv
  FOLDER=dev MINDEPTH=2 run_all.sh ls -l
  FILTER=oss run_all.sh ls -l
  FILTER='oss|zsh|omz' run_all.sh git fo
EOF
  exit 1
fi

MINDEPTH=${MINDEPTH:-1}
MAXDEPTH=${MAXDEPTH:-3}
FOLDER="${FOLDER:-.}"
FILTER="${FILTER:-}"

start_time=$(date +%s)
echo $(cyan "Script started at: $(date)")

echo $(yellow "Finding git repos starting in folder '${FOLDER}' for a min depth of ${MINDEPTH} and max depth of ${MAXDEPTH}")
[ "${FILTER}" != '' ] && echo $(yellow "Filtering with: ${FILTER}")

find_cmd=(
  find "${FOLDER}"
  -mindepth "${MINDEPTH}" -maxdepth "${MAXDEPTH}"
  # Exclude specific directory patterns by pruning them
  \( -path '*/tmp' -o -path '*/Library/Cache' \) -prune
  # Or (-o), find .git directories, prune them (don't descend), and print their parent directory
  -o
  \( -name ".git" -type d -prune -exec dirname {} \; \)
)

# Execute find, get parent directory, filter, and sort
mapfile -t DIR_ARRAY < <("${find_cmd[@]}" 2>/dev/null | grep -iE "${FILTER}" | sort -u)

TOTAL_COUNT=${#DIR_ARRAY[@]}

COUNT=1
for dir in "${DIR_ARRAY[@]}"; do
  if [ -d "${dir}" ] && [ ! -h "${dir}" ]; then
    echo $(green ">>>>>>>>>>>>>>>>>>>>> [${COUNT} of ${TOTAL_COUNT}] '$*' (in '${dir}') <<<<<<<<<<<<<<<<<<<<")
    # Use a subshell and "$@" for better argument handling and potentially less overhead than 'bash -c'
    (cd "${dir}" && eval "$@")
    COUNT=$((COUNT + 1))
  fi
done

end_time=$(date +%s)
echo $(cyan "Script finished at: $(date)")

duration=$((end_time - start_time))
duration_formatted=$(printf "%02d:%02d:%02d" $((duration/3600)) $((duration%3600/60)) $((duration%60)))
echo $(cyan "Total execution time: ${duration_formatted} (HH:MM:SS)")

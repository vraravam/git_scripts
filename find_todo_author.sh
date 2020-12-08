#!/usr/bin/env bash

# This script is used to find and print all the 'TODO' comments in your code along with the author's name and other relevant metadata.
# Original source from: http://jezenthomas.com/using-git-to-manage-todos/

set -e

todo_list() {
  GREP_OPTIONS='' grep -InR 'TODO' ./* \
    --exclude-dir=node_modules \
    --exclude-dir=public \
    --exclude-dir=vendor \
    --exclude-dir=compiled \
    --exclude-dir=bin \
    --exclude-dir=git-hooks
}

line_author() {
  LINE=$(line_number)
  FILE=$(file_path)
  tput setaf 6 2>/dev/null
  printf "%s" "$(git log --pretty=format:"%cN" -s -L "$LINE","$LINE":"$FILE" | head -n 1)"
  tput sgr0 2>/dev/null
}

file_path() {
  parse_line 1
}

line_number() {
  parse_line 2
}

message() {
  parse_line 3
}

parse_line() {
  printf "%s" "$todo" | cut -d':' -f "$1"
}

while IFS= read -r todo; do
  printf "%s\n" "$(file_path):$(line_number) $(line_author) $(message | xargs)"
done < <(todo_list)

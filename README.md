git_scripts
===========

These are some scripts that I use constantly when dealing with multiple git repositories.

## run_all
----------
This script is typically run from the common parent directory. Currently, they are hardcoded to -only peek into the first level of child directories-, find all directories that are git repositories and run the specified commands.

With the latest update, the `run_all` script can be configured to run against any level of subdirectory. Examples:
```bash
  run_all git status                                      # to get the git status of all git repos
  run_all git clean -fxd                                  # to clean all git repos
  run_all git remote prune origin                         # to run the git remote prune command
  run_all git add -p                                      # to add all modified (unstaged) files for a commit eventually
  run_all find . -iname patch.txt --exec rm -rfv {} \;    # find all files with the name 'patch.txt'
```

Note: Any command can be run whether they are specific to the shell that you are currently using or git commands. These commands are run within the context of each child git repository.

git_scripts
===========

These are some scripts that I use constantly when dealing with multiple git repositories.
They are typically run from the common parent directory. Currently, they are hardcoded to only peek into the first level
of child directories, find all directories that are git repositories and run the commands.


Example usage:
==============

Any command can be run whether they are specific to the shell that you are currently using or git commands. These commands are run within the context of each child git repository.
For eg, to get the git status of all git repos, I run:

run_all git status

To clean all git repos, I run:
run_all git clean -fxd

To run the git remote prune command, I run:
run_all git remote prune origin

and so on (you get the idea)

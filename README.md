forgetmenot
===========

`forgetmenot` is a small utility to check for git repositories which
have changes which are only locally visible, of a variety of
kinds. The idea is to make it easy to check, when working on many git
repositories across many machines, that the machine you are about to
shut down/travel away from/destroy does not have changes that you will
want somewhere else---for example, synchronising 'home' and 'work'
machines.

`forgetmenot` will start in a base directory (by default, your $HOME
directory), find all git repositories under that directory, and run
git on them to check for local changes and unpushed commits.

That's it. There isn't much to it.

Usage
-----

```
Options:
    -c <checks>     List of checks to run, options are:
                    - 'all' [default]
                    - 'untracked'
                    - 'added'
                    - 'modified'
                    - 'deleted'
                    - 'unpushed'

                    Checks should be separated with commas or given as separate
                    -c arguments.


    -e <pattern>    Pattern for directories to exclude.
                    Should work with 'grep'.
                    Defaults to '^$' (i.e., exclude nothing)

    -d <directory>  Base directory to check from.
                    Defaults to the value of HOME.

```

TODO
----

- It would be nice to be able to have a config file in your home
  directory to specify either repositories you always want to ignore,
  or sub-configurations, so you could say something like `forgetmenot
  work` and not get status info for all your personal projects.

- Check for bashisms for portability.

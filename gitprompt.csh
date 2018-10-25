## Put this file (gitprompt.csh) in ~/bin to work with the cshrc_git setup
setenv GIT_BRANCH_CMD "sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'"
set prompt="%~ `$GIT_BRANCH_CMD`%B%#%b "

function gs {
  git status -sb "$@"
}

function adjust_ps1 {
  perl -pe 's{(\\\$)([^\$]+?)$}{ $1 $2}s'
}

function render_ps1 {
  local ec="$?"
  
  export PS1_VAR=

  if [[ -n "${_CHM_USER:-}" ]]; then
    PS1_VAR="${_CHM_USER}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  local nm_profile="${_CHM_PROFILE:-${AWS_VAULT:-}}"
  if [[ -n "${nm_profile}" ]]; then
    if [[ -n "${AWS_VAULT_EXPIRATION:-}" ]]; then
      local time_left="$(( $(date -d "${AWS_VAULT_EXPIRATION:-}" +%s) - $(date +%s) ))"
      if [[ "${time_left}" -lt 0 ]]; then
        time_left=""
      fi
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}${time_left:+ ${time_left}}"
    else
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}"
    fi
  fi

  if [[ -n "${TMUX_PANE:-}" ]]; then
    PS1_VAR="${TMUX_PANE}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  echo
  powerline-go -error "$ec" --colorize-hostname -cwd-mode plain -mode flat -newline \
    -priority root,cwd,user,host,ssh,perms,git-branch,exit,cwd-path,git-status \
    -modules user,host,ssh,cwd,perms,gitlite,load,exit${PS1_VAR:+,shell-var --shell-var PS1_VAR} \
    -theme "$_CHM_HOME/themes/default.json"
}

function update_ps1 {
  PS1="$(render_ps1 | adjust_ps1)"
}

if tty >/dev/null; then
  if type -P powerline-go >/dev/null; then
    PROMPT_COMMAND="update_ps1"
  fi
fi

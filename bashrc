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
    PS1_VAR="${_CHM_USER%%@*}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  local nm_profile="${AWS_OKTA_PROFILE}"
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

    if [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}} ${AWS_DEFAULT_REGION}"
    fi
  fi

  if [[ -n "${TMUX_PANE:-}" ]]; then
    PS1_VAR="${TMUX_PANE}${PS1_VAR:+ ${PS1_VAR}}"
  fi

#  if [[ -f "${_CHM_HOME}/.kube/config" && -x "$(which kubectl 2>/dev/null || true)" ]]; then
#    local nm_context="$(kubectl config current-context 2>/dev/null || true)"
#    PS1_VAR="${PS1_VAR:+${PS1_VAR}}${nm_context:+ /${nm_context}}"
#  fi

  echo
  powerline-go -error "$ec" --colorize-hostname -cwd-mode plain -mode flat -newline \
    -priority root,cwd,user,host,ssh,perms,git-branch,exit,cwd-path,git-status \
    -modules user,host,ssh,cwd,perms,gitlite,load,exit${PS1_VAR:+,shell-var --shell-var PS1_VAR} \
    -theme "$_CHM_HOME/etc/themes/default.json"
}

function update_ps1 {
  PS1="$(render_ps1 | adjust_ps1)"
}

if tty >/dev/null; then
  if type -P powerline-go >/dev/null; then
    PROMPT_COMMAND="update_ps1"
  fi
fi

export EDITOR=vim

export AWS_OKTA_MFA_PROVIDER=YUBICO AWS_OKTA_MFA_FACTOR_TYPE=token:hardware

function _pwd_with_tilde
  echo $PWD | sed 's|^'$HOME'\(.*\)$|~\1|'
end

function _in_git_directory
  git rev-parse --git-dir > /dev/null 2>&1
end

function _git_branch_name_or_revision
  set -l branch (git symbolic-ref HEAD ^ /dev/null | sed -e 's|^refs/heads/||')
  set -l revision (git rev-parse HEAD ^ /dev/null | cut -b 1-7)

  if test (count $branch) -gt 0
    echo $branch
  else
    echo $revision
  end
end

function _git_upstream_configured
  git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function _git_behind_upstream
  test (git rev-list --right-only --count HEAD...@"{u}" ^ /dev/null) -gt 0
end

function _git_ahead_of_upstream
  test (git rev-list --left-only --count HEAD...@"{u}" ^ /dev/null) -gt 0
end

function _git_upstream_status
  set -l arrows

  if _git_upstream_configured
    if _git_behind_upstream
      set arrows "$arrows⇣"
    end

    if _git_ahead_of_upstream
      set arrows "$arrows⇡"
    end
  end

  echo $arrows
end

function _cmd_duration_days
  set -l days (expr $CMD_DURATION / 1000 / 60 / 60 / 24)
  if test $days -gt 0
    echo $days"d"
  end
end

function _cmd_duration_hours
  set -l hours (expr $CMD_DURATION / 1000 / 60 / 60 \% 24)
  if test $hours -gt 0
    echo $hours"h"
  end
end

function _cmd_duration_mins
  set -l minutes (expr $CMD_DURATION / 1000 / 60 \% 60)
  if test $minutes -gt 0
    echo $minutes"m"
  end
end

function _cmd_duration_secs
  set -l seconds (expr $CMD_DURATION / 1000 \% 60)
  if test $seconds -gt 0
    echo $seconds"s"
  end
end

function _cmd_duration
  set -l duration ""

  if test (expr $CMD_DURATION / 1000) -gt 5
    set duration "$duration"(_cmd_duration_days)
    set duration "$duration"(_cmd_duration_hours)
    set duration "$duration"(_cmd_duration_mins)
    set duration "$duration"(_cmd_duration_secs)
  end

  echo $duration
end

function _print_in_color
  set -l string $argv[1]
  set -l color  $argv[2]

  set_color $color
  printf $string
  set_color normal
end

function _prompt_color_for_status
  if test $argv[1] -eq 0
    echo magenta
  else
    echo red
  end
end

function fish_prompt
  set -l last_status $status

  _print_in_color "\n"(_pwd_with_tilde) blue

  if _in_git_directory
    _print_in_color " "(_git_branch_name_or_revision) 242
    _print_in_color " "(_git_upstream_status) cyan
  end

  _print_in_color " "(_cmd_duration) yellow

  _print_in_color "\n❯ " (_prompt_color_for_status $last_status)
end

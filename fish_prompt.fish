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

function _venv_is_activated
  set -q VIRTUAL_ENV  
end

function _venv_name
  basename $VIRTUAL_ENV
end

function fish_prompt
  set -l last_status $status

  _print_in_color "\n"(_pwd_with_tilde) blue

  if _in_git_directory
    _print_in_color " "(_git_branch_name_or_revision) 242
    _print_in_color " "(_git_upstream_status) cyan
  end

  printf "\n"

  if _venv_is_activated
    _print_in_color (echo "("(_venv_name)")") white
  end 
  
  _print_in_color "❯ " (_prompt_color_for_status $last_status)
end

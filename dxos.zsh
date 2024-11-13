#
# Git
#

alias gs='git-branch-select -l'
alias gb='git branch -vv'

#
# pnpm nx run-many --target=build
# pnpm -w nx build <target> --watch
#

alias pi="pnpm install"
alias pw="pnpm watch"
alias px="pnpm -w nx"
alias nx="pnpm -w nx"

# Run target in local directory (e.g., `p build`).
function p () {
  TARGET=$1
  shift 1

  px $TARGET "${PWD##*/}" "$@"
}

# Build
function pb () {
  px build "${PWD##*/}" "$@"
}

# Test
function pt () {
  px test "${PWD##*/}" "$@"
}

# Break NX cache (e.g., `pc test`).
function pc () {
  TARGET=$1
  shift 1

  px $TARGET "${PWD##*/}" "$@" "${RANDOM}"
}

# Run everything (e.g., `pa build`).
function pa () {
  TARGET=$1
  shift 1

  ROOT=$(git rev-parse --show-toplevel)
  if [ "$ROOT" = "$PWD" ]; then
    px run-many --target=$TARGET "$@"
  else;
    pushd $ROOT
    nx run-many --target=$TARGET "$@"
    popd
  fi;
}

# Build, test and lint everything.
function pre () {
  if [ "$1" = "-c" ]; then
    git clean -xdf
  fi;

  # export CI=true
  # ROOT=$(git rev-parse --show-toplevel)
  px reset

  CI=true pi
  CI=true pa build
  CI=true pa test
  CI=true pa lint
}

#
# CI monitoring the PR associated with the current branch.
# Set CIRCLECI_TOKEN
#
# Local development:
# - change .zplug/init.sh
#
# ```bash
# zplug dxos/zsh/dxos.zsh, from:local
# exec zsh
# ```
#

CIRCLECI_ORG="dxos"
CIRCLECI_REPO="dxos"

CLEAR="\033[0J"

function ci () {
  function ci_status () {
    PROJECT_SLUG="gh/$CIRCLECI_ORG/$CIRCLECI_REPO"

    # Get project.
    PROJECT_ID=$(curl -s -H "Circle-Token: $CIRCLECI_TOKEN" \
      "https://circleci.com/api/v2/project/${PROJECT_SLUG}/pipeline?branch=$(git branch --show-current)" | \
      jq -r '.items.[0].id')

    echo -e "Pipeline: $PROJECT_ID"

    # Get workflow.
    URL="https://circleci.com/api/v2/pipeline/${PROJECT_ID}/workflow"
    RESPONSE=$(curl -s -H "Circle-Token: $CIRCLECI_TOKEN" $URL)

    echo -e "$RESPONSE" | jq

    STATUS=$(echo -e "$RESPONSE" | jq -r '.items.[0].status')
    if [ "$STATUS" = "failed" ]; then
      WORKFLOW_ID=$(echo -e "$RESPONSE" | jq -r '.items.[0].id')

      # Get failed job.
      JOB_NUMBER=$(curl -s -H "Circle-Token: $CIRCLECI_TOKEN" \
        "https://circleci.com/api/v2/workflow/${WORKFLOW_ID}/job" |
        jq -r '.items | map(select(.status=="failed")) | .[0].job_number')

      URL=$(curl -s -H "Circle-Token: $CIRCLECI_TOKEN" \
        "https://circleci.com/api/v2/project/${PROJECT_SLUG}/job/${JOB_NUMBER}" | jq -r ".web_url")
    fi
  }

  while true; do
    tput sc
    ci_status
    tput rc

    case "$STATUS" in
      "running")
      ;;
      *)
        echo "${CLEAR}Result $STATUS"
        echo "$URL"
        break
      ;;
    esac
    sleep 10
  done
}

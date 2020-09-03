#!/bin/sh

set -euo pipefail

REGISTRY=${PLUGIN_REGISTRY:-}
REPO=${PLUGIN_REPO:-}

if [ "${REGISTRY}" ]; then
  IMAGE=${REGISTRY}/${REPO}
else
  IMAGE=${REPO}
fi

if [ "${PLUGIN_USERNAME:-}" ] && [ "${PLUGIN_PASSWORD:-}" ]; then
	echo "img login ${REGISTRY} -u ${PLUGIN_USERNAME} -p ${PLUGIN_PASSWORD}"
	if [ "${UNIT_TEST:-false}" != "true" ]; then
    echo $PLUGIN_PASSWORD | img login $REGISTRY -u $PLUGIN_USERNAME --password-stdin
  fi
elif [ "${PLUGIN_USERNAME:-}" ] || [ "${PLUGIN_PASSWORD:-}" ]; then
	echo "Username and Password must be provided same time" && false
fi

DOCKERFILE=${PLUGIN_DOCKERFILE:-Dockerfile}
CONTEXT=${PLUGIN_CONTEXT:-$PWD}

if [[ "${PLUGIN_DEBUG:-}" == "true" ]]; then
	DEBUG="--debug"
fi

if [[ "${PLUGIN_NO_CONSOLE:-}" == "true" ]]; then
	NO_CONSOLE="--no-console"
fi

if [[ "${PLUGIN_NO_CACHE:-}" == "true" ]]; then
	NO_CACHE="--no-cache"
fi

if [[ "${PLUGIN_AUTO_TAG:-false}" == "true" ]]; then
    tag=$(echo "${DRONE_TAG:-}" | sed 's/^v//g')
    part=$(echo "${tag}" | tr '.' '\n' | wc -l)
    # expect number
    echo ${tag} | grep -E "[a-z-]" &>/dev/null && isNum=1 || isNum=0

    if [ ! -n "${tag:-}" ]; then
        PLUGIN_TAGS="latest"
    elif [ ${isNum} -eq 1 -o ${part} -gt 3 ]; then
        PLUGIN_TAGS="${tag},latest"
    else
        major=$(echo "${tag}" | awk -F'.' '{print $1}')
        minor=$(echo "${tag}" | awk -F'.' '{print $2}')
        release=$(echo "${tag}" | awk -F'.' '{print $3}')
    
        major=${major:-0}
        minor=${minor:-0}
        release=${release:-0}
    
        PLUGIN_TAGS="${major}.${minor}.${release},${major}.${minor},${major},latest"
    fi  
fi

if [ -n "${PLUGIN_TAGS:-}" ] && [ -n "${REPO:-}" ]; then
    TAGS=$(echo "${PLUGIN_TAGS}" | tr ',' '\n' | while read tag; do echo "--tag=${IMAGE}:${tag} "; done)
elif [ -f .tags ] && [ -n "${REPO:-}" ]; then
    TAGS=$(cat .tags | tr ',' '\n' | while read tag; do echo "--tag=${IMAGE}:${tag} "; done)
elif [ -n "${REPO:-}" ]; then
    TAGS="--tag=${IMAGE}:latest"
else
    TAGS="--tag=none"
fi

CMD="img build \
    --file=${DOCKERFILE} \
    ${TAGS} \
    ${CONTEXT} \
    ${DEBUG:-} \
    ${NO_CACHE:-} \
    ${NO_CONSOLE:-}"

if [ "${UNIT_TEST:-false}" == "true" ]; then
  echo $CMD
else
  exec $CMD
fi

if [ "$TAGS" != "--tag=none" ]; then
  echo "$TAGS" | sed "s/--tag=//" | \
  while read tag; do
    CMD="img push \
        ${tag} \
        ${DEBUG:-} \
        ${NO_CONSOLE:-}"

    if [ "${UNIT_TEST:-false}" == "true" ]; then
      echo $CMD
    else
      exec $CMD
    fi
  done
fi

#!/bin/sh

__run() {
  actual=$(env UNIT_TEST=true $1 ./plugin.sh)
  echo $actual > .actual
  echo $2 > .expected
  cmp -s .actual .expected

  if [ $? != 0 ]; then
    echo "Failed:"
    echo -e "\tActual:\t\t\"$actual\""
    echo -e "\tExpected:\t\"$2\""
    exit 1
  fi

  rm .actual .expected
}

# Test Case 1
env=''
output='img build --file=Dockerfile --tag=none /drone/src'
__run "$env" "$output"
echo "Success"

# Test Case 2
env='PLUGIN_REPO=test_repo PLUGIN_USERNAME=test_username PLUGIN_PASSWORD=test_password PLUGIN_AUTO_TAG=true DRONE_TAG=1.2.3 PLUGIN_NO_CONSOLE=true'
output='img login  -u test_username -p test_password
img build --file=Dockerfile --tag=test_repo:1.2.3 --tag=test_repo:1.2 --tag=test_repo:1 --tag=test_repo:latest /drone/src --no-console
img push test_repo:1.2.3 --no-console
img push test_repo:1.2 --no-console
img push test_repo:1 --no-console
img push test_repo:latest --no-console'
__run "$env" "$output"
echo "Success"

# Test Case 3
env='PLUGIN_REGISTRY=test_registry PLUGIN_REPO=test_repo PLUGIN_USERNAME=test_username PLUGIN_PASSWORD=test_password PLUGIN_TAGS=test_tags PLUGIN_DEBUG=true'
output='img login test_registry -u test_username -p test_password
img build --file=Dockerfile --tag=test_registry/test_repo:test_tags /drone/src --debug
img push test_registry/test_repo:test_tags --debug'
__run "$env" "$output"
echo "Success"

# Test Case 4
env='PLUGIN_REGISTRY=test_registry PLUGIN_REPO=test_repo PLUGIN_USERNAME=test_username PLUGIN_PASSWORD=test_password PLUGIN_CONTEXT=test_context PLUGIN_DOCKERFILE=test_Dockerfile PLUGIN_NO_CACHE=true'
output='img login test_registry -u test_username -p test_password
img build --file=test_Dockerfile --tag=test_registry/test_repo:latest test_context --no-cache
img push test_registry/test_repo:latest'
__run "$env" "$output"
echo "Success"

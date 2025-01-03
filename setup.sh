#!/bin/sh

#If your host OS env is linux : linux
#If your host OS env is linux : wsl
HOST_OS_ENV="linux"

if [${HOST_OS_ENV} = "linux"]; then
  docker compose -f compose.yml up -d
elif [${HOST_OS_ENV} = "wsl"]; then
  docker compose -f compose.wsl.yml up -d
else
  echo "${HOST_OS_ENV} is not defined in the setup.bash script"
fi
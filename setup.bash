#!/bin/bash

#If your host OS env is linux : linux
#If your host OS env is linux : wsl
HOST_OS_ENV="linux"

if [$HOST_OS_ENV = "linux"]; then
    compose -f compose.yml up -d
elif [$HOST_OS_ENV = "wsl"]; then
    compose -f compose.wsl.yml up -d
fi
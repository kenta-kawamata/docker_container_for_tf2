#!/bin/sh

#If your host OS env is ubuntu : ubuntu
#If your host OS env is wsl : wsl
HOST_OS_ENV="linux"

#If文においては必ず[の次に空白を設けること
#[も含め文字列として認識される
if [ ${HOST_OS_ENV} = "linux" ]; then
  docker compose -f compose.yml up -d
elif [ ${HOST_OS_ENV} = "wsl" ]; then
  docker compose -f compose.wsl.yml up -d
else
  echo "${HOST_OS_ENV} is not defined in the setup.bash script"
fi

# ホストからアクセス可能とする
# https://zenn.dev/ykesamaru/articles/add7d844f56516
xhost +local:
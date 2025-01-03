# docker cotainer for tensorflow2

## コンテナ環境

|||
|:-----:|:-----:|
|os|Ubuntu20.04|
|CUDA|11.2.2|
|cudnn|8.1.0.77-1|
|TensorFlow|2.11.0|

## 動作確認したホストOS環境

|||
|:-----:|:-----:|
|os|Ubuntu20.04|
|nvidia-driver|535.183.01|

## How to Start

```
$ ./setup.sh
$ docker compose exec -it tf2110-cu112-cd81-py38 /bin/bash
```

or

```
$ docker compose up -f compose.yml -d
$ docker compose exec -it tf2110-cu112-cd81-py38 /bin/bash
```

## How to use jupyter notebook

Run in the container

```
# jupyter notebook --port=8887 --ip=0.0.0.0 --allow-root --NotebookApp.token=''
```

Connect to `http://localhost:8888` in the browser.

### 起動中のプロセスを表示

```
$ docker-compose top
```

### dockerfileでイメージを作成

```
$docker build -f <Docker file name> -t <image name> .
```

`-f`: Dockerfileを指定するオプション 
`-t`: image名を指定するオプション

### docker-composeで作成したコンテナ,イメージ,プロジェクトをすべて削除

```
$docker-compose down --rmi all --volumes --remove-orphans
```

### 作成したdocker containerに入る方法

```
$docker-compose exec <service name> bash
```

サービス名は,カレントディレクトリ名か,またはdocker-composeで設定したもの.

### docker-composeを使用してimageを作成する場合

```
$docker-compose build <service name>
```

上記コマンドでimageを作成する場合,  
image名はdocker-compose.ymlに記入したimage名で作成される.

サービス名を指定しないと,カレントディレクトリ名が
デフォルトでサービス名にされる.

ビルドするカレントディレクトリ（コンテクスト）名を変更した場合,
もう一度上記のコマンドを実行してリビルドする必要がある.
リビルドしないと,docker-composeのコマンドを実行した際,
ビルド時に定義されたコンテクストから各種ファイルを参照しようとするので,
実行に失敗する他,コンテナも探し出せなくなる(要検証).



### 参考

[Markdown記法](https://qiita.com/Qiita/items/c686397e4a0f4f11683d#blockquotes---%E5%BC%95%E7%94%A8)

[tensorflow公式docker環境](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/dockerfiles)

[docker-composeで作成したコンテナ,イメージ,プロジェクトの削除](https://qumeru.com/magazine/620)

[wsl2-docker-gui](https://github.com/0V/gpu-wslg)

[docker-compose build](http://docs.docker.jp/compose/reference/build.html)

[docker-composeのProjectという概念について](https://szk416.hatenablog.com/entry/20190209/1549706748)

[docker-compose サービス名の一覧を取得する](https://qiita.com/ucan-lab/items/e64cebd3f7d062124f6b)

[docker-compose.ymlのbuild設定はとりあえずcontextもdockerfileも埋めとけって話](https://qiita.com/sam8helloworld/items/e7fffa9afc82aea68a7a)
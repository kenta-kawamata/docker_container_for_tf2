#ディスプレイ設定

Dockerコンテナ環境で  
matplotlibなどのグラフを可視化する際,  
X Windowの設定が必要.  

'''
# export DISPLAY=:0.0
'''

予めDockerfileまたはdocker-compose.ymlに書き込んでおくと良い.

###参考



[WSLでGUIアプリを実行する](https://qiita.com/ryoma-jp/items/bff539d8b060a0ff84cc)

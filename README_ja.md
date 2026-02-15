# はじめに
本リポジトリではOpen OnDemandを用いて計算ノード上で動作する対話アプリケーションをまとめています。
すべてのアプリケーションはLinuxコンテナであるSingularityを利用して実行されます。
SingularityイメージのOSはRocky Linux 9.7、対応アーキテクチャはx86_64とaarch64です。

本リポジトリでは、対話アプリケーションは「可視化アプリケーション」と「開発アプリケーション」に分類しています。
提供しているアプリケーションは下記の通りです。

## 可視化アプリケーション
| 名前 | x86_64 | aarch64 | 説明 |
| --- | --- | --- | --- |
| [Gnuplot](http://www.gnuplot.info/) | 5.4.3 | 5.4.3 | コマンドライン駆動型グラフ作成プログラム |
| [ParaView](https://www.paraview.org/) | 6.0.1 | 5.11.1 | 科学技術データ可視化プログラム |
| [XCrySDen](http://www.xcrysden.org/) | 1.6.3 | 1.6.3 | 結晶構造や分子構造などの可視化プログラム |
| [PyMOL](https://www.pymol.org/) | 2.5.0 | 2.5.0 | 生体高分子の立体構造などび可視化・解析プログラム |
| [GrADS](http://opengrads.org/) | 2.2.3 | - | 気象・気候分野の格子点データの可視化・解析プログラム |
| [VisIt](https://visit-dav.github.io/visit-website/) | 3.4.2 | - | 様々な科学データ形式に対応した可視化・解析プログラム |
| [VESTA](https://jp-minerals.org/vesta/jp/) | 3.5.8 | - | 結晶構造や電子・核密度等の三次元データなどの可視化プログラム |
| [Smokeview](https://pages.nist.gov/fds-smv/) | 6.10.6 | - | [FDS](https://pages.nist.gov/fds-smv/)や[CFAST](https://pages.nist.gov/cfast/index.html)の結果を表示するための可視化プログラム |
| [OVITO](https://www.ovito.org/) | 3.14.1 | - | 粒子シミュレーションなどの大規模データの可視化・解析プログラム |
| [ImageJ](https://imagej.net/ij/) | 1.54 | - | Javaの仮想マシン上で動作する画像処理ソフトウェア |

## 開発アプリケーション
| 名前 | x86_64 | aarch64 | 説明 |
| --- | --- | --- | --- |
| [Desktop (Xfce)](https://www.xfce.org/) | 4.18 | 4.18 | X Window System上で動作する軽量デスクトップ環境 |
| [VSCode](https://code.visualstudio.com/) | 4.108.2 | 4.108.2 | [Microsoft](https://www.microsoft.com/)が開発しているコードエディタ |
| [JupyterLab](https://jupyter.org/) | 4.5.3 | 4.5.3 | Webブラウザ上で動作するプログラムの対話型実行環境 |
| [ttyd](https://github.com/tsl0922/ttyd) | 1.7.7 | 1.7.7 | ターミナルをWebブラウザ経由で操作できるコマンドラインツール |

# 利用方法
## リポジトリのダウンロード
本リポジトリを`/var/www/ood/apps/sys/`に保存します。
```bash
$ cd /var/www/ood/apps/sys
$ sudo git clone https://github.com/OpenOnDemandJP/oodjp_apps.git
```

## Singularityイメージの作成
計算ノードのアーキテクチャがx86_64の場合は`containers/rocky97_x86_64.def`を、aarch64の場合は`containers/rocky97_aarch64.def`を使ってSingularityイメージを作成します。
コマンドは下記の通りです。
実行時間は、サーバやネットワークのスペックによりますが、約20分です。

### x86_64の場合
```bash
$ singularity build --fakeroot rocky97_x86_64.sif rocky97_x86_64.def
```

### aarch64の場合
```bash
$ singularity build --fakeroot rocky97_aarch64.sif rocky97_aarch64.def
```

## 設定ファイルの編集
`/var/www/ood/apps/sys/oodjp_apps/utils/config.yml`を利用環境に合わせて編集します。利用しないアーキテクチャの設定は無視されるので、変更する必要はありません。
  - `xdg_data_home`：アプリケーションデータの保存用ディレクトリ
  - `container_image`：Singularityイメージのパス
```yaml
xdg_data_home:
  x86_64:  "<%= ENV['HOME'] %>/ondemand/x86_64"
  aarch64: "<%= ENV['HOME'] %>/ondemand/aarch64"

container_image:
  x86_64:  /cloud_opt/ondemand/rocky97_x86_64.sif
  aarch64: /cloud_opt/ondemand/rocky97_aarch64.sif
```

## アプリケーションをOpen OnDemandに登録
利用したい対話アプリケーションのシンボリックリンクを`/var/www/ood/apps/sys/`に作ります。下記は`Desktop`の例です。

```bash
$ cd /var/www/ood/apps/sys/
$ sudo ln -s oodjp_apps/apps/Desktop .
```

次にアプリケーションの設定ファイルを編集します。記法の詳細は下記にリンクしたOpen OnDemandのマニュアルを参照ください。
- `Desktop/manifest.yml`：[マニュアル](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/manifest.html)
- `Desktop/form.yml.erb`：[マニュアル](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/form.html)
- `Desktop/submit.yml.erb`：[マニュアル](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/submit.html)

## 動作確認
`sample_images/`内のデータを用いてください。詳細は[sample_images/README.md](./sample_images/README.md)を参照してください。

# Note
- Singularityコンテナとホストとでは、開発環境が異なることに注意してください。特に開発アプリケーションを使用する場合、Singularityコンテナとホストの開発環境を揃えた方が便利です。そのためには、適切なディレクトリのbind設定に加え、ホストの環境変数を引き継ぐ必要がありますが、それでも開発環境を完全に揃えることは難しいです。可能な場合は、開発アプリケーションをホストにインストールし、Singularityを使用せずにOpen OnDemandから利用することを推奨します。
- aarch64版のSingularityコンテナでは、SBSA（Server Base System Architecture）の`nvidia-driver-libs`を利用しています。このコンテナをSBSAでないサーバで利用したい場合は、`nvidia-driver-libs`を利用しないコンテナを作成してください。
- ttydはSafari Webブラウザでは動作しません（[参照](https://github.com/tsl0922/ttyd/issues/1437)）。
- ttydにおいて、ターミナルマルチプレクサとしてtmuxを使っていますが、GNU Screenなども使うことも可能です。複数のターミナルマルチプレクサを選択できるようにすると便利かもしれません。

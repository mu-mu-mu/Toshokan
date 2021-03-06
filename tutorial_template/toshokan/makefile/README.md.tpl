# Makefileの意味

## binutils
Makefileの解説に入る前に、`bin`以下の各実行形式ファイルについて解説します。

これらの実行形式ファイルの実体はシェルスクリプトで、binutils系ツールを容易にコンテナ内で実行するためのラッパーです。各々のスクリプトは`base`を呼び出すようになっており、`base`が実際のコンテナの起動を行います。

機能としては、Linuxにおけるbinutilsコマンド群とほぼ等価です。

## コンパイル

コンパイルは以下のステップで行われます。全ステップにおいて、`bin`以下の実行ファイルを用います。（即ち、コンテナ内で全て処理されます）

1. friendバイナリのコンパイル
1. friendバイナリをhakaseバイナリへ埋め込むためにオブジェクト化
1. friendバイナリからシンボルテーブルを抽出し、symファイル化
1. 上記３つとhakaseソースコードを合わせてhakaseバイナリを作成

hakaseバイナリにはfriendバイナリが埋め込まれており、hakaseバイナリ単体だけで、friendバイナリのロードと起動が可能です。

## 実行
1. コンテナ間ネットワークを作成
1. QEMUコンテナを作成、QEMU（仮想マシン）を起動
1. QEMU上のLinuxのrsyncサーバーの準備が完了するまで待機
1. hakaseバイナリをQEMU上のLinuxへrsyncで転送
1. QEMU上のLinuxへssh接続し、hakaseバイナリを起動

![](./img1.svg)

## サンプル
今回はディレクトリ内にサンプルを添付していません。適当なディレクトリ内のMakefileを参照してみてください。
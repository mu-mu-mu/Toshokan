{% import 'macro.tpl' as helper %}
# 実機実行

## サンプル
今回はディレクトリ内にサンプルを添付していません。適当なディレクトリ内のサンプルで試してください。

## 実機側の準備
事前準備として、以下が必要です。

- 物理マシン上への比較的新しいLinuxのインストール
- カーネルモジュールビルド環境の整備
- root権限を持つアカウントの作成
- GRUBの設定
- FriendLoaderコンパイル環境の整備
- 稼働させたいToshokanシステムと同一バージョンのFriendLoaderのインストール

### 物理マシン上への比較的新しいLinuxのインストール
カーネルモジュールはLinux 4.14.34上で動作する事を確認済みです。それ以前のバージョンではカーネルモジュールのコンパイルに失敗する可能性があるので、必ずバージョンを確認してください。

また、以降の具体的な手順はUbuntuの場合を掲載しています。他のディストリビューションでは一部手順が異なる可能性がありますが、適宜読み替えてください。

### カーネルモジュールビルド環境の整備

Ubuntuでは以下のコマンドでインストール可能です。

```
# apt install -y linux-headers-`uname -r` gcc make
```

### root権限を持つアカウントの作成
省略

### GRUBの設定
friend用のメモリを確保するため、カーネル起動オプションを設定してください。GRUB2の場合は以下のようになります。

```
// /etc/default/grub
// GRUB_CMDLINE_LINUX_DEFAULTが空でない場合は、良しなに追記する事
GRUB_CMDLINE_LINUX_DEFAULT="memmap=0x70000\\\$4K memmap=0x40000000\\\$0x40000000 "
```

以下の通り、編集した設定を反映させてください。grub-mkconfig等でも同様の事ができます。

```
# update-grub
```

Toshokanを物理マシン上で動かす場合、grubの選択画面の中で以下の起動オプションが設定されている物を選択するのを忘れないでください。

### FriendLoaderコンパイル環境の整備
FriendLoaderをコンパイルするためには、一般的なカーネルモジュールコンパイル環境に加え、以下が必要となります。

- scons (> 3.0)
- python (> 2.5)

パッケージマネージャ等でインストールしてください。

### 稼働させたいToshokanシステムと同一バージョンのFriendLoaderのインストール
Toshokanのソースコードを取得し、コンパイル、インストールします。必ず、 **稼働させたいToshokanシステムと同一バージョン** のソースを準備してください。そうでない場合、正常に動作しない可能性があります。

```
$ git clone https://github.com/PFLab-OS/Toshokan.git
```

ブランチを切り替える事で、目的のバージョンのソースが見つかるはずです。

以下のコマンドでFriendLoaderのビルド、及びカーネルモジュールの有効化が行われます。

```
$ scons rmmod
$ scons insmod
```

上記のコマンドは、必ずroot権限を持ったアカウント上で行ってください。また、再起動後に自動でFriendLoaderが読み込まれる事は無いので、注意してください。

カーネルモジュールのビルドのみの場合は、以下の通りです。
```
$ scons FriendLoader_local/friend_loader.ko
```

## 手元マシン側での準備・実行

- 対象となる物理マシンにsudo権限付きでssh可能なアカウントを作成
- ホスト名のみでsshできるよう、configを設定

実行方法は以下のとおりです。
```
$ make host=XXX
```
XXXはconfig内で設定したターゲットホスト名です。

`host=XXX`を指定しないと、qemu上でToshokanが起動します。

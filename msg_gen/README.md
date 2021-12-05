# msg_gen

![img](doc/design.drawio.svg)


ROS2 が生成するメッセージ定義パッケージを入力としてD言語向けにメッセージ型を定義したDUBパッケージを生成するツール。入力情報は `package.xml` 及び `*.idl` ファイル。以下のようなルールで生成する。

- DUB パッケージ名 : `package.xml` に記載されているパッケージ名
- msg 定義 : `source/<pkg_name>/msg.d` に全て定義
- srv 定義 : `source/<pkg_name>/srv.d` に全て定義 (未実装)
- action 定義 : `source/<pkg_name>/action.d` に全て定義(未実装)
- 各メッセージ定義の typesupport_c 連携も生成

## 使い方

```shell
# generate dub packages from ros2 message packages under AMENT_PREFIX_PATH
dub run ros2_d:msg_gen -- <outdir>
```

※ライブラリとしても使うことができる。

{% import 'build_misc/macro.tpl' as helper %}
# ページフォルト

今回は、[割り込み、例外](../../interrupt/)の知識が必要です。割り込みの基本を簡単に理解してから読んでください。

{{ helper.sample_info() }}

今回のサンプルでは、コンソールから1-2を入力する事により、異なるサンプルコードを実行できます。以下の説明に対応するサンプルを実行してください。

## 1. ページ設定されていないアドレスへのアクセス
仮想アドレスから物理アドレスの変換時に、関連するページテーブルのエントリが設定されていなかった場合、当然ですが変換はできません。CPUは変換失敗を検出し、「ページフォルト」という例外を発行します。サンプルで実際に試してみましょう。

このサンプルでは「敢えて」仮想アドレス0x80000000（vaddr）に対応するページテーブルエントリに0を書いておきます。

```cc
  // friend.cc
  pt.entry[(vaddr % k2MB) / k4KB] = 0;
```

その後、vaddrにアクセスします。

```cc
  // friend.cc
  uint64_t x = *((uint64_t *)vaddr); // page fault may happen
```

サンプル1では、int_handler1（int.Sで定義）がページフォルトハンドラに設定されており、このハンドラは何もせずに終了します。もちろん、ページフォルトの原因である、ページテーブルの未設定は解消されず、再度ページフォルトが発生します。（ページフォルトの無限ループ）

実際にそのようになるでしょうか？実行してみて、QEMUのモニタからRIPの位置を調べてみてください。（RIPは例外ハンドラ内か、例外発生箇所のどちらかを指しているはず）

## 2. ページフォルトの解消
サンプル２ではint_handler2をページフォルトハンドラに設定してみます。（もちろん、それ以外の部分は変えずに）

このint_handler2が何をやっているか解説します。

```asm
	// int.S
int_handler2:
	pushq %rax
	pushq %rbx
	movabsq $pt_entry, %rax
	movq (%rax), %rax  // store page table entry address to rax
	movabsq $(0x100000000UL | (1 << 0) | (1 << 1) | (1 << 2)), %rbx // store page table entry to rbx
	movq %rbx, (%rax) // set page table entry
	movq $0x80000000, %rax
	invlpg (%rax) // clear TLB entry
	popq %rbx
	popq %rax
	add  $8, %rsp // to remove error code
	iretq
```

まず、`pushq %rax` `pushq %rbx`と`popq %rax` `popq %rbx`では、rax,rbxレジスタを一時的に保存、再読み込みしています。割り込みハンドラ内ではレジスタの値を破壊してはいけないからです（破壊してしまうと復帰後に影響が出る）。次に、pt_entryから編集すべきページテーブルエントリのアドレスを取得します。pt_entryの値は以下のように初期化されています。

```cc
// friend.cc
  pt_entry = &pt.entry[(vaddr % k2MB) / k4KB]; // set page table entry address
```

pt_entryからエントリアドレスを取得したら、`0x100000000 | (1 << 0) | (1 << 1) | (1 << 2)`（指し示す先のページの物理アドレス＋α）をエントリに設定します。その後、`invlpg`命令でvaddrの仮想アドレスのページキャッシュを更新したらおしまいです。

さあ、今度はページフォルトから復帰し、処理を問題無く続行できるでしょうか？試してみてください。

## 今回のまとめ
- CPUのアドレス変換時に未設定のページテーブルエントリを参照すると、ページフォルト例外が発生する。
- 問題のページテーブルエントリを設定すると、ページフォルト例外から復帰できる。
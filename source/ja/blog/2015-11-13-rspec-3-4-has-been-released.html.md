---
title: RSpec 3.4 がリリースされました！
author: Yuji Nakayama
---

RSpec 3.4 がリリースされました！
私たちは [semantic versioning](http://semver.org/) に準拠する方針を掲げているため、
このリリースはすでに RSpec 3 を使っている方にとってなにか対応が必要になるものではありません。
しかし、もし私たちがバグを作り込んでしまっていた場合は教えてください。
できるだけ早く修正をし、パッチ版をリリースします。

RSpec は世界中のコントリビュータと共に、コミュニティ主導のプロジェクトであり続けます。
今回のリリースには、50 人近くのコントリビュータによる 500 以上のコミットと 160 以上の pull request が含まれています！

このリリースに向けて力になってくれたみなさん、ありがとう！

## 主要な変更

### Core: Bisect アルゴリズムの改善

[RSpec 3.3](/blog/2015/06/rspec-3-3-has-been-released/#core-bisect) では、
実行順序依存の失敗の原因を探す上で、
失敗を再現する最小限のコマンドを特定するための `--bisect` オプションを導入しました。
このときの二分アルゴリズムは単純な並び替えによる方法であり、
各ラウンドごとに、
まず最初の半分の example 群を試し、次にもう一方の半分、そしてそれら example 群の半分ずつの各組み合わせ、
という流れを、確実に無視できる半分を見つけるまで繰り返すものでした。
この方法は大抵の場合は問題ありませんでしたが、最悪のケースではひどい挙動を示すことがありました。
具体的には、実行順序依存の原因として _複数の_ example が関わっていた場合、
それら原因の example 群をすべて含んだ多数の組み合わせが発生してしまうことがありました。
さらに、残り半分以上の example 群が原因だった場合はすべての組み合わせを網羅的に試そうとし、
非常に長時間かかってしまうこともありました。

RSpec 3.4 では、この二分アルゴリズムは _はるかに_ 賢くなりました。
新しいアルゴリズムは再帰ベースになり、最小の試行回数で原因を特定します。
この新しいアルゴリズムはすでに非常に良い反響を得ており、
Sam Livingston-Gray は [3.3 の二分アルゴリズムは一晩中かかっても終わらない](https://twitter.com/geeksam/status/656858995932573697)と報告していましたが、
新しいアルゴリズムでは [20 分足らずで完了した](https://twitter.com/geeksam/status/656949626495328256)とのことです！

これを実装してくれた Simon Coffey、ありがとう！
もしこのアルゴリズムについてもっと知りたい場合は、
[こちらの pull request](https://github.com/rspec/rspec-core/pull/1997) を参照してください。
アルゴリズムの理解に役立つ図も載っています。

### Core: 失敗時の出力の改善

RSpec は失敗時のわかりやすいログ出力をこれまでずっと重要視してきましたが、
3.4 では様々な方法によってさらに改善されました。

#### 複数行のコードスニペット

RSpec は、エクスペクテーションが失敗したときにそのコードスニペットを表示します。
RSpec 3.4 以前では、エクスペクテーションが1行に収まっている場合は問題ありませんでしたが、
以下のように複数行で記述した場合、

~~~ ruby
expect {
  MyNamespace::MyClass.some_long_method_name(:with, :some, :arguments)
}.to raise_error(/some error snippet/)
~~~

最初の1行目（`expect {`）しか表示されませんでした。
なぜなら例外オブジェクトには、スタックフレームとしてそれだけの情報しか含まれていないからです。
RSpec 3.4 では、
標準ライブラリの [Ripper](http://ruby-doc.org/stdlib-2.2.0/libdoc/ripper/rdoc/Ripper.html) が利用可能な場合はそれを読み込み、
ソースをパースして問題のエクスペクテーションの式が何行続くかを判断するようになりました。
上記のような複数行のケースでは、式全体が表示されるようになります。

また、これに伴う設定オプション `config.max_displayed_failure_line_count` も追加されており、
表示されるスニペットの最大行数を設定することができます（デフォルトで 10）。

これを[実装](https://github.com/rspec/rspec-core/pull/2083)してくれた Yuji Nakayama、ありがとう！

#### `coderay`がインストール済みの場合、シンタックスハイライトが有効に

これをさらに一歩進めて、[`coderay`](http://coderay.rubychan.de/) gem がインストールされている場合、
RSpec 3.4 はコードスニペットのシンタックスハイライトを行うようになりました。
前述のスニペットの場合、こんな感じで表示されます。

![Failure with syntax highlighting](/images/blog/multiline_failure_with_syntax_highlighting.png)

#### 失敗元の行の検出の改善

RSpec は、例外のスタックトレース中から適切なフレームを調べることで、失敗の元となったコードスニペットを探し出します。
これを行う上で、単純にスタックトレースの一番上のフレームを使うこともできますが、
それは大抵の場合あなたが求めているものではありません。
例えばエクスペクテーションが失敗した場合は、
一番上のフレームは常に RSpec 内の `RSpec::Expectations::ExpectationNotMetError` が発生した箇所になりますが、
あなたが知りたいのは RSpec 内のコードではなく、spec ファイル中で `expect` を呼び出している箇所でしょう。
RSpec 3.4 以前のこの実装はかなり単純で、
現在実行中の example が含まれている spec ファイル内の一番最初のスタックフレームを探すだけでした。
そのため、場合によっては間違ったスニペットを表示してしまうことがありました
（例えば spec ファイル内から、`spec/support` 以下で定義されたヘルパーメソッドを呼び出しており、本当はそこで失敗していた場合）。
また、該当するスタックフレームを見つけられなかった場合は
`Unable to find matching line from backtrace` と表示するしかありませんでした。

RSpec 3.4 ではこのロジックが改善され、
まずは `config.project_source_dirs`（デフォルトで `lib`、`app`、`spec`）に含まれる最初のフレームを探し、
もし該当するフレームが見つからなかった場合は一番最初のスタックフレームにフォールバックします。
もう `Unable to find matching line from backtrace` が表示されることはありません！

### Expectations: 複合エクスペクテーションの失敗時メッセージの改善

さらに失敗時出力の改善が続きます。
rspec-expectations 3.4 では、複合エクスペクテーション（_compound expectations_）の失敗メッセージが改善されました。
これまでは複数の失敗メッセージを単純に1行に連結しており、例えば以下のようなエクスペクテーションの場合、

~~~ ruby
expect(lyrics).to start_with("There must be some kind of way out of here")
              .and include("No reason to get excited")
~~~

このような読みにくいメッセージが出力されてしまっていました。

~~~
1) All Along the Watchtower has the expected lyrics
   Failure/Error: expect(lyrics).to start_with("There must be some kind of way out of here")
     expected "I stand up next to a mountain And I chop it down with the edge of my hand" to start with "There must be some kind of way out of here" and expected "I stand up next to a mountain And I chop it down with the edge of my hand" to include "No reason to get excited"
   # ./spec/example_spec.rb:20:in `block (2 levels) in <top (required)>'
~~~

RSpec 3.4 では、それぞれのメッセージが個別に表示されるようになり、読みやすくなりました。

~~~
1) All Along the Watchtower has the expected lyrics
   Failure/Error:
     expect(lyrics).to start_with("There must be some kind of way out of here")
                   .and include("No reason to get excited")

        expected "I stand up next to a mountain And I chop it down with the edge of my hand" to start with "There must be some kind of way out of here"

     ...and:

        expected "I stand up next to a mountain And I chop it down with the edge of my hand" to include "No reason to get excited"
   # ./spec/example_spec.rb:20:in `block (2 levels) in <top (required)>'
~~~

### Expectations: `match` マッチャへの `with_captures` の追加

RSpec 3.4 では、`match` マッチャに新しい機能が追加され、正規表現のキャプチャを指定することができるようになりました。
新しい `with_captures` メソッドを使って、このようにインデックスベースのキャプチャを指定することができます。

~~~ ruby
year_regex = /(\d{4})\-(\d{2})\-(\d{2})/
expect(year_regex).to match("2015-12-25").with_captures("2015", "12", "25")
~~~

また、名前付きキャプチャを指定することも可能です。

~~~ ruby
year_regex = /(?<year>\d{4})\-(?<month>\d{2})\-(?<day>\d{2})/
expect(year_regex).to match("2015-12-25").with_captures(
  year: "2015",
  month: "12",
  day: "25"
)
~~~

Sam Phippen と、この実装にあたって協力してくれた Jason Karns、ありがとう。

### Rails: ActiveJob のための新しい `have_enqueued_job` マッチャ

Rails 4.2 には ActiveJob が組み込まれました。
rspec-rails 3.4 では、任意のコードがジョブをキューに加えることを指定するためのマッチャが追加されました。
このマッチャはメソッドチェーンによるインターフェースを持っており、
rspec-mock を使ったことがあれば見覚えがあるのではないでしょうか。

~~~ ruby
expect {
  HeavyLiftingJob.perform_later
}.to have_enqueued_job

expect {
  HelloJob.perform_later
  HeavyLiftingJob.perform_later
}.to have_enqueued_job(HelloJob).exactly(:once)

expect {
  HelloJob.perform_later
  HelloJob.perform_later
  HelloJob.perform_later
}.to have_enqueued_job(HelloJob).at_least(2).times

expect {
  HelloJob.perform_later
}.to have_enqueued_job(HelloJob).at_most(:twice)

expect {
  HelloJob.perform_later
  HeavyLiftingJob.perform_later
}.to have_enqueued_job(HelloJob).and have_enqueued_job(HeavyLiftingJob)

expect {
  HelloJob.set(wait_until: Date.tomorrow.noon, queue: "low").perform_later(42)
}.to have_enqueued_job.with(42).on_queue("low").at(Date.tomorrow.noon)
~~~

この機能を実装してくれた Wojciech Wnętrzak、ありがとう！

## 統計

### 全体:

* **総コミット**: 502
* **マージされた pull request**: 163
* **48 コントリビュータ**: Aaron Kromer, Alex Dowad, Alex Egan, Alex Pounds, Andrew Horner, Ara Hacopian, Ashley Engelund (aenw / weedySeaDragon), Ben Woosley, Bradley Schaefer, Brian John, Bryce McDonnell, Chris Zetter, Dan Kohn, Dave Marr, Dennis Günnewig, Diego Carrion, Edward Park, Gavin Miller, Jack Scotti, Jam Black, Jamela Black, Jason Karns, Jon Moss, Jon Rowe, Leo Cassarani, Liz Rush, Marek Tuchowski, Max Meyer, Myron Marston, Nikki Murray, Pavel Pravosud, Sam Phippen, Sebastián Tello, Simon Coffey, Tim Mertens, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, Zshawn Syed, bennacer860, bootstraponline, draffensperger, georgeu2000, jackscotti, mrageh, rafik, takiy33, unmanbearpig

### rspec-core:

* **総コミット**: 180
* **マージされた pull request**: 52
* **24 コントリビュータ**: Aaron Kromer, Alex Pounds, Ashley Engelund (aenw / weedySeaDragon), Ben Woosley, Bradley Schaefer, Brian John, Edward Park, Gavin Miller, Jack Scotti, Jon Moss, Jon Rowe, Leo Cassarani, Marek Tuchowski, Myron Marston, Sebastián Tello, Simon Coffey, Tim Mertens, Yuji Nakayama, bennacer860, bootstraponline, draffensperger, jackscotti, mrageh, takiy33

### rspec-expectations:

* **総コミット**: 93
* **マージされた pull request**: 34
* **17 コントリビュータ**: Aaron Kromer, Alex Egan, Bradley Schaefer, Brian John, Dennis Günnewig, Jason Karns, Jon Moss, Jon Rowe, Max Meyer, Myron Marston, Nikki Murray, Sam Phippen, Xavier Shay, Yuji Nakayama, Zshawn Syed, mrageh, unmanbearpig

### rspec-mocks:

* **総コミット**: 77
* **マージされた pull request**: 26
* **12 コントリビュータ**: Aaron Kromer, Alex Dowad, Alex Egan, Brian John, Bryce McDonnell, Jon Moss, Jon Rowe, Liz Rush, Myron Marston, Pavel Pravosud, Sam Phippen, georgeu2000

### rspec-rails:

* **総コミット**: 97
* **マージされた pull request**: 31
* **16 コントリビュータ**: Aaron Kromer, Alex Egan, Ara Hacopian, Bradley Schaefer, Brian John, Chris Zetter, Dan Kohn, Dave Marr, Diego Carrion, Jam Black, Jamela Black, Jon Moss, Jon Rowe, Myron Marston, Nikki Murray, Wojciech Wnętrzak

### rspec-support:

* **総コミット**: 55
* **マージされた pull request**: 20
* **10 コントリビュータ**: Aaron Kromer, Alex Egan, Andrew Horner, Bradley Schaefer, Brian John, Jon Rowe, Myron Marston, Xavier Shay, Yuji Nakayama, rafik

## ドキュメント

### API ドキュメント

* [rspec-core](/documentation/3.4/rspec-core/)
* [rspec-expectations](/documentation/3.4/rspec-expectations/)
* [rspec-mocks](/documentation/3.4/rspec-mocks/)
* [rspec-rails](/documentation/3.4/rspec-rails/)

### Cucumber フィーチャ

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## リリースノート

### rspec-core 3.4.0
[すべての Changelog](http://github.com/rspec/rspec-core/compare/v3.3.2...v3.4.0)

改善:

* 複数の `--pattern` オプションが指定されたとき、それらを統合して `--pattern=1,2,...,n` と等価に扱うようにしました。
  (Jon Rowe, #2002)
* `RSpec::Core::Example` オブジェクトの `inspect` と `to_s` の出力を、Ruby 標準の冗長過ぎる出力を置き換えることで改善しました。
  (Gavin Miller, #1922)
* `silence_filter_announcements` 設定オプションを追加しました。
  (David Raffensperger, #2007)
* `Reporter` プロトコルに、example の実行結果にかかわらず常に呼び出される `example_finished` 通知（optional）を追加しました。
  (Jon Rowe, #2013)
* `--bisect` を並べ替えベースのアルゴリズムから再帰ベースに変更しました。
  これによって、失敗する example が他の複数の example 群に依存にしているケースによりうまく対応できるようになり、
  最小限の組み合わせに到達するまでの実行回数も減りました。
  (Simon Coffey, #1997)
* 単純なフィルタ（`:symbol` キーのみ）が、真 (truthy) と評価された場合にも適用されるようになりました。
  (Tim Mertens, #2035)
* Windows で RSpec の `--color` オプションを使った場合に表示される、`ansicon` についての不要な警告を削除しました。
  (Ashley Engelund, #2038)
* RSpec が警告を表示しようとしたときに例外を発生させるためのオプションを追加しました。
  (Jon Rowe, #2052)
* 失敗やエラーの元となった `cause` が存在している場合、それを出力に含めるようにしました。
  (Adam Magan)
* `NoMemoryError`、`SignalExcepetion`、`Interrupt`、`SystemExit` を rescue しないようにしました。
  これらに干渉するのは危険なためです。
  (Myron Marston, #2063)
* バックトレースがあなたのプロジェクト由来なのか外部ライブラリ由来なのかを RSpec が判断するための
  `config.project_source_dirs` 設定を追加しました。
  デフォルトで `spec`、`lib`、`app` が設定されていますが変更可能です。
  (Myron Marston, #2088)
* 失敗元の行の検出を、spec ファイル内だけでなくプロジェクトディレクトリ全体から探すように改善しました。
  さらにプロジェクトディレクトリ内で該当の行が見つからなかった場合は、
  バックトレースの1番目の行にフォールバックします。
  これによって "Unable to find matching line from backtrace" というメッセージが表示されることは事実上なくなります。
  (Myron Marston, #2088)
* 失敗時の出力に追加して表示される `:extra_failure_lines` メタデータを追加しました。
  (bootstraponline, #2092)
* メタデータをコピーしながら新しい example を生成するための
  `RSpec::Core::Example#duplicate_with` を追加しました。
  (bootstraponline, #2098)
* example グループが作成されたときに呼び出されるフックを登録するための
  `RSpec::Core::Configuration#on_example_group_definition` を追加しました。
  (bootstraponline, #2094)
* example グループの example 群を操作するための `add_example` と `remove_example` を
  `RSpec::Core::ExampleGroup` に追加しました。
  (bootstraponline, #2095)
* Ripper が利用可能な場合、複数行の失敗したソースを表示できるようにしました（MRI >= 1.9.2 と、JRuby >= 1.7.5 && < 9.0.0.0.rc1）。
  (Yuji Nakayama, #2083)
* `max_displayed_failure_line_count` 設定オプション（デフォルト 10）を追加しました。
  (Yuji Nakayama, #2083)
* `fail_fast` オプションを拡張し、指定した回数（例: `--fail-fast=3`）だけ失敗が発生した後に中断することができるようになりました。
  (Jack Scotti, #2065)
* POSIX システム上で、`color` が有効化されていて、`coderay` gem がインストールされている場合、
  失敗したスニペットがシンタックスハイライトされるようになりました。
  (Myron Marston, #2109)

バグ修正:

* 複数のプロセスが `example_status_persistence_file` が読み書きしようとしたときに競合が発生しないよう、ロックを行うようにしました。
  (Ben Woosley, #2029)
* 3.3 において、ファイル名に角括弧が含まれている spec ファイル（例えば `1[]_spec.rb`）が読み込まれなくなったバグを修正しました。
  (Myron Marston, #2041)
* Ruby 1.9.3 における ASCII リテラル由来の出力エンコーディングの問題を修正しました。
  (Jon Rowe, #2072)
* 何人かのユーザに確認された、`rspec/core/rake_task.rb` が重複 require を行ってしまう問題を修正しました。
  (Myron Marston, #2101)

### rspec-expectations 3.4.0
[すべての Changelog](http://github.com/rspec/rspec-expectations/compare/v3.3.1...v3.4.0)

改善:

* MRI 1.9において、`RSpec::Matchers` がサブクラスにすでに include された後にスーパークラスにも include された場合、
  警告を行うようになりました。その状況で `super` を使うと無限再帰が発生してしまうためです。
  (Myron Marston, #816)
* `NoMemoryError`、`SignalExcepetion`、`Interrupt`、`SystemExit` を rescue しないようにしました。
  これらに干渉するのは危険なためです。
  (Myron Marston, #845)
* [match マッチャ]((https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/match-matcher))で文字列に対して正規表現をマッチさせるとき、
  期待するキャプチャを指定するための `#with_captures` を追加しました。
  (Sam Phippen, #848)
* 複合エクスペクテーションの失敗メッセージ群を常に複数行で表示するようにしました。
  それらをすべて1行で表示するのはあまり読みやすくなかったためです。
  (Myron Marston, #859)

バグ修正:

* 動的な predicate マッチャにおいて、オブジェクトがその predicate メソッドに応答しない場合、
  失敗メッセージ出力にそのオブジェクトの `to_s` を利用しないように改善しました。
  例えばオブジェクトが `nil` だった場合、空文字列ではなく `"nil"` が表示されるようになります。
  (Myron Marston, #841)
* `#each` がそのオブジェクト自身を含む Enumerable オブジェクトを diff しようとした場合に、
  SystemStackError が発生していた問題を修正しました。
  (Yuji Nakayama, #857)

### rspec-mocks 3.4.0
[すべての Changelog](http://github.com/rspec/rspec-mocks/compare/v3.3.2...v3.4.0)

改善:

* `expect(...).to have_received` が rspec-expectations に依存せず利用できるようになりました。
  (Myron Marston, #978)
* `nil` に対してエクスペクテーションを設定した場合にテストを失敗させるオプションを追加しました。
  (Liz Rush, #983)

バグ修正:

* 対象のメソッドに渡されたブロックが`have_received { ... }` のブロックに渡されるように修正をしました。
  (Myron Marston, #1006)
* `respond_to?` をスタブしている場合にエラー出力時に無限ループになってしまうのを修正しました。
  (Alex Dowad, #1022)
* Ruby 1.8.7 において、サブクラスのクラスメソッドに対して `receive` を使ったときに発生していた問題を修正しました。
  (Alex Dowad, #1026)

### rspec-rails 3.4.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.3.3...v3.4.0)

改善:

* `have_rendered` マッチャがリダイレクトレスポンスによって失敗したときのメッセージを改善しました。
  (Alex Egan, #1440)
* 各種 Rails gem をバックトレースからフィルターするための設定オプションを追加しました。
  (Bradley Schaefer, #1458)
* 大幅な速度改善のために view spec で resolver cache を有効化しました。
  (Chris Zetter, #1452)
* ブロックがジョブをキューに追加したかどうかを確認するための `have_enqueued_job` マッチャを追加しました。
  (Wojciech Wnętrzak, #1464)

バグ修正:

* spec が作成された後で rspec-rails が読み込まれた場合に、
  "undefined method `fixture_path`" エラーが発生してしまう、ロード順の問題を修正しました。
  (Nikki Murray, #1430)
* rspec-rails 自身の `lib` コードをバックトレースから除外するためのパターンが、
  不適切に空白で囲われてしまっていたのを削除しました。
  (Jam Black, #1439)

### rspec-support 3.4.0
[すべての Changelog](http://github.com/rspec/rspec-support/compare/v3.3.0...v3.4.0)

改善:

* `Delegator` ベースのオブジェクト（例: `SimpleDelgator`）が失敗時メッセージやdiffで表示されたときのフォーマットを改善しました。
  (Andrew Horner, #215)
* `ComparableVersion` を追加しました。
  (Yuji Nakayama, #245)
* `Ripper`がサポートされているか検出する機能を追加しました。
  (Yuji Nakayama, #245)

バグ修正:

* JRubyのバグとして、`attr_writer` によって生成されたメソッドがパラメータを持たないと報告する問題に対処しました。
  RSpec の検証付きダブルで writer メソッドをモックやスタブした時に、間違って失敗してしまっていたためです。
  (Myron Marston, #225)

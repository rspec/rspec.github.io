---
title: RSpec 3.5 がリリースされました！
author: Sam Phippen, Myron Marston, Jon Rowe and Yuji Nakayama
---

RSpec 3.5 がリリースされました！
私たちは [semantic versioning](http://semver.org/) に準拠する方針を掲げているため、
このリリースはすでに RSpec 3 を使っている方にとってなにか対応が必要になるものではありません。
しかし、もし私たちがバグを作り込んでしまっていた場合は教えてください。
できるだけ早く修正をし、パッチ版をリリースします。

RSpec は世界中のコントリビュータと共に、コミュニティ主導のプロジェクトであり続けます。
今回のリリースには、50 人以上のコントリビュータによる 600 以上のコミットと 150 以上の pull request が含まれています！

このリリースに向けて力になってくれたみなさん、ありがとう！

## 主要な変更

### Core: `config.when_first_matching_example_defined`

一部の spec でしか使わないセットアップロジックを `spec_helper.rb` に書くことは、基本的におすすめしません。
そうすることで、単独の spec を実行する際の起動時間を短縮できるからです。
そういったセットアップロジックは `spec/support` ディレクトリに入れることができます。
そしてそれを必要とする spec ファイルでは、まずサポートファイルを require し、example group にタグをつけることで、
関連付けられたフックやモジュールを include することができます。

~~~ ruby
require 'support/db'

RSpec.describe SomeClassThatUsesTheDB, :db do
  # ...
end
~~~

この方法は上手くいきます。しかし、require と `:db` タグの両方が必要になるのは最適な方法ではないかもしれません。
その DB を利用するすべての spec において、毎回重複が発生してしまうからです。
また、もしその DB を使う spec に `require 'support/db'` を書き忘れてしまった場合、
その spec ファイル単体で実行すると失敗するけれども、
すべての spec を実行した場合にはパスする、
というような状況が起こりえます（他の spec ファイルがサポートファイルを読み込むので）。

RSpec 3.5 では、こういった状況で上手く使える新しいフックを導入しました。
`support/db` を必要とするすべての spec ファイルでそれを require する代わりに、
`:db` タグがついた example が定義されたタイミングでそれを自動的に読み込むように設定できます。

~~~ ruby
RSpec.configure do |config|
  config.when_first_matching_example_defined(:db) do
    require 'support/db'
  end
end
~~~

この新しい `when_first_matching_example_defined` フックは、
一致するメタデータを持つ最初の example が定義されたタイミングで発火し、
メタデータを基に必要なものを読み込むように設定できます。
もちろん、この仕組みは他にもいろいろな使い道があると思いますが、
これが私たちの想定している主なユースケースの一つです。

### Core: `config.filter_run_when_matching`

RSpec のメタデータの一般的な使い方の一つとして、focus フィルタがあります。
RSpec 3.5 以前では、このように focus フィルタを設定していたでしょう。

~~~ ruby
RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
~~~

そして、example か example group に `:focus` タグをつけることで、RSpec にそれらのみを実行させることができます。
`run_all_when_everything_filtered = true` オプションは、
`:focus` タグがついたものが何もない場合に RSpec にこのフィルタを無視させるために使います。

しかしながら、`run_all_when_everything_filtered` は（`:focus` フィルタだけでなく）
_すべての_ フィルタに適用されるため、場合によっては予想外の挙動が発生してしまうことがあります
（例えば[この issue](https://github.com/rspec/rspec-core/issues/1920)）。
この問題に関して、私たちは `:focus` を _条件付きの_ フィルタとしてセットアップできれば上手くいくと考え、
RSpec 3.5 では以下のように設定できるようにしました。

~~~ ruby
RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
~~~

この設定を使うと、`:focus` タグのついた example か example group が一つ以上存在する場合にのみ、
`:focus` フィルタが有効になります。また、以前より短く、シンプルな設定になります！

### Core: コマンドラインで指定された順番で spec ファイルを読み込むように

RSpec 3.5 では、コマンドライン引数で渡された順番で spec ファイルやディレクトリを読み込むようになりました。
これによって、その場で簡単に順序を指定することができるようになります。
例えばその場で一度だけ、高速なユニット spec を、時間のかかる受け入れ spec の前に実行したいという場合、
このように RSpec を実行します。

~~~
$ rspec spec/unit spec/acceptance --order defined
~~~

この `--order defined` オプションは、
あなたのプロジェクトでデフォルトの実行順序をランダムに設定（推奨）している場合にのみ必要になります。

### Core: Shared example group の include 方式の変更

これまで RSpec は shared context という概念
（任意のコンテキスト用のヘルパーメソッドやフックを共通化するための shared example group）
をサポートしてきました。
Shared context はこんな風に定義します。

~~~ ruby
RSpec.shared_context "DB support" do
  let(:db) { MyORM.database }

  # それぞれの example をトランザクションで囲う
  around do |ex|
    db.transaction(:rollback => :always, &ex)
  end

  # SQL 文がどの example から発行されたのかわかるように
  # 開始/終了メッセージを DB のログに出力する
  before do |ex|
    db.logger.info "Beginning example: #{ex.metadata[:full_description}"
  end
  after do |ex|
    db.logger.info "Ending example: #{ex.metadata[:full_description}"
  end
end
~~~

この shared context を使うには、任意の example group で `include_context` を使って include します。

~~~ ruby
RSpec.describe MyModel do
  include_context "DB support"
end
~~~

また、 メタデータによって _暗黙的に_ shared context を include する方法もあります。

~~~ ruby
RSpec.shared_context "DB support", :db do
  # ...
end

# ...

RSpec.describe MyModel, :db do
  # ...
end
~~~

この方法はまあまあ上手くいきます。しかし、いくつかの問題がありました。

* `shared_context` の第一引数（`"DB support"`）は、そのグループが何のためのものかというラベルでしかない（コメントと大差ない）。
* メタデータが shared example group の場合だけ特別に扱われ、通常の example group のように単純にそのグループに適用されない、
  という挙動に対して、予想外だという意見がこれまで挙がってきていた。
* Shared example group を include した側の example group に対して自動的に適用されるようなメタデータを付与することが不可能だった。
  例えば、一時的に `:skip` や `:focus` メタデータを、include した側の example group に自動的に適用する、ということができない。
* Shared example group を、すべての example group に自動的に include する明確な方法がなかった
  （例えば、グローバルな `before` フックや `let` をあらゆる場所で利用可能にするなど）。
* モジュールの include 方式と一貫性がなかった（例: `config.include DBSupport, :db`）。

RSpec 3.5 では、いくつかの変更によってこれらの問題に対処しました。

#### 新しい API: `config.include_context`

`RSpec.configure` ブロック内で、shared context の include 定義ができるようになりました。

~~~ ruby
RSpec.configure do |config|
  config.include_context "DB support", :db
end
~~~

これは、モジュールを include するための既存の `config.include` API と一貫しており、
メタデータを基に shared context を include するためのわかりやすい方法を提供します。
さらに、shared context をすべての example group に include することもできます（メタデータ引数を省略すれば良いだけ）。

#### 新しい設定: `config.shared_context_metadata_behavior`

Shared context のメタデータの挙動を変更するための設定も追加されました。

~~~ ruby
RSpec.configure do |config|
  config.shared_context_metadata_behavior = :trigger_inclusion
  # または
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
~~~


The former value (`:trigger_inclusion`) is the default and exists only for backwards
compatibility. It treats metadata passed to `RSpec.shared_context` exactly how it was
treated in RSpec 3.4 and before: it triggers inclusion in groups with matching metadata.
We plan to remove support for it in RSpec 4.

The latter value (`:apply_to_host_groups`) opts-in to the new behavior. Instead of
triggering inclusion in groups with matching metadata, it applies the metadata to host
groups.  For example, you could focus on all groups that use the DB by tagging your
shared context:

前者（`:trigger_inclusion`）はデフォルトの挙動であり、後方互換性のためだけに存在しています。
この場合、`RSpec.shared_context` に渡されたメタデータは
RSpec 3.4 までと同様
（shared example group が、一致するメタデータを持つ example group に include されるように）に扱われます。
この挙動は RSpec 4 で廃止する予定です。

後者（`:apply_to_host_groups`）は、新しい挙動を有効にするためのものです。
この場合、`RSpec.shared_context` に渡されたメタデータは、
include した側の example group に適用されるようになります。
例えば DB shared context に `:focus` タグをつけることによって、
それに依存するすべての example group のみを実行することができます。

~~~ ruby
RSpec.shared_context "DB support", :focus do
  # ...
end
~~~

### Expectations: `respond_to` マッチャのキーワード引数サポート

キーワード引数が Ruby の安定した言語機能となってしばらく経ちましたが、
これまで RSpec の多くのマッチャにおいて、キーワード引数に対するエクスペクテーションを設定することができませんでした。

rspec-expectations 3.5 では、
オブジェクトが任意のメソッドに応答するかどうかを、キーワード引数を使って検証できるようになりました。
メソッドが任意のキーワード引数を受け取るかどうかや、通常引数のカウントを検証することができます。

~~~ ruby
expect(my_object).to respond_to(:find).with_keywords(:limit, :offset) }
expect(my_object).to respond_to(:find).with(1).argument.and_keywords(:limit, :offset)
~~~

さらに、幅のある引数カウントや、無限に引数を受け取れるかどうかも検証できます。

~~~ ruby
expect(my_object).to respond_to(:build).with(2..3).arguments
expect(my_object).to respond_to(:build).with_unlimited_arguments
~~~

これを実装してくれた Rob Smith、ありがとう。

### Expectations: Minitest 5.6+ のサポート

rspec-expectations は通常、rspec-core と一緒に使われますが、
他のテストフレームワークで使うことも簡単にできます。
Minitest とのインテグレーションも提供しており、
Minitest 自身を読み込んだ後に rspec-expectations の Minitest サポートを読み込むことで利用できます。

~~~ ruby
require 'rspec/expectations/minitest_integration'
~~~

しかし Minitest は、バージョン 5.6 においてそれ自身の `expect` メソッドを導入したため、
RSpec の `expect` と衝突し、このインテグレーションが壊れてしまいました。
rspec-expectations 3.5 にはこのための修正が含まれています。

### Mocks: Minitest インテグレーションの追加

私たちは以前から rspec-expectations の Minitest インテグレーションを提供していましたが、
rspec-mocks に関しては同レベルの簡単なインテグレーションを提供してきませんでした。
そのため、これまでユーザーは rspec-mocks のライフサイクルフックを使って Minitest と統合する必要がありました。
これは Minitest 5.6 で前述の `expect` メソッドが追加され、それによって動作が壊れるまでは問題なく動いていました。
rspec-mock 3.5 では、ファーストクラスの Minitest サポートを提供します。
これを利用するには、ただインテグレーションファイルを require するだけです。

~~~ ruby
require 'rspec/mocks/minitest_integration'
~~~

### Rails: Rails 5 のサポート

今回の重大ニュースは、RSpec 3.5.0 が Rails 5 をサポートしたという点です。
私たちは、Rails 5 のベータや RC がリリースされると共に、並行して RSpec 3.5.0 のベータをリリースしてきました。
これは Rails のメジャーリリースなため、RSpec が使っているいくつかの API が deprecared 扱いになりましたが、
RSpec 3.5 はメジャーリリースではなく、私たちのユーザーに影響するのはコントローラーテストのみです。

[Rails 5](https://github.com/rails/rails/issues/18950) では、
`assigns` と `assert_template` が soft deprecated になりました。
コントローラーテスト自身は deprecated _にはなっておらず_、
`:type => controller` メタデータを spec に指定するのは未だ完全にサポートされています。
Rails 3 と 4 において、controller spec の `assigns` は慣用されてきました。
今回の RSpec 3.5 はマイナーリリースであり、私たちは SemVer に準拠する以上、
既存の controller spec を壊さないようにしています。
既存の Rails アプリケーションで `assigns` を多用しているものについては、
[`rails-controller-testing`](https://github.com/rails/rails-controller-testing) gem
を Gemfile に追加することで `assigns` と `assert_template` を復活させることができます。
RSpec はこの gem とシームレスに連携するため、controller spec は問題なく動作し続けるはずです。

これから新しく作成する Rails アプリケーションについては、
`rails-controller-testing` gem を追加するのはおすすめしません。
Rails チームや RSpec コアチームとしては、代わりに
[request spec](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec)
を書くことを推奨します。
Request spec は一つのコントローラーアクションにフォーカスしますが、
controller spec とは違い、ルーターやミドルウェアスタック、Rack リクエストやレスポンスも関与します。
これによって、より現実に近い環境でテストを実行し、controller spec で発生しがちな多くの問題を避けることができます。
Rails 5 では、request spec が Rails 4までの request spec や controller spec よりもかなり高速になっています。
これは Rails チームの [Eileen Uchitelle](https://twitter.com/eileencodes)[^foot_1] のおかげです。

他の Rails 5 の重要な機能としては ActionCable があります。
残念ながら、RSpec は今のところ ActionCable をちゃんとテストするための方法を提供できていません。
Rails 側では、Rails 5.1 でリリース予定の ActionCable のための新しいテストタイプに取り組んでいます。
私たちは常にそれを注視し、準備ができた時には RSpec 側でも取り掛かる予定です。
それまでの間は、統合テスト的にブラウザー経由で ActionCable をテストすることをおすすめします。

Rails 5 の成果には RSpec コアチームメンバーによる貢献が含まれており、
また私たちも Rails コアチームに大きく助けられました。
このリリースに向けて力になってくれたみなさんに感謝します。

## Stats


### Combined:

* **Total Commits**: 625
* **Merged pull requests**: 192
* **62 contributors**: Aaron Stone, Ahmed AbouElhamayed, Al Snow, Alex Altair,
  Alexander Skiba, Alireza Bashiri, Andrew Kozin (aka nepalez), Andrew White,
Anton Rieder, Ben Saunders, Benjamin Quorning, Bradley Schaefer, Bruno Bonamin,
DarthSim, David Rodríguez, Diogo Benicá, Eliot Sykes, Fernando Seror, Gautam
Sawhney, Isaac Betesh, James Coleman, Joe Rafaniello, John Schroeder, Jon Moss,
Jon Rowe, Jun Aruga, Kilian Cirera Sant, Koen Punt, Liss McCabe, Marc Ignacio,
Martin Emde, Matt Jones, Michele Piccirillo, Miklos Fazekas, Myron Marston,
Patrik Wenger, Perry Smith, Peter Swan, Prem Sichanugrist, Rob, Rob Smith, Ryan
Beckman, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev, Simon
Coffey, Thomas Hart II, Timo Schilling, Tobias Bühlmann, Travis Grathwell,
William Jeffries, Wojciech Wnętrzak, Xavier Shay, Yoshihiro Ashida, Yuji
Nakayama, Zshawn Syed, chrisarcand, liam-m, mrageh, sleepingkingstudios, yui-knk

### rspec-core:

* **Total Commits**: 194
* **Merged pull requests**: 66
* **18 contributors**: Alexander Skiba, Alireza Bashiri, Benjamin Quorning,
  Bradley Schaefer, Jon Moss, Jon Rowe, Matt Jones, Michele Piccirillo, Myron
Marston, Patrik Wenger, Perry Smith, Sam Phippen, Simon Coffey, Thomas Hart II,
Travis Grathwell, Yuji Nakayama, mrageh, yui-knk

### rspec-expectations:

* **Total Commits**: 83
* **Merged pull requests**: 25
* **14 contributors**: Alex Altair, Ben Saunders, Benjamin Quorning, Bradley
  Schaefer, James Coleman, Jon Rowe, Myron Marston, Rob Smith, Sam Phippen,
William Jeffries, Yuji Nakayama, Zshawn Syed, chrisarcand, sleepingkingstudios

### rspec-mocks:

* **Total Commits**: 82
* **Merged pull requests**: 28
* **17 contributors**: Andrew Kozin (aka nepalez), Benjamin Quorning, Bradley
  Schaefer, Bruno Bonamin, David Rodríguez, Isaac Betesh, Joe Rafaniello, Jon
Rowe, Kilian Cirera Sant, Marc Ignacio, Martin Emde, Myron Marston, Patrik
Wenger, Ryan Beckman, Sam Phippen, Tobias Bühlmann, Yuji Nakayama

### rspec-rails:

* **Total Commits**: 185
* **Merged pull requests**: 47
* **31 contributors**: Ahmed AbouElhamayed, Al Snow, Andrew White, Anton Rieder,
  Benjamin Quorning, Bradley Schaefer, DarthSim, David Rodríguez, Diogo Benicá,
Eliot Sykes, Fernando Seror, Gautam Sawhney, John Schroeder, Jon Rowe, Jun
Aruga, Koen Punt, Liss McCabe, Miklos Fazekas, Myron Marston, Peter Swan, Prem
Sichanugrist, Rob, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev,
Timo Schilling, Wojciech Wnętrzak, Xavier Shay, Yoshihiro Ashida, Yuji Nakayama

### rspec-support:

* **Total Commits**: 81
* **Merged pull requests**: 26
* **8 contributors**: Aaron Stone, Bradley Schaefer, Jon Rowe, Myron Marston,
  Sam Phippen, Yuji Nakayama, liam-m, sleepingkingstudios

## Docs

### API Docs

* [rspec-core](/documentation/3.5/rspec-core/)
* [rspec-expectations](/documentation/3.5/rspec-expectations/)
* [rspec-mocks](/documentation/3.5/rspec-mocks/)
* [rspec-rails](/documentation/3.5/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### RSpec Core (combining all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta4...v3.5.0)

Enhancements:

* Include any `SPEC_OPTS` in reproduction command printed at the end of
  a bisect run. (Simon Coffey, #2274)

Bug Fixes:

* Handle `--bisect` in `SPEC_OPTS` environment variable correctly so as
  to avoid infinite recursion. (Simon Coffey, #2271)

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:

* Filter out bundler stackframes from backtraces by default, since
  Bundler 1.12 now includes its own frames in stack traces produced
  by using `bundle exec`. (Myron Marston, #2240)
* HTML Formatter uses exception presenter to get failure message
  for consistency with other formatters. (@mrageh, #2222)
* Load spec files in the order of the directories or files passed
  at the command line, making it easy to make some specs run before
  others in a one-off manner.  For example, `rspec spec/unit
  spec/acceptance --order defined` will run unit specs before acceptance
  specs. (Myron Marston, #2253)
* Add new `config.include_context` API for configuring global or
  filtered inclusion of shared contexts in example groups.
  (Myron Marston, #2256)
* Add new `config.shared_context_metadata_behavior = :apply_to_host_groups`
  option, which causes shared context metadata to be inherited by the
  metadata hash of all host groups and examples instead of configuring
  implicit auto-inclusion based on the passed metadata. (Myron Marston, #2256)

Bug Fixes:

* Fix `--bisect` so it works on large spec suites that were previously triggering
  "Argument list too long errors" due to all the spec locations being passed as
  CLI args. (Matt Jones, #2223).
* Fix deprecated `:example_group`-based filtering so that it properly
  applies to matching example groups. (Myron Marston, #2234)
* Fix `NoMethodError` caused by Java backtraces on JRuby. (Michele Piccirillo, #2244)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Add new `config.filter_run_when_matching` API, intended to replace
  the combination of `config.filter_run` and
  `config.run_all_when_everything_filtered` (Myron Marston, #2206)

Bug Fixes:

* Use the encoded string logic for source extraction. (Jon Rowe, #2183)
* Fix rounding issue in duration formatting helper. (Fabersky, Jon Rowe, #2208)
* Fix failure snippet extraction so that `def-end` snippets
  ending with `end`-only line can be extracted properly.
  (Yuji Nakayama, #2215)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Remove unneeded `:execution_result` example group metadata, saving a
  bit of memory. (Myron Marston, #2172)
* Apply hooks registered with `config` to previously defined groups.
  (Myron Marston, #2189)
* `RSpec::Core::Configuration#reporter` is now public API under SemVer.
  (Jon Rowe, #2193)
* Add new `config.when_first_matching_example_defined` hook. (Myron
  Marston, #2175)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.4.4...v3.5.0.beta1)

Enhancements:

* Add `RSpec::Core::ExampleGroup.currently_executing_a_context_hook?`,
  primarily for use by rspec-rails. (Sam Phippen, #2131)

Bug Fixes:

* Ensure `MultipleExceptionError` does not contain a recursive reference
  to itself. (Sam Phippen, #2133)


### RSpec Expectations (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta4...v3.5.0)

**No user facing changes since beta4**

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta3...v3.5.0.beta4)

Bug Fixes:

* Fix `include` matcher so that it provides a valid diff for hashes. (Yuji Nakayama, #916)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Make `rspec/expectations/minitest_integration` work on Minitest::Spec
  5.6+. (Myron Marston, #904)
* Add an alias `having_attributes` for `have_attributes` matcher.
  (Yuji Nakayama, #905)
* Improve `change` matcher error message when block is mis-used.
  (Alex Altair, #908)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Add the ability to raise an error on encountering false positives via
  `RSpec::Configuration#on_potential_false_positives = :raise`. (Jon Rowe, #900)
* When using the custom matcher DSL, support new
  `notify_expectation_failures: true` option for the `match` method to
  allow expectation failures to be raised as normal instead of being
  converted into a `false` return value for `matches?`. (Jon Rowe, #892)

Bug Fixes:

* Allow `should` deprecation check to work on `BasicObject`s. (James Coleman, #898)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.4.0...v3.5.0.beta1)

Enhancements:

* Make `match_when_negated` in custom matcher DSL support use of
  expectations within the match logic. (Chris Arcand, #789)

Bug Fixes:

* Return `true` as expected from passing negated expectations
  (such as `expect("foo").not_to eq "bar"`), so they work
  properly when used within a `match` or `match_when_negated`
  block. (Chris Arcand, #789)

### RSpec Mocks (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta4...v3.5.0)

Enhancements:

* Provides a nice string representation of
  `RSpec::Mocks::MessageExpectation` (Myron Marston, #1095)

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:

* Add `and_throw` to any instance handling. (Tobias Bühlmann, #1068)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Issue warning when attempting to use unsupported
  `allow(...).to receive(...).ordered`. (Jon Rowe, #1000)
* Add `rspec/mocks/minitest_integration`, to properly integrate rspec-mocks
  with minitest. (Myron Marston, #1065)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Improve error message displayed when using `and_wrap_original` on pure test
  doubles. (betesh, #1063)

Bug Fixes:

* Fix issue that prevented `receive_message_chain(...).with(...)` working
  correctly on "any instance" mocks. (Jon Rowe, #1061)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.4.1...v3.5.0.beta1)

Bug Fixes:

* Allow `any_instance_of(...).to receive(...)` to use `and_yield` multiple
  times. (Kilian Cirera Sant, #1054)
* Allow matchers which inherit from `rspec-mocks` matchers to be used for
  `allow`. (Andrew Kozin, #1056)
* Prevent stubbing `respond_to?` on partial doubles from causing infinite
  recursion. (Jon Rowe, #1013)
* Prevent aliased methods from disapearing after being mocked with
  `any_instance` (regression from #1043). (Joe Rafaniello, #1060)

### RSpec Support (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta4...v3.5.0)

**No user facing changes since beat4**

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:
* Improve `MethodSignature` to better support keyword arguments. (#250, Rob Smith).

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta2...v3.5.0.beta3)

Bug Fixes:

* Fix `EncodedString` to properly handle the behavior of `String#split`
  on JRuby when the string contains invalid bytes. (Jon Rowe, #268)
* Fix `ObjectFormatter` so that formatting objects that don't respond to
  `#inspect` (such as `BasicObject`) does not cause `NoMethodError`.
  (Yuji Nakayama, #269)
* Fix `ObjectFormatter` so that formatting recursive array or hash does not
  cause `SystemStackError`. (Yuji Nakayama, #270, #272)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta1...v3.5.0.beta2)

No user-facing changes.

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.4.1...v3.5.0.beta1)


## Footnotes

[^foot_1]: See also Eileen's [talk about request spec performance](https://www.youtube.com/watch?v=oT74HLvDo_A)

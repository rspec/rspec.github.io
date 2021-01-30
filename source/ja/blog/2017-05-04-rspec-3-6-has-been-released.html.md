---
title: RSpec 3.6 がリリースされました！
author: Sam Phippen, Myron Marston, Jon Rowe, Yuji Nakayama
---

RSpec 3.6 がリリースされました！
私たちは [semantic versioning](http://semver.org/) への準拠を約束しているので、
既に RSpec 3 をお使いの場合、このバージョンへのアップグレードは簡単なはずです。
しかし、もしバグを見つけた場合は教えてください。
できるだけ早く修正をし、パッチ版をリリースします。

RSpec は世界中のコントリビュータと共に、コミュニティ主導のプロジェクトであり続けます。
今回のリリースには、
50 人以上のコントリビュータによる 450 以上のコミットと、
120 以上の pull request が含まれています！

このリリースに向けて力になってくれたみなさん、ありがとう！

## 主な変更

### Core: Example の外で発生したエラーが rescue され、きれいに表示されるように

これまでのバージョンの RSpec では、spec ファイルの読み込み中や `:suite` フックの実行中にエラーが発生した場合、
Ruby インタプリタはクラッシュし、生のバックトレースすべてが表示されていました。
RSpec 3.6 では、example の外で発生したエラーは rescue され、
フィルタされたバックトレースとエラー元のコードがきれいに表示されるようになります。
例えば `before(:suite)` フックで発生したエラーは以下のように表示されます。

<img alt="Errors outside example execution"
src="/images/blog/errors_outside_example.png">

この実装を手伝ってくれた Jon Rowe、ありがとう。

### Core: 出力先が TTY の場合、自動でカラー出力が有効に

これまでの RSpec では、カラー出力をしたい場合、
出力先がターミナルであろうが、ファイルであろうが、CI 環境であろうが、
常に `--color` オプションを指定する必要がありました。
RSpec 3.6 では、出力先が TTY の場合はカラー出力が自動的に有効化されるようになりました。
これまで通り、出力先に関わらず常にカラーを有効にしたい場合は `--color` オプションを使えますし、
`--no-color` オプションを使えば TTY でカラー出力を明示的に無効化することもできます。

この機能を追加してくれた Josh Justice に感謝します。

### Core: `config.fail_if_no_examples`

通常、example が一つも定義されていない場合、RSpec は成功を意味する exit code `0` と共に終了しますが、
今回追加された `config.fail_if_no_examples` を有効にすると、
そういった場合に失敗を意味する exit code `1` で終了するようになります。
これは CI 環境において有用で、
例えば RSpec の実行対象とする spec ファイルのパスのパターンを間違って設定してしまったような場合に、
それを検出することができます。

~~~ ruby
RSpec.configure do |config|
  config.fail_if_no_examples = true
end
~~~

これを実装してくれた Ewa Czechowska に心から感謝します。

### Expectations: `change`、`satisfy` マッチャの失敗時メッセージの改善

`change` マッチャと `satisfy` マッチャはブロックを受け取ることができます。
`change` マッチャの場合は「何が」変化するのを期待するか、
`satisfy` マッチャの場合はテスト対象が「どうあるべきか」をブロックで表現します。
これまで、これらのマッチャの失敗時のメッセージは非常に抽象的でした。
例えば以下のような spec で、

~~~ ruby
RSpec.describe "`change` and `satisfy` matchers" do
  example "`change` matcher" do
    a = b = 1

    expect {
      a += 1
      b += 2
    }.to change { a }.by(1)
    .and change { b }.by(1)
  end

  example "`satisfy` matcher" do
    expect(2).to satisfy { |x| x.odd? }
            .and satisfy { |x| x.positive? }
  end
end
~~~

これまでの失敗時のメッセージは
"expected result to have changed by 1, but was changed by 2"
や、
"expected 2 to satisfy block"
というような形でした。
これらのメッセージの内容は間違っていませんが、
二つのマッチャのどちらが失敗したのかを区別するためのヒントがありませんでした。

RSpec 3.6 では、失敗時の出力は以下のようになります。

~~~
Failures:

  1) `change` and `satisfy` matchers `change` matcher
     Failure/Error:
       expect {
         a += 1
         b += 2
       }.to change { a }.by(1)
       .and change { b }.by(1)

       expected `b` to have changed by 1, but was changed by 2
     # ./spec/example_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) `change` and `satisfy` matchers `satisfy` matcher
     Failure/Error:
       expect(2).to satisfy { |x| x.odd? }
               .and satisfy { |x| x.positive? }

       expected 2 to satisfy expression `x.odd?`
     # ./spec/example_spec.rb:13:in `block (2 levels) in <top (required)>'
~~~

Yuji Nakayama による素晴らしい取り組みのおかげで、
RSpec は [Ripper](http://ruby-doc.org/stdlib-2.4.0/libdoc/ripper/rdoc/Ripper.html) を使って
ブロックのスニペットを抽出し、失敗時のメッセージに含めるようになりました。
もしブロックのスニペットが1行に収まるシンプルなものでない場合は、従来通りの抽象的なメッセージを出力します。

### Expectations: マッチャの別名や否定マッチャの定義が example group ごとにできるように

RSpec 3 では `alias_matcher` が追加され、
[マッチャの別名 (matcher aliases)](http://rspec.info/blog/2014/01/new-in-rspec-3-composable-matchers/#matcher-aliases)
を定義して可読性を高めることができるようになりました。
また、3.1 では
[否定マッチャ (negated matchers)](http://rspec.info/blog/2014/09/rspec-3-1-has-been-released/#expectations-new-definenegatedmatcher-api)
を定義するための `define_negated_matcher` が追加されました.

これまでのバージョンでは、これらのメソッドを使って新しく定義されたマッチャは、
グローバルスコープに定義されていました。
RSpec 3.6 からは、`alias_matcher` や `define_negated_matcher` を
example group（`describe` や `context` など）のスコープで呼び出せるようになり、
それによって定義されたマッチャは、その example group 自身とその内側の example group のみで有効になります。

~~~ ruby
RSpec.describe 'scoped matcher aliases' do
  describe 'example group with a matcher alias' do
    alias_matcher :be_a_string_starting_with, :start_with

    it 'can use the matcher alias' do
      expect('a').to be_a_string_starting_with('a')
    end
  end

  describe 'example group without the matcher alias' do
    it 'cannot use the matcher alias' do
      # 上で定義されたマッチャの別名はここでは利用できず、テストは失敗する
      expect('a').to be_a_string_starting_with('a')
    end
  end
end
~~~

この機能に貢献してくれた Markus Reiter、ありがとう。

### Mocks: `without_partial_double_verification`

RSpec 3.0 では
[インターフェイス検証付きダブル (verifying doubles)](http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#verifying-doubles)
が追加されました。
インターフェイス検証付きダブルを使うと、あなたが作ったスタブやモックが、
その対象オブジェクトのインターフェイスを正確に模倣できているかを検証することができます。
今回追加された `without_partial_double_verification` を使うと、
そのブロックの内側でこの挙動を無効化することができます。
例えば、

~~~ ruby
class Widget
  def call(takes_an_arg)
  end
end

RSpec.describe Widget do
  it 'can be stub with a mismatched arg count' do
    without_partial_double_verification do
      w = Widget.new
      allow(w).to receive(:call).with(1, 2).and_return(3)
      w.call(1, 2)
    end
  end
end
~~~

もしこのテストで `without_partial_double_verification` を使わなかった場合、
`Widget` クラスの `call` メソッドを本来の実装とは異なる数の引数でスタブしようとしているため、
テストは失敗します。
この機能は、ビュー内でローカル変数をスタブしようとした時に発生する、
部分的ダブル (partial double) の問題に対処するために追加されました。
詳細については [この issue](https://github.com/rspec/rspec-mocks/issues/1102) と、
そこからリンクされている rspec-rails の issue を参照してください。

この機能を追加してくれた Jon Rowe に心から感謝します。

### Rails: Rails 5.1 のサポート

RSpec 3.6.0 では Rails 5.1 がサポートされました。
Rails 5.1 の API には大きな変更はなかったため、今回のアップグレードはスムーズにできるはずです。
あなたの Rails アプリケーションの RSpec をただ最新バージョンにアップグレードするだけで、
他に作業は必要ありません。

Rails の [system tests](http://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/)
はまだサポートされていませんが、近い将来サポートする予定です。

## Stats:

### Combined:

* **Total Commits**: 493
* **Merged pull requests**: 127
* **58 contributors**: Alessandro Berardi, Alex Coomans, Alex DeLaPena, Alyssa Ross, Andy Morris, Anthony Dmitriyev, Ben Pickles, Benjamin Quorning, Damian Simon Peter, David Grayson, Devon Estes, Dillon Welch, Eugene Kenny, Ewa Czechowska, Gaurish Sharma, Glauco Custódio, Hanumakanth, Hun Jae Lee, Ilya Lavrov, Isaac Betesh, John Meehan, Jon Jensen, Jon Moss, Jon Rowe, Josh Justice, Juanito Fatas, Jun Aruga, Kevin Glowacz, Koichi ITO, Krzysztof Zych, Luke Rollans, Luís Costa, Mark Campbell, Markus Reiter, Markus Schwed, Megan O'Neill, Mike Butsko, Mitsutaka Mimura, Myron Marston, Olle Jonsson, Phil Thompson, Sam Phippen, Samuel Giddins, Samuel Lourenço, Sasha Gerrand, Sophie Déziel, Travis Spangle, VTJamie, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, ansonK, bootstraponline, gajewsky, matrinox, mrageh, proby, yui-knk

### rspec-core:

* **Total Commits**: 201
* **Merged pull requests**: 59
* **25 contributors**: Alyssa Ross, Benjamin Quorning, David Grayson, Devon Estes, Eugene Kenny, Ewa Czechowska, Ilya Lavrov, Jon Jensen, Jon Rowe, Josh Justice, Juanito Fatas, Jun Aruga, Mark Campbell, Mitsutaka Mimura, Myron Marston, Phil Thompson, Sam Phippen, Samuel Lourenço, Travis Spangle, VTJamie, Xavier Shay, Yuji Nakayama, bootstraponline, matrinox, yui-knk

### rspec-expectations:

* **Total Commits**: 85
* **Merged pull requests**: 25
* **11 contributors**: Alex DeLaPena, Alyssa Ross, Gaurish Sharma, Jon Rowe, Koichi ITO, Markus Reiter, Myron Marston, Sam Phippen, Xavier Shay, Yuji Nakayama, gajewsky

### rspec-mocks:

* **Total Commits**: 68
* **Merged pull requests**: 17
* **13 contributors**: Alessandro Berardi, Alex DeLaPena, Dillon Welch, Glauco Custódio, Jon Rowe, Luís Costa, Myron Marston, Olle Jonsson, Sam Phippen, Samuel Giddins, Yuji Nakayama, mrageh, proby

### rspec-rails:

* **Total Commits**: 84
* **Merged pull requests**: 13
* **25 contributors**: Andy Morris, Anthony Dmitriyev, Ben Pickles, Damian Simon Peter, Hanumakanth, Hun Jae Lee, Isaac Betesh, John Meehan, Jon Moss, Jon Rowe, Josh Justice, Kevin Glowacz, Krzysztof Zych, Luke Rollans, Markus Schwed, Megan O'Neill, Mike Butsko, Myron Marston, Sam Phippen, Sasha Gerrand, Sophie Déziel, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, yui-knk

### rspec-support:

* **Total Commits**: 55
* **Merged pull requests**: 13
* **7 contributors**: Alex Coomans, Jon Rowe, Myron Marston, Olle Jonsson, Sam Phippen, Yuji Nakayama, ansonK

## Docs

### API Docs

* [rspec-core](/documentation/3.6/rspec-core/)
* [rspec-expectations](/documentation/3.6/rspec-expectations/)
* [rspec-mocks](/documentation/3.6/rspec-mocks/)
* [rspec-rails](/documentation/3.6/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### RSpec Core (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Add seed information to JSON formatter output. (#2388, Mitsutaka Mimura)
* Include example id in the JSON formatter output. (#2369, Xavier Shay)
* Respect changes to `config.output_stream` after formatters have been
  setup. (#2401, #2419, Ilya Lavrov)

Bug Fixes:

* Delay formatter loading until the last minute to allow accessing the reporter
  without triggering formatter setup. (Jon Rowe, #2243)
* Ensure context hook failures running before an example can access the
  reporter. (Jon Jensen, #2387)
* Multiple fixes to allow using the runner multiple times within the same
  process: `RSpec.clear_examples` resets the formatter and no longer clears
  shared examples, and streams can be used across multiple runs rather than
  being closed after the first. (#2368, Xavier Shay)
* Prevent unexpected `example_group_finished` notifications causing an error.
  (#2396, VTJamie)
* Fix bugs where `config.when_first_matching_example_defined` hooks would fire
  multiple times in some cases. (Yuji Nakayama, #2400)
* Default `last_run_status` to "unknown" when the `status` field in the
  persistence file contains an unrecognized value. (#2360, matrinox)
* Prevent `let` from defining an `initialize` method. (#2414, Jon Rowe)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Include count of errors occurring outside examples in default summaries.
  (#2351, Jon Rowe)
* Warn when including shared example groups recursively. (#2356, Jon Rowe)
* Improve failure snippet syntax highlighting with CodeRay to highlight
  RSpec "keywords" like `expect`. (#2358, Myron Marston)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.4...v3.6.0.beta1)

Enhancements:

* Warn when duplicate shared examples definitions are loaded due to being
  defined in files matching the spec pattern (e.g. `_spec.rb`) (#2278, Devon Estes)
* Improve metadata filtering so that it can match against any object
  that implements `===` instead of treating regular expressions as
  special. (Myron Marston, #2294)
* Improve `rspec -v` so that it prints out the versions of each part of
  RSpec to prevent confusion. (Myron Marston, #2304)
* Add `config.fail_if_no_examples` option which causes RSpec to fail if
  no examples are found. (Ewa Czechowska, #2302)
* Nicely format errors encountered while loading spec files.
  (Myron Marston, #2323)
* Improve the API for enabling and disabling color output (Josh
  Justice, #2321):
  * Automatically enable color if the output is a TTY, since color is
    nearly always desirable if the output can handle it.
  * Introduce new CLI flag to force color on (`--force-color`), even
    if the output is not a TTY. `--no-color` continues to work as well.
  * Introduce `config.color_mode` for configuring the color from Ruby.
    `:automatic` is the default and will produce color if the output is
    a TTY. `:on` forces it on and `:off` forces it off.

### RSpec Expectations (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Treat NoMethodError as a failure for comparison matchers. (Jon Rowe, #972)
* Allow for scoped aliased and negated matchers--just call
  `alias_matcher` or `define_negated_matcher` from within an example
  group. (Markus Reiter, #974)
* Improve failure message of `change` matcher with block and `satisfy` matcher
  by including the block snippet instead of just describing it as `result` or
  `block` when Ripper is available. (Yuji Nakayama, #987)

Bug Fixes:

* Fix `yield_with_args` and `yield_successive_args` matchers so that
  they compare expected to actual args at the time the args are yielded
  instead of at the end, in case the method that is yielding mutates the
  arguments after yielding. (Alyssa Ross, #965)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0.beta1...v3.6.0.beta2)

Bug Fixes:

* Using the exist matcher on `File` no longer produces a deprecation warning.
  (Jon Rowe, #954)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Fix `contain_exactly` to work correctly with ranges. (Myron Marston, #940)
* Fix `change` to work correctly with sets. (Marcin Gajewski, #939)

### RSpec Mocks (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0.beta2...v3.6.0)

Bug Fixes:

* Fix "instance variable @color not initialized" warning when using
  rspec-mocks without rspec-core. (Myron Marston, #1142)
* Restore aliased module methods properly when stubbing on 1.8.7.
  (Samuel Giddins, #1144)
* Allow a message chain expectation to be constrained by argument(s).
  (Jon Rowe, #1156)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Add new `without_partial_double_verification { }` API that lets you
  temporarily turn off partial double verification for an example.
  (Jon Rowe, #1104)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Return the test double instance form `#freeze` (Alessandro Berardi, #1109)
* Allow the special logic for stubbing `new` to work when `<Class>.method` has
  been redefined. (Proby, #1119)

### RSpec Rails (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Add compatibility for Rails 5.1. (Sam Phippen, Yuichiro Kaneko, #1790)

Bug Fixes:

* Fix scaffold generator so that it does not generate broken controller specs
  on Rails 3.x and 4.x. (Yuji Nakayama, #1710)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Improve failure output of ActiveJob matchers by listing queued jobs.
  (Wojciech Wnętrzak, #1722)
* Load `spec_helper.rb` earlier in `rails_helper.rb` by default.
  (Kevin Glowacz, #1795)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.5.2...v3.6.0.beta1)

Enhancements:

* Add support for `rake notes` in Rails `>= 5.1`. (John Meehan, #1661)
* Remove `assigns` and `assert_template` from scaffold spec generators (Josh
  Justice, #1689)
* Add support for generating scaffolds for api app specs. (Krzysztof Zych, #1685)

### RSpec Support (combining all betas of RSpec 3.6.0)


#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0.beta2...3.6.0)

Enhancements:

* Import `Source` classes from rspec-core. (Yuji Nakayama, #315)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0.beta1...v3.6.0.beta2)

No user-facing changes.

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Prevent truncated formatted object output from mangling console codes. (#294, Anson Kelly)

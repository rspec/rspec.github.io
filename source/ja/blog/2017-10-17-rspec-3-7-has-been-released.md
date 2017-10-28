---
title: RSpec 3.7 がリリースされました！
author: Sam Phippen, Yuji Nakayama
---

RSpec 3.7 がリリースされました！
RSpec プロジェクトは [Semantic Versioning](http://semver.org/) に準拠したリリースを行なっているので、
既に RSpec 3 をお使いの場合、このバージョンへのアップグレードは簡単なはずです。
しかし、もしバグを見つけた場合は教えてください。
できるだけ早く修正をし、パッチ版をリリースします。

RSpec は世界中のコントリビュータと共に、コミュニティ主導のプロジェクトであり続けます。
今回のリリースには、27 人のコントリビュータによる 127 のコミットと、31 以上の pull request が含まれています！

ちなみに今回のリリースは、Rails の System Test サポートをできるだけ早くお届けするために、
いつもよりも小規模なリリースになっています。

このリリースに向けて力になってくれたみなさん、ありがとう！

## 主な変更

### Rails: `ActionDispatch::SystemTest` との統合 (System Spec)

Rails 5.1 では、System Test と呼ばれる新しいタイプのテストが追加されました。
これは Capyara を利用し、フロントエンドの JavaScript からサーバーサイドのデータベースまでフルスタックのテストを可能にするものです。

RSpec には以前から [Feature Spec](https://relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec) という同様の機能がありました。
しかし、Feature Spec と今回追加された System Spec（System Test の RSpec 版）には以下のような違いがあります。

1. Feature Spec では、JavaScript が有効な Capybara ドライバー（Selenium や Poltergeist) を使った場合、
   テストは Rails とは**別のプロセス**で実行されます。
   その結果、テストプロセスと Rails プロセス間でデータベースのトランザクションが共有されないため、
   RSpec 標準のデータベースロールバック機構を利用できず、
   代わりに [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) のような gem を使う必要がありました。
   Rails 開発チームは System Test でこのような問題が発生しないように実装をしました。
   そのおかげで、System Spec では別の gem を利用することなく RSpec のロールバック機構を利用できます。
2. RSpec の Feature Spec はデフォルトの Capyara ドライバーとして `Rack::Test` を利用します。
   もし Selenium のような JavaScript が有効なドライバーを使いたい場合は、
   ユーザーが自身で Capybara の設定をする必要がありますが、この設定はかなり高度で難しいものでした。
   System Spec でデフォルトで Selenium 経由で Chrome を利用しますが、
   これらの難解な設定は Rails があなたの代わりに行なってくれます。

以上のような点から、もし Rails 5.1 をお使いの場合、
フルスタックの統合テストとしては Feature Spec よりも System Spec を書くことをおすすめします。
Rails プロジェクトで System Test の実装を主導した [Eileen Uchitelle](https://twitter.com/eileencodes) には深く感謝します。

## Stats:

### Combined:

* **Total Commits**: 127
* **Merged pull requests**: 31
* **27 contributors**: Aaron Rosenberg, Alex Shi, Alyssa Ross, Britni Alexander, Dave Woodall, Devon Estes, Hisashi Kamezawa, Ian Ker-Seymer, James Adam, Jim Kingdon, Jon Rowe, Levi Robertson, Myron Marston, Pat Allan, RustyNail, Ryan Lue, Sam Phippen, Samuel Cochran, Sergei Trofimovich, Takeshi Arabiki, Thomas Hart, Tobias Pfeiffer, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, Zhong Zheng, oh_rusty_nail

### rspec-core:

* **Total Commits**: 40
* **Merged pull requests**: 10
* **11 contributors**: Devon Estes, Ian Ker-Seymer, Jon Rowe, Levi Robertson, Myron Marston, Pat Allan, Sam Phippen, Takeshi Arabiki, Thomas Hart, Tobias Pfeiffer, Yuji Nakayama

### rspec-expectations:

* **Total Commits**: 13
* **Merged pull requests**: 2
* **5 contributors**: Jim Kingdon, Myron Marston, Pat Allan, Sam Phippen, Yuji Nakayama

### rspec-mocks:

* **Total Commits**: 14
* **Merged pull requests**: 2
* **6 contributors**: Aaron Rosenberg, Myron Marston, Pat Allan, Sam Phippen, Yuji Nakayama, Zhong Zheng

### rspec-rails:

* **Total Commits**: 38
* **Merged pull requests**: 9
* **16 contributors**: Alex Shi, Alyssa Ross, Britni Alexander, Dave Woodall, Hisashi Kamezawa, James Adam, Jon Rowe, Myron Marston, RustyNail, Ryan Lue, Sam Phippen, Samuel Cochran, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, oh_rusty_nail

### rspec-support:

* **Total Commits**: 22
* **Merged pull requests**: 8
* **6 contributors**: Jon Rowe, Myron Marston, Pat Allan, Sam Phippen, Sergei Trofimovich, Yuji Nakayama

## Docs

### API Docs

* [rspec-core](/documentation/3.7/rspec-core/)
* [rspec-expectations](/documentation/3.7/rspec-expectations/)
* [rspec-mocks](/documentation/3.7/rspec-mocks/)
* [rspec-rails](/documentation/3.7/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release notes:

### RSpec Core
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0...v3.7.0)

Enhancements:

* Add `-n` alias for `--next-failure`. (Ian Ker-Seymer, #2434)
* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #2425, #2427, #2437)
* Do not run `:context` hooks for example groups that have been skipped.
  (Devon Estes, #2442)
* Add `errors_outside_of_examples_count` to the JSON formatter.
  (Takeshi Arabiki, #2448)

Bug Fixes:

* Improve compatibility with frozen string literal flag. (#2425, Pat Allan)

### RSpec Expectations
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #997)

## RSpec Mocks
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #1165)

Bug Fixes:

* Fix `hash_including` and `hash_excluding` so that they work against
  subclasses of `Hash`. (Aaron Rosenberg, #1167)

## RSpec Rails
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0...v3.7.0)

Bug Fixes:

* Prevent "template not rendered" log message from erroring in threaded
  environments. (Samuel Cochran, #1831)
* Correctly generate job name in error message. (Wojciech Wnętrzak, #1814)

Enhancements:

* Allow `be_a_new(...).with(...)` matcher to accept matchers for
  attribute values. (Britni Alexander, #1811)
* Only configure RSpec Mocks if it is fully loaded. (James Adam, #1856)
* Integrate with `ActionDispatch::SystemTestCase`. (Sam Phippen, #1813)

## RSpec Support
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #320)
* Add `Support.class_of` for extracting class of any object.
  (Yuji Nakayama, #325)

Bug Fixes:

* Fix recursive const support to not blow up when given buggy classes
  that raise odd errors from `#to_str`. (Myron Marston, #317)

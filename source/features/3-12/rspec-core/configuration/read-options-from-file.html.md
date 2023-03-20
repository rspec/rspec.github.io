# Reading command line configuration options from files

RSpec reads command line configuration options from several different files,
  all conforming to a specific level of specificity. Options from a higher
  specificity will override conflicting options from lower specificity files.

  The locations are:

    * **Global options:** First file from the following list (i.e. the user's
      personal global options)

      * `$XDG_CONFIG_HOME/rspec/options` ([XDG Base Directory
        Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
        config)
      * `~/.rspec`

    * **Project options:**  `./.rspec` (i.e. in the project's root directory, usually
      checked into the project)

    * **Local:** `./.rspec-local` (i.e. in the project's root directory, can be
      gitignored)

  Options specified at the command-line has even higher specificity, as does
  the `SPEC_OPTS` environment variable. That means that a command-line option
  would overwrite a project-specific option, which overrides the global value
  of that option.

  The default options files can all be ignored using the `--options`
  command-line argument, which selects a custom file to load options from.

## Color set in `.rspec`

_Given_ a file named ".rspec" with:

```
--force-color
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "color_enabled?" do
  context "when set with RSpec.configure" do
    it "is true" do
      expect(RSpec.configuration).to be_color_enabled
    end
  end
end
```

_When_ I run `rspec ./spec/example_spec.rb`

_Then_ the examples should all pass.

## Custom options file

_Given_ a file named "my.options" with:

```
--format documentation
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "formatter set in custom options file" do
  it "sets formatter" do
    expect(RSpec.configuration.formatters.first).
      to be_a(RSpec::Core::Formatters::DocumentationFormatter)
  end
end
```

_When_ I run `rspec spec/example_spec.rb --options my.options`

_Then_ the examples should all pass.

## RSpec ignores `./.rspec` when custom options file is used

_Given_ a file named "my.options" with:

```
--format documentation
```

_And_ a file named ".rspec" with:

```
--no-color
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "custom options file" do
  it "causes .rspec to be ignored" do
    expect(RSpec.configuration.color_mode).to eq(:automatic)
  end
end
```

_When_ I run `rspec spec/example_spec.rb --options my.options`

_Then_ the examples should all pass.

## Using ERB in `.rspec`

_Given_ a file named ".rspec" with:

```
--format <%= true ? 'documentation' : 'progress' %>
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "formatter" do
  it "is set to documentation" do
    expect(RSpec.configuration.formatters.first).
      to be_an(RSpec::Core::Formatters::DocumentationFormatter)
  end
end
```

_When_ I run `rspec ./spec/example_spec.rb`

_Then_ the examples should all pass.

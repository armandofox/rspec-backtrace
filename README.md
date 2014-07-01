**When `--backtrace` is on and `Time.parse` is used to dynamically
generate the name of an example, `autotest` is unable to re-run the
failing specs because the first argument to `rspec` is malformed.**

This is the weirdest rspec/autotest bug I have seen.  I'm not sure if
the bug is in autotest or in part of rspec.

I'm on Mac OS 10.8.5 using Ruby 1.9.3-p429 via `rvm`.

I found this bug with RSpec 2.14.0, but I have confirmed it is present in 2.99 as well.

I have no `~/.rspec` or `~/.autotest` file, or any
environment variables controlling them;
my only RSpec options are being set by the `.rspec` file here.

1) Run `autotest` in this directory.  The single example in
  `spec/foo_spec.rb` will fail.

2) Make a trivial change to `foo_spec.rb` (or just touch the file) to
   trigger `autotest` to rerun it.  On my computer, the rerun fails because the
   first filename passed to rspec (right after the `--tty` argument) is actually *two* filenames, of which
   the first seems to be a bogus path to rspec itself: (for readability,
   I have replaced my gem path
   `/Users/fox/.rvm/gems/ruby-1.9.3-p429/gems/` with `$GEMS`)

```
"/Users/fox/.rvm/rubies/ruby-1.9.3-p429/bin/ruby" -rrubygems -S "$GEMS/rspec-core-2.14.8/exe/rspec" --tty "/tmp/rspec-backtrace/rspec ./spec/foo_spec.rb" "/tmp/rspec-backtrace/spec/foo_spec.rb"
$GEMS/rspec-core-2.14.8/lib/rspec/core/configuration.rb:896:in `load': cannot load such file -- /tmp/rspec-backtrace/rspec ./spec/foo_spec.rb (LoadError)
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/configuration.rb:896:in `block in load_spec_files'
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/configuration.rb:896:in `each'
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/configuration.rb:896:in `load_spec_files'
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/command_line.rb:22:in `run'
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/runner.rb:80:in `run'
	from $GEMS/rspec-core-2.14.8/lib/rspec/core/runner.rb:17:in `block in autorun'
```

3) Weirdness #1: stop autotest, then edit the `.rspec` file to remove
   `--backtrace`.  Now repeat steps 1 and 2.  This
   time, `autotest` will correctly re-run the failed spec.

4) Weirdness #2: stop autotest, put `--backtrace` back into `.rspec`, **and**
   edit `spec/foo_spec.rb` to eliminate the call to `Time.parse`:

**BEFORE:**

```ruby
test_case_name = Time.parse "12:00pm"
# test_case_name = "12:00 pm"
```

**AFTER:**

```ruby
# test_case_name = Time.parse "12:00pm"
test_case_name = "12:00 pm"
```

Repeat steps 1 and 2.  Autotest will again correctly re-run the
failed spec!

So to summarize what I'm experiencing:

* With `--backtrace` **and** a call to `Time.parse` to generate the name of
   an example, `autotest` seems unable to re-run failing specs.
* Removing **either** `--backtrace` **or** the call to `Time.parse`
   makes `autotest` do the right thing.
* Specifying RSpec 2.99 in the Gemfile gives all these same behaviors (albeit with some 2.99 deprecation warnings).

For the moment, my workaround is to remove `--backtrace`, though I like
having it on since it makes debugging non-obvious failures faster for
me.

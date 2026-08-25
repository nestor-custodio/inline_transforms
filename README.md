[![Gem Version](https://img.shields.io/github/v/release/nestor-custodio/inline_transforms?color=green&label=gem%20version)](https://rubygems.org/gems/inline_transforms)
[![MIT License](https://img.shields.io/github/license/nestor-custodio/inline_transforms)](https://tldrlegal.com/license/mit-license)


# Inline Transforms

Ruby is an incredibly expressive (and easy to read!) language, but lacks a way for you to transform a value _inline_ without resorting to nested ternaries (🫠). This gem allows you to do exactly that in a way that still feels like _Ruby_ (i.e. via _value manipulation_ through method calls rather than classic flow control blocks).

In simplest terms:
```ruby
# "Unless" Logic:

final_value = original_value
final_value = different_value if original_value == a_bad_thing

# ... or ...

final_value = if original_value == a_bad_thing
                different_value
              else
                original_value
              end

# ... becomes ...

final_value = original_value.unless a_bad_thing,
                                    then: different_value


# "Transform" Logic:

final_value = case original_value
              when true   then 'success'
              when false  then 'failure'
              when String then %(error: "#{original_value}")
              end

# ... becomes ...

final_value = original_value.transform true   => 'success',
                                       false  => 'failure',
                                       String => %(error: "#{original_value}")

```

[Full documentation is available here](https://nestor-custodio.github.io/inline_transforms), but do read below for a crash course on availble featues!


## Installation

- If your project uses [Bundler](https://github.com/bundler/bundler):
  - Add one of the following to your application's Gemfile:
    ```ruby
    # For on-demand usage:

    gem 'inline_transforms'
    ```
  - And then run a:
    ```shell
    $ bundle install
    ```

- Or, you can keep things simple with a manual install:
  ```shell
  $ gem install inline_transforms
  ```


## Usage

### Object#unless

`unless` lets you specify a "bad" value and a `then` replacement.

- If your `then` replacement is a `Proc`, it is resolved (via `call`) before being returned.
- This method uses **case comparison** (`===`), so you can check for range inclusion or class.

```ruby
final = value.unless bad_value, then: fallback_value
# ... or ...
final = value.unless bad_value, then: -> { some_method_call with_params }
```


### Object#transform

`transform` lets you specify a transformation hash and will return the value for the first matching key, or (if no matching key is found) the `:else` value.

- Any `Proc` values in the transform hash are resolved (via `call`) before being returned.
- This method uses **case comparison** (`===`), so range and class keys work as you expect.

```ruby
final = value.transform key_1 => value_1,
                        key_2 => value_2,
                        # ...
                        else: else_value
```


## Potential Gotchas

- `Proc` instances are only resolved if they _need to be returned and are not the original value_:
  ```ruby
  value = -> { 'value proc' }
  replacement_proc = -> { 'replacement proc' }

  # Returns the original `value`, still a *Proc*.
  #
  # The original `value` is never resolved.
  # The `replacement_proc` is not resolved.
  #
  final = value.unless 99, then: replacement_proc

  # Returns the *String* 'replacement proc'.
  #
  # The original `value` is never resolved.
  # The `replacement_proc` DOES get resolved.
  #
  final = value.unless value, then: replacement_proc

  # Returns 99.
  #
  # The original `value` is never resolved.
  # The `replacement_proc` is not resolved.
  #
  final = value.transform value => 99, else: replacement_proc

  # Returns the *String* 'replacement proc'.
  #
  # The original `value` is never resolved.
  # The `replacement_proc` DOES get resolved.
  #
  final = value.transform 99 => 99, else: replacement_proc
  ```

- Because _return_ `Proc`s are resolved before being passed back, you have to "proc-wrap" any `Proc` you want returned as-is (😵‍💫):
  ```ruby
  value = 'some value'
  replacement_proc = -> { 'replacement proc' }

  # Returns the `replacement_proc`, still a *Proc*.
  #
  value.unless 99, then: -> { replacement_proc }
  ```
  It should be _exceedingly rare_ for someone to want to do this, but it _is_ supported and this is how you would make that happen.


## Contribution / Development

Bug reports and pull requests are welcome at: [https://github.com/nestor-custodio/inline_transforms](https://github.com/nestor-custodio/inline_transforms)

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://docs.rubocop.org/) (`rake rubocop`) and documentation is built using [YARD](https://yardoc.org/). Please ensure you have a clean bill of health from Rubocop and that any new features and/or changes to behaviour are reflected in the adjacent documentation before submitting a pull request.


## License

The `inline_transforms` gem is available as open source under the terms of the [MIT License](https://tldrlegal.com/license/mit-license).

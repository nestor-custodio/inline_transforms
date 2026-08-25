require_relative 'inline_transforms/version'

# Defines `unless` and `transform`, which we'll then want to make available in `Object` instances.
#
module InlineTransforms
  # Our use of case equality in matching bad/target values
  # is intentional and part of the promise behind the gem.
  #
  # rubocop:disable Style/CaseEquality

  # Returns `self` ... unless it matches a "bad" value, in which case it returns an alternate (`then:`) value.
  #
  # (NOTE: this takes a `then: nil` named param, but is defined as taking `(**options)` because `then` is reserved.)
  #
  #
  # @param bad_value [Object]
  #   The one value we consider "bad", and for which we'd like the `then:` option back instead.
  #
  # @option then: [Object]
  #   The value we'd like back if `self` matches the `bad_value` **using case comparison**.
  #   Defaults to `nil`.
  #
  # @return
  #   Returns either `self` or the value given as the `then:` option.
  #
  def unless(bad_value, **options)
    return self unless inline_transforms_equality? bad_value

    alt_value = options[:then]
    return alt_value.call if alt_value.is_a? Proc

    alt_value
  end

  # Returns `self` ... unless it matches one of the keys in the given "transformation hash", in which case the
  # corresponding hash value is returned. If no matching hash key is found, this returns a fallback (`else:`) value.
  #
  # (NOTE: this takes an `else: nil` named param, but is defined as taking `(**options)` because `else` is reserved.)
  #
  #
  # @option **
  #   A hash of keys to case-compare against `self` so we can return the corresponding value.
  #
  # @option else: [Object]
  #   The fallback value to return if no matching key is found. Defaults to `nil`.
  #
  # @return
  #   Returns either `self`, one of the transformation hash values, or the `else:` option.
  #
  def transform(**options)
    default = options.delete :else

    options.each { |key, value| return value.unless Proc, then: -> { value.call } if inline_transforms_equality? key }
    default
  end

  private

  # You can't case-compare *against* a `Proc` because `Proc#===` is an alias for `Proc#call`. (?!)
  # So we have to be careful when testing for this.
  #
  # @param value [Object]
  #   The value against which to case-compare `self`.
  #
  # @return [true, false]
  #
  def inline_transforms_equality?(value)
    return value == self if value.is_a? Proc

    value === self
  end

  # rubocop:enable Style/CaseEquality
end

# Gets the `InlineTransforms` methods.
#
class Object; include InlineTransforms; end # rubocop:disable Style/OneClassPerFile

require_relative 'inline_transforms/version'

# Defines `only_if`, `unless`, and `transform`, which we'll then want to make available in `Object` instances.
#
module InlineTransforms
  # Our use of case equality in matching bad/target values
  # is intentional and part of the promise behind the gem.
  #
  # rubocop:disable Style/CaseEquality

  # Returns `self` _only if_ it matches a "good" value; otherwise returns an alternate (`else:`) value.
  #
  # (NOTE: this takes an `else: nil` named param, but is defined as taking `(**options)` because `else` is reserved.)
  #
  #
  # @param good_value [Object]
  #   The one value we consider "good", and for which we'd like `self` returned.
  #
  # @option else: [Object]
  #   The value we'd like back if `self` does not match the `good_value` **using case comparison**.
  #   Defaults to `nil`.
  #
  # @return
  #   Returns either `self` or the value given as the `else:` option.
  #
  def only_if(good_value, **options)
    return self if inline_transforms_equality? good_value

    inline_transforms_response_processor options[:else]
  end

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

    inline_transforms_response_processor options[:then]
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

    options.each { |key, value| return inline_transforms_response_processor value if inline_transforms_equality? key }
    inline_transforms_response_processor default
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

  # We want to pass fallback values through as-is **except for `Proc`s**,
  # which we must resolve by passing `self` _or not_, as dictated by its arity.
  #
  # @param response_value [Object]
  #   The `then`, `else`, or matching transform value from one of the above.
  #
  # @return [Object]
  #   The given `response_value`, unless it's a `Proc`, in which case we want to resolve it first.
  #
  # @raise [ArgumentError]
  #
  def inline_transforms_response_processor(response_value)
    return response_value unless response_value.is_a? Proc

    case response_value.arity
    when 0 then response_value.call
    when 1, -1 then response_value.call self
    else raise ArgumentError, 'fallback Proc must be of arity 0 or 1'
    end
  end

  # rubocop:enable Style/CaseEquality
end

# Gets the `InlineTransforms` methods.
#
class Object; include InlineTransforms; end # rubocop:disable Style/OneClassPerFile

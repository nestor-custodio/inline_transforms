require_relative 'inline_transforms/version'

# Defines `unless` and `transform`, which we'll then want to make available in `Object` instances.
#
module InlineTransforms
  # Our use of case equality in matching bad/target values
  # is intentional and part of the promise behind the gem.
  #
  # rubocop:disable Style/CaseEquality

  # This takes an option `then: nil`, but is defined with `**options` because `then` is reserved.
  #
  def unless(bad_value, **options)
    return self unless inline_transforms_equality? bad_value

    alt_value = options[:then]
    return alt_value.call if alt_value.is_a? Proc

    alt_value
  end

  # This takes an option `else: nil`, but is defined with `**options` because `else` is reserved.
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
  def inline_transforms_equality?(value)
    return value == self if value.is_a? Proc

    value === self
  end

  # rubocop:enable Style/CaseEquality
end

# Add these methods to all `Object`s.
#
class Object; include InlineTransforms; end # rubocop:disable Style/OneClassPerFile

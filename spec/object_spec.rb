RSpec.describe Object do
  describe '#only_if' do
    test_values = [nil, true, false, 99, :symbol, 'string', ['array'], { key: 'value' }, -> { puts 'value proc' }]
    safe_bad_value = 'something not present in the `test_values` list'
    replacement_value = 'some different value'

    it 'is available' do
      expect(Object).to respond_to(:only_if)
    end

    it 'takes the proper arguments' do
      expect(Object).to respond_to(:only_if).with(1).arguments.with_any_keywords
    end

    it 'passes "good" values unaltered' do
      test_values.each { |value| expect(value.only_if(value)).to eq value }
    end

    it 'replaces "bad" values with the `else` param' do
      test_values.each do |value|
        expect(value.only_if(safe_bad_value, else: replacement_value)).to eq replacement_value
      end
    end

    it %(`call`s the `else` param before use if it's a Proc) do
      @rand_value = rand 1..10000
      replacement_proc = -> { @rand_value }

      test_values.each do |value|
        expect(value.only_if(safe_bad_value, else: replacement_proc)).to eq @rand_value
      end
    end
  end

  # ---

  describe '#unless' do
    test_values = [nil, true, false, 99, :symbol, 'string', ['array'], { key: 'value' }, -> { puts 'value proc' }]
    safe_bad_value = 'something not present in the `test_values` list'
    test_proc_value = -> { puts 'test proc' }
    replacement_value = 'some different value'

    it 'is available' do
      expect(Object).to respond_to(:unless)
    end

    it 'takes the proper arguments' do
      expect(Object).to respond_to(:unless).with(1).arguments.with_any_keywords
    end

    it 'passes "good" values unaltered' do
      test_values.each { |value| expect(value.unless(safe_bad_value)).to eq value }
    end

    it 'allows a `Proc` instance as the "bad" value' do
      test_values.each do |value|
        expect(value.unless(test_proc_value, then: replacement_value)).to eq value
      end
    end

    it 'replaces "bad" values with the `then` param' do
      test_values.each do |value|
        expect(value.unless(safe_bad_value, then: replacement_value)).to eq value
        expect(value.unless(value, then: replacement_value)).to eq replacement_value
      end
    end

    it %(`call`s the `then` param before use if it's a Proc) do
      @rand_value = rand 1..10000
      replacement_proc = -> { @rand_value }

      test_values.each do |value|
        expect(value.unless(value, then: replacement_proc)).to eq @rand_value
      end
    end
  end

  # ---

  describe '#transform' do
    value = 'some value'
    proc_value = -> { puts 'proc value' }
    matching_value = value.dup
    mismatching_value = 'a mismatching value'
    replacement_value = 'some different value'
    else_value = 'fallback transform'

    it 'is available' do
      expect(Object).to respond_to(:transform)
    end

    it 'takes the proper arguments' do
      expect(Object).to respond_to(:transform).with_any_keywords
    end

    it 'transforms matched values' do
      expect(value.transform(matching_value => replacement_value)).to eq replacement_value
    end

    it 'falls back to the `else` param' do
      expect(value.transform(mismatching_value => replacement_value, else: else_value)).to eq else_value
    end

    it 'allows a `Proc` instance as a transform key' do
      expect(value.transform(proc_value => replacement_value, else: else_value)).to eq else_value
      expect(proc_value.transform(proc_value => replacement_value, else: else_value)).to eq replacement_value
    end

    it %(`call`s a transformed value before use if it's a Proc) do
      @rand_value = rand 1..10000
      replacement_proc = -> { @rand_value }

      expect(value.transform(value => replacement_proc)).to eq @rand_value
    end
  end
end

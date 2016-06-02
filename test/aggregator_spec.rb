require './src/aggregator'
require 'test/unit'

class AggregatorSpec < Test::Unit::TestCase

  def test_aggregator_with_sum
    current_val = 1
    new_val = 2
    result = Aggregator.aggregate(:sum, current_val, new_val)

    assert_equal(result, current_val + new_val, 'The aggregator did not perform sum properly.')
  end

  def test_aggregator_with_average
    current_average = 9
    count = 10
    new_val = 20
    expected_val = 10
    result = Aggregator.aggregate(:average, current_average, count, new_val)

    assert_equal(result, expected_val, 'The aggregator did not perform average properly.')
  end

  def test_aggregator_with_min_and_greater_current
    current_val = 10
    new_val = 9
    expected_val = 9
    result = Aggregator.aggregate(:min, current_val, new_val)

    assert_equal(result, expected_val, 'The aggregator did not perform min properly when the current value was greater than the new value.')
  end

  def test_aggregator_with_min_and_greater_new
    current_val = 2
    new_val = 100
    expected_val = 2
    result = Aggregator.aggregate(:min, current_val, new_val)

    assert_equal(result, expected_val, 'The aggregator did not perform min properly when the new value was greater than the current value.')
  end

  def test_aggregator_with_max_and_greater_current
    current_val = 11
    new_val = 4
    expected_val = 11
    result = Aggregator.aggregate(:max, current_val, new_val)

    assert_equal(result, expected_val, 'The aggregator did not perform max properly when the current value was greater than the new value.')
  end

  def test_aggregator_with_max_and_greater_new
    current_val = 20
    new_val = 1009
    expected_val = 1009
    result = Aggregator.aggregate(:max, current_val, new_val)

    assert_equal(result, expected_val, 'The aggregator did not perform max properly when the new value was greater than the current value.')
  end

end
require './src/column'
require 'test/unit'

class ColumnSpec < Test::Unit::TestCase

  def test_initialize_with_valid_params
    name = 'test'
    default = nil
    test_column = Column.new(name, default)

    assert_equal(test_column.class, Column, 'Test column was not of class Column.')
    assert_equal(test_column.name, name, 'Test column name was different than passed in name.')
    assert_equal(test_column.default, default, 'Test column default was different than the passed in default')
  end

  def test_initialize_with_optional_count
    name = 'test'
    default = nil
    count = 5
    test_column = Column.new(name, default, count)

    assert_equal(test_column.class, Column, 'Test column was not of class Column.')
    assert_equal(test_column.name, name, 'Test column name was different than passed in name.')
    assert_equal(test_column.default, default, 'Test column default was different than the passed in default')
  end

  def test_array_accessor_with_one_param
    default = 5
    test_column = Column.new('test', default, 10)

    assert_equal(test_column[2], default, 'The correct values where not found when accessing the storage.')
  end

  def test_array_accessor_with_two_params
    default = 3
    test_column = Column.new('test', default, 10)

    assert_equal(test_column[2,2], [default, default], 'The correct values where not found when accessing the storage.')
  end

  def test_array_setter
    test_column = Column.new('test', nil, 10)

    changed_index = 2
    new_value = 5
    test_column[changed_index] = new_value

    assert_equal(test_column[changed_index], new_value, 'The newly changed value was not the same as the one we passed in.')
  end

  def test_length
    count = 100
    test_column = Column.new('test', nil, count)

    assert_equal(test_column.length, count, 'The length of the storage was not the same as the length')
  end

  def test_push
    default = nil
    count = 9
    test_column = Column.new('test', default, count)
    new_value = 4
    test_column.push(new_value)

    assert_equal(test_column.length, count+1, 'The length of storage is not equal to the default count plus the new record.')
    assert_equal(test_column[count], new_value, 'The new value is not at the end of the array.')
  end
end

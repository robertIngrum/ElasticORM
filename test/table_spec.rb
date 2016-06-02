require './src/table'
require 'test/unit'

class TableSpec < Test::Unit::TestCase

  def test_initialize_with_valid_params
    name = 'test'
    column_names = ['test', 'this', 'table']
    test_table = Table.new(name, column_names)

    assert_equal(test_table.class, Table, 'Test table was not of class Table.')
    assert_equal(test_table.count, 0, 'Test table count was incorrect.')

    column_names.each do |column_name|
      assert(test_table.columns.include?(column_name), "#{column_name} does not exist in columns hash.")
    end
    assert_equal(test_table.columns.length, column_names.length, 'There are a different number of columns than column names.')
  end

  def test_add_column
    column_names = ['test', 'this', 'table']
    test_column_name = 'new'
    test_table = Table.new('test', column_names)
    test_table.add_column(test_column_name, nil)

    assert(test_table.columns.include?(test_column_name), "#{test_column_name} does not exist in columns hash.")
    assert_equal(test_table.columns.length, column_names.length + 1, 'There are a different number of columns saved than expected.')
  end

  def test_add_repeat_column
    require './src/exceptions/ColumnAlreadyExistsError'

    column_names = ['test', 'this', 'table']
    test_column_name = 'test'
    test_table = Table.new('test', column_names)

    assert_raise ColumnAlreadyExistsError do
      test_table.add_column(test_column_name, nil)
    end
  end

  def test_insert
    data = {'test' => [1, 2, 3, 4, 5]}
    test_table = Table.new('test', ['test'])
    test_table.insert(data)

    assert_equal(test_table[0, data['test'].length], data, 'The data inserted into the table does not match the data retrieved.')
  end

  def test_array_accessor_with_one_param
    data = {'test' => [1, 2, 3, 4, 5]}
    target = {'test' => 1}
    test_table = Table.new('test', ['test'])
    test_table.insert(data)

    assert_equal(test_table[0], target, 'The data fetched does not match the expected value.')
  end

  def test_array_accessor_with_two_params
    data = {'test' => [1, 2, 3, 4, 5]}
    target = {'test' => [1, 2]}
    test_table = Table.new('test', ['test'])
    test_table.insert(data)

    assert_equal(test_table[0,2], target, 'The data fetched does not match the expected value.')
  end

  def test_import_csv
    name = 'CSVTest'
    path = './src/bin/TestCSV.csv'
    csv_column_names = ['data1', 'data2', 'data3', 'data4']
    csv_rows = 34
    sample_row = {'data1' => '24', 'data2' => '49', 'data3' => '50', 'data4' => '120'}
    test_table = Table.import_csv(name, path)

    assert_equal(test_table.class, Table, 'The test table was not of type Table.')
    csv_column_names.each do |csv_column_name|
      assert(test_table.columns.include?(csv_column_name), 'The column in the csv could not be found in the table.')
    end
    assert_equal(test_table.columns.length, csv_column_names.length, 'There were a different number of columns in the csv and table.')
    assert_equal(test_table.count, csv_rows, 'There were a different number of rows in the csv and the table.')
    assert_equal(test_table[23], sample_row, 'The retrieved row is not the same as the sample row.')
  end

end

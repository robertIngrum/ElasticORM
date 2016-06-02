require './src/dataset'
require './src/table'
require 'test/unit'

class DatasetSpec < Test::Unit::TestCase

  def setup
    @test_table = Table.new('test', ['hello', 'im', 'a', 'table'])
  end

  def test_initialize_with_empty_table
    test_dataset = Dataset.new(@test_table)

    assert_equal(test_dataset.class, Dataset, 'Test dataset was not of class Dataset.')
    assert_equal(test_dataset.table, @test_table, 'Test dataset table was not equal to the table it was initialized with.')
    assert_equal(test_dataset.filters, [], 'Test dataset filters were not initialized to an empty array.')
    assert_equal(test_dataset.groups, [], 'Test dataset groups were not initialized to an empty array.')
    assert_equal(test_dataset.joins, [], 'Test dataset joins were not initialized to an empty array.')
    assert_equal(test_dataset.result.class, Hash, 'Test dataset result was not of class array.')
    test_dataset.result.each do |column_name, column|
      assert(@test_table.columns.include?(column_name.split('__')[-1]), 'The test dataset had a column that was not in the table it was initialized with.')
      assert_equal(column.length, @test_table.columns['hello'].length, 'There were a different number of rows in the test dataset than the table it was initialized with.')
    end
    assert_equal(test_dataset.result.length, @test_table.columns.length, 'There were a different number of columns in the test dataset than the table it was initialized with.')
  end

  def test_initialize_with_full_table
    @test_table = Table.import_csv('test', './src/bin/TestCSV.csv')
    test_dataset = Dataset.new(@test_table)


    assert_equal(test_dataset.class, Dataset, 'Test dataset was not of class Dataset.')
    assert_equal(test_dataset.table, @test_table, 'Test dataset table was not equal to the table it was initialized with.')
    assert_equal(test_dataset.filters, [], 'Test dataset filters were not initialized to an empty array.')
    assert_equal(test_dataset.groups, [], 'Test dataset groups were not initialized to an empty array.')
    assert_equal(test_dataset.joins, [], 'Test dataset joins were not initialized to an empty array.')
    assert_equal(test_dataset.result.class, Hash, 'Test dataset result was not of class array.')
    test_dataset.result.each do |column_name, column|
      assert(@test_table.columns.include?(column_name.split('__')[-1]), 'The test dataset had a column that was not in the table it was initialized with.')
      assert_equal(column.length, @test_table.columns['data1'].length, 'There were a different number of rows in the test dataset than the table it was initialized with.')
    end
    assert_equal(test_dataset.result.length, @test_table.columns.length, 'There were a different number of columns in the test dataset than the table it was initialized with.')
  end

  def test_filter_with_valid_params
    table_name = 'test'
    column_name = 'data1'
    filter_proc = Proc.new { |x| x.to_i%2==0 } # Expecting to filter out odd values
    @test_table = Table.import_csv(table_name, './src/bin/TestCSV.csv')
    test_dataset = Dataset.new(@test_table)
    test_dataset.filter(table_name, column_name, filter_proc)


    assert_equal(test_dataset.class, Dataset, 'Test dataset was not of class Dataset.')
    assert_equal(test_dataset.table, @test_table, 'Test dataset table was not equal to the table it was initialized with.')
    assert_equal(test_dataset.filters.length, 1, 'Test dataset filters were not initialized to an empty array.')
    test_dataset.result.each do |column_name, column|
      assert(@test_table.columns.include?(column_name.split('__')[-1]), 'The test dataset had a column that was not in the table it was initialized with.')
    end
    assert_equal(test_dataset.result.length, @test_table.columns.length, 'There were a different number of columns in the test dataset than the table it was initialized with.')
    test_dataset.result[column_name].each { |x| assert(x.to_i%2==0, 'Test dataset contained values that should have been filtered out.')}
  end

  def test_group_by_with_valid_params
    table_name = 'test'
    column_name = 'data1'
    @test_table = Table.import_csv(table_name, './src/bin/TestCSV2.csv')
    test_dataset = Dataset.new(@test_table)
    test_dataset.group_by(table_name, column_name, :sum)


    assert_equal(test_dataset.class, Dataset, 'Test dataset was not of class Dataset.')
    assert_equal(test_dataset.table, @test_table, 'Test dataset table was not equal to the table it was initialized with.')
    assert_equal(test_dataset.groups.length, 1, 'Test dataset groups were not initialized to an empty array.')
    test_dataset.result.each do |column_name, column|
      assert(@test_table.columns.include?(column_name.split('__')[-1]), 'The test dataset had a column that was not in the table it was initialized with.')
    end
    assert_equal(test_dataset.result.length, @test_table.columns.length, 'There were a different number of columns in the test dataset than the table it was initialized with.')

    item_count = Hash.new(0)
    test_dataset.result[column_name].each { |x| item_count[x] += 1 }

    item_count.each do |_, count|
      assert(count == 1, 'Test dataset contained more than value for the grouped column.')
    end
  end

  def test_join_with_valid_params
    table1_data = { name: 'test',
                    column: 'data1',
                    src: './src/bin/TestCSV.csv' }
    table2_data = { name: 'me',
                    column: 'data1',
                    src: './src/bin/TestCSV2.csv' }

    table1 = Table.import_csv(table1_data[:name], table1_data[:src])
    table2 = Table.import_csv(table2_data[:name], table2_data[:src])
    test_dataset = Dataset.new(table1)
    test_dataset.join(table2, table2_data[:column], table1_data[:name], table1_data[:column])

    assert_equal(test_dataset.class, Dataset, 'Test dataset was not of class Dataset.')
    assert_equal(test_dataset.joins.length, 1, 'Test dataset joins were not initialized to an empty array.')
    test_dataset.result.each do |column_name, column|
      assert(@test_table.columns.include?(column_name.split('__')[-1]), 'The test dataset had a column that was not in the table it was initialized with.')
    end
    assert_equal(test_dataset.result.length, @test_table.columns.length, 'There were a different number of columns in the test dataset than the table it was initialized with.')

    item_count = Hash.new(0)
    test_dataset.result[column_name].each { |x| item_count[x] += 1 }

    item_count.each do |_, count|
      assert(count == 1, 'Test dataset contained more than value for the grouped column.')
    end
  end
end

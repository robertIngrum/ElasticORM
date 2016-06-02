require './src/column'
require 'csv'

# This class represents a data structure similar to a table, where data is stored in rows and grouped by columns
class Table

  attr_reader :count
  attr_reader :columns

  # Creates a new Table
  # @param name [string] :: String representing the name of the table
  # @param column_names [array] :: Contains an array of strings, each of which will be assigned as the name of a column
  # @return [table] :: Initialized table object
  def initialize(name, column_names)

    # Storing the name, setting the count of the data to 0, and creating an empty container for the columns
    @name = name
    @count = 0
    @columns = {}

    # Iterate through the column names and create a new column for each one
    column_names.each do |column_name|
      add_column(column_name, nil)
    end

  end

  # Adds a new column to the table
  # @param name [string] :: The name of the column
  # @param default [?] :: The default value for the dataset
  def add_column(name, default)

    # Make sure there isn't already a column with the same name
    if @columns.include?(name)
      require './src/exceptions/ColumnAlreadyExistsError'
      raise ColumnAlreadyExistsError.new(name)
    end

    # Create the new column
    @columns[name] = Column.new(name, default, @count)

  end

  # Inserts data into our table
  # @param data [hash] :: A dictionary containing the column name for the key and an array of data for the value
  def insert(data)
    validate_insert(data)

    # Iterate through each column in the data
    data.each do |column_name, column_data|
      # Push the new data to the end up the currently stored data
      @columns[column_name].push(*column_data)

      # Update the length of the table
      @count = @columns[column_name].length
    end

  end

  # Fetches data from the specific column indexes and packages them into a hash
  # @param index [integer] :: The first record that is fetched
  # @param length [integer] :: The number of records that are fetched
  # @return [hash] :: Hash with the column name as the key, and the dataset for that column as the value
  def [](index, length=1)
    # This is where we are going to store our column data
    data = {}

    # Iterate through each of our columns
    @columns.each do |name, column_data|
      # Store the data fetched from the column under that column's name
      data[name] = (length == 1 ? column_data[index] : column_data[index, length])
    end

    # Return the hash containing all of the column data
    data
  end

  # Imports data from an csv and creates a new table object. NOTE: This requires that the first row in the CSV be the column names
  # @param name [string] :: The name of the table to be created
  # @param path [string] :: The path to the CSV file
  # @return [Table] :: The table object that was created from the CSV
  def self.import_csv(name, path)

    # Parse the CSV into an array of arrays
    raw_data = CSV.read(path)

    # Delete the first row and save it as the column names
    column_names = raw_data.delete_at(0)

    # Create a new table
    table = Table.new(name, column_names)

    # Convert our column names into a hash where the names are the keys and the values are empty lists
    sorted_data = Hash[column_names.collect { |column_name| [column_name, []] } ]

    # Iterate through the raw data and sort everything into columns
    raw_data.each do |row|
      (0..row.length-1).each do |index|
        sorted_data[column_names[index]] << row[index]
      end
    end

    # Now that the data's sorted, we can just insert it
    table.insert(sorted_data)

    # Return the table object
    table
  end

  private

  # Validates that the data is valid for insertion into the table.  Will raise an exception if it isn't.
  # @param data [hash] :: A hash where the key is the column, and the value is an array of data to be imported
  def validate_insert(data)

    # If the number of columns in the data does not match the number of columns in the table, error out
    unless data.length == @columns.length
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError("#{data.length} columns in data set, #{@columns.length} expected.")
    end

    # We need to track the number of rows in each column of our data, but we need to scope it outside our loop, so we initialize it to -1
    column_data_length = -1

    # Iterate through each column
    data.each do |column_name, column_data|

      # If the column data length is -1, it has not been set yet, so we set it
      if column_data_length == -1
        column_data_length = column_data.length

      # If the column data length is different than a previously saved length, error out since they should all be the same.
      elsif column_data_length != column_data.length
        require './src/exceptions/InvalidDataSetError'
        raise InvalidDataSetError('Datasets columns contain different number of records.')
      end

      # If the column name from the data is not saved to the table, error out since our table can't hold it
      unless @columns.include?(column_name)
        require './src/exceptions/InvalidDataSetError'
        raise InvalidDataSetError("Column #{column_name} was in the dataset, but not the table.")
      end
    end
  end
end
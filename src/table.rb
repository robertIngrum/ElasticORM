require 'column'

# This class represents a data structure similar to a table, where data is stored in rows and grouped by columns
class Table

  # Creates a new Table
  # @param name [string] :: String representing the name of the table
  # @param column_names [array] :: Contains an array of strings, each of which will be assigned as the name of a column
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
  # @param count [integer] :: Defaults to 0, the length of the column (will be filled with the default value)
  def add_column(name, default, count=0)

    # Make sure there isn't already a column with the same name
    if @columns.include?(name)
      require 'exceptions/ColumnAlreadyExistsError'
      raise ColumnAlreadyExistsError.new(name)
    end

    # Create the new column
    @columns[name] = Column.new(name, default, count)

  end

  # Inserts data into our table
  # @param data [hash] :: A dictionary containing the column name for the key and an array of data for the value
  def insert(data)
    # Iterate through each column in the data
    data.each do |column_name, column_data|
      # Push the new data to the end up the currently stored data
      @columns[column_name].push(*column_data)
    end
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
        sorted_data[column_names[index]] = raw_data[index]
      end
    end

    # Now that the data's sorted, we can just insert it
    table.insert(sorted_data)

    # Return the table object
    table
  end
end
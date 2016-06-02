require './src/aggregator'
require './src/table'

# This class represents a segment of data that belongs to a table
class Dataset

  attr_reader :table
  attr_reader :filters
  attr_reader :groups
  attr_reader :joins
  attr_reader :result

  # Creates a new dataset from a given table
  # @param table [Table] :: A valid table object
  # @return [Dataset] :: A dataset built from the table
  def initialize(table)
    # Save the base properties with an empty query
    @table = table
    @filters = []
    @groups = []
    @joins = []

    # Build the dataset
    fetch
  end

  # Performs a very simple where on the dataset
  # @param table_name [string] :: The name of the table that is being filtered
  # @param column_name [string] :: The name of the column that is being filtered
  # @param proc [Proc] :: The proc that the  column data is being filtered through.  Should have one parameter and return true if valid or false if invalid.
  def filter(table_name, column_name, proc)

    # Raise an error if the filter is not being performed on the main table or one of the tables that have been joined
    unless (@table.name == table_name && @table.columns.include?(column_name)) ||
        (@joins.include?(table_name) && @joins[table_name].columns.include?(column_name))
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A join was performed on a dataset without a matching table or column.')
    end

    # Raise an error if the proc is not a valid proc
    unless proc.class == Proc && proc.arity == 1
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('The proc used to filter a dataset was not a valid Proc.')
    end

    # Save the filter
    @filters << {table_name: table_name, column_name: column_name, proc: proc}

    # Rebuild the dataset
    fetch
  end

  # Performs a group by on the dataset
  # @param table_name [string] :: The name of the table that is being grouped
  # @param column_name [string] :: The name of the column that is being grouped
  # @param aggregation_method [symbol] :: The name of the aggregation method that is being called on the data
  def group_by(table_name, column_name, aggregation_method)

    # Raise an error if the group by is not being performed on the main table or one of the tables that have been joined
    unless (@table.name == table_name && @table.columns.include?(column_name)) ||
        (@joins.include?(table_name) && @joins[table_name].columns.include?(column_name))
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A group by was performed on a dataset without a matching table or column.')
    end

    # Raise an error if the aggregation method is not in the aggregator
    unless Aggregator::METHODS.include?(aggregation_method)
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A group by was performed on a dataset with an invalid aggregation method.')
    end

    # Save the group by
    @groups << {table_name: table_name, column_name: column_name, aggregation_method: aggregation_method}

    # Rebuild the dataset
    fetch
  end

  # Performs a simple inner join on another table. TODO: Implement aliases and different joins
  # @param table [Table] :: The table that is being joined
  # @param column_name [string] :: The column that is being joined
  # @param target_table_name [string] :: The table that the table is being joined to
  # @param target_column_name [string] :: The column that the table is being joined to
  def join(table, column_name, target_table_name, target_column_name)

    # Raise an error if the table is not of class Table
    unless table.class == Table
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A join was performed with an object that was not of class Table.')
    end

    # Raise an error if the table does not contain the column
    unless table.columns.include?(column_name)
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A join was performed with a Table that does not contain the corresponding column name.')
    end

    # Raise an error if the join is not being performed on the main table or one of the tables that have already been joined
    unless (@table.name == target_table_name && @table.columns.include?(target_column_name)) ||
        (@joins.include?(target_table_name) && @joins[target_table_name].columns.include?(target_column_name))
      require './src/exceptions/InvalidDataSetError'
      raise InvalidDataSetError.new('A group by was performed on a dataset without a matching table or column.')
    end

    # Save the join
    @joins << {
        table: table,
        column_name: column_name,
        target_table_name: target_table_name,
        target_column_name: target_column_name
    }

    # Rebuild the dataset
    fetch
  end

  private

  # Performs the query and fetches all of the relevant data.  Then stores it to result
  # @returns [hash] :: Hash of columns and their data
  def fetch

    # If there are joins, prepend the table name before the column name
    prepend_table_name = !@joins.length.zero?

    # Get the base table data from the columns
    table_data = convert_table_to_table_data(@table, prepend_table_name)

    # Store the table data as the result and return it
    @result = table_data

  end

  # Pulls the raw data from a table and it's columns.  Also performs filters and group bys.
  # @param table [Table] :: The table that is to be converted
  # @return [Hash] :: A hash where the key is the column name, and the values are arrays with the raw data
  def convert_table_to_table_data(table, prepend_table_name = false)

    # Grab the column prefix for the column names
    column_prefix = build_column_prefix(table.name, prepend_table_name)

    # First we duplicate the table's columns object (we don't want to modify the actual table)
    table_data = table.columns.dup

    # Then we iterate over the columns and modify them in place, stripping away the column object and leaving the data
    table_data = table_data.map do |column_name, column|
      ["#{column_prefix}#{column_name}",  column[0..column.length - 1]]
    end.to_h

    # TODO: The filter and group loops are almost identical, combine them
    # Iterate through each filter to see if it applies to the current table.
    @filters.each do |filter|
      if filter[:table_name] == table.name

        # Get the column that is being filtered
        column = table_data[column_prefix << filter[:column_name]]

        table_data = apply_filter(table_data, column, filter[:proc])

      end
    end

    # Iterate through each group by to see if it applies to the current table.
    @groups.each do |group|
      if group[:table_name] == table.name

        # Get the column that is being grouped
        column = table_data[column_prefix << group[:column_name]]

        table_data = apply_group_by(table_data, column, group[:aggregation_method])
      end
    end

    # TODO: Currently, it is possible to get some very strange functionality with the same table joined multiple times.
    # This is because aliases are currently not supported and there isn't an easy way to keep track of multiple instances
    # of the same table.

    # Perform every join that is targeting the current table, and then recursively convert the joined table to table data
    @joins.each_with_index do |join_data, index|
      if join_data[:target_table_name] == table.name

        # First thing to do is remove the join from the list.  This will prevent infinite loops with multiple joins
        @joins.delete_at(index)

        # Next, recursively build out the new table and save the table data to the target table data.
        # Also clear out the table data since it needs to be rebuilt
        joined_table_data = convert_table_to_table_data(join_data[:table], prepend_table_name)
        target_table_data = table_data.dup
        table_data = {}


        # Since we currently only support inner joins, we need to find the intersection of the joined column and the target column
        joined_column_prefix = build_column_prefix(join_data[:table].name, prepend_table_name)
        joined_column = joined_table_data["#{joined_column_prefix}#{join_data[:column_name]}"]
        target_column = target_table_data["#{column_prefix}#{join_data[:target_column_name]}"]

        # Convert the two columns to arrays of hashes that contain both the index and value. Then sort the two columns
        # by value.  Note, the order doesn't actually matter, so long as they are both sorted the same way
        joined_column, target_column = [joined_column, target_column].map! do |column|
          column.each_with_index.map { |value, i| {index: i, value: value} }.sort { |a, b| a[:value] <=> b[:value] }
        end

        # Groupings are stored as an array of hashes which contain the joined index and target index
        groupings = []

        # Iterate through the target column, then the joined column.
        target_column.each_with_index do |target_row, target_position|
          joined_column.each_with_index do |joined_row, joined_position|
            # If the values of the row are the same, we have a valid join and store the pairings.
            if target_row[:value] == joined_row[:value]
              groupings << {target: target_position, joined: joined_position}

            # If the value of the first row is less than the value of the second row, break out of the joined loop because it's value will never decrease
            elsif target_row[:value] < joined_row[:value]
              break
            end
          end
        end

        # TODO: Combine the next two loops since they're nearly the same
        # Iterate through each column in the target column and apply the groupings
        target_table_data.each do |column_name, column|
          # For each record in the groupings, grab the index from the column and save it to the table data under the column name
          table_data[column_name] = groupings.map {
              |grouping| column[grouping[:target].to_i].to_s
          }
        end

        # Iterate through each column in the joined column and apply the groupings
        joined_table_data.each do |column_name, column|
          # If the column is the same one that the join was performed on, skip it since it's the same as the target table
          unless column_name == joined_column_prefix << join_data[:column_name]
            # For each record in the groupings, grab the index from the column and save it to the table data under the column name
            table_data[column_name] = groupings.map { |grouping| column[grouping[:joined]]}
          end
        end
      end
    end

    # Then we just return the raw table data
    table_data
  end

  def apply_filter(table_data, filtered_column, filter_proc)
    # Save every index that is to be dropped
    dropped_indexes = []

    # Iterate through each index in the column
    (0..filtered_column.length - 1).each do |index|

      # Add the index to the dropped indexes unless the proc filter returns true
      dropped_indexes << index unless filter_proc.call(filtered_column[index])

    end

    # Sort the dropped indexes first, it's important we delete last to first
    dropped_indexes.sort!

    # Iterate through every column and remove the dropped indexes from largest to smallest.  TODO: See if this can be done without nested loops
    table_data.each do |_, column|
      dropped_indexes.reverse_each do |index|
        column.delete_at(index)
      end
    end

    # Return the filtered table data
    table_data

  end

  def apply_group_by(table_data, grouped_column, aggregation_method)
    # Save the index groupings
    index_groupings = {}

    # Iterate through each index in the column
    (0..grouped_column.length - 1).each do |index|

      # If the column value is already a key in index groupings, append the index to the values that are already there.
      if index_groupings.include?(grouped_column[index])
        index_groupings[grouped_column[index]] << index
      # Else, add it and set the value to an array with the index.
      else
        index_groupings[grouped_column[index]] = [index]
      end

    end

    # Iterate through every column and perform the groupings.  Then return the result.  TODO: See if this can be done without nested loops
    table_data = table_data.map do |column_name, column|

      # If the column is the one we're grouping, just take the keys from our index groupings and replace it with those.
      if column == grouped_column
        [column_name, index_groupings.keys]

      # Otherwise, use the aggregator to combine the values into one
      else
        # An array to store the aggregated values
        aggregated_column = []

        # Iterate through the index groupings and aggregate each
        index_groupings.each do |__, indexes|

          # Start off with the current value equal to the first value
          current_value = column[indexes[0]]

          # Iterate through the length of the array, keeping track of the number of items that have been iterated through
          (2..indexes.length).each do |count|

            # Store the current index that is being aggregated, then pass everything into the aggregator
            index = indexes[count-1]
            current_value = Aggregator.aggregate(aggregation_method, current_value, column[index], count)
          end

          # Append the current, fully aggregated value to the aggregated column
          aggregated_column << current_value
        end

        # Return the column name and aggregated column to the map function
        [column_name, aggregated_column]
      end

    end.to_h
  end

  def build_column_prefix(table_name, prepend_table_name)
    # If prepend table name is true, we need to add 'table_name__' before every column, else leave it blank
    prepend_table_name ? "#{table_name}__" : ''
  end
end
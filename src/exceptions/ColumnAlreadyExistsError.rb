# Thrown when trying to create a column with a name that already exists
class ColumnAlreadyExistsError < StandardError

  attr_reader :column_name

  # Creates a new ColumnAlreadyExistsError
  # @param column_name [string] :: Represents the name of the column that was created.
  # @param note [string] :: Defaults to nil, this optional parameter can be used to pass additional notes about the error.
  # @return [ColumnAlreadyExistsError] :: Returns an instance of the ColumnAlreadyExistsError
  def initialize(column_name, note=nil)
    # Save the column name to the exception for debugging purposes
    @column_name = column_name

    # Pass a custom message to standard error.  Note that the message only includes the note if it is not nil.
    super("A column with the name #{column_name} already exists#{ " (#{note})" unless note.nil?}.")
  end
end
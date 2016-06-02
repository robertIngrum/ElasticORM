# Thrown when trying to use a dataset that does not match it's table
class InvalidDataSetError < StandardError

  attr_reader :reason

  # Creates a new InvalidDataSetError
  # @param reason [string] :: Represents the reason the dataset was rejected.
  # @param note [string] :: Defaults to nil, this optional parameter can be used to pass additional notes about the error.
  # @return [InvalidDataSetError] :: Returns an instance of the InvalidDataSetError error
  def initialize(reason, note=nil)

    @reason = reason

    # Pass a custom message to standard error.  Note that the message only includes the note if it is not nil.
    super("Dataset was rejected because: #{reason} #{"(#{note})" unless note.nil?}")
  end
end
# Thrown when the aggregator encounters an error.  This is kind of a catch all for anything pertaining to the aggregator.  This should probably be broken up.
class AggregatorError < StandardError

  attr_reader :reason

  # Creates a new AggregatorError
  # @param reason [string] :: Represents the reason the aggregator failed.
  # @param note [string] :: Defaults to nil, this optional parameter can be used to pass additional notes about the error.
  # @return [AggregatorError] :: Returns an instance of the AggregatorError
  def initialize(reason, note=nil)

    @reason = reason

    # Pass a custom message to standard error.  Note that the message only includes the note if it is not nil.
    super("Aggregator failed because: #{reason} #{"(#{note})" unless note.nil?}")
  end
end
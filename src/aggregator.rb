# This class is used to perform group by operations on tables.  Currently is static, don't really need to store anything.
class Aggregator
  METHODS = {
      sum: Proc.new { |current_val, new_val| current_val + new_val },
      average: Proc.new { |current_average, count, new_val| ((current_average * count) + new_val) / (count + 1) },
      min: Proc.new { |current_val, new_val| [current_val, new_val].min },
      max: Proc.new { |current_val, new_val| [current_val, new_val].max }
  }

  # Performs a specific aggregation method on the arguments passed in
  # @param method [symbol] :: The aggregation method that is being performed.  (From METHODS)
  # @param *arguments [?] :: The parameters to the aggregation method that was chosen.
  # @return [?] :: The result of the aggregation method
  def self.aggregate(method, *arguments)
    # Get the number of arguments needed from the chosen aggregation method
    method_arguments = METHODS[method].arity

    # If there are fewer arguments than the method requires, raise an exception
    if arguments.length < method_arguments
      require './src/exceptions/AggregatorError'
      raise AggregatorError('The number of arguments passed in does not match the number of arguments required by the chosen aggregation method.')
    end

    # Select the number of arguments needed by the aggregation method
    required_arguments = arguments[0..method_arguments - 1]

    # Call the aggregation method and implicitly return it
    METHODS[method].call(*required_arguments)
  end
end
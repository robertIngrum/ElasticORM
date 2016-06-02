# This class represents a data column, where similar data is grouped together and identified by index
class Column

  attr_accessor :name
  attr_reader :default

  # Creates a new Column
  # @param name [string] :: String representing the name of the column
  # @param default [?] :: The default value of the column if none is passed in
  # @param count [integer] :: The length of the column on initialization.  All rows will be the default value
  # @return [Column] :: Returns an instance of the column object.
  def initialize(name, default, count=0)

    # We need to store the name and default for later.
    @name = name
    @default = default

    # This will contain all of our column data
    @storage = []

    # We need to populate our storage array with default data until it is as long as our count
    while @storage.length < count
      @storage.push(default)
    end

  end

  # This acts as an accessor on the storage array, allowing this class to be used like a very simple array
  # @param start [integer] :: The index of the first row that is being fetched
  # @param length [integer] :: The length of the dataset that is being fetched.  This defaults to 1
  # @return [?]  :: The data that is stored at the given index in @storage.  Returns an array if length > 1
  def [](start, length=1)
    length == 1 ? @storage[start] : @storage[start, length]
  end

  # This acts as a setter on the storage array, allowing this class to be used like a very simple array
  # @param key [integer] :: The index of the row that is being set
  # @param value [?] :: The value that the given index is being set to
  def []=(key, value)
    @storage[key] = value
  end

  # This just returns the length of our storage array
  # @return [integer] :: The length of the storage array
  def length
    @storage.length
  end

  # This just adds the new data to the end of our storage array
  # @param new_data [array] :: The new data being added to @storage
  def push(new_data)
    @storage.push(new_data)
  end
end

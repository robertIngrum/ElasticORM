# Building a quick script to go through each of the points on the original doc and show how I addressed them.

# 1. Can define models with API
### I just did this when you first initialize a table.  It allows you to input the column names, so you can decide
### on the structure of the table.
require './src/table'
table = Table.new('test', ['col1', 'col2', 'col3'])
print '1: '
p table.columns

# 2. Loads up CSV files for models
### I built out a static method to handle this.  Just pass in a name for the table and a path and it will create a new
### table for the data.  The import code can actually be separated out so that data can be imported to existing tables,
### but I haven't quite gotten that far yet.
table = Table.import_csv('CSV_test', './src/bin/TestCSV.csv')
print '2: '
p table.columns

# 3. Can define field names for columns
### This is done whenever you initialize a table.  Since you initialize a table with an array of names for
### each column, the fields are always named.  I don't currently have a way to rename them though.
print '3: '
p table.columns['data1'].name

# 4. Can perform the equivalent of a GROUP BY operation to combine records
### There is a group by method when you generate a dataset from a table.  It also contains 4 default aggregators,
### but it's very easy to add more since the aggregator has been separated out.
require './src/dataset'
table = Table.new('1', ['col1', 'col2'])
table.insert({'col1' => [1, 1, 2, 3, 3], 'col2' => [2, 5, 6, 3, 2]})
dataset = Dataset.new(table)
dataset.group_by('1', 'col1', :sum)
print '4: '
p dataset.result

# 5. Can define and load joins between models by field name
### I didn't build out a separate object for this, but rather stored it with my dataset object.  It's still
### technically possible to load joins from other datasets, but it's just difficult.  I think the filters, groups,
### and joins could have been built out into separate objects to simplify things a bit.  Also, only inner joins
### are currently supported
table2 = Table.new('2', ['col1', 'col3'])
table2.insert({'col1' => [1, 2, 3, 4, 5], 'col3' => [2, 4, 5, 3, 2]})
dataset = Dataset.new(table)
dataset.join(table2, 'col1', '1', 'col1')
print '5: '
p dataset.result

# 6. Unit Tests
### Unit tests can be found in the test directory.  They aren't complete but they test the basic functionality.
### They also don't have the comments that I would usually put in them, but they all pass and test every public
### function.


# 7. Can define aggregation strategy for a group by operation
### This is what the aggregator class is for.  If you append a new key value pair to the METHODS constant,
### it can then be called as an aggregation method in the group by function.
require './src/aggregator'
Aggregator::METHODS[:rand] = Proc.new { |current_val, new_val| [current_val, new_val].sample }
dataset = Dataset.new(table)
dataset.group_by('1', 'col1', :rand)
print '7: '
p dataset.result

# 8. Efficient algorithm design
### I think I definitely could have done better here.  I decided early on to sort data into columns since it would make
### grouping faster, but I don't think that's the case after all.  The dataset class is also more cluttered than I would
### like and I think a lot of loops could be combined.

# 9. Full test coverage
### While every public method is tested, I don't believe there is full test coverage at this point.

# 10. Query builder (basic WHERE implementation)
### This is actually fully functional, but it's called filter in this case.  It accepts a proc that is called on each
### value in a column and keeps the data if it evaluates to true.  There are a few bugs with this because
### I don't have aliases implemented, but overall it's functional.  In general, complex datasets cause
### odd interactions, in part because the datasets are built recursively.  So if a is joined to b, then b to c, and
### then c back to a, the wheres and joins will be applied in a strange order resulting in a different dataset than
### was potentially expected.  Aliases would solve this, but I didn't quite get that far.
dataset = Dataset.new(table)
dataset.filter('1', 'col1', Proc.new { |x| x == 1})
print '10: '
p dataset.result

# This was a ton of fun, let me know if there's anything I can answer or add.  Also hosted on Github here: https://github.com/rkingrum/ElasticORM
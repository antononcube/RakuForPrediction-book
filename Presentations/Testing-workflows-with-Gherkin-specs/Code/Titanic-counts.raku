
use v6.d;

use Data::ExampleDatasets;
use Data::Reshapers;
use Data::Summarizers;
use DSL::English::DataQueryWorkflows;

my @dsTitanic = get-titanic-dataset;

say to-pretty-table(@dsTitanic.pick(6), field-names=>@dsTitanic.head.keys.sort.List);

my $obj = @dsTitanic ;
$obj = group-by($obj, "passengerSex") ;
say "counts: ", $obj>>.elems
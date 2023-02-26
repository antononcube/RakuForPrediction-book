
ToDataQueryWorkflowCode 'use @dsTitanic;
group by passengerSex;
show counts'


ToDataQueryWorkflowCode 'use @dsTitanic;
group by passengerSex;
show counts;
include setup code' --target=Raku --format=hash


dsl-translation 'DSL TARGET Raku::Reshapers;
use @dsTitanic;
group by passengerSex;
show counts;
include setup code' --format=code

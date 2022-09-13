# Standard Data Wrangling Commands

***WL::System, version 0.9***

Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[SimplifiedMachineLearningWorkflows-book at GitHub](https://github.com/antononcube/SimplifiedMachineLearningWorkflows-book)  
September 2022  



------

## Introduction

This document demonstrates and exemplifies the abilities of the Raku package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows), [AAp1],
to produce executable Python code that fits majority of the data wrangling use cases.

The examples should give a good idea of the English-based Domain Specific Language (DSL) utilized by [AAp1].

The data wrangling in Python is done with the package ["pandas"](https://pandas.pydata.org).

This notebook has examples that were used in the presentation
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs), [AAv1].
That presentation is an introduction to data wrangling from a more general, multi-language perspective.

*It is assumed that the readers of this notebook are familiar with the general data processing workflow discussed in the presentation [AAv1].*

For detailed introduction into data wrangling (with- and in Raku) see the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/), [AA1].
(And its Bulgarian version [AA2].)

Some of the datasets are acquired with the package
["ExampleDatasets"](https://pypi.org/project/ExampleDatasets/).

The data wrangling sections have two parts: a code generation part, and an execution steps part.

### Generated code

- Jupyter notebooks allow the invocation of shell commands and the definition of command aliases. Both of these features are leveraged.
- The Raku package [AAp1] is utilized in this Jupyter notebook through package's Command Line Interface (CLI) script `ToDataQueryWorkflowCode`.
- Additionally, the CLI script `ToDataQueryWorkflowCode` allows its code results to be copied to the clipboard of the host Operating System (OS).



------

## Setup


### Load packages

```mathematica
Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/DataReshape.m"];
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/DSLMode.m"];
```

### Load data


In order to use file sources with *unverified* Secure Sockets Layer (SSL) we use this code:


#### Titanic data

We can obtain the Titanic dataset provided by project ["MathematicaVsR"](https://github.com/antononcube/MathematicaVsR):

```mathematica
dfTitanic = Import["https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv", "Dataset", HeaderLines->1];
Dimensions[dfTitanic]
```

#### Anscombe's quartet

The dataset named
["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet)
has four datasets that have nearly identical simple descriptive statistics,
yet have very different distributions and appear very different when graphed.

Anscombe's quartet is (usually) given in a table with eight columns that is somewhat awkward to work with.
Below we demonstrate data transformations that make plotting of the four datasets easier.
The DSL specifications used make those data transformations are programming language independent.

We can obtain the Anscombe's dataset using the function `example_dataset` provided by "ExampleDatasets", [AAp4]:

```mathematica
dfAnscombe = ResourceFunction["ExampleDataset"][{"Statistics", "AnscombeRegressionLines"}];
Dimensions[dfAnscombe]
```

#### Star Wars films data

We can obtain [Star Wars films](https://en.wikipedia.org/wiki/List_of_Star_Wars_films) datasets using the `pandas` function `read_csv`:

```mathematica
dfStarwars = Import["https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwars.csv", "Dataset", HeaderLines->1];
dfStarwarsFilms = Import["https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv", "Dataset", HeaderLines->1];
dfStarwarsStarships = Import["https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv", "Dataset", HeaderLines->1];
dfStarwarsVehicles = Import["https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv", "Dataset", HeaderLines->1];
```

Here are the dimensions of the obtained data frames:

```mathematica
Map[ # -> Dimensions[ToExpression[#]]&, {"dfStarwars", "dfStarwarsFilms", "dfStarwarsStarships", "dfStarwarsVehicles"}]
```

### External sessions objects

```mathematica
StartRakuProcess["Raku" -> $HomeDirectory<>"/.rakubrew/shims/raku"]
```

```mathematica
shellSession = StartExternalSession["Shell"];
```

### Handy conversion function


Make an "alias" for the UNIX (macOS or Linux) Command Line Interface (CLI) program `ToDataQueryWorkflowCode`:

```mathematica
Clear[FromDSL];
FromDSL[spec_String, target_String : "WL::System"] := FromDSL[shellSession, spec, target];
FromDSL[shellSession_ExternalSessionObject, spec_String, target_String : "WL::System"] := ExternalEvaluate[shellSession, "ToDataQueryWorkflowCode " <> target <>" '" <> spec <> "'"];
```

Try out the alias:`

```mathematica
FromDSL["use dfTitanic"]
```

### Options settings

Here we set `MaxItems` option for `Dataset` to show all columns:

```mathematica
SetOptions[Dataset, MaxItems->{15, All}]
```

------

## Multi-language translation

In this section show that the Raku package "DSL::English::DataQueryWorkflows" generates code for multiple programming languages.
Also, it translates the English DSL into DSLs of other natural languages.

### Programming languages

```mathematica
command="use dfTitanic; group by passengerClass; counts;";
dsRes=Dataset@Map[<| "Language" -> #, "Code" -> ToDataQueryWorkflowCode[command, "Target"->#, "Execute"->False] |> &, {"Julia", "Python", "R", "Raku", "WL"}];
ResourceFunction["GridTableForm"][dsRes]
```

### Natural languages

```mathematica
dsRes=Dataset@Map[<| "Language" -> #, "Code" -> ToDataQueryWorkflowCode[command, "Target"->#, "Execute"->False] |> &, {"Bulgarian", "English", "Korean", "Russian", "Spanish"}];
ResourceFunction["GridTableForm"][dsRes]
```

------

## Using `ToDataQueryWorkflowCode`

The WL package "DSLMode.m", [AAp1], provides the function `ToDataQueryWorkflowCode`.
Here is its usage message:

```mathematica
?ToDataQueryWorkflowCode 
```

Here are function's options:

```mathematica
ToDataQueryWorkflowCode//Options
```

------

## Trivial workflow

In this section we demonstrate code generation and execution results for very simple (and very frequently used) sequence of data wrangling operations.

### Code generation

For the simple specification:

```mathematica
command0 = "
use dfTitanic;
group by passengerClass;
show counts;
";
```

We generate target code with `ToDataQueryWorkflowCode` using the alias `to_pandas` defined above:

```mathematica
FromDSL[command0]
```
**Remark:** Executing the commands above puts the generated code into the clipboard of the Operating System (OS).

Here is the execution (and result) of the generated code:

```mathematica
obj = dfTitanic;
obj = GroupBy[ obj, #["passengerClass"]& ];
Echo[Map[ Length, obj], "counts:"]
```

### Execution steps

Get the dataset into a "pipeline object":

```mathematica
obj = dfTitanic;
Dimensions[obj]
```

Group by column:

```mathematica
obj = GroupBy[ obj, #["passengerClass"]& ];
Length[obj]
```

Print the group sizes of the "pipeline object":

```mathematica
Map[Length, obj]
```

------

## Cross tabulation

[Cross tabulation](https://en.wikipedia.org/wiki/Contingency_table) is a fundamental data wrangling operation. For the related transformations to long- and wide-format see the section "Complicated and neat workflow".

### Code generation

Here we define a command that filters the Titanic dataset and then makes cross-tabulates:

```mathematica
command1 = "
use dfTitanic;
filter with passengerSex is \"male\" and passengerSurvival equals \"died\" or passengerSurvival is \"survived\" ;
cross tabulate passengerClass, passengerSurvival over passengerAge;
take pipeline value
"
```

```mathematica
FromDSL[command1]
```

#### Execution

```mathematica
obj = dfTitanic;
obj = Select[ obj, #["passengerSex"] == "male" && #["passengerSurvival"] == "died" || #["passengerSurvival"] == "survived" & ];
obj = ResourceFunction["CrossTabulate"][ { #["passengerClass"], #["passengerSurvival"], #["passengerAge"] }& /@ obj ];
obj
```

### Execution steps

Copy the Titanic data into a "pipeline object" and show its dimensions and a sample of it:


```mathematica
obj = dfTitanic;
Print["Dimensions:", Dimensions[obj]];
obj[[1;;7]]
```

Filter the data and show the number of rows in the result set:

```mathematica
obj = Select[ obj, #["passengerSex"] == "male" && #["passengerSurvival"] == "died" || #["passengerSurvival"] == "survived" & ];
Dimensions[obj]
```

Cross tabulate and show the result:

```mathematica
obj = ResourceFunction["CrossTabulate"][ { #["passengerClass"], #["passengerSurvival"], #["passengerAge"] }& /@ obj ];
obj
```

------

## Mutation with formulas

In this section we discuss formula utilization to mutate data. We show how to use column references.

Special care has to be taken when the specifying data mutations with formulas that reference to columns in the dataset.

The code corresponding to the `transform ...` line in this example produces
*expected* result for the target "R::tidyverse":

```mathematica
command2 = "use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
transform with bmi = ${mass/height^2*10000};
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending";
```

```mathematica
FromDSL[command2, "R::tidyverse"]
```

Specifically, for "WL::System" the transform specification line has to refer to the context variable `#`.
Here is an example:


```mathematica
command2p = "
use data frame dfStarwars;
transform with bmi = ${#[\"mass\"]/#[\"height\"]^2*10000} and homeworld = ${ToUpperCase@ToString@#[\"homeworld\"]};
take pipeline value";
```

```mathematica
FromDSL[command2p]
```

```mathematica
obj = dfStarwars;
obj = Map[ Join[ #, <|"bmi" -> #["mass"]/#["height"]^2*10000, "homeworld" -> ToUpperCase@ToString@#["homeworld"]|> ]&, obj];
obj

```

**Remark:** Note that we have to use single quotes for the command invocation; using double quotes will invoke the string interpolation feature.


------

## Grouping awareness

In this section we discuss the treatment of multiple "group by" invocations within the same DSL specification.

### Code generation

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- we can try to make the command sequence parsing to be "aware" of the grouping operations.

In the following example before applying the grouping operation in fourth line we have to flatten the data (which is grouped in the second line):

```mathematica
command3 = "
use dfTitanic;
group by passengerClass;
echo counts;
group by passengerSex;
show counts
";
```

```mathematica
FromDSL[command3]
```

### Execution

Here we execute the generated code:

```mathematica
obj = dfTitanic;
obj = GroupBy[ obj, #["passengerClass"]& ];
Echo[Map[ Length, obj], "counts:"];
obj = GroupBy[ Join @@ obj, #["passengerSex"]& ];
Echo[Map[ Length, obj], "counts:"]
```

### Execution steps

First grouping:

```mathematica
obj = dfTitanic;
obj = GroupBy[ obj, #["passengerClass"]& ];
Echo[Map[ Length, obj], "counts:"];
```

Before doing the second grouping we flatten the groups of the first:

```mathematica
obj = Join @@ obj;
Dimensions[obj]
```

Here we do the second grouping and print-out the group sizes:

```mathematica
obj = GroupBy[ obj, #["passengerSex"]& ];
Echo[Map[ Length, obj], "counts:"];
```

------

## Non-trivial workflow

In this section we generate and demonstrate data wrangling steps that clean, mutate, filter, group, and summarize a given dataset.

### Code generation


```mathematica
command4 = "
use dfStarwars;
replace missing with 0;
mutate with \"mass\" = ${obj[\"mass\"]} and \"height\" = ${obj[\"height\"]};  
show dimensions;
echo summary;
filter by birth_year greater than 27;
select homeworld, mass and height;
group by homeworld;
show counts;
summarize the variables mass and height with Mean and Median
";
```

```mathematica
FromDSL[command4]
```

### Execution

```mathematica
obj = dfStarwars;
obj = ReplaceAll[ obj, _Missing -> 0 ];
obj = Map[ Join[ #, <|"mass" -> obj["mass"], "height" -> obj["height"]|> ]&, obj];
Echo[Dimensions[obj], "dimensions:"];
Echo[ResourceFunction["RecordsSummary"][obj], "summary:"];
obj = Select[ obj, #["birth_year"] > 27 & ];
obj = Map[ KeyTake[ #, {"homeworld", "mass", "height"} ]&, obj];
obj = GroupBy[ obj, #["homeworld"]& ];
Echo[Map[ Length, obj], "counts:"];
```

```mathematica
obj = Dataset[obj][All, Association @ Flatten @ Outer[ToString[#1] <> "_" <> ToString[#2] -> Query[#2, #1] &,{"mass", "height"}, {Mean, Median}]]
```

### Execution steps

Here is code that cleans the data of missing values, and shows dimensions and summary (corresponds to the first five lines above):

```mathematica

```

Here is a sample of the dataset (wrangled so far):

```mathematica

```

Here we select the columns "homeworld", "mass", and "height", group by "homeworld", and show counts for each group:

```mathematica

```

Here is summarization at specified columns with specified functions:

```mathematica

```


------

## Joins

In this section we demonstrate the fundamental operation of joining two datasets.

### Code generation


```mathematica
command5 = "
use dfStarwarsFilms;
left join with dfStarwars by 'name';
replace missing with ${0};
sort by name, film desc;
take pipeline value
";
```

```mathematica
FromDSL[command5]
```

### Execution

```mathematica
obj = dfStarwarsFilms;
obj = JoinAcross[ obj, dfStarwars, {"name"}, "Left"];
obj = ReplaceAll[ obj, _Missing -> 0 ];
obj = ReverseSortBy[ obj, {#["name"], #["film"]}& ];
obj
```

------

## Complicated and neat workflow

In this section we demonstrate a fairly complicated data wrangling sequence of operations that transforms [Anscombe's quartet](https://en.wikipedia.org/wiki/Anscombe's_quartet) into a form that is easier to plot.

**Remark:** Anscombe's quartet has four sets of points that have nearly the same x- and y- mean values. (But the sets have very different shapes.)

### Code generation

```mathematica
command6 = "
use dfAnscombe;
convert to long form;
separate the data column \"Variable\" into \"Variable\" and \"Set\" with separator pattern \"\";
to wide form for id columns Set and AutomaticKey variable column Variable and value column Value
";
```

```mathematica
FromDSL[command6]
```

### Execution

```mathematica
obj = dfAnscombe;
obj = ToLongForm[ obj ];
obj = SeparateColumn[ obj, "Variable", {"Variable", "Set"}, "Separator" -> "" ];
obj = ToWideForm[ obj,  "IdentifierColumns" -> {"Set", "AutomaticKey"}, "VariablesFrom" -> "Variable", "ValuesFrom" -> "Value" ]

```

### Execution steps

Get a copy of the dataset into a "pipeline object":


```mathematica
obj = dfAnscombe;
obj
```


Summarize Anscombe's quartet (using the WFR function [`RecordsSummary`](https://resources.wolframcloud.com/FunctionRepository/resources/RecordsSummary/), [AAf2]):

```mathematica
ResourceFunction["RecordsSummary"][obj]
```

**Remark:** From the table above it is not clear how exactly we have to access the data in order to plot each of Anscombe's sets. The data wrangling steps below show a way to separate the sets and make them amenable for set-wise manipulations.

Very often values of certain data parameters are conflated and put into dataset's column names. (As in Anscombe's dataset.)

In those situations we:

- Convert the dataset into long format, since that allows column names to be treated as data

- Separate the values of a certain column into to two or more columns

Reshape the "pipeline object" into [long format](https://en.wikipedia.org/wiki/Wide_and_narrow_data):

```mathematica
obj = ToLongForm[ obj ];
obj[[1;;7]]
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```mathematica
obj = SeparateColumn[ obj, "Variable", {"Variable", "Set"}, "Separator" -> "" ];
obj[[1;;7]]
```

Reshape the "pipeline object" into [wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data) using appropriate identifier-, variable-, and value column names:

```mathematica
obj = ToWideForm[ obj,  "IdentifierColumns" -> {"Set", "AutomaticKey"}, "VariablesFrom" -> "Variable", "ValuesFrom" -> "Value" ];
obj[[1;;9]]
```

Plot each dataset of Anscombe's quartet:

```mathematica
GroupBy[obj, #Set&, ListPlot[{#X,#Y}& /@ #]&]
```

------

## References

### Articles

[AA1] Anton Antonov, ["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/) , (2021), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov, ["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/), (2022), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[HW1] Hadley Wickham, ["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01), (2011), [Journal of Statistical Software](https://www.jstatsoft.org/).

### Functions

[AAf1] Anton Antonov, ["ExampleDataset"](https://resources.wolframcloud.com/FunctionRepository/resources/ExampleDataset), (2020), [Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf2] Anton Antonov, ["RecordsSummary"](https://resources.wolframcloud.com/FunctionRepository/resources/RecordsSummary), (2020), [Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

### Packages

[AAp1] Anton Antonov, [DSL::English::DataQueryWorkflows Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows), (2020-2022), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian), (2022), [GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov, [DSL::Shared::Utilities::ComprehensiveTranslations Raku package](https://github.com/antononcube/Raku-Text-Plot), (2020-2022), [GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov, [Example Datasets, Python package](https://pypi.org/project/ExampleDatasets/), (2021-2022), [PyPI.org](https://pypi.org).


### Videos

[AAv1] Anton Antonov, ["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs), (2020), [Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).


# Standard Data Wrangling Commands

***Raku-centric, version 0.9***   
Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[SimplifiedMachineLearningWorkflows-book at GitHub](https://github.com/antononcube/SimplifiedMachineLearningWorkflows-book)   
September 2022

## Introduction

This document demonstrates and exemplifies the abilities of the package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows), [AAp1],
to produce executable code that fits majority of the data wrangling use cases.

The examples should give a good idea of the English-based Domain Specific Language (DSL)
utilized by [AAp1].

The data wrangling in Raku is done with the packages:
["Data::Generators"](https://raku.land/zef:antononcube/Data::Generators),
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), and
["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers).

This document has examples that were used in the presentation [“Multi-language Data-Wrangling Conversational Agent”](https://www.youtube.com/watch?v=pQk5jwoMSxs), [AAv1]. 
That presentation is an introduction to data wrangling from a more general, multi-language perspective.
It is assumed that the readers of this document are familiar with the general data processing workflow discussed in the presentation [AAv1]. Additional examples are discussed in the presentation ["Implementation of ML algorithms in Raku"](https://www.youtube.com/watch?v=efRHfjYebs4), [AAv2], (given at [TRC-2022](https://conf.raku.org/talk/170).)

For detailed introduction into data wrangling (with- and in Raku) see the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA1]. (And its Bulgarian version [AA2].)

Some of the data is acquired with the package
["Data::ExampleDatasets"](https://raku.land/zef:antononcube/Data::ExampleDatasets).

The data wrangling sections have two parts: a code generation part, and an execution steps part. 

### Document execution

This document has a Jupyter notebook version and a Markdownd file version. ("Document" is often used to mean any of those versions or both versions.)

The Markdown file version is a "computable Markdown document" -- the Raku cells are (context-consecutively) evaluated with the
["literate programming"](https://en.wikipedia.org/wiki/Literate_programming)
package
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AA3, AAp7].

### Other programming languages

Versions of this document (or notebook) are made for other programming languages: Python, R, and Wolfram Language (WL).
Here is a list of all notebooks hosted at GitHub repository 
["RakuForPrediction-book"](https://github.com/antononcube/RakuForPrediction-book):

- [Python](https://github.com/antononcube/RakuForPrediction-book/blob/main/Notebooks/Jupyter/Standard-data-wrangling-commands-Python.ipynb)

- [R](https://github.com/antononcube/RakuForPrediction-book/blob/main/Notebooks/Jupyter/Standard-data-wrangling-commands-R.ipynb)

- [Raku](https://github.com/antononcube/RakuForPrediction-book/blob/main/Notebooks/Jupyter/Standard-data-wrangling-commands-Raku.ipynb)

- [WL](https://github.com/antononcube/RakuForPrediction-book/blob/main/Notebooks/Jupyter/Standard-data-wrangling-commands-WL.ipynb)

**Remark:** Wolfram Language (WL) and Mathematica are used as synonyms.

------

## Setup

### Parameters


```raku
my $examplesTarget = 'Raku::Reshapers';
```




    Raku::Reshapers



### Load packages


```raku
use Stats;
use Data::ExampleDatasets;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;

use DSL::English::DataQueryWorkflows;
```

### Load data

#### Titanic data

We can obtain the Titanic dataset using the function `get-titanic-dataset` provided by "Data::Reshapers":


```raku
my @dfTitanic = get-titanic-dataset();
dimensions(@dfTitanic)
```




    (1309 5)



#### Anscombe's quartet

The dataset named
["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet)
has four datasets that have nearly identical simple descriptive statistics, 
yet have very different distributions and appear very different when graphed.

Anscombe's quartet is (usually) given in a table with eight columns that is somewhat awkward to work with.
Below we demonstrate data transformations that make plotting of the four datasets easier.
The DSL specifications used make those data transformations are programming language independent.

We can obtain the Anscombe's dataset using the function `example-dataset` provided by ["Data::ExampleDatasets"](https://raku.land/zef:antononcube/Data::ExampleDatasets):


```raku
records-summary(@dfTitanic)
```

    +-------------------+---------------+----------------+-----------------+----------------+
    | passengerSurvival | passengerSex  | passengerAge   | id              | passengerClass |
    +-------------------+---------------+----------------+-----------------+----------------+
    | died     => 809   | male   => 843 | 20      => 334 | 20      => 1    | 3rd => 709     |
    | survived => 500   | female => 466 | -1      => 263 | 201     => 1    | 1st => 323     |
    |                   |               | 30      => 258 | 717     => 1    | 2nd => 277     |
    |                   |               | 40      => 190 | 691     => 1    |                |
    |                   |               | 50      => 88  | 838     => 1    |                |
    |                   |               | 60      => 57  | 804     => 1    |                |
    |                   |               | 0       => 56  | 947     => 1    |                |
    |                   |               | (Other) => 63  | (Other) => 1302 |                |
    +-------------------+---------------+----------------+-----------------+----------------+





    ({id => 20      => 1, passengerAge => 20      => 334, passengerClass => 3rd => 709, passengerSex => male   => 843, passengerSurvival => died     => 809} {id => 201     => 1, passengerAge => -1      => 263, passengerClass => 1st => 323, passengerSex => female => 466, passengerSurvival => survived => 500} {id => 717     => 1, passengerAge => 30      => 258, passengerClass => 2nd => 277, passengerSex => , passengerSurvival => } {id => 691     => 1, passengerAge => 40      => 190, passengerClass => , passengerSex => , passengerSurvival => } {id => 838     => 1, passengerAge => 50      => 88, passengerClass => , passengerSex => , passengerSurvival => } {id => 804     => 1, passengerAge => 60      => 57, passengerClass => , passengerSex => , passengerSurvival => } {id => 947     => 1, passengerAge => 0       => 56, passengerClass => , passengerSex => , passengerSurvival => } {id => (Other) => 1302, passengerAge => (Other) => 63, passengerClass => , passengerSex => , passengerSurvival => })




```raku
my @dfAnscombe = |example-dataset('anscombe');
@dfAnscombe = |@dfAnscombe.map({ %( $_.keys Z=> $_.values>>.Numeric) });
dimensions(@dfAnscombe)
```




    (11 8)



#### Star Wars films data

We can obtain
[Star Wars films](https://en.wikipedia.org/wiki/List_of_Star_Wars_films)
datasets using (again) the function `example-dataset`:


```raku
my @dfStarwars = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwars.csv");
my @dfStarwarsFilms = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv");
my @dfStarwarsStarships = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv");
my @dfStarwarsVehicles = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv");

.say for <@dfStarwars @dfStarwarsFilms @dfStarwarsStarships @dfStarwarsVehicles>.map({ $_ => dimensions(::($_)) })
```

    @dfStarwars => (87 11)
    @dfStarwarsFilms => (173 2)
    @dfStarwarsStarships => (31 2)
    @dfStarwarsVehicles => (13 2)


------

## Multi-language translation

In this section show that the Raku package [“DSL::English::DataQueryWorkflows”](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows) generates code for multiple programming languages. 
Also, it translates the English DSL into DSLs of other natural languages.

### Programming languages


```raku
my $command0 = 'use dfTitanic; group by passengerClass; counts;';
<Python Raku R R::tidyverse WL>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```

    
    Python:
    obj = dfTitanic.copy()
    obj = obj.groupby(["passengerClass"])
    obj = obj.size()
    
    Raku:
    $obj = dfTitanic ;
    $obj = group-by($obj, "passengerClass") ;
    $obj = $obj>>.elems
    
    R:
    obj <- dfTitanic ;
    obj <- split( x = obj, f = obj[["passengerClass"]] ) ;
    obj = length(obj)
    
    R::tidyverse:
    dfTitanic %>%
    dplyr::group_by(passengerClass) %>%
    dplyr::count()
    
    WL:
    obj = dfTitanic;
    obj = GroupBy[ obj, #["passengerClass"]& ];
    obj = Map[ Length, obj]





    (True True True True True)



### Natural languages


```raku
<Bulgarian Korean Russian Spanish>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```

    
    Bulgarian:
    използвай таблицата: dfTitanic
    групирай с колоните: passengerClass
    намери броя
    
    Korean:
    테이블 사용: dfTitanic
    열로 그룹화: passengerClass
    하위 그룹의 크기 찾기
    
    Russian:
    использовать таблицу: dfTitanic
    групировать с колонками: passengerClass
    найти число
    
    Spanish:
    utilizar la tabla: dfTitanic
    agrupar con columnas: "passengerClass"
    encontrar recuentos





    (True True True True)



------

## Using DSL cells

If the package ["DSL::Shared::Utilities::ComprehensiveTranslations"](https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation), [AAp3], is installed
then DSL specifications can be directly written in the Markdown cells.

Here is an example:

```raku-dsl
DSL TARGET Python::pandas;
include setup code;
use dfStarwars;
join with dfStarwarsFilms by "name"; 
group by species; 
counts;
```

------

## Trivial workflow

In this section we demonstrate code generation and execution results for very simple (and very frequently used) sequence of data wrangling operations.

### Code generation

For the simple specification:


```raku
say $command0;
```

    use dfTitanic; group by passengerClass; counts;


We generate target code with `ToDataQueryWorkflowCode`:


```raku
ToDataQueryWorkflowCode($command0, target => $examplesTarget)
```




    $obj = dfTitanic ;
    $obj = group-by($obj, "passengerClass") ;
    $obj = $obj>>.elems



### Execution steps

Get the dataset into a "pipeline object":


```raku
my $obj = @dfTitanic;
dimensions($obj)
```




    (1309 5)



Group by column:


```raku
$obj = group-by($obj, "passengerClass") ;
$obj.elems
```




    3



Assign group sizes to the "pipeline object":


```raku
$obj = $obj>>.elems
```




    {1st => 323, 2nd => 277, 3rd => 709}



------

## Cross tabulation

[Cross tabulation](https://en.wikipedia.org/wiki/Contingency_table) 
is a fundamental data wrangling operation. For the related transformations to long- and wide-format
see the section "Complicated and neat workflow".

### Code generation

Here we define a command that filters the Titanic dataset and then makes cross-tabulates:


```raku
my $command1 = "use dfTitanic;
filter with passengerSex is 'male' and passengerSurvival equals 'died' or passengerSurvival is 'survived' ;
cross tabulate passengerClass, passengerSurvival over passengerAge;";

ToDataQueryWorkflowCode($command1, target => $examplesTarget);
```




    $obj = dfTitanic ;
    $obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
    $obj = cross-tabulate( $obj, "passengerClass", "passengerSurvival", "passengerAge" )



### Execution steps

Copy the Titanic data into a "pipeline object" and show its dimensions and a sample of it:


```raku
my $obj = @dfTitanic ;
say "Titanic dimensions:", dimensions(@dfTitanic);
say to-pretty-table($obj.pick(7));
```

    Titanic dimensions:(1309 5)
    +-------------------+------+--------------+--------------+----------------+
    | passengerSurvival |  id  | passengerSex | passengerAge | passengerClass |
    +-------------------+------+--------------+--------------+----------------+
    |      survived     | 551  |    female    |      20      |      2nd       |
    |        died       | 1231 |    female    |      0       |      3rd       |
    |      survived     | 135  |    female    |      -1      |      1st       |
    |      survived     | 1255 |     male     |      20      |      3rd       |
    |      survived     | 895  |     male     |      0       |      3rd       |
    |      survived     | 260  |     male     |      30      |      1st       |
    |        died       | 229  |     male     |      20      |      1st       |
    +-------------------+------+--------------+--------------+----------------+


Filter the data and show the number of rows in the result set:


```raku
$obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
say $obj.elems;
```

    1182


Cross tabulate and show the result:


```raku
$obj = cross-tabulate( $obj, "passengerClass", "passengerSurvival", "passengerAge" );
say to-pretty-table($obj);
```

    +-----+----------+------+
    |     | survived | died |
    +-----+----------+------+
    | 1st |   6671   | 4290 |
    | 2nd |   2776   | 4419 |
    | 3rd |   2720   | 7562 |
    +-----+----------+------+


------

## Mutation with formulas

In this section we discuss formula utilization to mutate data. We show how to use column references.

Special care has to be taken when the specifying data mutations with formulas that reference to columns in the dataset.

The code corresponding to the `transform ...` line in this example produces 
*expected* result for the target "R::tidyverse":


```raku
my $command2 = "use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
transform with bmi = `mass/height^2*10000`;
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending";

ToDataQueryWorkflowCode($command2, target => 'R::tidyverse');
```




    dfStarwars %>%
    dplyr::select(name, homeworld, mass, height) %>%
    dplyr::mutate(bmi = mass/height^2*10000) %>%
    dplyr::filter(bmi >= 30 & height < 200) %>%
    dplyr::arrange(desc(mass), desc(height))



Specifically, for ["Raku::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers) the transform specification line has to refer to the context variable `$_`.
Here is an example:


```raku
my $command2r = 'use data frame dfStarwars;
transform with bmi = `$_<mass>/$_<height>^2*10000` and homeworld = `$_<homeworld>.uc`;';

ToDataQueryWorkflowCode($command2r, target => 'Raku::Reshapers');
```




    $obj = dfStarwars ;
    $obj = $obj.map({ $_{"bmi"} = $_<mass>/$_<height>^2*10000; $_{"homeworld"} = $_<homeworld>.uc; $_ })



**Remark:** Note that we have to use single quotes for the command assignment; 
using double quotes will invoke Raku's string interpolation feature. 

------

## Grouping awareness

In this section we discuss the treatment of multiple "group by" invocations within the same DSL specification.

### Code generation 

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- we
can try to make the command sequence parsing to be "aware" of the grouping operations.

In the following example before applying the grouping operation in fourth line 
we have to flatten the data (which is grouped in the second line):


```raku
my $command3 = "use dfTitanic; 
group by passengerClass; 
echo counts; 
group by passengerSex; 
counts";

ToDataQueryWorkflowCode($command3, target => $examplesTarget)
```




    $obj = dfTitanic ;
    $obj = group-by($obj, "passengerClass") ;
    say "counts: ", $obj>>.elems ;
    $obj = group-by($obj.values.reduce( -> $x, $y { [|$x, |$y] } ), "passengerSex") ;
    $obj = $obj>>.elems



### Execution steps

First grouping:


```raku
my $obj = @dfTitanic ;
$obj = group-by($obj, "passengerClass") ;
say "counts: ", $obj>>.elems ;
```

    counts: {1st => 323, 2nd => 277, 3rd => 709}


Before doing the second grouping we flatten the groups of the first:


```raku
$obj = group-by($obj.values.reduce( -> $x, $y { [|$x, |$y] } ), "passengerSex") ;
$obj = $obj>>.elems
```




    {female => 466, male => 843}



Instead of `reduce` we can use the function `flatten` (provided by "Data::Reshapers"):


```raku
my $obj2 = group-by(@dfTitanic , "passengerClass") ;
say "counts: ", $obj2>>.elems ;
$obj2 = group-by(flatten($obj2.values, max-level => 1).Array, "passengerSex") ;
say "counts: ", $obj2>>.elems;
```

    counts: {1st => 323, 2nd => 277, 3rd => 709}
    counts: {female => 466, male => 843}


------

## Non-trivial workflow

In this section we generate and demonstrate data wrangling steps that clean, mutate, filter, group, and summarize a given dataset.

### Code generation


```raku
my $command4 = '
use dfStarwars;
replace missing with `<NaN>`;
mutate with mass = `+$_<mass>` and height = `+$_<height>`;
show dimensions;
echo summary;
filter by birth_year greater than 27;
select homeworld, mass and height;
group by homeworld;
show counts;
summarize the variables mass and height with &mean and &median
';

ToDataQueryWorkflowCode($command4, target => $examplesTarget)
```




    $obj = dfStarwars ;
    $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
    $obj = $obj.map({ $_{"mass"} = +$_<mass>; $_{"height"} = +$_<height>; $_ }) ;
    say "dimensions: {dimensions($obj)}" ;
    records-summary($obj) ;
    $obj = $obj.grep({ $_{"birth_year"} > 27 }).Array ;
    $obj = select-columns($obj, ("homeworld", "mass", "height") ) ;
    $obj = group-by($obj, "homeworld") ;
    say "counts: ", $obj>>.elems ;
    $obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (&mean, &median)) })



### Execution steps

Here is code that cleans the data of missing values, and shows dimensions and summary (corresponds to the first five lines above):


```raku
my $obj = @dfStarwars ;
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
$obj = $obj.map({ $_{"mass"} = +$_<mass>; $_{"height"} = +$_<height>; $_ }).Array ;
say "summary:" ;
records-summary($obj);
say "dimensions: {dimensions($obj)}" ;
```

    summary:
    +-----------------------------------------+------------------+----------------+----------------------------------------+-----------------+----------------------------------------+---------------+----------------------+-----------------+---------------+---------------+
    | height                                  | name             | species        | mass                                   | homeworld       | birth_year                             | hair_color    | sex                  | gender          | eye_color     | skin_color    |
    +-----------------------------------------+------------------+----------------+----------------------------------------+-----------------+----------------------------------------+---------------+----------------------+-----------------+---------------+---------------+
    | Min                       => 66         | Mon Mothma => 1  | Human    => 35 | Min                       => 15        | Naboo     => 11 | Min                       => 8         | none    => 37 | male           => 60 | masculine => 66 | brown   => 21 | fair    => 17 |
    | 1st-Qu                    => 166.5      | Eeth Koth  => 1  | Droid    => 6  | 1st-Qu                    => 55        | Tatooine  => 10 | 1st-Qu                    => 33        | brown   => 18 | female         => 16 | feminine  => 17 | blue    => 19 | light   => 11 |
    | Mean                      => 174.358025 | Kit Fisto  => 1  | NaN      => 4  | Mean                      => 97.311864 | NaN       => 10 | Mean                      => 87.565116 | black   => 13 | none           => 6  | NaN       => 4  | yellow  => 11 | dark    => 6  |
    | Median                    => 180        | Mace Windu => 1  | Gungan   => 3  | Median                    => 79        | Coruscant => 3  | Median                    => 52        | NaN     => 5  | NaN            => 4  |                 | black   => 10 | grey    => 6  |
    | 3rd-Qu                    => 191        | Dooku      => 1  | Twi'lek  => 2  | 3rd-Qu                    => 85        | Kamino    => 3  | 3rd-Qu                    => 72        | white   => 4  | hermaphroditic => 1  |                 | orange  => 8  | green   => 6  |
    | Max                       => 264        | Adi Gallia => 1  | Mirialan => 2  | Max                       => 1358      | Alderaan  => 3  | Max                       => 896       | blond   => 3  |                      |                 | red     => 5  | pale    => 5  |
    | (Any-Nan-Nil-or-Whatever) => 6          | Zam Wesell => 1  | Kaminoan => 2  | (Any-Nan-Nil-or-Whatever) => 28        | Corellia  => 2  | (Any-Nan-Nil-or-Whatever) => 44        | grey    => 1  |                      |                 | hazel   => 3  | brown   => 4  |
    |                                         | (Other)    => 80 | (Other)  => 33 |                                        | (Other)   => 45 |                                        | (Other) => 6  |                      |                 | (Other) => 10 | (Other) => 32 |
    +-----------------------------------------+------------------+----------------+----------------------------------------+-----------------+----------------------------------------+---------------+----------------------+-----------------+---------------+---------------+
    dimensions: 87 11


Here is the deduced type:


```raku
say deduce-type($obj);
```

    Vector((Any), 87)


Here is a sample of the dataset (wrangled so far):


```raku
say to-pretty-table($obj.pick(7));
```

    +--------------------+--------------+-----------+--------+--------------+--------------+-----------+-----------+------+------------+--------+
    |        name        |  skin_color  | eye_color |  sex   |  hair_color  |   species    | homeworld |   gender  | mass | birth_year | height |
    +--------------------+--------------+-----------+--------+--------------+--------------+-----------+-----------+------+------------+--------+
    |     Wat Tambor     | green, grey  |  unknown  |  male  |     none     |   Skakoan    |   Skako   | masculine |  48  |    NaN     |  193   |
    |       Bossk        |    green     |    red    |  male  |     none     |  Trandoshan  | Trandosha | masculine | 113  |     53     |  190   |
    |       Ackbar       | brown mottle |   orange  |  male  |     none     | Mon Calamari |  Mon Cala | masculine |  83  |     41     |  180   |
    |   Wilhuff Tarkin   |     fair     |    blue   |  male  | auburn, grey |    Human     |   Eriadu  | masculine | NaN  |     64     |  180   |
    | Beru Whitesun lars |    light     |    blue   | female |    brown     |    Human     |  Tatooine |  feminine |  75  |     47     |  165   |
    |    Arvel Crynyd    |     fair     |   brown   |  male  |    brown     |    Human     |    NaN    | masculine | NaN  |    NaN     |  NaN   |
    |        Finn        |     dark     |    dark   |  male  |    black     |    Human     |    NaN    | masculine | NaN  |    NaN     |  NaN   |
    +--------------------+--------------+-----------+--------+--------------+--------------+-----------+-----------+------+------------+--------+


Here we group by "homeworld" and show counts for each group:


```raku
$obj = group-by($obj, "homeworld") ;
say "counts: ", $obj>>.elems ;
```

    counts: {Alderaan => 3, Aleen Minor => 1, Bespin => 1, Bestine IV => 1, Cato Neimoidia => 1, Cerea => 1, Champala => 1, Chandrila => 1, Concord Dawn => 1, Corellia => 2, Coruscant => 3, Dathomir => 1, Dorin => 1, Endor => 1, Eriadu => 1, Geonosis => 1, Glee Anselm => 1, Haruun Kal => 1, Iktotch => 1, Iridonia => 1, Kalee => 1, Kamino => 3, Kashyyyk => 2, Malastare => 1, Mirial => 2, Mon Cala => 1, Muunilinst => 1, NaN => 10, Naboo => 11, Nal Hutta => 1, Ojom => 1, Quermia => 1, Rodia => 1, Ryloth => 2, Serenno => 1, Shili => 1, Skako => 1, Socorro => 1, Stewjon => 1, Sullust => 1, Tatooine => 10, Toydaria => 1, Trandosha => 1, Troiken => 1, Tund => 1, Umbara => 1, Utapau => 1, Vulpter => 1, Zolan => 1}


Here is summarization at specified columns with specified functions (from the "Stats"):


```raku
$obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (&mean, &median)) });
say to-pretty-table($obj.pick(7));
```

    +-------------+------------+-------------+-------------+---------------+
    |             | mass.mean  | height.mean | mass.median | height.median |
    +-------------+------------+-------------+-------------+---------------+
    | Corellia    | 78.500000  |  175.000000 |  78.500000  |   175.000000  |
    | Coruscant   |    NaN     |  173.666667 |     NaN     |   170.000000  |
    | Glee Anselm | 87.000000  |  196.000000 |  87.000000  |   196.000000  |
    | Kashyyyk    | 124.000000 |  231.000000 |  124.000000 |   231.000000  |
    | Mirial      | 53.100000  |  168.000000 |  53.100000  |   168.000000  |
    | Socorro     | 79.000000  |  177.000000 |  79.000000  |   177.000000  |
    | Umbara      | 48.000000  |  178.000000 |  48.000000  |   178.000000  |
    +-------------+------------+-------------+-------------+---------------+


------

## Joins

In this section we demonstrate the fundamental operation of joining two datasets.

### Code generation


```raku
my $command5 = "use dfStarwarsFilms;
left join with dfStarwars by 'name';
replace missing with `<NaN>`;
sort by name, film desc;
take pipeline value";

ToDataQueryWorkflowCode($command5, target => $examplesTarget)
```




    $obj = dfStarwarsFilms ;
    $obj = join-across( $obj, dfStarwars, ("name"), join-spec=>"Left") ;
    $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
    $obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse.Array ;
    $obj



### Execution steps


```raku
$obj = @dfStarwarsFilms ;
$obj = join-across( $obj, select-columns( @dfStarwars, <name species>), ("name"), join-spec=>"Left") ;
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
$obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse ;
to-pretty-table($obj.head(12))
```




    +----------------------+----------------+-----------------------+
    |         film         |    species     |          name         |
    +----------------------+----------------+-----------------------+
    | Attack of the Clones |    Clawdite    |       Zam Wesell      |
    |  Return of the Jedi  | Yoda's species |          Yoda         |
    |  The Phantom Menace  |    Quermian    |      Yarael Poof      |
    |      A New Hope      |     Human      |     Wilhuff Tarkin    |
    |  Return of the Jedi  |      Ewok      | Wicket Systri Warrick |
    |      A New Hope      |     Human      |     Wedge Antilles    |
    |  The Phantom Menace  |   Toydarian    |         Watto         |
    | Attack of the Clones |    Skakoan     |       Wat Tambor      |
    | Revenge of the Sith  |     Pau'an     |       Tion Medon      |
    | Attack of the Clones |    Kaminoan    |        Taun We        |
    | Revenge of the Sith  |    Wookiee     |        Tarfful        |
    | Revenge of the Sith  |      NaN       |       Sly Moore       |
    +----------------------+----------------+-----------------------+



------

## Complicated and neat workflow

In this section we demonstrate a fairly complicated data wrangling sequence of operations that transforms [Anscombe's quartet](https://en.wikipedia.org/wiki/Anscombe's_quartet) into a form that is easier to plot.

**Remark:** Anscombe's quartet has four sets of points that have nearly the same x- and y- mean values. (But the sets have very different shapes.)

### Code generation


```raku
my $command6 =
        'use dfAnscombe;
convert to long form;
separate the data column Variable into Variable and Set with separator pattern "";
to wide form for id columns Set and AutomaticKey variable column Variable and value column Value';

ToDataQueryWorkflowCode($command6, target => $examplesTarget)
```




    $obj = dfAnscombe ;
    $obj = to-long-format( $obj ) ;
    $obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
    $obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" )



### Execution steps

Get a copy of the dataset into a "pipeline object":


```raku
my $obj = @dfAnscombe;
say to-pretty-table($obj);
```

    +-----------+-----------+----+----+----------+-----------+----+----+
    |     y1    |     y3    | x2 | x4 |    y2    |     y4    | x3 | x1 |
    +-----------+-----------+----+----+----------+-----------+----+----+
    |  8.040000 |  7.460000 | 10 | 8  | 9.140000 |  6.580000 | 10 | 10 |
    |  6.950000 |  6.770000 | 8  | 8  | 8.140000 |  5.760000 | 8  | 8  |
    |  7.580000 | 12.740000 | 13 | 8  | 8.740000 |  7.710000 | 13 | 13 |
    |  8.810000 |  7.110000 | 9  | 8  | 8.770000 |  8.840000 | 9  | 9  |
    |  8.330000 |  7.810000 | 11 | 8  | 9.260000 |  8.470000 | 11 | 11 |
    |  9.960000 |  8.840000 | 14 | 8  | 8.100000 |  7.040000 | 14 | 14 |
    |  7.240000 |  6.080000 | 6  | 8  | 6.130000 |  5.250000 | 6  | 6  |
    |  4.260000 |  5.390000 | 4  | 19 | 3.100000 | 12.500000 | 4  | 4  |
    | 10.840000 |  8.150000 | 12 | 8  | 9.130000 |  5.560000 | 12 | 12 |
    |  4.820000 |  6.420000 | 7  | 8  | 7.260000 |  7.910000 | 7  | 7  |
    |  5.680000 |  5.730000 | 5  | 8  | 4.740000 |  6.890000 | 5  | 5  |
    +-----------+-----------+----+----+----------+-----------+----+----+


Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):


```raku
records-summary($obj);
```

    +-----------------+--------------+--------------+--------------------+--------------------+--------------+--------------+--------------------+
    | y3              | x3           | x1           | y2                 | y1                 | x2           | x4           | y4                 |
    +-----------------+--------------+--------------+--------------------+--------------------+--------------+--------------+--------------------+
    | Min    => 5.39  | Min    => 4  | Min    => 4  | Min    => 3.1      | Min    => 4.26     | Min    => 4  | Min    => 8  | Min    => 5.25     |
    | 1st-Qu => 6.08  | 1st-Qu => 6  | 1st-Qu => 6  | 1st-Qu => 6.13     | 1st-Qu => 5.68     | 1st-Qu => 6  | 1st-Qu => 8  | 1st-Qu => 5.76     |
    | Mean   => 7.5   | Mean   => 9  | Mean   => 9  | Mean   => 7.500909 | Mean   => 7.500909 | Mean   => 9  | Mean   => 9  | Mean   => 7.500909 |
    | Median => 7.11  | Median => 9  | Median => 9  | Median => 8.14     | Median => 7.58     | Median => 9  | Median => 8  | Median => 7.04     |
    | 3rd-Qu => 8.15  | 3rd-Qu => 12 | 3rd-Qu => 12 | 3rd-Qu => 9.13     | 3rd-Qu => 8.81     | 3rd-Qu => 12 | 3rd-Qu => 8  | 3rd-Qu => 8.47     |
    | Max    => 12.74 | Max    => 14 | Max    => 14 | Max    => 9.26     | Max    => 10.84    | Max    => 14 | Max    => 19 | Max    => 12.5     |
    +-----------------+--------------+--------------+--------------------+--------------------+--------------+--------------+--------------------+





    ({x1 => Min    => 4, x2 => Min    => 4, x3 => Min    => 4, x4 => Min    => 8, y1 => Min    => 4.26, y2 => Min    => 3.1, y3 => Min    => 5.39, y4 => Min    => 5.25} {x1 => 1st-Qu => 6, x2 => 1st-Qu => 6, x3 => 1st-Qu => 6, x4 => 1st-Qu => 8, y1 => 1st-Qu => 5.68, y2 => 1st-Qu => 6.13, y3 => 1st-Qu => 6.08, y4 => 1st-Qu => 5.76} {x1 => Mean   => 9, x2 => Mean   => 9, x3 => Mean   => 9, x4 => Mean   => 9, y1 => Mean   => 7.500909, y2 => Mean   => 7.500909, y3 => Mean   => 7.5, y4 => Mean   => 7.500909} {x1 => Median => 9, x2 => Median => 9, x3 => Median => 9, x4 => Median => 8, y1 => Median => 7.58, y2 => Median => 8.14, y3 => Median => 7.11, y4 => Median => 7.04} {x1 => 3rd-Qu => 12, x2 => 3rd-Qu => 12, x3 => 3rd-Qu => 12, x4 => 3rd-Qu => 8, y1 => 3rd-Qu => 8.81, y2 => 3rd-Qu => 9.13, y3 => 3rd-Qu => 8.15, y4 => 3rd-Qu => 8.47} {x1 => Max    => 14, x2 => Max    => 14, x3 => Max    => 14, x4 => Max    => 19, y1 => Max    => 10.84, y2 => Max    => 9.26, y3 => Max    => 12.74, y4 => Max    => 12.5})



**Remark:** From the table above it is not clear how exactly we have to access the data in order 
to plot each of Anscombe's sets. The data wrangling steps below show a way to separate the sets
and make them amenable for set-wise manipulations.

Very often values of certain data parameters are conflated and put into dataset's column names.
(As in Anscombe's dataset.)

In those situations we:

- Convert the dataset into long format, since that allows column names to be treated as data

- Separate the values of a certain column into to two or more columns

Reshape the "pipeline object" into
[long format](https://en.wikipedia.org/wiki/Wide_and_narrow_data):


```raku
$obj = to-long-format($obj);
to-pretty-table($obj.head(7))
```




    +----------+----------+--------------+
    | Variable |  Value   | AutomaticKey |
    +----------+----------+--------------+
    |    x2    |    10    |      0       |
    |    y3    | 7.460000 |      0       |
    |    x1    |    10    |      0       |
    |    y4    | 6.580000 |      0       |
    |    y1    | 8.040000 |      0       |
    |    x3    |    10    |      0       |
    |    y2    | 9.140000 |      0       |
    +----------+----------+--------------+



Separate the data column "Variable" into the columns "Variable" and "Set":


```raku
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```




    +----------+--------------+----------+-----+
    | Variable | AutomaticKey |  Value   | Set |
    +----------+--------------+----------+-----+
    |    x     |      0       |    10    |  2  |
    |    y     |      0       | 7.460000 |  3  |
    |    x     |      0       |    10    |  1  |
    |    y     |      0       | 6.580000 |  4  |
    |    y     |      0       | 8.040000 |  1  |
    |    x     |      0       |    10    |  3  |
    |    y     |      0       | 9.140000 |  2  |
    +----------+--------------+----------+-----+



Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:


```raku
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```




    +----+------+-----+--------------+
    | x  |  y   | Set | AutomaticKey |
    +----+------+-----+--------------+
    | 10 | 8.04 |  1  |      0       |
    | 8  | 6.95 |  1  |      1       |
    | 13 | 7.58 |  1  |      2       |
    | 9  | 8.81 |  1  |      3       |
    | 11 | 8.33 |  1  |      4       |
    | 14 | 9.96 |  1  |      5       |
    | 6  | 7.24 |  1  |      6       |
    +----+------+-----+--------------+



Plot each dataset of Anscombe's quartet (using ["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp6]):


```raku
group-by($obj, 'Set').map({ say "\n", text-list-plot( $_.value.map({ +$_<x> }).List, $_.value.map({ +$_<y> }).List, title => 'Set : ' ~ $_.key) })
```

    
                              Set : 3                           
    +---+---------+---------+----------+---------+---------+---+       
    |                                                          |       
    |                                                 *        |       
    +                                                          +  12.00
    |                                                          |       
    |                                                          |       
    +                                                          +  10.00
    |                                                      *   |       
    |                                            *             |       
    +                                  *    *                  +   8.00
    |                       *    *                             |       
    |             *    *                                       |       
    +   *    *                                                 +   6.00
    |                                                          |       
    +---+---------+---------+----------+---------+---------+---+       
        4.00      6.00      8.00       10.00     12.00     14.00       
    
                              Set : 2                           
    +---+---------+---------+----------+---------+---------+---+      
    |                                                          |      
    +                            *     *    *    *    *        +  9.00
    |                                                          |      
    +                       *                              *   +  8.00
    |                  *                                       |      
    +                                                          +  7.00
    +             *                                            +  6.00
    |                                                          |      
    +                                                          +  5.00
    |        *                                                 |      
    +                                                          +  4.00
    |   *                                                      |      
    +                                                          +  3.00
    +---+---------+---------+----------+---------+---------+---+      
        4.00      6.00      8.00       10.00     12.00     14.00      
    
                              Set : 4                           
    +---+--------+--------+---------+--------+---------+-------+       
    |                                                          |       
    +                                                      *   +  12.00
    |                                                          |       
    |                                                          |       
    +                                                          +  10.00
    |                                                          |       
    |   *                                                      |       
    +   *                                                      +   8.00
    |   *                                                      |       
    |   *                                                      |       
    +                                                          +   6.00
    |   *                                                      |       
    |                                                          |       
    +---+--------+--------+---------+--------+---------+-------+       
        8.00     10.00    12.00     14.00    16.00     18.00           
    
                              Set : 1                           
    +---+---------+---------+----------+---------+---------+---+       
    |                                                          |       
    |                                            *             |       
    +                                                      *   +  10.00
    |                                                          |       
    |                            *                             |       
    +                                  *    *                  +   8.00
    |                                                 *        |       
    |             *         *                                  |       
    |                                                          |       
    +        *                                                 +   6.00
    |                                                          |       
    |   *              *                                       |       
    +                                                          +   4.00
    +---+---------+---------+----------+---------+---------+---+       
        4.00      6.00      8.00       10.00     12.00     14.00       





    (True True True True)



------

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
(2021), 
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/)
,
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[HW1] Hadley Wickham,
["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01),
(2011),
[Journal of Statistical Software](https://www.jstatsoft.org/).

### Packages

[AAp1] Anton Antonov,
[DSL::English::DataQueryWorkflows Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[DSL::Shared::Utilities::ComprehensiveTranslations Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp8] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

[AAv2] Anton Antonov,
["Implementation of ML algorithms in Raku"](https://www.youtube.com/watch?v=efRHfjYebs4),
(2022),
[Anton A. Antonov's channel at YouTube](https://www.youtube.com/channel/UC5qMPIsJeztfARXWdIw3Xzw).


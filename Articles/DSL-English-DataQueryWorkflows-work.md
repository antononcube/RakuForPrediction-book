# DSL::English::DataQueryWorkflows

## Introduction

This document proclaims and briefly describes the Raku package 
["DSL::English::DataQueryWorkflows"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows).

["DSL::English::DataQueryWorkflows"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows) 
has grammar- and action classes for the parsing and interpretation of natural
Domain Specific Language (DSL) commands that specify data queries in the style of Standard Query Language (SQL) or
[RStudio](https://rstudio.com)'s library [`tidyverse`](https://tidyverse.tidyverse.org).

The interpreters (actions) have as targets different programming languages (and packages in them.)

The currently implemented programming-language-and-package targets are:
"Julia::DataFrames", "Mathematica", "Python::pandas", "R::base", "R::tidyverse", "Raku::Reshapers".

There are also interpreters to different natural languages: "Bulgarian", "English", "Korean", "Russian", "Spanish".

The data wrangling code generation of this package can be accessed through the 
[DSL-evaluations interface](https://antononcube.shinyapps.io/DSL-evaluations/), [AAv3].

[![](./Diagrams/DSL-English-DataQueryWorkflows/DSL-evalutations-Data-wrangling-starwars-Raku.png)](https://antononcube.shinyapps.io/DSL-evaluations/)

At this point, I have used this package in multiple Raku- or data wrangling related presentations; see:

- ["Multi-language Data-Wrangling Conversational Agent" at WTC-2022](https://www.youtube.com/watch?v=pQk5jwoMSxs), [AAv1]

- ["Raku for Prediction" at TRC-2021](https://conf.raku.org/talk/157), [AAv2]

- ["Doing it like a Cro (Raku data wrangling Shortcuts demo)"](https://www.youtube.com/watch?v=wS1lqMDdeIY), [AAv3]

- ["Multi language Data Wrangling and Acquisition Conversational Agents (in Raku)" at FOSDEM-2022](https://www.youtube.com/watch?v=pQk5jwoMSxs), [AAv4]

- ["Implementing Machine Learning algorithms in Raku" at TRC-2022](https://conf.raku.org/talk/170), [AAv5]


------

## Installation

Zef ecosystem:

```
zef install DSL::English::DataQueryWorkflows
```

GitHub:

```
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git
```

-------

## Current state

The following diagram:

- Summarizes the data wrangling capabilities envisioned for this package 
- Represents the Raku parsers and interpreters in this package with the hexagon
- Indicates future plans with dashed lines


![](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Diagrams/DSLs-Interpreter-for-Data-Wrangling-August-2022-state.png)

**Remark:** The grammar of this package is extended to parse Bulgarian DSL commands
with the package 
["DSL::Bulgarian"](https://github.com/antononcube/Raku-DSL-Bulgarian), 
[AAp5].

-------

## Workflows considered

The following flow-chart encompasses the data transformations workflows we consider:

![](https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/ConceptualDiagrams/Tabular-data-transformation-workflows.png)

Here are some properties of the methodology / flow chart:

- The flow chart is for tabular datasets, or for lists (arrays) or dictionaries (hashes) of tabular datasets
- In the flow chart only the data loading and summary analysis are not optional
- All other steps are optional
- Transformations like inner-joins are represented by the block “Combine groups”
- It is assumed that in real applications several iterations (loops) have to be run over the flow chart

In the world of the programming language R the orange blocks represent the so called
Split-Transform-Combine pattern;
see the article "The Split-Apply-Combine Strategy for Data Analysis" by Hadley Wickham, [HW1].

For more data query workflows design details see the article 
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/), 
[AA1] or its translation (and upgrade) in Bulgarian, [AA2].

------

## Examples

Here is example code:

```perl6
use DSL::English::DataQueryWorkflows;

say ToDataQueryWorkflowCode('select mass & height', 'R-tidyverse');
```

Here is a longer data wrangling command:

```perl6
my $command = 'use starwars;
select species, mass & height;
group by species;
arrange by the variables species and mass descending';
```
Here we translate that command into executable code for Julia, Mathematica, Python, R, and Raku:

```perl6
{say $_.key,  ":\n", $_.value, "\n"} for <Julia Mathematica Python R R::tidyverse Raku>.map({ $_ => ToDataQueryWorkflowCode($command, $_ ) });
```

Here we translate to other human languages:

```perl6
{say $_.key,  ":\n", $_.value, "\n"} for <Bulgarian English Korean Russian Spanish>.map({ $_ => ToDataQueryWorkflowCode($command, $_ ) });
```

Additional examples can be found in this file:
[DataQueryWorkflows-examples.raku](./examples/DataQueryWorkflows-examples.raku).

-------

## Command line interface

The package provides the Command Line Interface (CLI) program `ToDataQueryWorkflowCode`.
Here is its usage message:

```shell
> ToDataQueryWorkflowCode --help
Usage:
  ToDataQueryWorkflowCode [--target=<Str>] [--language=<Str>] [--format=<Str>] <command> -- Translates natural language commands into data transformations programming code.
  ToDataQueryWorkflowCode [--language=<Str>] [--format=<Str>] <target> <command>
  
    <command>           A string with one or many commands (separated by ';').
    --target=<Str>      Target (programming language with optional library spec.) [default: 'R-tidyverse']
    --language=<Str>    The natural language to translate from. [default: 'English']
    --format=<Str>      The format of the output
```

Here is an example invocation:

```shell
> ToDataQueryWorkflowCode Python "use the dataset dfTitanic; group by passengerSex; show counts"
obj = dfTitanic.copy()
obj = obj.groupby(["passengerSex"])
print(obj.size())
```

-------

## Testing

There are three types of unit tests for:

1. Parsing abilities; see [example](./t/Basic-commands.rakutest)

2. Interpretation into correct expected code; see [example](./t/Basic-commands-R-tidyverse.rakutest)

3. Data transformation correctness; see tests in:
   - [R](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests), [AAp2]
   - [WL](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/WL/DataQueryWorkflows-Unit-Tests.wlt), [AAp3]
   - [Python](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/Python/DataQueryWorkflows-Unit-Tests.py), [AAp4]

The unit tests R-package [AAp2] can be used to test both R and Python translations and equivalence between them.

There is a similar WL package, [AAp3].
(The WL unit tests package *can* have unit tests for Julia, Python, R -- not implemented yet.)

------

## On naming of translation packages

WL has a `System` context where usually the built-in functions reside. WL adepts know this, but others do not.
(Every WL package provides a context for its functions.)

My naming convention for the translation files so far is `<programming language>::<package name>`. 
And I do not want to break that invariant.

Knowing the package is not essential when invoking the functions. For example `ToDataQueryWorkflowCode[_,"R"]` produces
same results as `ToDataQueryWorkflowCode[_,"R-base"]`, etc.

------

## Versions

The original version of this Raku package was developed/hosted at
[ [AAp1](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows) ].

A dedicated GitHub repository was made in order to make the installation with Raku's `zef` more direct.
(As shown above.)

------

## Future plans

- "Proper" implement SQL actions.

- Implementation of [Swift::TabularData](https://developer.apple.com/documentation/tabulardata) actions.
  
- Implementation of [Raku::Dan](https://github.com/p6steve/raku-Dan) actions.

- More comprehensive unit tests for Python and Raku.

------

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[HW1] Hadley Wickham, 
["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01), 
(2011), 
[Journal of Statistical Software](https://www.jstatsoft.org/).


### Packages

[AAp1] Anton Antonov,
[Data Query Workflows Raku Package](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows)
,
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

[AAp2] Anton Antonov,
[Data Query Workflows Tests](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests),
(2020),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

[AAp3] Anton Antonov,
[Data Query Workflows Mathematica Unit Tests](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/WL/DataQueryWorkflows-Unit-Tests.wlt),
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

[AAp4] Anton Antonov,
[Data Query Workflows Python Unit Tests](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/Python/DataQueryWorkflows-Unit-Tests.py),
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

[AAp5] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

[AAv2] Anton Antonov, 
["Raku for Prediction"](https://conf.raku.org/talk/157), 
(2021), 
[The Raku Conference 2021](https://conf.raku.org/).

[AAv3] Anton Antonov,
["Doing it like a Cro (Raku data wrangling Shortcuts demo)"](https://www.youtube.com/watch?v=wS1lqMDdeIY),
(2021),
[Anton Antonov's channel at YouTube](https://www.youtube.com/channel/UC5qMPIsJeztfARXWdIw3Xzw).

[AAv4] Anton Antonov,
["FOSDEM2022 Multi language Data Wrangling and Acquisition Conversational Agents (in Raku)"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2022),
[Anton Antonov's channel at YouTube](https://www.youtube.com/channel/UC5qMPIsJeztfARXWdIw3Xzw).

[AAv5] Anton Antonov,
["Implementing Machine Learning algorithms in Raku" at TRC-2022](https://conf.raku.org/talk/170)
(2022),
[The Raku Conference 2022](https://conf.raku.org/).
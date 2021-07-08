# Introduction

This book discusses the architectural design and implementation of a software system 
for the specification, navigation, and utilization of computational workflows in the fields of 
data science, machine learning, and scientific computing.

The programming language [Raku](https://raku.org) is used for the implementation and its features
has heavily influenced many details of the architectural design.

More specifically the book has two primary goals of the book are:

1. The introduction of a simple, operational, and extendable system of natural language commands
   for computational workflows.
  
2. The description of a software architecture and its Raku implementation of a system that
   interprets natural language commands into executable programming code of computational workflows.
   
The system described in the book ***multi-language*** from both natural language and programming language
perspectives. (See Figure "DSLs-Interpreter-Simple".)

[![DSLs-Interpreter-Simple](./Diagrams/DSLs-Interpreter-Simple.png)](./Diagrams/DSLs-Interpreter-Simple.pdf)

Here is an example of converting a data wrangling computational workflow specification
into the R code:

```perl6
use DSL::Shared::Utilities::ComprehensiveTranslation;
ToDSLCode("
DSL TARGET R-tidyverse;
use mtcars;
group by cyl;
counts", 
        format => "JSON")
```
```
# {
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLTARGET": "R-tidyverse",
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, Str $target = \"tidyverse\") {*}",
#   "CODE": "mtcars %>%\ndplyr::group_by(cyl) %>%\ndplyr::count()",
#   "USERID": ""
# }
```

In the code above the function `ToDSLCode` guessed the appropriate Domain Specific Language (DSL),
generated R code for RStudio's library
[tidyverse](https://www.tidyverse.org), 
and gave the result in a dictionary form 
([JSON](https://www.json.org/json-en.html).)

More precisely the result dictionary has entries for:
- The Raku DSL package that fits the sequence of commands 
  ([`DSL::English::DataQueryWorkflows`](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows)) 
- DSL target, a string that combines a programming language name and a package name (`R-tidyverse`)
- The DSL function used to generate the code (`ToDataQueryWorkflowCode`)
- Generated code that corresponds to the commands and DSL target
- User ID (empty above)

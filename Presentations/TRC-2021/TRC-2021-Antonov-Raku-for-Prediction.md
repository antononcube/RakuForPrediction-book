# Raku for Prediction

**Anton Antonov, Accendo Data LLC**   

**The Raku Conference, August 6-8, 2021**   

---

## ABSTRACT

In this presentation we discuss the architectural design and implementation of a software system for the specification, navigation, and utilization of computational workflows in the fields of data science, machine learning, and scientific computing.

More specifically in the presentation we are going to:

1. Introduce of simple, operational, and extendable system of natural Domain Specific Languages (DSLs) for the specification of computational workflows

1. Outline a general strategy and a software architecture of a system that translates sequences of sentences of those natural DSLs into executable code for different programming languages (and packages in them)   

1. Discuss and demonstrate a Raku implementation of such software system and how to utilize it through Raku

The system we describe in the presentation is ***multi-language*** from both natural language and programming language perspectives. We give a large number of illustrating examples of its functionalities, scope, and principles. Alternative approaches are discussed. Current state and future plans are given at the end.

[Link to the talk page at TRC-2021.](https://conf.raku.org/talk/157)

---

## Who am I?

- MSc in Mathematics, General Algebra.

        - University of Ruse, Bulgaria.

- MSc in Computer Science, Data Bases.

        - University of Ruse, Bulgaria.

- PhD in Applied Mathematics, Large Scale Air-Pollution Simulations.

        - The Danish Technical University, Denmark

- Former kernel developer of Mathematica, 2001-2008.

        - Wolfram Research, Inc.

- Currently working as a “Senior data scientist.”

        - Accendo Data LLC

---

## Motivation

### In brief

- Rapid specification of prediction workflows using natural language commands.

    - Data science, Machine learning, Scientific computing

- Too many packages and languages for doing prediction computations.

- Same workflows, but different syntax and “small” details.

### Target audience

Data science, data analysis, and scientific computing practitioners. 

(Professionals, wannabes, full time, part time, etc.)

---

## Motivation 2

Here are data wrangling examples that support the statements above:

```mathematica
commands = "use dfStarwars; rename homeworld as HW and age as HOWOLD;group by species; counts;";
```

```mathematica
aRes = Association@Map[# -> ToDataQueryWorkflowCode[commands, "Target" -> #, "Execute" -> False, "StringResult" -> True] &, {"Julia-DataFrames", "Python-pandas", "R-base", "R-tidyverse", "Spanish", "WL-System"}];
```

```mathematica
ResourceFunction["GridTableForm"][List @@@ Normal[aRes]]
```

![0h25coirykf6l](Diagrams/0h25coirykf6l.png)

**Remark:** Shorter code is produced for dedicated data wrangling packages. (As expected.)

See this interactive interface : https://antononcube.shinyapps.io/DSL-evaluations/

---

## Motivation 3

### Longer description

Here are our primary motivation points:

- Often we have to apply the same prediction workflows within different programming languages and/or packages. 

- Although the high-level computational workflows are the same, it might be time consuming to express those workflows in the logic and syntax of concrete programming languages or packages.

- It would be nice to have software solutions that speed-up the processes for multi-language expression of computational workflows.

Further, assume that:

We want to create conversation agents that help Data Science (DS) and ML practitioners to quickly create first, initial versions of different prediction workflows for different programming languages and related packages. 

We expect that the initial versions of programming code are tweaked further. (In order to produce desired outcomes in the application area of interest.)

---

## Multi-language in both senses

Let us repeat and emphasize: the Raku for Prediction (R4P) system is designed to translate multiple natural DSLs into multiple programming DSLs:

![0r3d48zk1x90p](Diagrams/0r3d48zk1x90p.png)

Note that the interpreter can be made with Raku and/or other relevant systems.

---

## It is not “prediction with Raku”

- Note that this system is named “Raku for prediction” not “prediction with Raku.”

- Raku is used to generate code for the computational workflows, not for the actual computational workflows algorithms.

    - Those are delegated to other (specialized) programming languages and/or libraries.

- Raku is the procurer or facilitator, not the performer. 

- I am using the principle “the clothes have no emperor.”

Hoare

---

## Clothes have no emperor

See the project [Sous Chef Susana at GitHub](https://github.com/sgizm/SousChefSusana) :

```mathematica
imgSCSWorkflow = Import["https://github.com/sgizm/SousChefSusana/raw/main/Diagrams/Sous-Chef-Susana-workflow.png"];
ImageResize[imgSCSWorkflow, 900]
```

![0hacs7g79vm7i](Diagrams/0hacs7g79vm7i.png)

---

## The ideal end result

- Interactive environments

    - Notebooks with appropriate contexts

- IDE plugins

    - “Standard” way of utilization

- Web services

    - To be utilized, say, with other “voice” interfaces

### Less than ideal (but still good)

Consider the natural language commands:

```mathematica
myCommand = "use dfTitanic; filter by passengerSex is 'female' and passengerSurvival is 'died'; group by passengerClass and passengerSurvival;count;take value";
```

#### Julia

```mathematica
ToDataQueryWorkflowCode[myCommand, "Target" -> "Julia-DataFrames"]

(*"obj = dfTitanicobj = obj[ ((obj.passengerSex .== \"female\") .& (obj.passengerSurvival .== \"died\")), :]obj = groupby( obj, [:passengerClass, :passengerSurvival] )obj = combine(obj, nrow)obj"*)
```

```mathematica
CellPrintAndRunJulia[%]
```

```julia
obj = dfTitanic
obj = obj[ ((obj.passengerSex .== "female") .& (obj.passengerSurvival .== "died")), :]
obj = groupby( obj, [:passengerClass, :passengerSurvival] )
obj = combine(obj, nrow)
obj
```

#### Python

```mathematica
ToDataQueryWorkflowCode[myCommand, "Target" -> "Python-pandas"]

(*"obj = dfTitanic.copy()obj = obj[((obj[\"passengerSex\"]== \"female\") & (obj[\"passengerSurvival\"]== \"died\"))]obj = obj.groupby([\"passengerClass\", \"passengerSurvival\"])obj = obj.size()obj"*)
```

```mathematica
CellPrintAndRunPython[%]
```

```python
obj = dfTitanic.copy()
obj = obj[((obj["passengerSex"]== "female") & (obj["passengerSurvival"]== "died"))]
obj = obj.groupby(["passengerClass", "passengerSurvival"])
obj = obj.size()
obj
```

---

## The three questions by sceptics, challengers, naysayers

Answering these questions is an absolute must!

### Why are you using natural language?

- Specifications with natural languages are not specific enough.

- And that useful -- actual code is easier and more direct for computation specification.

### Why using grammars, not GPT-3, BERT, etc?

- Why using hard to program, maintain, and (probably) deploy and utilize grammars? 

- It is much easier to use GPT-3 or other  statistical method or model of extracting specification parameters

### Is this a product?

- Is this something that can be turned into a product?

- It is too vague and product-definable (even if it is useful.)

---

## Quick answers

### Why are you using natural language?

- Portability of thought and intention.

- A type of abstraction that hides (or removes) idiosyncrasies of programming languages and packages.

### Why using grammars, not GPT-3, BERT, etc?

- Heuristics breed special and corner cases.

- Are concrete algorithmic steps and data that address special and corner cases applicable for the “next” versions of those statistical methods/models?

- When are we going to get reliable results?

- What training and re-training data is going to be used?

    - How it is obtained? Is it generated?

### Is this a product?

- This is a computer system that facilitates the efforts of Data Scientists and Machine Learning engineers.

- It is like UNIX in many ways. 

    - (More of that later...)

---

## The translation execution loop

In this notebook we use the following translation (parser-interpreter) execution loop:

```mathematica
Import["https://github.com/antononcube/RakuForPrediction-book/raw/main/Part-0-Introduction/Diagrams/Raku-execution-in-Mathematica-notebook.jpg"]
```

![18xc89rtk7q6a](Diagrams/18xc89rtk7q6a.png)

---

## Connecting Raku to notebooks

Raku cells in DSLMode or RakuMode use an OS process of sandboxed Raku through the library [ZeroMQ](https://zeromq.org).

Here is an infographic that summarizes my “journey” of implementing Raku connections to Mathematica and RStudio notebooks:

```mathematica
Import["https://github.com/antononcube/RakuForPrediction-book/raw/main/Part-0-Introduction/Diagrams/Raku-hook-up-to-notebooks-journey.jpg"]
```

![0m1ijf4c4cs9e](Diagrams/0m1ijf4c4cs9e.png)

---

## “Storm in a teacup”  Raku package

Almost all of the points bellow are reflected in the design, implementation, and functionalities of the package [Lingua::NumericWordForms](https://modules.raku.org/dist/Lingua::NumericWordForms):

```perl6
use Lingua::NumericWordForms;
from-numeric-word-form("two hundred and seven thousand and thirty five")

(*"207035"*)
```

Here are word forms of the number above in different languages:

```mathematica
Association[# -> IntegerName[207035, #] & /@ {"Bulgarian", "Japanese"}]

(*<|"Bulgarian" -> "двеста седем хиляди тридесет и пет", "Japanese" -> "二十万七千三十五"|>*)
```

Here is an example of automatic language recognition and word form interpretation:

```perl6
from-numeric-word-form(["двеста седем хиляди тридесет и пет", "二十万七千三十五"]):p

(*"(bulgarian => 207035 japanese => 207035)"*)
```

Here are the Raku process and ZMQ socket used:

```mathematica
$RakuProcess
```

![1e7hdns8h3onl](Diagrams/1e7hdns8h3onl.png)

```mathematica
$RakuZMQSocket
```

![0d6ale1zgdi80](Diagrams/0d6ale1zgdi80.png)

---

## Workflow considerations

### Simplifications are required

As in any software framework design certain assumptions, simplifications, and invariants are required.

### Pipelines

We concentrate on using (monadic) pipelines.

### Named entity recognition is required

### Data acquisition and data wrangling are big parts of prediction workflows

Both data acquisition and data wrangling have to be included in the system we consider

---

## Complete feature set and development state

The complete feature set and development state can be seen this ...

[Raku DSL package design](https://github.com/antononcube/ConversationalAgents/raw/master/ConceptualDiagrams/Raku-DSL-package-design.png):

```mathematica
Import["https://github.com/antononcube/ConversationalAgents/raw/master/ConceptualDiagrams/Raku-DSL-package-design.png"]
```

![1dau7vxmz8zo8](Diagrams/1dau7vxmz8zo8.png)

---

## The three types of Raku DSL packages

- Core computational workflows

    - Generic within the domain

- Entity name recognizers

    - Metadata recognition

- Complex packages

    - For specific problem domains

- Utilities

---

## The participating Raku DSL packages 

Here are graphs showing the dependencies between the Raku DSL packages:

![1lx329ku1mq8m](Diagrams/1lx329ku1mq8m.png)

![0ya12izqppk9e](Diagrams/0ya12izqppk9e.png)

---

## Example DSL: Tabular data transformation workflows

Here is a flow chart that shows the targeted workflows:

```mathematica
plWorkflows = ImageCrop@Import["https://github.com/antononcube/ConversationalAgents/raw/master/ConceptualDiagrams/Tabular-data-transformation-workflows.jpg"]
```

![0tj4hmpeg7h8m](Diagrams/0tj4hmpeg7h8m.png)

Only the data loading and summary analysis are not optional. (The left-most diagram elements.)

All other steps are optional.

**Remark:** The Split-Transform-Combine pattern (orange blocks) is implemented in [ParallelCombine](http://reference.wolfram.com/mathematica/ref/ParallelCombine.html).

Also, see the article ["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01) by Hadley Wickham, [[HW1](https://www.jstatsoft.org/article/view/v040i01)].

---

## Example DSL: Tabular data transformation workflows 2

Here is a corresponding workflow translation:

```mathematica
dfTitanic2 = ResourceFunction["ExampleDataset"][{"MachineLearning", "Titanic"}];
dfTitanic2[[1 ;; 6]]
```

![0o8di2grg0km4](Diagrams/0o8di2grg0km4.png)

use dfTitanic2;
delete missing;
filter with ‘passenger sex’ is ‘male’ and ‘passenger survival’ equals ‘died’ or ‘passenger survival’ is ‘survived’;
cross tabulate ‘passenger class’, ‘passenger survival’ over ‘passenger age’;

use dfTitanic2;
delete missing;
filter with 'passenger sex' is 'male' and 'passenger survival' equals 'died' or 'passenger survival' is 'survived';
cross tabulate 'passenger class', 'passenger survival' over 'passenger age';

```mathematica
obj = dfTitanic2;
obj = DeleteMissing[obj, 1, 2];
obj = Select[ obj, #["passenger sex"] == "male" && #["passenger survival"] == "died" || #["passenger survival"] == "survived" & ];
obj = ResourceFunction["CrossTabulate"][ { #["passenger class"], #["passenger survival"], #["passenger age"] }& /@ obj ];
```

```mathematica
obj
```

![05xtietqn9qgn](Diagrams/05xtietqn9qgn.png)

---

## Latent Semantic Analysis workflows

Same development stages as those of the Data Wrangling DSL.

```mathematica
Import["https://github.com/antononcube/SimplifiedMachineLearningWorkflows-book/raw/master/Part-2-Monadic-Workflows/Diagrams/A-monad-for-Latent-Semantic-Analysis-workflows/LSA-workflows.jpg"]
```

![1dqe9vihi2aam](Diagrams/1dqe9vihi2aam.png)

---

## Latent Semantic Analysis workflows 2

The same methodology is applied to Machine Learning and Scientific Computing workflows.

Here is an example with a Latent Semantic Analysis workflow:

```mathematica
ToDSLCode["create from aAbstracts;make document term matrix with stemming FALSE and automatic stop words;apply LSI functions glbal weight function IDF, local term weight function TermFrequency, normalizer function Cosine;extract 12 topics using method NNMF and max steps 16 and 20 min number of documents per term;show topics table with 12 terms;show tesaurus table for science, symbolic, system;"];
```

![1787yzq8vcfal](Diagrams/1787yzq8vcfal.png)

```mathematica
LSAMonUnit[aAbstracts] ⟹
LSAMonMakeDocumentTermMatrix[ "StemmingRules" -> False, "StopWords" -> Automatic] ⟹
LSAMonApplyTermWeightFunctions["GlobalWeightFunction" -> "IDF", "LocalWeightFunction" -> "None", "NormalizerFunction" -> "Cosine"] ⟹
LSAMonExtractTopics["NumberOfTopics" -> 12, Method -> "NNMF", "MaxSteps" -> 16, "MinNumberOfDocumentsPerTerm" -> 20] ⟹
LSAMonEchoTopicsTable["NumberOfTerms" -> 12] ⟹
LSAMonEchoStatisticalThesaurus[ "Words" -> {"science", "symbolic", "system"}];
```

![0m1drijurqoxs](Diagrams/0m1drijurqoxs.png)

![0hm2ots5o9kva](Diagrams/0hm2ots5o9kva.png)

---

## Scientific computing workflows

Obviously this approach can be used for any type of computational workflows.   
For more details and examples see the *useR! 2020 Conference* presentation [AA1, AA2]. 

Here is an example of an Epidemiologic Modeling workflow:

create with the model susceptible exposed infected two hospitalized recovered;
assign 100000 to the susceptible population;
set infected normally symptomatic population to be 0;
set infected severely symptomatic population to be 1;
assign 0.56 to contact rate of infected normally symptomatic population;
assign 0.58 to contact rate of infected severely symptomatic population;
assign 0.1 to contact rate of the hospitalized population;
simulate for 240 days;
plot populations results;

```mathematica
ECMMonUnit[SEI2HRModel[t]] ⟹
ECMMonAssignInitialConditions[<|SP[0] -> 100000|>] ⟹
ECMMonAssignInitialConditions[<|INSP[0] -> 0|>] ⟹
ECMMonAssignInitialConditions[<|ISSP[0] -> 1|>] ⟹
ECMMonAssignRateRules[<|β[INSP] -> 0.56|>] ⟹
ECMMonAssignRateRules[<|β[ISSP] -> 0.58|>] ⟹
ECMMonAssignRateRules[<|β[HP] -> 0.1|>] ⟹
ECMMonSimulate["MaxTime" -> 240] ⟹
ECMMonPlotSolutions[ "Stocks" -> __ ~~ "Population"];
```

![0rnh1rwezh0rr](Diagrams/0rnh1rwezh0rr.png)

---

## How it is done?

We two types of Domain Specific Languages (DSL’s) for data wrangling:

1. a software package for data transformations and 

1. a data wrangling DSL that is a subset of a spoken language.

These two DSL's are combined: the natural language commands of the latter are translated into the former.

By executing those translations we interpret commands of spoken DSL's into data transformation computational results.

Note, that we assume that there is a separate system that converts speech into text.

---

## Development cycle

Here is a clarification diagram:

```mathematica
Import["https://github.com/antononcube/ConversationalAgents/raw/master/ConceptualDiagrams/Monadic-making-of-ML-conversational-agents.jpg"]
```

![1t2sfbd3u3mhq](Diagrams/1t2sfbd3u3mhq.png)

---

## Monadic pipelines

The code generated follows the “monadic pipeline” pattern.

Here is a comparison:

```mathematica
commands = "use dfStarwars; group by species; counts;";
```

```mathematica
aRes = Association@Map[# -> ToDataQueryWorkflowCode[commands, "Target" -> #, "Execute" -> False, "StringResult" -> True] &, {"Julia-DataFrames", "R-tidyverse", "Python-pandas", "WL-System"}];
```

```mathematica
ResourceFunction["GridTableForm"][List @@@ Normal[aRes]]
```

![0x8ifw8a34xfh](Diagrams/0x8ifw8a34xfh.png)

### Executable cells

```mathematica
(*ToDSLCode["DSL TARGET "<># <>";"<>commands,Method->"Print"]&/@{"Julia-DataFrames","R-tidyverse","Python-pandas","WL-System"}*)
```

---

## In-place evaluation demo

I think using software monads and corresponding grammars is fairly important design decision.

Here is illustration of the principle with “in place” evaluations

```mathematica
ToQuantileRegressionWorkflowCode["use finData"]\[DoubleLongRightArrow]
   ToQuantileRegressionWorkflowCode["echo data summary"]\[DoubleLongRightArrow]
   ToQuantileRegressionWorkflowCode["compute quantile regression with 20 knots and probabilities 0.5 and 0.7"]\[DoubleLongRightArrow]
   ToQuantileRegressionWorkflowCode["show date list plots"]\[DoubleLongRightArrow]
   ToQuantileRegressionWorkflowCode["show error plots"];
```

---

## Grammars and parsers

For each natural language is developed a specialized DSL translation [Raku](https://raku.org) module.

Each Raku module:

1. Has grammars for parsing a sequence of natural commands of a certain DSL

1. Translates the parsing results into corresponding programming code

Different programming languages and packages can be the targets of the DSL translation.

(At this point are implemented DSL-translators to Julia, Python, R, and Wolfram Language.)

Here is an [example grammar](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows/blob/master/lib/DSL/English/DataQueryWorkflows/Grammar.rakumod). 

---

## Rigorous testing

Rigorous, multi-faceted, multi-level testing is required in order this whole machinery to work.

- Of course, certain level of testing is required in order to advance with the development. 

- Advanced testing is definitely required for any kind of "product release."   

    - That includes "minimal viable product" too.

### Types of tests

Parsing and translation tests:

- [Raku tests](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows/tree/master/t)

- Execution and correctness tests:

    - [R-base and R-tidyverse testing package](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests) 

    - [Python-pandas test file](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/Python/DataQueryWorkflows-Unit-Tests.py)

    - [WL test file](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/WL/DataQueryWorkflows-Unit-Tests.wlt)

Much of the tests design and programming is not finished yet.

---

## Server solution

Instead of installing the packages for every user we can have a “web service”. 

Here are examples getting DSL interpretations served with the [Raku library Cro](https://cro.services) from a server hosted at Digital Ocean:

Here is an example with data query commands:

```mathematica
command = "DSL TARGET Julia-DataFrames; use data dfMeals; inner join with dfFinelyFoodName over FOODID; group by 'Cuisine';find counts";
```

Here we construct an URL with the commands above:

```mathematica
DSLWebServiceInterpretationURL[command] // InputForm
```

```mathematica
"http://accendodata.net:5040/translate/'DSL%20TARGET%20Julia-DataFrames%3B%20%0Ause%20data%20dfMeals%3B%20%0Ainner%20join%20with%20dfFinelyFoodName%20over%20FOODID%3B%20%0Agroup%\
20by%20%27Cuisine%27%3B%0Afind%20counts'"
```

Here we get the interpretation and tabulate it:

```mathematica
res = DSLWebServiceInterpretation[command];
ResourceFunction["GridTableForm"][List @@@ Normal[KeySort[res]], TableHeadings -> {"Key", "Value"}]
```

![106td54ss37ei](Diagrams/106td54ss37ei.png)

---

## Server solution 2

```mathematica
plDSLWebService = Import["https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Part-0-Introduction/Diagrams/DSL-Web-Service-via-Cro.jpg"]
```

![0klqgoy5x4mxi](Diagrams/0klqgoy5x4mxi.png)

---

## Concise commands might produce lots of code

Here is an example of a simple specification that can produce disproportionally larger code:

```mathematica
ToDSLCode["use dfStarwars;rename species as VAR1;show pipeline value", Method -> "Print"]
```

```mathematica
obj = dfStarwars;
obj = Map[ Join[ KeyDrop[ #, {"species"} ], <|"VAR1" -> #["species"]|> ]&, obj];
Echo[obj]
```

---

## “My data wrangling is too complicated for this approach”

It seems that I have to convince some data wrangling practitioners that the proposed workflows can be useful to them.

Two reasons for those doubts:

- [The LISP curse](http://winestockwebdesign.com/Essays/Lisp_Curse.html)

- WL targeting deeply hierarchical data

My response is:

- For tabular data (collections) we can streamline your complicated data wrangling to a large degree.  

---

## General philosophy

- Minimalistic approach

- Using grammars

- Using pipelines

---

## Am I re-inventing UNIX (badly)?

- In many ways R4P’s philosophy and design resembles that of UNIX.

    - That statement can be seen as “appeal to authority”, but probably is going to introduce and clarify the messages faster.

- Almost of all of [Eric Raymond's 17 Unix rules](https://en.wikipedia.org/wiki/Unix_philosophy) are adhered to:

```mathematica
Magnify[ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Part-0-Introduction/R4P-vs-UnixRules.csv"], 1.7]
```

![1ppe73kbamh7o](Diagrams/1ppe73kbamh7o.png)

---

## Why not use GPT-3, BERT, etc.?

Let us answer this question with questions:

- At what point we can guarantee "solid" results from a GPT-based system?

- What is the training data for such statistical approach?

- How exactly a GPT-based system is going to generate correct code for, say, the following quantile regression sequence of commands:

use dfOrlandoTemperature;
echo data summary;
compute quantile regression with 16 knots and interpolation order 3;
show date list plot;
plot relative errors;

```mathematica
QRMonUnit[dfOrlandoTemperature] ⟹
QRMonEchoDataSummary[] ⟹
QRMonQuantileRegression["Knots" -> 16, "InterpolationOrder" -> 3] ⟹
QRMonDateListPlot[] ⟹
QRMonErrorPlots[ "RelativeErrors" -> True];
```

---

## Why not use GPT-3, BERT, etc.?  2

Consider the following command

```mathematica
command = "use dfOrlandoTemperature;echo data summary;compute quantile regression with 16 knots and interpolation order 3;show date list plot;plot relative errors;";
```

### Here are answers to questions using stochastic method(s)

```mathematica
aRes = Association@Map[# -> FindTextualAnswer[command, #, 4, {"Probability", "String"}] &, Sort@{"How many knots", "What is the interpolation order", "Should we plot it", "Date list plot or not", "How to plot the errors", "Which dataset to use"}];
```

```mathematica
Dataset /@ aRes
```

![1jdn8eztb4q60](Diagrams/1jdn8eztb4q60.png)

---

## How do you make these conversational agents “stochastic”?

First, I see these approaches as completing not competing.

R4P is extendable to include stochastic natural language semantic interpretation. 

We can draw analogy with the terminators from the [Terminator franchise](https://en.wikipedia.org/wiki/Terminator_(franchise)):

-  T-800 (Arnold Schwarzenegger) -- hard skeleton;

- T-1000 (Robert Patrick) -- liquid metal;

- T-X (Kristanna Loken) -- liquid metal over hard skeleton.

Here is the correspondence:

- The Raku-grammar approach corresponds to T-800

- The GPT-3 approach corresponds to T-1000

- Endowing the Raku-grammars to have GPT-3 features corresponds to T-X

---

## Handling misspellings

The fuzzy, stochastic matching is currently used at “word level.” 

It is important to handle misspellings:

- We make mistakes while typing

- Speech recognition systems mishear

Here is an example:

```mathematica
ToDataQueryWorkflowCode["use dfTitanic;flter by passengerSex is 'female';cross tablate passengerClass, passengerSurvival over passengerAge;"]
```

![1tblpyaw03pda](Diagrams/1tblpyaw03pda.png)

![1ilpxxwmm4egt](Diagrams/1ilpxxwmm4egt.png)

---

## Other human languages

Obviously we can translate a DSL based on English into DSL’s based on other natural languages.

Here is another example (EnglishSpanish):

```mathematica
ToDSLCode["DSL TARGET Spanish;use dfTitanic;filter by passengerSex == 'male';echo text grouping by variables;group by passengerClass, passengerSurvival;count;ungroup;"]["CODE"]

(*"utilizar la tabla: dfTitanicfiltrar con la condicion: ((passengerSex es igual \"male\"))mensaje impreso: \"grouping by variables\"agrupar con columnas: \"passengerClass\", \"passengerSurvival\"encontrar recuentosdesagrupar"*)
```

Here is another example (EnglishBulgarian):

```mathematica
ToDSLCode["DSL TARGET Bulgarian;use dfTitanic;filter by passengerSex == 'male';echo text grouping by variables;group by passengerClass, passengerSurvival;count;ungroup;"]["CODE"]

(*"използвай таблицата: dfTitanicфилтрирай с предиката: ((passengerSex се равнява на \"male\"))отпечатай съобщението: \"grouping by variables\"групирай с колоните: passengerClass, passengerSurvivalнамери брояраз-групирай"*)
```

---

## Wish list

### Random sentence generation from Raku grammars

### Faster regex matching

---

## More on UNIX phylosophy rules adherences

```mathematica
Magnify[ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Part-0-Introduction/R4P-vs-UnixRules.csv"], 1.7]
```

![1ppe73kbamh7o](Diagrams/1ppe73kbamh7o.png)

---

## Responding to other participants

- Jonathan Worthingon  

- Vadim Belman

    - https://github.com/antononcube/QRMon-R

- Daniel Sockwell

- Elizabeth Mattijsen

    - https://github.com/antononcube/Raku-UML-Translators

- Alexey Melezhik

- Chemists and aggriculturists

---

## As a conclusion: end user perspective (again)

Possible products to consider:

- IDE’s plugins for translating natural language commands into code 

    - Say, in IntelliJ IDEA, VSCode, Atom.

- Web service as a learning tool.

- Concrete “big functionality” systems:

    - Food preparation workflows (Sous Chef Sousana)

    - Recruiting workflows (Head Huntress Gemma)

    - Data Acquisition

    - Flight/ship crews scheduling workflows (First Mate Donna)

---

## Future plans

### ["Raku for Prediction" book](https://github.com/antononcube/RakuForPrediction-book)

### Finishing the implementations

### More “server solutions”

Shiny interfaces showing DSL commands being translated and corresponding execution results

### Automatic generation of playground environments for data scientists

---

## References

### Articles, movies

[AA1] Anton Antonov, ["How to simplify Machine learning workflows specifications? (useR! 2020)"](https://mathematicaforprediction.wordpress.com/2020/06/28/how-to-simplify-machine-learning-workflows-specifications-user-2020/), (2020), [MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov, ["useR! 2020: How to simplify Machine Learning workflows specifications (A. Antonov), lightning"](https://www.youtube.com/watch?v=b9Uu7gRF5KY), (2020), R Consortium at YouTube.

[HW1] Hadley Wickham, ["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01), (2011), [Journal of Statistical Software](https://www.jstatsoft.org).

### Repositories

[AAr1] Anton Antonov, [DSL::English::DataQueryWorkflows Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows), (2020), [GitHub/antononcube](https://github.com/antononcube).

[AAr2] Anton Antonov, [DSL::English::EpidemiologyModelingWorkflows Raku package](https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows), (2020), [GitHub/antononcube](https://github.com/antononcube).

[AAr3] Anton Antonov, [Epidemiology Compartmental Modeling Monad in R](https://github.com/antononcube/ECMMon-R), (2020), [GitHub/antononcube](https://github.com/antononcube).

[AAr4] Anton Antonov, ["Raku for Prediction" book](https://github.com/antononcube/RakuForPrediction-book), (2021), [GitHub/antononcube](https://github.com/antononcube).

[AAp1] Anton Antonov, [Monadic Epidemiology Compartmental Modeling Mathematica package](https://github.com/antononcube/SystemModeling/blob/master/Projects/Coronavirus-propagation-dynamics/WL/MonadicEpidemiologyCompartmentalModeling.m), (2020), [SystemModeling at GitHub/antononcube](https://github.com/antononcube/SystemModeling).

[RS1] RStudio, [https://www.tidyverse.org](https://www.tidyverse.org).

[RS2] RStudio, [https://github.com/tidyverse](https://github.com/tidyverse).

---

## Initialization code

### DSLMode

```mathematica
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/RakuMode.m"]
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/ExternalParsersHookup.m"]
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/DSLMode.m"]
```

```mathematica
DSLMode[]
KillRakuProcess[]
StartRakuProcess[]
```

![0ncr7y66cj6wn](Diagrams/0ncr7y66cj6wn.png)

### Load data

#### Quantile Regression

```mathematica
finData = FinancialData["NYSE:GE", {{2016, 1, 1}, Now, "Day"}];
```

```mathematica
tempData = WeatherData[{"Orlando", "Florida"}, "Temperature", {{2016, 1, 1}, Now, "Day"}];
```

#### Latent Semantic Analysis

```mathematica
dsAbstracts = ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/SimplifiedMachineLearningWorkflows-book/master/Data/Wolfram-Technology-Conference-2016-to-2019-abstracts.csv"];
aAbstracts = Normal@dsAbstracts[Association, #ID -> #Abstract &];
```

```mathematica
Length[aAbstracts]

(*578*)
```

```mathematica
RandomSample[dsAbstracts, 4]
```

![09o4t2k7c4t31](Diagrams/09o4t2k7c4t31.png)

#### Classification

```mathematica
dsTitanic = ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv"];
```

```mathematica
RandomSample[dsTitanic, 6]
```

![198jidy0niens](Diagrams/198jidy0niens.png)


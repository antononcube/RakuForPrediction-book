# Introduction with Questions and Answers

In this introduction we use questions and answers to introduce book's goals, problem domain, and proposed solutions.

We formulate and answer the more important questions first.

------

## What is this book about?

This book is about a system that translates sequences of natural language commands into
programming code for (prediction) computational workflows.

The system can be used as a fundamental ingredient of conversational agent for computational workflows.

------

## What are book's goals?

The book has three goals:

1. To introduce a system of natural language Domain Specific Languages (DSLs) 
   that can be used to specify prediction computational workflows

2. To describe a general design strategy and software architecture for a system that 
   translates specifications with those natural language DSLs into 
   executable code for different programming languages (and packages in them)
   
3. To describe a Raku implementation of such system and how Raku
   can be used to utilize it
   
The goals are inter-dependent:

- By describing the DSLs in the first goal we formulate the problem domain 
  for the design strategy and software architecture of the second goal.
  
- In order explain the Raku implementation and utilization in the third goal we have to
  explain the strategy and architecture of the second goal.
  
- Having working implementation(s) demonstrates the viability and utility of the 
  DSLs of the first goal.

------
   
## What kind of predictions?

The computational and scientific fields we consider are:

- Data Science (DS),
- Machine Learning (ML), 
- Scientific Computing (SC)

------

## What problem we are trying to solve?

We want to facilitate the specification and execution of computational workflows in those fields.
The system described is not making the predictions per se: it generates programming code for 
several computational systems like, Mathematica, R, Python. 

(Base programming languages and suitable packages.) 

**Remark:** Note that the book is called "Raku for Prediction", not, say, "Prediction with Raku".
I.e. we consider just the building of the computational workflows, not validity of their results. 

------

## What is the proposed solution?

- We propose a modular system that comprises multiple interpreters. 

- Each of those interpreters maps a natural Domain Specific Language (DSL) into a programming DSL.
  
- We assume that for most concrete computational projects would not require all of the interpreters.
    - I.e. for a given project a user of the system can choose a subset of the interpreters 
      that fit project's problem area. 
    
------

## Does the system proposed and discussed in the book have a name?

We refer to the system as "Raku for Prediction" or "R4P".

------

## Why use grammars not GPT-3, BERT, etc.?

Let us answer this question with questions:

- At what point we can guarantee "solid" results from a GPT-based system?

- What is the training data for such statistical approach? 
  
  - How big that training data should be in order to obtain good results reliably? (Not just, say, often enough.) 

- How exactly a GPT-based system is going to generate correct code for sequences of commands
  like the one below?
  
- ...  
  
### Example  

The following sequence of commands specifies a Quantile Regression workflow:
  
```{raku-dsl, outputPrompt=NONE, format=code}
use dfOrlandoTemperature;
echo data summary;
compute quantile regression with 16 knots and interpolation order 3;
show date list plot;
plot relative errors;
```

From the above commands R4P produces the following R code for the package 
[QRMon](https://github.com/antononcube/QRMon-R), [AA-QRMon-R]:

```r
QRMonUnit( data = dfOrlandoTemperature) %>%
QRMonEchoDataSummary() %>%
QRMonQuantileRegression(df = 16, degree = 3) %>%
QRMonPlot( datePlotQ = TRUE) %>%
QRMonErrorsPlot( relativeErrorsQ = TRUE)
```  

------
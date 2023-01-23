# Grammar based random sentences generation -- Part 1

## Introduction

In this article we discuss the generation of random sentences using [Raku grammars](https://docs.raku.org/language/grammars).

The generations discussed are done with the package functions and scripts of 
["Grammar::TokenProcessing"](https://raku.land/zef:antononcube/Grammar::TokenProcessing), [AAp1].

The random sentence generator in "Grammar::TokenProcessing" is limited, it does not parse all possible Raku grammars. 
But since I need it for my 
[Domain Specific Language (DSL) parser-interpreters work](https://raku.land/?q=DSL%3A%3AEnglish),
it covers a fairly large (if common) grammar ground.

### Preliminary examples

Let us generate a few random sentences using the front page example at [raku.org](https://raku.org):

```perl6
grammar Parser {
    rule  TOP  { I <love> <lang> }
    token love { '♥' | '🤮' | love }
    token lang { < Raku Perl Rust Go Python Ruby > }
}

use Grammar::TokenProcessing;

.say for random-sentence-generation(Parser) xx 6;
```
```
# I love Python
# I ♥ Raku
# I ♥ Ruby
# I ♥ Raku
# I 🤮 Go
# I love Ruby
```

Here is an example of random sentence generation using the DSL package
[DSL::English::LatentSemanticAnalysis](https://raku.land/zef:antononcube/DSL::English::LatentSemanticAnalysisWorkflows):

```perl6
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

.say for random-sentence-generation(DSL::English::LatentSemanticAnalysisWorkflows::Grammar) xx 6;
```
```
# take data the VAR_NAME("zakKs") with VAR_NAME("goGEk")
# utilize using textual VAR_NAME("NyNrs")
# reflect using terms query QUERY_TEXT("ranching aspirate wail dishearten")
# transform the term - weight functions normalization max normalization and global function None
# what are the nns of the VAR_NAME("Opqph") and VAR_NAME("rCH5e")
# create simple object textual VAR_NAME("JZspA")
```

------

## Motivation

The ability to design and implement grammars using the Object-Oriented Programming (OOP) paradigm
is one of the most distinguishing features of Raku. (I think it is "the most.")

Real-life grammars -- especially developed with OOP -- can have multiple component definitions (say, roles)
in multiple files. Figuring out what sentences a grammar can handle is most likely not an easy task. 

Here are some additional reasons to have grammar-based random sentence generation:

- Quick review of what kind of sentences a grammar can parse
- Grammar adequacy evaluation
- Handling un-parsable statements by showing examples of similar (random) statements
- Development of classifiers of grammars or grammar rules
- Generation of random expressions with a particular structure

**Remark:** The article [AA1] and the presentation [AAv1] discuss making grammar classifiers
using random sentences generated with the grammars the classifiers are for.

------

## Not using RakuAST

I evaluate maturity of parser-making systems by their ability to generate random sentences from grammars.
Surprisingly, with almost all systems that is not easy. (That list includes Raku.)

I was told that making a random sentence generator with
[RakuAST](https://news.perlfoundation.org/post/2022-02-raku-ast-grant)
would be easy. But until "RakuAST" is released, I am interested in having "current Raku" solution(s).

------

## Simple grammars

### Love-hate of languages

Consider a version of the "love-hate of languages" grammar in which:

- The `<love>` token has a quantifier

- More standard alternation specification is used

```perl6
grammar Parser2 {
    rule  TOP  { I <love> ** 1..3 <lang> }
    token love { '♥' | '🤮' | love }
    token lang { Raku | Perl | Rust | Go | Python | Ruby }
}

.say for random-sentence-generation(Parser2) xx 6;
```
```
# I ♥ love Go
# I 🤮 🤮 Python
# I ♥ 🤮 ♥ Perl
# I ♥ ♥ love Go
# I ♥ Rust
# I ♥ love 🤮 Rust
```

Now let us move the quantifier in the token `love`:

```perl6
grammar Parser3 {
    rule  TOP  { I <love>  <lang> }
    token love { [ '♥' | '🤮' | love ] ** 1..3 }
    token lang { Raku | Perl | Rust | Go | Python | Ruby }
}

.say for random-sentence-generation(Parser3) xx 6;
```
```
# I ♥ ♥ Rust
# I 🤮 🤮 🤮 Ruby
# I ♥ Raku
# I love love Raku
# I ♥ Python
# I 🤮 🤮 🤮 Rust
```

### ISBN parser

Here is an [International Standard Book Number (ISBN)](https://en.wikipedia.org/wiki/ISBN) grammar:

```perl6
grammar ISBN {
    token TOP {  <tenner>  |  <niner-xray>  }
    token tenner { [ <digit> <:Pd>? ] ** 10   }
    token niner-xray { [ <digit> <:Pd>? ] ** 9 X }
}
```
```
# (ISBN)
```

In order to generate "good looking" random sentences with that grammar we have to:

- Define a random digit generator that is simpler than the default one
- Use an empty string as a separator

```perl6
use Data::Generators;
use Data::Reshapers;

my %randomTokenGenerators = default-random-token-generators();
%randomTokenGenerators{'<:Pd>'} = { '-' };
%randomTokenGenerators{'<digit>'} = -> { random-string(chars => 1, ranges => "0" .. "9") };

.say for random-sentence-generation(ISBN, random-token-generators => %randomTokenGenerators, sep => '') xx 6;
```
```
# 601780065X
# 1-67-6-7-410-43-
# 234-2-237-79-8-
# 781129118X
# 951959951X
# 9-23-2271-5-4-3-
```

Here is how the random ISBNs look with the default settings:

```perl6
.say for random-sentence-generation(ISBN) xx 6;
```
```
# DIGIT(2) DIGIT(9) DIGIT(6) DIGIT(0) DIGIT(4) - DIGIT(2) - DIGIT(5) - DIGIT(0) DIGIT(4) DIGIT(8) -
# DIGIT(4) DIGIT(1) DIGIT(4) DIGIT(9) DIGIT(2) DIGIT(3) DIGIT(1) DIGIT(3) DIGIT(5) X
# DIGIT(6) DIGIT(0) - DIGIT(7) DIGIT(4) DIGIT(8) - DIGIT(3) - DIGIT(9) - DIGIT(6) DIGIT(1) DIGIT(1)
# DIGIT(3) DIGIT(3) DIGIT(1) DIGIT(9) DIGIT(7) DIGIT(0) DIGIT(4) DIGIT(7) DIGIT(0) X
# DIGIT(7) DIGIT(7) DIGIT(2) DIGIT(9) DIGIT(1) DIGIT(1) DIGIT(0) DIGIT(1) DIGIT(8) X
# DIGIT(0) - DIGIT(2) DIGIT(4) DIGIT(2) - DIGIT(4) - DIGIT(9) DIGIT(8) - DIGIT(9) DIGIT(1) - DIGIT(0)
```

------

## Default random token generators

Here are the *keys* of the default random token generators used by `random-sentence-generation`:

```perl6
.say for default-random-token-generators().keys;
```
```
# <digit>
# <:Pd>
# <shell-expr>
# <.ws>?
# <ws>
# <query-text>
# <variable-name>
# <.ws>
# <quoted-variable-name>
# <integer>
# <.alnum>
# <wl-expr>
# <mixed-quoted-variable-name>
# <alnum>
# <dataset-name>
# <list-separator>?
# <code-expr>
# <function-name>
# <list-separator>
# <number>
# <raku-module-name>
# <number-value>
# <integer-value>
# <.digit>
# <regex-pattern>
```

As it was demonstrated in the previous section, generation rules can changed and new ones added.

------

## "Advanced" DSL grammars

My primary "target" grammars are DSL grammars for computational workflows. Here are the main ones:

- `DSL::English::ClassificationWorkflows::Grammar`
- `DSL::English::DataQueryWorkflows::Grammar`
- `DSL::English::LatentSemanticAnalysisWorkflows::Grammar`
- `DSL::English::QuantileRegressionWorkflows::Grammar`
- `DSL::English::RecommenderWorkflows::Grammar`

The main, first level rules of those grammars have names that finish with "-command".
Here are the commands in the classification workflows grammar:

```perl6
use DSL::English::ClassificationWorkflows;
my $focusGrammar = DSL::English::ClassificationWorkflows::Grammar;
my %focusRules = $focusGrammar.^method_table;
to-pretty-table(%focusRules.keys.grep({ $_.ends-with('command') }).sort.rotor(3):partial, align=>'l');
```
```
# +--------------------------------------+----------------------------------+--------------------------+
# | 0                                    | 1                                | 2                        |
# +--------------------------------------+----------------------------------+--------------------------+
# | classifier-ensemble-creation-command | classifier-measurements-command  | classifier-query-command |
# | classifier-testing-command           | data-load-command                | data-outliers-command    |
# | data-summary-command                 | dimension-reduction-command      | dsl-module-command       |
# | dsl-spec-command                     | dsl-translation-target-command   | echo-command             |
# | ensemble-by-single-method-command    | find-outliers-command            | make-classifier-command  |
# | make-classifier-simple-command       | make-classifier-thorough-command | pipeline-command         |
# | remove-outliers-command              | roc-diagrams-command             | roc-plots-command        |
# | setup-code-command                   | show-outliers-command            | split-data-command       |
# | user-id-spec-command                 | user-spec-command                | workflow-command         |
# +--------------------------------------+----------------------------------+--------------------------+
```

Here we generate sentences with `<split-data-command>`:

```perl6
.say for random-sentence-generation($focusGrammar, '<split-data-command>') xx 6;
```
```
# split dataset
# partition the time series using NUMBER(144.02)
# partition data frame by data split NUMBER(224) , and method proportional method , random method using method class label proportional
# partition data with fraction NUMBER(247.15) and using validation data NUMBER(242.1) and random method
# partition the dataset using method class label proportional method & using validation NUMBER(55.28) using validation fraction NUMBER(176.18) using method random , using validation data fraction NUMBER(187.83) & validation data ratio NUMBER(215.61)
# partition the data frame
```

Here we generate sentences with `<recommend-data-command>` of the recommender workflows grammar:

```perl6
use DSL::English::RecommenderWorkflows;
my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;
.say for random-sentence-generation($focusGrammar, '<recommend-by-profile-command>', max-iterations => 100) xx 6;
```
```
# recommend with profile VAR_NAME("P94f4") , VAR_NAME("sMXS0") and VAR_NAME("JHg7J") : VAR_NAME("JlnaM") and VAR_NAME("tdP9E") : VAR_NAME("yDmTW")
# recommend with the profile “ VAR_NAME("QqdsV") : VAR_NAME("Qb4m5") “ , VAR_NAME("QizBj") : VAR_NAME("xIWMr") , VAR_NAME("Ba0k2") : VAR_NAME("c4PFA") , VAR_NAME("W1GIP") and VAR_NAME("CrRW6") : VAR_NAME("PADrX") and VAR_NAME("ND4ES")
# compute the INTEGER(294) recommendation using profile VAR_NAME("cfygh") : VAR_NAME("L0nZG") -> NUMBER(53.1) and VAR_NAME("wdGdr") : NUMBER(158.98) , VAR_NAME("Dm7Ls") -> NUMBER(236.98)
# what is the top most relevant INTEGER(167) recommendation using profile ‘ VAR_NAME("NyP4u") : VAR_NAME("VP6pm") ‘ , VAR_NAME("gLiu3") : VAR_NAME("WMyrl") and VAR_NAME("oFANk") : VAR_NAME("dLnij")
# top most relevant profile recommendation
# most relevant top most relevant profile recommendation
```

**Remark:** The grammars, generally, parse a larger set of sentences than the grammatically correct ones.
Hence, in some (or many) cases the generated sentences might look "strange" or "non-linear."

------

## Other natural languages

Here is how we generate commands with DSLs based other languages (Bulgarian):

```perl6
use DSL::Bulgarian::QuantileRegressionWorkflows::Grammar;
.say for random-sentence-generation(DSL::Bulgarian::QuantileRegressionWorkflows::Grammar, syms => <Bulgarian English>) xx 6;
```
```
# покажи чертеж чрез дати дата нула
# вземи и ползвай DATASET_NAME("FSOSP")
# прост обект създание DATASET_NAME("SquOV")
# покажи текст VAR_NAME("tSQvh") , VAR_NAME("D6BOM") , VAR_NAME("xOAwk")
# прави  QuantileRegression пасване
# изчисли  данни връх  извънредности
```

**Remark:** The package "DSL::Bulgarian", [AAp2], reuses the English-based grammars for computational workflows. 
It just provides Bulgarian tokens that replace English tokens -- the assumption is short Bulgarian and English commands
have the same structure, [AA2]. Hence, a fair amount of the Bulgarian random sentences are "wrong." As mentioned in 
the previous section, correct Bulgarian sentences are, of course, also parsed.

------

## CLI

The package "Grammar::TokenProcessing" provides a Command Line Interface (CLI) script. Here is an example:

```shell
random-sentence-generation DSL::English::QuantileRegressionWorkflows::Grammar -n=10
```
```
# load the data frame DATASET_NAME("D6l3M")
# show the function VAR_NAME("NIV0X") over the pipeline context
# display summaries
# compute anomalies by residuals by the threshold NUMBER(79.54)
# compute anomalies by the VAR_NAME("Jemt2") outlier identifier
# utilize the dataset VAR_NAME("eaHnU")
# configuration code
# echo graph by dates using date origin
# rescale the regressor axis
# show data summary
```

------

## "Leftover" comments 

- I decided I cannot wait for RakuAST in order to advance the development of my DSL projects, so, I actively program "workarounds".
  One such workaround is the implementation of random sentences generator.

- Moritz Lenz remarks in "Parsing with Perl 6 Regexes and Grammars", [ML1], that grammars are Swiss-army chain saw for parsing.
  Hence, being able to randomly -- and quickly -- unfold the components of such chain saw would give a nice overview of 
  its Swiss-army-ness.

- Jonathan Worthington discussed random sentences generation with Raku (Perl6) grammars 7-9 years. 
  Unfortunately, I cannot find that presentation. (When I do I will post a link here.)

------

## References

### Articles, books

[AA1] Anton Antonov,
["Fast and compact classifier of DSL commands"](https://rakuforprediction.wordpress.com/2022/07/31/fast-and-compact-classifier-of-dsl-commands/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["DSL::Bulgarian"](https://rakuforprediction.wordpress.com/2022/12/31/dslbulgarian/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[ML1] Moritz Lenz,
"Parsing with Perl 6 Regexes and Grammars: A Recursive Descent into Parsing",
2017,
Apress; 1st ed. edition.
ISBN-10 : 1484232275.
ISBN-13 : 978-1484232279.


### Packages

[AAp1] Anton Antonov,
[Grammar::TokenProcessing Raku package](https://raku.land/zef:antononcube/Grammar::TokenProcessing),
(2021-2022),
[raku.land/antononcube](https://raku.land/zef:antononcube).

[AAp2] Anton Antonov,
[DSL::Bulgarian Raku package](https://raku.land/zef:antononcube/DSL::Bulgarian),
(2021-2022),
[raku.land/antononcube](https://raku.land/zef:antononcube).


### Presentations

[AA1] Anton Antonov,
["Natural Language Processing Template Engine"](https://www.youtube.com/watch?v=IrIW9dB5sRM),
(2022),
[Wolfram Technology Conference 2022]().




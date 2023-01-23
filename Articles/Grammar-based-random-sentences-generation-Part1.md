# Grammar based random sentences generation
## **Part 1**

## Introduction

In this article we discuss the generation of random sentences using [Raku grammars](https://docs.raku.org/language/grammars).

The generations discussed are done with the package functions and scripts of 
["Grammar::TokenProcessing"](https://raku.land/zef:antononcube/Grammar::TokenProcessing), [AAp1].

The random sentence generator in [AAp1] is limited, it does not parse all possible Raku grammars. 
But I need it for my 
[Domain Specific Language (DSL) parser-interpreters work](https://raku.land/?q=DSL%3A%3AEnglish),
which cover a fairly large (if common) grammar ground.

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
# I ♥ Rust
# I ♥ Perl
# I 🤮 Rust
# I 🤮 Rust
# I 🤮 Ruby
# I ♥ Ruby
```

Here is an example of random sentence generation using the DSL package
[DSL::English::LatentSemanticAnalysis](https://raku.land/zef:antononcube/DSL::English::LatentSemanticAnalysisWorkflows):

```perl6
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

.say for random-sentence-generation(DSL::English::LatentSemanticAnalysisWorkflows::Grammar) xx 6;
```
```
# compute item -vs- term matrix
# extract  NUMBER(8) topics
# make the item - term matrix
# transform matrix term - weight the latent semantic indexing functions idf local term function binary frequency normalizer term weight cosine
# compute a item -vs- word matrix
# partition into sentences
```

------

## Motivation

The ability to design and implement grammars using the Object-Oriented Programming (OOP) paradigm
is one of the most distinguishing features of Raku. (I think it is "the most.")

Real-life grammars -- especially developed with OOP -- can multiple component definitions (say, roles)
in multiple files. Figuring out what sentences a grammar can handle is most like not an easy task. 

Here are some additional reasons to have grammar-based random sentence generation:

- Quick review of what kind of sentences a grammar can parse
- Grammar adequacy evaluation
- Handling un-parsable statements by showing examples of similar (random) statements
- Development of classifiers of grammars or grammar rules

**Remark:** The article [AA1] and the presentation [AAv1] discuss making grammar classifiers
using random sentences generated with the grammars the classifiers are for.

------

## Not using RakuAST

I evaluate maturity of parser-making systems by their ability to generate random sentences from grammars.
Surprisingly, with almost all systems that is not easy. (That list includes Raku and ANTLR.)

I was told that making a random sentence generator with
["RakuAST"](https://news.perlfoundation.org/post/2022-02-raku-ast-grant)
that might / should be easy.
But until "RakuAST" is released, I am interested in having "current Raku" solution(s).

------

## Simple grammars

### Love-hate languages

Consider a version of the "love-hate languages" grammar in which:

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
# I 🤮 🤮 🤮 Ruby
# I ♥ Go
# I 🤮 Perl
# I 🤮 Python
# I love ♥ Perl
# I ♥ Rust
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
# I ♥ ♥ Python
# I ♥ ♥ ♥ Rust
# I 🤮 🤮 🤮 Rust
# I love love Raku
# I ♥ ♥ Perl
# I love love Go
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

In order to generate ("good looking") random sentences with that grammar we have to:

- Define a random digit generator that is simpler than the default one
- Use a empty string for a separator

```perl6
use Data::Generators;
use Data::Reshapers;

my %randomTokenGenerators = default-random-token-generators();
%randomTokenGenerators{'<:Pd>'} = { '-' };
%randomTokenGenerators{'<digit>'} = -> { random-string(chars => 1, ranges => "0" .. "9") };

.say for random-sentence-generation(ISBN, random-token-generators => %randomTokenGenerators, sep => '') xx 6;
```
```
# 9-7-8-3-3-2-5-0-34
# 740052491X
# 2-6-4-4-2-0-6-8-0-X
# 45-07-3-9-9-657-
# 8-7-3-9-1-3-5-4-0-X
# 617-17-5-3680-
```

Here is how the random ISBNs look with the default settings:

```perl6
.say for random-sentence-generation(ISBN) xx 6;
```
```
# DIGIT(2) DIGIT(7) - DIGIT(8) DIGIT(1) DIGIT(3) - DIGIT(3) - DIGIT(2) DIGIT(7) - DIGIT(4) DIGIT(2) -
# DIGIT(7) - DIGIT(7) - DIGIT(9) - DIGIT(4) - DIGIT(0) - DIGIT(4) - DIGIT(5) - DIGIT(2) - DIGIT(8) - X
# DIGIT(0) - DIGIT(9) - DIGIT(1) - DIGIT(2) - DIGIT(7) - DIGIT(5) - DIGIT(5) - DIGIT(9) - DIGIT(6) - X
# DIGIT(7) DIGIT(8) - DIGIT(2) DIGIT(3) - DIGIT(5) - DIGIT(0) DIGIT(7) - DIGIT(0) DIGIT(6) - DIGIT(7) -
# DIGIT(6) - DIGIT(1) - DIGIT(1) - DIGIT(8) - DIGIT(6) - DIGIT(1) - DIGIT(9) - DIGIT(6) - DIGIT(0) - X
# DIGIT(3) DIGIT(9) DIGIT(3) DIGIT(6) DIGIT(2) DIGIT(3) DIGIT(6) DIGIT(7) DIGIT(1) X
```

------

## Default random token generators

Here are the *keys* default random token generators used by `random-sentence-generation`:

```perl6
.say for default-random-token-generators().keys;
```
```
# <quoted-variable-name>
# <mixed-quoted-variable-name>
# <shell-expr>
# <ws>
# <.digit>
# <.ws>?
# <number-value>
# <function-name>
# <code-expr>
# <regex-pattern>
# <:Pd>
# <number>
# <digit>
# <.alnum>
# <list-separator>
# <raku-module-name>
# <.ws>
# <query-text>
# <variable-name>
# <integer>
# <alnum>
# <integer-value>
# <dataset-name>
# <list-separator>?
# <wl-expr>
```

As it was demonstrated in the previous section, generation rules can changed and new ones added.

------

## "Advanced" DSL grammars

My main "target" grammars are DSL grammars for computational workflows. Here are the main ones:

- `DSL::English::ClassificationWorkflows::Grammar`
- `DSL::English::DataQueryWorkflows::Grammar`
- `DSL::English::LatentSemanticAnalysisWorkflows::Grammar`
- `DSL::English::QuantileRegressionWorkflows::Grammar`
- `DSL::English::RecommenderWorkflows::Grammar`

The main, first level rules of those grammars have name that finish with "-command".
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
# partition the data by validation ratio  NUMBER(150) & using method label proportional method , and using validation fraction  NUMBER(212) , and using validation data ratio  NUMBER(109) using validation ratio  NUMBER(175) and using validation data  NUMBER(127)
# partition the dataset
# partition the data frame with method label proportional using  NUMBER(43) using validation data  NUMBER(5) and using training  NUMBER(135) using split  NUMBER(136) , validation data fraction  NUMBER(49)
# divide the data frame by  NUMBER(77) and ratio  NUMBER(240) & method proportional method
# partition the data
# partition dataset with validation  NUMBER(20)
```

Here we generate sentences with `<split-data-command>`:

```perl6
use DSL::English::RecommenderWorkflows;
my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;
.say for random-sentence-generation($focusGrammar, '<recommend-by-profile-command>') xx 6;
```
```
# what is INTEGER(169) recommendations using the profile VAR_NAME("LntuO") :
# compute the INTEGER(3) profile recommendation
# compute INTEGER(37) most relevant profile recommendation
# recommend for profile with VAR_NAME("upjuV") : VAR_NAME("UwRHt") = and VAR_NAME("zHvm6") : VAR_NAME("Zsbl0") -> and " VAR_NAME("hVL8Q") : VAR_NAME("A5v1x") " →
# recommend by the profile VAR_NAME("nWL1r") : and VAR_NAME("xXjXD") -> , " VAR_NAME("D13Fq") : VAR_NAME("wE7fy") " -> and “ VAR_NAME("6TklB") : VAR_NAME("yLP05") “ = , VAR_NAME("mCY7o") : VAR_NAME("mYuhe") -> and VAR_NAME("xelNb") =
# recommend for profile with VAR_NAME("tWxpg") : VAR_NAME("65Exc") and VAR_NAME("k1XKW") and VAR_NAME("mSfdx") and VAR_NAME("uZfdl") : VAR_NAME("estZt")
```

------

## Other natural languages

Here is how we generate commands with DSLs based other languages (Bulgarian):

```perl6
use DSL::Bulgarian::QuantileRegressionWorkflows::Grammar;
.say for random-sentence-generation(DSL::Bulgarian::QuantileRegressionWorkflows::Grammar, '<pipeline-command>', syms => <Bulgarian English>) xx 6;
```
```
# вземи канален стойност
# USER ID VAR_NAME("nvdgi")
# USER IDENTIFIER VAR_NAME("s1y4p")
# събери  настройващ код
# WL_EXPR("Sqrt[3]")
# конфигуриращ код
```


------

## CLI

The package [AAp1] provides are Command Line Interface (CLI) script. Here is an example:

```shell
random-sentence-generation DSL::English::QuantileRegressionWorkflows::Grammar -n=10
```
```
# display data summary
# show dates list plot by date origin
# compute anomalies by outlier identifier VAR_NAME("Da4uX")
# compute and show an quantile regression
# echo summary
# compute a quantile regression using knots  NUMBER(186) ,  NUMBER(81) and  NUMBER(112) ,  NUMBER(72) ,  NUMBER(176) and  NUMBER(100)  NUMBER(190) the knots
# assign to VAR_NAME("6asxp") value
# summarize data
# display plot
# rescale the axes
```

------

## Additional remarks 

- I decided I cannot wait for RakuAST for the development of my DSL projects, so I actively program "workarounds".
  One such workaround is the implementation of random sentences generator

- Moritz Lenz remarks in "Parsing with Perl 6 Regexes and Grammars", [ML1], that grammars are Swiss-army chain saw for parsing.
  Hence, being able to randomly -- and quickly -- unfold the tools/components of such chain saw would give a nice overview of 
  its Swiss-army-ness.


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
[raku.land](https://raku.land/zef:antononcube/Grammar::TokenProcessing).


### Presentations

[AA1] Anton Antonov,
["Natural Language Processing Template Engine"](https://www.youtube.com/watch?v=IrIW9dB5sRM),
(2022),
[Wolfram Technology Conference 2022]().




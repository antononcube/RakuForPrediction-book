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
    token love { '♥' | ':O=' | love }
    token lang { < Raku Perl Rust Go Python Ruby > }
}

use Grammar::TokenProcessing;

.say for random-sentence-generation(Parser) xx 6;
```
```
# I :O= Python
# I ♥ Go
# I love Rust
# I ♥ Rust
# I :O= Perl
# I love Rust
```

Here is an example of random sentence generation using the DSL package
[DSL::English::LatentSemanticAnalysis](https://raku.land/zef:antononcube/DSL::English::LatentSemanticAnalysisWorkflows):

```perl6
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

.say for random-sentence-generation(DSL::English::LatentSemanticAnalysisWorkflows::Grammar) xx 6;
```
```
# show topics table
# utilize lsa object VAR_NAME("K7YJQ")
# utilize object VAR_NAME("LReXn")
# reflect using terms the VAR_NAME("KPGW8")
# what are the top nns with words VAR_NAME("EPV0q") , VAR_NAME("8OjDK")
# show an term document
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
    token love { '♥' | ':O=︎' | love }
    token lang { Raku | Perl | Rust | Go | Python | Ruby }
}

.say for random-sentence-generation(Parser2) xx 6;
```
```
# I love ♥ Go
# I :O=︎ Perl
# I :O=︎ love Go
# I ♥ love ♥ Perl
# I love love Perl
# I love :O=︎ Raku
```

Now let us move the quantifier in the token `love`:

```perl6
grammar Parser3 {
    rule  TOP  { I <love>  <lang> }
    token love { [ '♥' | ':O=' | love ] ** 1..3 }
    token lang { Raku | Perl | Rust | Go | Python | Ruby }
}

.say for random-sentence-generation(Parser3) xx 6;
```
```
# I :O= Perl
# I :O= Python
# I :O= :O= Perl
# I :O= :O= Python
# I ♥ ♥ Rust
# I love love Ruby
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
# 8-7-9-9-5-1-2-8-9-X
# 8618-1-4-56-38-
# 18-043-1-5-90-4
# 1-3-0-5-7-3-3-9-9-X
# 66-430-6-5-43-4
# 3-2-8-482-7-0-52
```

Here is how the random ISBNs look with the default settings:

```perl6
.say for random-sentence-generation(ISBN) xx 6;
```
```
# DIGIT(9) - DIGIT(5) - DIGIT(1) - DIGIT(3) DIGIT(9) - DIGIT(9) DIGIT(6) - DIGIT(6) DIGIT(6) DIGIT(2)
# DIGIT(9) - DIGIT(1) DIGIT(0) DIGIT(4) - DIGIT(8) DIGIT(7) DIGIT(8) - DIGIT(6) - DIGIT(6) - DIGIT(5)
# DIGIT(8) - DIGIT(3) - DIGIT(6) - DIGIT(7) DIGIT(2) - DIGIT(0) DIGIT(3) - DIGIT(3) DIGIT(1) - DIGIT(2) -
# DIGIT(2) - DIGIT(2) - DIGIT(8) - DIGIT(9) - DIGIT(0) - DIGIT(7) - DIGIT(8) - DIGIT(4) - DIGIT(5) - X
# DIGIT(6) - DIGIT(0) DIGIT(9) DIGIT(1) - DIGIT(3) DIGIT(5) - DIGIT(8) DIGIT(0) DIGIT(4) - DIGIT(9) -
# DIGIT(0) - DIGIT(4) - DIGIT(0) - DIGIT(7) - DIGIT(0) - DIGIT(6) - DIGIT(4) - DIGIT(2) - DIGIT(3) - X
```

------

## Default random token generators

Here are the *keys* of the default random token generators used by `random-sentence-generation`:

```perl6
.say for default-random-token-generators().keys;
```
```
# <number>
# <shell-expr>
# <quoted-variable-name>
# <regex-pattern>
# <function-name>
# <dataset-name>
# <mixed-quoted-variable-name>
# <.alnum>
# <alnum>
# <raku-module-name>
# <.ws>?
# <.digit>
# <ws>
# <wl-expr>
# <variable-name>
# <digit>
# <list-separator>?
# <:Pd>
# <integer-value>
# <number-value>
# <list-separator>
# <query-text>
# <.ws>
# <code-expr>
# <integer>
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
# split the data set with NUMBER(15.97)
# divide data set
# split time series data
# divide time series data
# divide time series with the ratio NUMBER(92)
# partition data using proportional
```

Here we generate sentences with `<recommend-data-command>` of the recommender workflows grammar:

```perl6
use DSL::English::RecommenderWorkflows;
my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;
.say for random-sentence-generation($focusGrammar, '<recommend-by-profile-command>', max-iterations => 100) xx 6;
```
```
# recommend by the profile with VAR_NAME("vIEBc") : VAR_NAME("xCkpW") → NUMBER(7.38)
# recommend by the profile with VAR_NAME("5ARpF") and VAR_NAME("97tS9") , VAR_NAME("yS8ZY") : VAR_NAME("hR27Q")
# what is the most relevant recommendations for the profile VAR_NAME("EBFCV") : VAR_NAME("VyNsU") , VAR_NAME("4ICVj") : VAR_NAME("12fJv") , “ VAR_NAME("HL9TE") : VAR_NAME("pmSQg") “ , VAR_NAME("1iSCh") and VAR_NAME("SglMq") : VAR_NAME("P1oJf") , VAR_NAME("XZqht")
# most relevant INTEGER(121) recommendation for profile VAR_NAME("5HQWx") -> NUMBER(188.16) and VAR_NAME("vguqu") -> NUMBER(143.52) and “ VAR_NAME("3a9SL") : VAR_NAME("qIbai") “ : NUMBER(118.9) , VAR_NAME("ZLRik") : VAR_NAME("iSmmV") : NUMBER(283.17) and VAR_NAME("A3EBt") : NUMBER(261.18) , VAR_NAME("ZXxLH") : VAR_NAME("aP4AY") -> NUMBER(178.04)
# recommend for the profile with VAR_NAME("U83Io") : VAR_NAME("BNCAV") = NUMBER(39.51) and “ VAR_NAME("utgnU") : VAR_NAME("KRgKm") “ -> NUMBER(236.73) , VAR_NAME("IT8Sa") → NUMBER(31.07)
# compute the top most relevant profile recommendation
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
# движещ средeн чрез NUMBER(175.23) елементи
# чертеж  абсолютен грешка чертежи
# изчисли и покажи  дъно  извънредности
# изчисли аномалии чрез праг NUMBER(36.33)
# покажи канален стойност
# рекапитулирай  данни
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
# compute and display data frame outliers with the seq( NUMBER(222.17) NUMBER(50.38) )
# rescale both axes
# take context
# compute the outliers using the probabilities NUMBER(278.69) NUMBER(107.23) NUMBER(146.02)
# echo summary
# compute anomalies by residuals by the threshold NUMBER(222.34)
# compute top outliers by the probability from NUMBER(91.44) into NUMBER(69.15) step NUMBER(256.2)
# show plot of relative error plot
# compute an QuantileRegression with the from NUMBER(190.34) into NUMBER(169.36)
# compute and show the outliers
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




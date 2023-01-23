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

Here is an example of random sentence generation using the DSL package
[DSL::English::LatentSemanticAnalysis](https://raku.land/zef:antononcube/DSL::English::LatentSemanticAnalysisWorkflows):

```perl6
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

.say for random-sentence-generation(DSL::English::LatentSemanticAnalysisWorkflows::Grammar) xx 6;
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

Now let us move the quantifier in the token `love`:

```perl6
grammar Parser3 {
    rule  TOP  { I <love>  <lang> }
    token love { [ '♥' | '🤮' | love ] ** 1..3 }
    token lang { Raku | Perl | Rust | Go | Python | Ruby }
}

.say for random-sentence-generation(Parser3) xx 6;
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

Here is how the random ISBNs look with the default settings:

```perl6
.say for random-sentence-generation(ISBN) xx 6;
```

------

## Default random token generators

Here are the *keys* default random token generators used by `random-sentence-generation`:

```perl6
.say for default-random-token-generators().keys;
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

Here we generate sentences with `<split-data-command>`:

```perl6
.say for random-sentence-generation($focusGrammar, '<split-data-command>') xx 6;
```

Here we generate sentences with `<split-data-command>`:

```perl6
use DSL::English::RecommenderWorkflows;
my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;
.say for random-sentence-generation($focusGrammar, '<recommend-by-profile-command>') xx 6;
```

------

## Other natural languages

Here is how we generate commands with DSLs based other languages (Bulgarian):

```perl6
use DSL::Bulgarian::QuantileRegressionWorkflows::Grammar;
.say for random-sentence-generation(DSL::Bulgarian::QuantileRegressionWorkflows::Grammar, '<pipeline-command>', syms => <Bulgarian English>) xx 6;
```


------

## CLI

The package [AAp1] provides are Command Line Interface (CLI) script. Here is an example:

```shell
random-sentence-generation DSL::English::QuantileRegressionWorkflows::Grammar -n=10
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




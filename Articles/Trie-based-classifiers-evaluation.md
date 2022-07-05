# Trie based classifiers evaluation

## Introduction

In this document we show how to evaluate TriesWithFrequencies, [AA3, AAp7], based classifiers created over well known
Machine Learning (ML) datasets. The computations are done with packages from [Raku's ecosystem](https://raku.land).

The classifiers based on TriesWithFrequencies can be seen as some sort of Naive Bayesian Classifiers (NBCs).

This is a "computable Markdown document" -- the Raku cells are (context-consecutively) evaluated with the
["literate programming"](https://en.wikipedia.org/wiki/Literate_programming)
package
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AA1, AAp5].

------

## Data

Here we get Titanic data using the package "Data::Reshapers", [AA1, AAp2]:

```perl6
use Data::Reshapers;
my @dsTitanic=get-titanic-dataset(headers=>'auto');
dimensions(@dsTitanic)
```
```
# (1309 5)
```

Here is data sample:

```perl6
to-pretty-table( @dsTitanic.pick(5), field-names => <passengerAge passengerClass passengerSex passengerSurvival>)
```
```
# +--------------+----------------+--------------+-------------------+
# | passengerAge | passengerClass | passengerSex | passengerSurvival |
# +--------------+----------------+--------------+-------------------+
# |      20      |      3rd       |     male     |        died       |
# |      70      |      3rd       |     male     |        died       |
# |      -1      |      3rd       |     male     |      survived     |
# |      20      |      1st       |     male     |        died       |
# |      40      |      3rd       |     male     |      survived     |
# +--------------+----------------+--------------+-------------------+
```

Here is a summary:

```perl6
use Data::Summarizers;
records-summary(@dsTitanic)
```
```
# +----------------+----------------+-------------------+-----------------+---------------+
# | passengerClass | passengerAge   | passengerSurvival | id              | passengerSex  |
# +----------------+----------------+-------------------+-----------------+---------------+
# | 3rd => 709     | 20      => 334 | died     => 809   | 740     => 1    | male   => 843 |
# | 1st => 323     | -1      => 263 | survived => 500   | 872     => 1    | female => 466 |
# | 2nd => 277     | 30      => 258 |                   | 114     => 1    |               |
# |                | 40      => 190 |                   | 954     => 1    |               |
# |                | 50      => 88  |                   | 1096    => 1    |               |
# |                | 60      => 57  |                   | 1255    => 1    |               |
# |                | 0       => 56  |                   | 1038    => 1    |               |
# |                | (Other) => 63  |                   | (Other) => 1302 |               |
# +----------------+----------------+-------------------+-----------------+---------------+
```

-------

## Trie creation

For demonstration purposes let us create a *shorter* trie and display it in tree form:

```perl6
use ML::TriesWithFrequencies;
my $trTitanicShort = 
  @dsTitanic.map({ $_<passengerClass passengerSex passengerSurvival> }).&trie-create
  .shrink;
say $trTitanicShort.form;  
```
```
# TRIEROOT => 1309
# ├─1st => 323
# │ ├─female => 144
# │ │ ├─died => 5
# │ │ └─survived => 139
# │ └─male => 179
# │   ├─died => 118
# │   └─survived => 61
# ├─2nd => 277
# │ ├─female => 106
# │ │ ├─died => 12
# │ │ └─survived => 94
# │ └─male => 171
# │   ├─died => 146
# │   └─survived => 25
# └─3rd => 709
#   ├─female => 216
#   │ ├─died => 110
#   │ └─survived => 106
#   └─male => 493
#     ├─died => 418
#     └─survived => 75
```

-------

## Trie classifier

Here we get indices (of dataset rows) to make the training data:

```perl6
my ($dsTraining, $dsTesting) = take-drop( @dsTitanic.pick(*), floor(0.8 * @dsTitanic.elems));
say $dsTraining.elems;
say $dsTesting.elems;
```
```
# 1047
# 262
```

Alternatively, we can say that: 

1. We get indices of dataset rows to make the training data
2. We obtain the testing data indices as the complement of the training indices

Here we make a trie with the training data:

```perl6
my $trTitanic = $dsTraining.map({ $_.<passengerClass passengerSex passengerAge passengerSurvival> }).Array.&trie-create;
$trTitanic.node-counts
```
```
# {Internal => 61, Leaves => 84, Total => 145}
```

Here is an example classification:

```perl6
$trTitanic.classify(<1st female>)
```
```
# survived
```

Here classify across all testing data:

```perl6
my @testinRecords = $dsTesting.map({ $_.<passengerClass passengerSex passengerAge> }).Array;
my @clRes = $trTitanic.classify(@testinRecords).Array;
```
```
# The first argument 1st female 10 is not key in the trie.
#   in method classify at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7FEE3603397180ACFD855DF5740A138C408D80DA (ML::TriesWithFrequencies::Trie) line 794
#   in block  at /Users/antonov/.raku/precomp/199E3E7AC4C17053CE269BF9CC204874BEF020CF/7F/7FEE3603397180ACFD855DF5740A138C408D80DA line 1
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
# 
# The first argument 3rd female 60 is not key in the trie.
#   in method classify at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7FEE3603397180ACFD855DF5740A138C408D80DA (ML::TriesWithFrequencies::Trie) line 794
#   in block  at /Users/antonov/.raku/precomp/199E3E7AC4C17053CE269BF9CC204874BEF020CF/7F/7FEE3603397180ACFD855DF5740A138C408D80DA line 1
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
```

Here is a tally of the classification results

```perl6
tally(@clRes)
```
```
# {(Any) => 2, died => 189, survived => 71}
```

Here we make a Receiver Operating Characteristic (ROC) record, [AA5, AAp4]:

```perl6
use ML::ROCFunctions;
my %roc = to-roc-hash('survived', 'died', select-columns( $dsTesting, 'passengerSurvival')>>.values.flat, @clRes)
```
```
# Use of uninitialized value @clRes of type Any in string context.
# Methods .^name, .raku, .gist, or .say can be used to stringify it to something meaningful.
#   in sub to-roc-hash at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/DED0AF7825BF846EE426F21C9408FBF9F424C0FE (ML::ROCFunctions) line 208
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
# 
# Use of uninitialized value @clRes of type Any in string context.
# Methods .^name, .raku, .gist, or .say can be used to stringify it to something meaningful.
#   in sub to-roc-hash at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/DED0AF7825BF846EE426F21C9408FBF9F424C0FE (ML::ROCFunctions) line 208
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
```

```perl6
say %roc
```
```
# {FalseNegative => 44, FalsePositive => 15, TrueNegative => 145, TruePositive => 56}
```

-------

## Trie classification with ROC plots

```perl6
use Hash::Merge;
my @clRes = 
do for [|$dsTesting] -> $r {
    my $res = [|$trTitanic.classify( $r<passengerClass passengerSex passengerAge>,  prop => 'Probs' ), Actual => $r<passengerSurvival>].Hash;
    merge-hash( { died => 0, survived => 0}, $res)
}
```
```
# The first argument 1st female 10 is not key in the trie.
#   in method classify at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7FEE3603397180ACFD855DF5740A138C408D80DA (ML::TriesWithFrequencies::Trie) line 794
#   in code  at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 5
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
# 
# Use of uninitialized value element of type Any in string context.
# Methods .^name, .raku, .gist, or .say can be used to stringify it to something meaningful.
#   in code  at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 5
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
# 
# The first argument 3rd female 60 is not key in the trie.
#   in method classify at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7FEE3603397180ACFD855DF5740A138C408D80DA (ML::TriesWithFrequencies::Trie) line 794
#   in code  at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 5
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
# 
# Use of uninitialized value element of type Any in string context.
# Methods .^name, .raku, .gist, or .say can be used to stringify it to something meaningful.
#   in code  at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 5
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 1
#   in method eval at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E8D1F65079701F85ABBF42E476DC10E66E89CC81 (Text::CodeProcessing::REPLSandbox) line 90
#   in sub CodeChunkEvaluate at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 252
#   in sub MarkdownReplace at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 97
#   in sub StringCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 280
#   in sub FileCodeChunksProcessing at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 350
#   in sub FileCodeChunksEvaluation at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/7F5F26385B8A88207A9F240B9DFB540A8589A209 (Text::CodeProcessing) line 367
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 13
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/resources/9AAFACD13222601B60B8E75DC56BF915E56F2C89 line 3
#   in sub MAIN at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 3
#   in block <unit> at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/bin/file-code-chunks-eval line 1
```

```perl6
my @vals = flatten(select-columns(@clRes, 'survived')>>.values);
(min(@vals), max(@vals))
```
```
# (0 1)
```

```perl6
my @thRange = min(@vals), min(@vals) + (max(@vals)-min(@vals))/30 ... max(@vals);
records-summary(@thRange)
```
```
# +-------------------------------+
# | numerical                     |
# +-------------------------------+
# | Median => 0.49999999999999994 |
# | Mean   => 0.5000000000000001  |
# | 3rd-Qu => 0.7666666666666666  |
# | Max    => 0.9999999999999999  |
# | 1st-Qu => 0.2333333333333333  |
# | Min    => 0                   |
# +-------------------------------+
```

```perl6
my @rocs = @thRange.map(-> $th { to-roc-hash('survived', 'died', select-columns(@clRes, 'Actual')>>.values.flat, select-columns(@clRes, 'survived')>>.values.flat.map({ $_ >= $th ?? 'survived' !! 'died' })) });
to-pretty-table(@rocs.head(3))
```
```
#ERROR: The lengths of the second and third arguments are expected to be the same.
# Nil
```

```perl6
use Text::Plot; 
text-list-plot(roc-functions('FPR')(@rocs), roc-functions('TPR')(@rocs), height=>20, width=>60)
```
```
#ERROR: 'NaN.2f' is not valid in sprintf format sequence '%NaN.2f'
# Nil
```

-------

## References

### Articles

[AA1] Anton Antonov,
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["ML::TriesWithFrequencies"](https://rakuforprediction.wordpress.com/2022/06/22/mltrieswithfrequencies/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA4] Anton Antonov,
["Data::Generators"](https://rakuforprediction.wordpress.com/2022/06/25/datagenerators/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA5] Anton Antonov,
["ML::ROCFunctions"](https://rakuforprediction.wordpress.com/2022/06/30/mlrocfunctions/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[Wk1] Wikipedia
entry, ["Receiver operating characteristic"](https://en.wikipedia.org/wiki/Receiver_operating_characteristic).

### Packages

[AAp1] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[ML::ROCFunctions Raku package](https://github.com/antononcube/Raku-ML-ROCFunctions),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[ML::TriesWithFrequencies Raku package](https://github.com/antononcube/Raku-ML-TriesWithFrequencies),
(2021),
[GitHub/antononcube](https://github.com/antononcube).


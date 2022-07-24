# Fast and simple DSL classifier

Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
July 2022


## Introduction

In this (computational Markdown) document we show how to derive with Raku a fast and simple 
Machine Learning (ML) classifier that classifies natural language commands into 
Domain Specific Language (DSL) labels.

For example, such classifier should classify the command *"calculate item term matrix"*
as a Latent Semantic Analysis (LSA) workflow command. (And give it, say, the label `LatentSemanticAnalysis`.) 

The primary motivation for making DSL-classifier is to speed up the parsing specifications that
belong to a (somewhat) large collection of workflows. (For example, the Raku package [AAp5] has twelve workflows.)

### DSL specifications

Here are example computational DSL specs for the workflows 
*Classification*, *Latent Semantic Analysis*, and *Quantile Regression*:

```shell
ToDSLCode WL "
DSL MODULE Classification;
use the dataset dfGoods;
split data with ratio 0.8;
make a logistic regression classifier;
show accuracy, precision;
"
```

```shell
ToDSLCode R "
DSL MODULE LatentSemanticAnalysis;
use aDocs;
create document-term matrix;
apply LSI functions IDF, Frequency, and Cosine;
extract 36 topics with the method NNMF and max steps 12;
show topics table 
"
```

```shell
ToDSLCode R "
DSL MODULE QuantileRegression;
use dfStocksVolume;
summarize data;
computed quantile regression with 30 knots and order 2;
show date list plot 
"
```

### Problem formulation

For a given DSL specification order the available DSL parsers according to how likely
each of them is to parse the given specification completely.


------

## Procedures outlines

In this section we outline: 

- The brute force DSL parsing procedure

- The modification of the brute force procedure by using the DSL-classifier

- The derivation of the DSL-classifier

It is assumed that:

- We have two or more DSL parsers.
- For each parser we can obtain a *parsing residual* -- the number characters it could not parse.

If the parsing residual is 0 then we say that the parser "exhausted the specification" or "parsed the specification completely."  

### Inputs

- A computational DSL specification
- A list of available DSL parsers

### Brute force DSL parsing

1. Random shuffle the available DSL parsers
2. Attempt parsing with each of the available DSL parsers
3. If any parser gives 0 residual then stop the loop and use that parser as "working parser." 
4. The parser that gives smallest residual is chosen and "working parser."

### Parsing with the help of a DSL-classifier

1. Apply the DSL classifier to the given spec and order the DSL parsers according to the obtained classification probabilities
2. Do the "Brute force DSL parsing" steps 2, 3, and 4.

### Derivation of DSL-classifier

1. For each of the DSLs generate a few hundred random commands using their grammars.
   - Label each command with the DSL it was generated with. 
   - Export to a JSON file and / or CSV file.
2. Ingest the DSL commands data into a hash (dictionary or association.)
3. Do basic data analysis 
   - Summarize the textual data.
   - Split the commands into words.
   - Remove stop words, random words, words with (too many) special symbols.
   - Find, summarize, and display word frequencies.
4. Split the data into training and testing parts.
   - Do stratified splitting, per label.
5. Turn each command into a trie phrase:
   - Split the command into words
   - Keep frequent enough words (as found in step 3)
   - Sort the words and append the DSL label 
6. Make a trie with trie commands of the training data part.
7. Evaluate the trie classifier over the trie commands of the testing data part.
8. Show classification success rates and confusion matrix. 

**Remark:** The trie classifiers are made with the Raku package
["ML::TriesWithFrequencies"](https://raku.land/zef:antononcube/ML::TriesWithFrequencies), [AAp9].

### Association rules study

1. Create Association Rule Learning (ARL) baskets of words.
   - Put all words to lower case
   - Filter words using different criteria:
     - Remove stop words
     - Keep dictionary words
     - Remove words that have special symbols or are random strings
2. Find frequent sets that include the DSL labels.
3. Examine frequent sets.
4. Using the frequent sets create and evaluate trie classifier.

**Remark:** ARL algorithm Apriori can be implemented via Tries. See for example the Apriori
implementation in the Raku package
["ML::AssociationRuleLearning"](https://raku.land/zef:antononcube/ML::AssociationRuleLearning), [AAp7].

------
## Load packages

Load the Raku packages used below:

```perl6
use ML::AssociationRuleLearning;
use ML::TriesWithFrequencies;
use Lingua::StopwordsISO;

use Data::Reshapers;
use Data::Summarizers;
use Data::Generators;
use Data::ExampleDatasets;
```
```
# (Any)
```

**Remark:** All packages are available at [raku.land](https://raku.land).

------

## Load text data

Read the text data from a CSV file (using `example-dataset` from 
["Data::ExampleDatasets"](https://github.com/antononcube/Raku-Data-ExampleDatasets), [AAp2]):

```perl6
my @tbl = example-dataset('https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Data/RandomWorkflowCommands.csv');
@tbl.elems
```
```
# 5220
```

Show summary of the data (using `records-summary` from 
["Data::Summarizers"](https://github.com/antononcube/Raku-Data-Summarizers), [AAp4]):


```perl6
records-summary(@tbl)
```
```
# +-------------------------------+---------------------------------------+
# | Workflow                      | Command                               |
# +-------------------------------+---------------------------------------+
# | LatentSemanticAnalysis => 870 | summarize data                => 27   |
# | Recommendations        => 870 | summarize the data            => 25   |
# | NeuralNetworkCreation  => 870 | train                         => 16   |
# | RandomTabularDataset   => 870 | graph                         => 14   |
# | Classification         => 870 | net regression                => 13   |
# | QuantileRegression     => 870 | extract statistical thesaurus => 13   |
# |                               | do quantile regression        => 13   |
# |                               | (Other)                       => 5099 |
# +-------------------------------+---------------------------------------+
```

Make a list of pairs:

```perl6
my @wCommands = @tbl.map({ $_<Command> => $_<Workflow>}).List;
say @wCommands.elems
```
```
# 5220
```

Show a sample of the pairs:

```perl6
srand(33);
.say for @wCommands.pick(12).sort
```
```
# compute profile for r98w0 , rkzbaou1g7 together with rkzbaou1g7 => Recommendations
# generate the recommender over the 0rl => Recommendations
# how many networks => NeuralNetworkCreation
# make a random-driven tabular data set for => RandomTabularDataset
# modify boolean variables into symbolic => Classification
# recommend over history y5g8v => Recommendations
# set decoder tokens => NeuralNetworkCreation
# set encoder Characters => NeuralNetworkCreation
# show classifier measurements test results classification threshold 742.444 of dahm7ip26g => Classification
# split the into 271.426 % of testing => Classification
# verify that FalseNegativeRate of tgvh is equal to 63.9506 => Classification
# what is the number of neural models => NeuralNetworkCreation
```

------

## Word tallies

Here we get (English) dictionary words (using the function `random-word` from 
["Data::Generators"](https://raku.land/zef:antononcube/Data::Generators), [AAp1]):

```perl6
my %dictionaryWords = Set(random-word(Inf)>>.lc);
%dictionaryWords.elems
```
```
# 83599
```

Here we:

1. Split each keys (i.e. commands) of the data pairs into words 
2. Flatten into one list of words 
3. Trim each word and turn into lower case
4. Find word tallies (using the function `tally` from ["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers), [AAp4].)

```perl6
my %wordTallies = @wCommands>>.key.map({ $_.split(/ \s | ',' /) }).&flatten>>.trim>>.lc.&tally;
%wordTallies.elems
```
```
# 4090
```

Show summary of the word tallies:

```perl6
records-summary(%wordTallies.values.List)
```
```
# +---------------------+
# | numerical           |
# +---------------------+
# | Median => 1         |
# | Max    => 2828      |
# | 3rd-Qu => 2         |
# | 1st-Qu => 1         |
# | Min    => 1         |
# | Mean   => 11.189731 |
# +---------------------+
```

Here we filter the word tallies to be only with words that are:
- Have frequency 10 or higher
- Dictionary words 
- Not English stop words (using the function `stopwords-iso` from ["Lingua::StopwordsISO"](https://raku.land/cpan:ANTONOV/Lingua::StopwordsISO), [AAp6])

```perl6
my %wordTallies2 = %wordTallies.grep({ $_.value ≥ 10 && $_.key.chars > 1 && $_ ∈ %dictionaryWords && $_.key ∉ stopwords-iso('English')});
%wordTallies2.elems
```
```
# 0
```

Instead of checking for dictionary words -- or in conjunction -- we can filter to have only words 
that made of letters and dashes:

```perl6
my %wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 0
```

Here we tabulate the most frequent  

```perl6
my @tbls = do for %wordTallies3.pairs.sort(-*.value).rotor(40) { to-pretty-table(transpose([$_>>.key, $_>>.value])
.map({ %(<word count>.Array Z=> $_.Array) }), align => 'l', field-names => <word count>).Str }
to-pretty-table([%( ^@tbls.elems Z=> @tbls),], field-names => (0 ..^ @tbls.elems)>>.Str, align => 'l', :!header, vertical-char => ' ', horizontal-char => ' ');
```
```
# None of the specified field names are known.
#   in block  at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/0F0F02947BDF8EA88884374F57CC4E6E363E847E (Data::Reshapers::ToPrettyTable) line 201
#   in sub ToPrettyTable at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/0F0F02947BDF8EA88884374F57CC4E6E363E847E (Data::Reshapers::ToPrettyTable) line 196
#   in sub to-pretty-table at /Users/antonov/.rakubrew/versions/moar-/share/perl6/site/sources/E311A46781B6CAA919A25354D3EDEB887BCB033E (Data::Reshapers) line 412
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

------

## Data split

In this section we split the data into training and testing parts. The split is stratified per DSL.

We categorize the DSL commands according to their DSL:

```perl6
srand(83);
my %splitGroups = @wCommands.categorize({ $_.value });
%splitGroups>>.elems
```
```
# {Classification => 870, LatentSemanticAnalysis => 870, NeuralNetworkCreation => 870, QuantileRegression => 870, RandomTabularDataset => 870, Recommendations => 870}
```

Here we split each category with the ratio 0.75 (using the function `take-drop` from ["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), [AAp3]): 

```perl6
my %split = %splitGroups.map( -> $g { $g.key => %( ['training', 'testing'] Z=> take-drop($g.value.pick(*), 0.75)) });
%split>>.elems
```
```
# {Classification => 2, LatentSemanticAnalysis => 2, NeuralNetworkCreation => 2, QuantileRegression => 2, RandomTabularDataset => 2, Recommendations => 2}
```

Here we aggregate the training and testing parts for each category and show the corresponding sizes: 

```perl6
my %split2;
for %split.kv -> $k, $v { 
	%split2<training> = %split2<training>.append(|$v<training>); 
	%split2<testing> = %split2<testing>.append(|$v<testing>);
};
%split2>>.elems
```
```
# {testing => 1302, training => 3918}
```

Here we show a sample of commands from the training part:

```perl6
.raku.say for %split2<training>.pick(6)
```
```
# "train network for 27.7402 days , for 346 rounds , and 224.647 seconds , 224.647 second" => "NeuralNetworkCreation"
# "give line roc curve plot of f1 score" => "Classification"
# "give classifier Accuracy summarize the data divide dataset using 6.38282 \% for training data and 912.709 percent validation data , 82.8963 percent for validation together with 194.255 \% for testing" => "Classification"
# "calculate outliers" => "QuantileRegression"
# "find statistical thesaurus with 355.023 number of synonyms" => "LatentSemanticAnalysis"
# "get data the hrb data" => "LatentSemanticAnalysis"
```

------

## Trie creation

Here we take the unique DSL commands labels:

```perl6
my @labels = unique(@wCommands>>.value)
```
```
# [Classification LatentSemanticAnalysis NeuralNetworkCreation QuantileRegression RandomTabularDataset Recommendations]
```

Here we make derive a set of "known words" set using the "frequent enough" words of training data:

```perl6
%wordTallies = %split2<training>>>.key.map({ $_.split(/ \s | ',' /) }).&flatten>>.trim>>.lc.&tally;
%wordTallies2 = %wordTallies.grep({ $_.value ≥ 12 && $_.key.chars > 1 && $_.key ∉ stopwords-iso('English')});
%wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 212
```

```perl6
my %knownWords = Set(%wordTallies3);
%knownWords.elems
```
```
# 212
```

Here we define sub the converts a command into trie-phrase: 

```perl6
multi make-trie-basket(Str $command, %knownWords) {
	$command.split(/\s | ','/)>>.trim>>.lc.grep({ $_ (elem) %knownWords }).unique.sort.Array
}

multi make-trie-basket(Pair $p, %knownWords) {
   make-trie-basket($p.key, %knownWords).append($p.value)
}
```
```
# &make-trie-basket
```

Here is an example invocation `make-trie-basket`:

```perl6
my $rb = %split2<training>.pick;
say $rb.raku;
say make-trie-basket($rb, %knownWords).raku;
```
```
# :LongShortTermMemoryLayer("NeuralNetworkCreation")
# ["NeuralNetworkCreation"]
```

Here we convert all training data commands into trie-phrases:

```perl6
my $tStart = now;

my @training = %split2<training>.map({ make-trie-basket($_, %knownWords) }).Array;

say "Time to process traning commands: {now - $tStart}."
```
```
# Time to process traning commands: 0.330286766.
```

Here we make the trie:

```perl6
$tStart = now;

my $trDSL = @training.&trie-create.node-probabilities;

say "Time to make the DSL trie: {now - $tStart}."
```
```
# Time to make the DSL trie: 0.465165654.
```

Here are the trie node counts:

```perl6
$trDSL.node-counts
```
```
# {Internal => 5214, Leaves => 1801, Total => 7015}
```

------

## Confusion matrix

In this section we put together the confusion matrix of derived trie classifier over the testing data.

First we define a function that gives actual and predicted DSL-labels for given training rules:

```perl6
sub make-cf-couple(Pair $p) {
    my $query = make-trie-basket($p.key, %knownWords);
    my $lbl = $trDSL.classify($query, :!verify-key-existence);
    %(actual => $p.value, predicted => ($lbl ~~ Str) ?? $lbl !! 'NA', command => $p.key)
}
```
```
# &make-cf-couple
```

Here we classify all commands in the testing data part:

```perl6
my $tStart = now;

my @actualPredicted = %split2<testing>.map({ make-cf-couple($_) }).Array;

my $tEnd = now;
say "Total time to classify with the DSL trie: {$tEnd - $tStart}.";
say "Time per classification: {($tEnd - $tStart)/@actualPredicted.elems}."
```
```
# Total time to classify with the DSL trie: 0.662988808.
# Time per classification: 0.0005092079938556068.
```

Here is the confusion matrix (using `cross-tabulate` of 
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), [AAp3]):

```perl6
my $ct = cross-tabulate(@actualPredicted, "actual", "predicted");
to-pretty-table($ct, field-names=>@labels.sort.Array.append('NA'))
```
```
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----+
# |                        | Classification | LatentSemanticAnalysis | NeuralNetworkCreation | QuantileRegression | RandomTabularDataset | Recommendations | NA |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----+
# | Classification         |      169       |           15           |           3           |         19         |          8           |        2        | 1  |
# | LatentSemanticAnalysis |       1        |          188           |                       |         13         |          8           |        5        | 2  |
# | NeuralNetworkCreation  |                |                        |          200          |         5          |          1           |        2        | 9  |
# | QuantileRegression     |       27       |           16           |           6           |        157         |          6           |        5        |    |
# | RandomTabularDataset   |                |                        |                       |         1          |         214          |        2        |    |
# | Recommendations        |                |           12           |           2           |         23         |          2           |       167       | 11 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----+
```

Here are the corresponding fractions:

```perl6
my $ct2 = $ct.map({ $_.key => $_.value <</>> $_.value.values.sum });
to-pretty-table($ct2, field-names=>@labels.sort.Array.append('NA'))
```
```
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
# |                        | Classification | LatentSemanticAnalysis | NeuralNetworkCreation | QuantileRegression | RandomTabularDataset | Recommendations |    NA    |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
# | Classification         |    0.778802    |        0.069124        |        0.013825       |      0.087558      |       0.036866       |     0.009217    | 0.004608 |
# | LatentSemanticAnalysis |    0.004608    |        0.866359        |                       |      0.059908      |       0.036866       |     0.023041    | 0.009217 |
# | NeuralNetworkCreation  |                |                        |        0.921659       |      0.023041      |       0.004608       |     0.009217    | 0.041475 |
# | QuantileRegression     |    0.124424    |        0.073733        |        0.027650       |      0.723502      |       0.027650       |     0.023041    |          |
# | RandomTabularDataset   |                |                        |                       |      0.004608      |       0.986175       |     0.009217    |          |
# | Recommendations        |                |        0.055300        |        0.009217       |      0.105991      |       0.009217       |     0.769585    | 0.050691 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
```

Here we show a sample of confused (misclassified) commands:

```perl6
srand(883);
to-pretty-table(@actualPredicted.grep({ $_<actual> ne $_<predicted> }).pick(12).sort({ $_<command> }), field-names=><actual predicted command>, align=>'l')
```
```
# +-----------------------+------------------------+------------------------------------------------------------------------------------------------------------------------------+
# | actual                | predicted              | command                                                                                                                      |
# +-----------------------+------------------------+------------------------------------------------------------------------------------------------------------------------------+
# | NeuralNetworkCreation | NA                     | SummationLayer                                                                                                               |
# | QuantileRegression    | LatentSemanticAnalysis | add to context as c8uw                                                                                                       |
# | Classification        | QuantileRegression     | display current pipeline context keys                                                                                        |
# | QuantileRegression    | Classification         | echo current pipeline value                                                                                                  |
# | QuantileRegression    | Classification         | find outliers                                                                                                                |
# | Recommendations       | QuantileRegression     | get me217 from context                                                                                                       |
# | Classification        | NA                     | how many classifiers?                                                                                                        |
# | QuantileRegression    | Classification         | make standard regression pipeline xtabs for dependent column against dependent column compute least squares do NetRegression |
# | Recommendations       | LatentSemanticAnalysis | make the pipeline using zpqrx7203s                                                                                           |
# | Recommendations       | LatentSemanticAnalysis | retrieve d14wvunz from context                                                                                               |
# | NeuralNetworkCreation | NA                     | show OutputPorts                                                                                                             |
# | QuantileRegression    | LatentSemanticAnalysis | show the pipeline value                                                                                                      |
# +-----------------------+------------------------+------------------------------------------------------------------------------------------------------------------------------+
```

By examining the confusion matrix we can conclude that the classifier is good enough.

-----

## Association rules

In this section we go through the association rules finding outlined above. 

**Remark"** We do not present the trie classifier making and results with frequent sets, 
but I can (bravely) declare that experiments with trie classifiers made with the words 
of the found frequent sets produce very similar results as the ones with word-tallies.

Here we process the "word baskets" made from the DSL commands and corresponding DSL workflow labels:

```perl6
my $tStart = now;

my @baskets = @wCommands.map({ ($_.key.split(/\s | ','/)>>.trim.grep({ $_.chars > 0 && $_ ~~ /<:L>+/ && $_ ∈ %dictionaryWords && $_ ∉ stopwords-iso('English')})).Array.append($_.value) }).Array;

say "Number of baskets: {@baskets.elems}";

say "Time to process baskets {now - $tStart}."
```
```
# Number of baskets: 5220
# Time to process baskets 17.622710602.
```

Here is a sample of the baskets:

```perl6
.say for @baskets.pick(6) 
```
```
# [transform symbolic numeric Classification]
# [echo data time series data graph QuantileRegression]
# [verify Classification]
# [compute moving average QuantileRegression]
# [calculate rescale add context time series data default step QuantileRegression]
# [partition LatentSemanticAnalysis]
```

Here is a summary of the basket sizes:

```perl6
records-summary(@baskets>>.elems)
```
```
# +--------------------+
# | numerical          |
# +--------------------+
# | Min    => 1        |
# | 3rd-Qu => 5        |
# | Max    => 37       |
# | 1st-Qu => 2        |
# | Mean   => 4.081418 |
# | Median => 3        |
# +--------------------+
```

Here we find frequent sets of words (using the function `frequent-sets` from 
["ML::AssociationRuleLearning"](https://raku.land/zef:antononcube/ML::AssociationRuleLearning), [AAp7]):

```perl6
my $tStart = now;

my @freqSets = frequent-sets(@baskets.grep({ 3 < $_.elems }).Array, min-support => 0.005, min-number-of-items => 2, max-number-of-items => 6):counts;

say "\t\tNumber of frequent sets: {@freqSets.elems}.";

my $tEnd = now;
say "Timing: {$tEnd - $tStart}."
```
```
# Number of frequent sets: 5110.
# Timing: 138.428897789.
```

Here is a sample of the found frequent sets:

```perl6
.say for @freqSets.pick(12)
```
```
# (form frame max tabular values) => 17
# (LatentSemanticAnalysis item matrix word) => 41
# (RandomTabularDataset chance data frame tabular values) => 12
# (create data random values) => 12
# (data max randomized set tabular) => 12
# (generate max names) => 18
# (matrix term) => 70
# (RandomTabularDataset data generate max min names) => 13
# (RandomTabularDataset arbitrary form frame) => 12
# (arbitrary data randomized) => 13
# (RandomTabularDataset chance data driven min set) => 18
# (create set tabular) => 47
```


------

## References

### Articles

### Packages, repositories

[AAp1] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::ExampleDatasets Raku package](https://github.com/antononcube/Raku-Data-ExampleDatasets),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[DSL::Shared::Utilities::ComprehensiveTranslation Raku package](https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Lingua::StopwordsISO Raku package](https://github.com/antononcube/Raku-Lingua-StopwordsISO),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[ML::AssociationRuleLearning Raku package](https://github.com/antononcube/Raku-ML-AssociationRuleLearning),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp8] Anton Antonov,
[ML::ROCFunctions Raku package](https://github.com/antononcube/Raku-ML-ROCFunctions),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp9] Anton Antonov,
[ML::TriesWithFrequencies Raku package](https://github.com/antononcube/Raku-ML-TriesWithFrequencies),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp10] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov
["Raku for Prediction"](https://www.youtube.com/watch?v=frpCBjbQtnA),
(2021),
[TRC-2021](https://conf.raku.org/2021)
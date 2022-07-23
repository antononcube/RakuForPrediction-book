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
# 4020
```

Show summary of the data (using `records-summary` from 
["Data::Summarizers"](https://github.com/antononcube/Raku-Data-Summarizers), [AAp4]):


```perl6
records-summary(@tbl)
```
```
# +---------------------------------------+-------------------------------+
# | Command                               | Workflow                      |
# +---------------------------------------+-------------------------------+
# | summarize data                => 18   | QuantileRegression     => 670 |
# | summarize the data            => 18   | Recommendations        => 670 |
# | drill                         => 13   | Classification         => 670 |
# | graph                         => 11   | NeuralNetworkCreation  => 670 |
# | train                         => 10   | LatentSemanticAnalysis => 670 |
# | plots                         => 9    | RandomTabularDataset   => 670 |
# | extract statistical thesaurus => 9    |                               |
# | (Other)                       => 3932 |                               |
# +---------------------------------------+-------------------------------+
```

Make a list of pairs:

```perl6
my @wCommands = @tbl.map({ $_<Command> => $_<Workflow>}).List;
say @wCommands.elems
```
```
# 4020
```

Show a sample of the pairs:

```perl6
srand(33);
.say for @wCommands.pick(12).sort
```
```
# calculate profile for the s1u2h together with mpy5e3kx72 and mpy5e3kx72 , and mpy5e3kx72 and mpy5e3kx72 together with mpy5e3kx72 => Recommendations
# generate the standard workflow with gui10jevz => Recommendations
# how many nets in repository => NeuralNetworkCreation
# make a random-driven data set for max number of values 299 => RandomTabularDataset
# make ensemble with 474.094 NearestNeighbors from nr2y for of data => Classification
# recommend through the consumption profile 7nt4owyr93 together with gn47hp2 together with gn47hp2 , gn47hp2 => Recommendations
# remove the outliers => Classification
# set decoder Boolean by edi74qy edi74qy edi74qy edi74qy => NeuralNetworkCreation
# set decoder Image3D with hop6 hop6 hop6 => NeuralNetworkCreation
# split => Classification
# verify the MeanCrossEntropy is greater than False => Classification
# what is the number of the nets generate network state object for u8il0ksb45 => NeuralNetworkCreation
```

------

## Word tallies

```perl6
my %wordTallies = @wCommands>>.key.map({ $_.split(/ \s | ',' /) }).&flatten>>.trim>>.lc.&tally;
%wordTallies.elems
```
```
# 3295
```

```perl6
records-summary(%wordTallies.values.List)
```
```
# +---------------------+
# | numerical           |
# +---------------------+
# | Median => 1         |
# | 1st-Qu => 1         |
# | 3rd-Qu => 3         |
# | Max    => 2356      |
# | Min    => 1         |
# | Mean   => 11.145068 |
# +---------------------+
```

```perl6
my %wordTallies2 = %wordTallies.grep({ $_.value >= 10 && $_.key.chars > 1 && $_.key !(elem) stopwords-iso('English')});
%wordTallies2.elems
```
```
# 270
```

```perl6
my %wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 244
```

```perl6
my @tbls = do for %wordTallies3.pairs.sort(-*.value).rotor(40) { to-pretty-table(transpose([$_>>.key, $_>>.value])
.map({ %(<word count>.Array Z=> $_.Array) }), align => 'l', field-names => <word count>).Str }
to-pretty-table([%( ^@tbls.elems Z=> @tbls),], field-names => (0 ..^ @tbls.elems)>>.Str, align => 'l', :!header, vertical-char => ' ', horizontal-char => ' ');
```
```
# +                           +                             +                                +                            +                                   +                                   +
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
#   | word          | count |   | word            | count |   | word               | count |   | word           | count |   | word                  | count |   | word                  | count |  
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
#   | data          | 1145  |   | time            | 120   |   | form               | 61    |   | modify         | 32    |   | accuracies            | 21    |   | sentences             | 15    |  
#   | tabular       | 404   |   | column          | 118   |   | initialize         | 60    |   | axes           | 31    |   | shuffling             | 21    |   | records               | 15    |  
#   | set           | 391   |   | loss            | 116   |   | functions          | 60    |   | xtabs          | 31    |   | boolean               | 20    |   | sections              | 15    |  
#   | create        | 362   |   | document        | 114   |   | ensemble           | 58    |   | chart          | 31    |   | ingest                | 20    |   | tanh                  | 15    |  
#   | generate      | 348   |   | batch           | 113   |   | encoder            | 56    |   | summaries      | 30    |   | timestamp             | 20    |   | steps                 | 15    |  
#   | frame         | 303   |   | assign          | 112   |   | epochs             | 55    |   | interpolation  | 30    |   | hours                 | 20    |   | training              | 15    |  
#   | pipeline      | 271   |   | variable        | 112   |   | analysis           | 55    |   | reduce         | 29    |   | tokens                | 20    |   | sum                   | 15    |  
#   | dataset       | 257   |   | size            | 110   |   | transform          | 53    |   | plot           | 29    |   | temporal              | 20    |   | maximum               | 15    |  
#   | values        | 248   |   | item            | 106   |   | quantileregression | 53    |   | probability    | 29    |   | nmf                   | 19    |   | ctclosslayer          | 15    |  
#   | context       | 225   |   | consumption     | 104   |   | model              | 52    |   | class          | 28    |   | chapters              | 19    |   | absolute              | 14    |  
#   | layer         | 215   |   | poisson         | 104   |   | function           | 50    |   | lsi            | 28    |   | ctc                   | 19    |   | ramp                  | 14    |  
#   | columns       | 215   |   | echo            | 101   |   | percent            | 50    |   | total          | 28    |   | method                | 19    |   | map                   | 14    |  
#   | profile       | 200   |   | semantic        | 99    |   | rounds             | 48    |   | texts          | 28    |   | paragraphs            | 19    |   | sequence              | 14    |  
#   | display       | 194   |   | term            | 96    |   | knots              | 47    |   | count          | 28    |   | dimensions            | 18    |   | equals                | 14    |  
#   | matrix        | 192   |   | series          | 94    |   | fit                | 47    |   | generators     | 28    |   | roc                   | 18    |   | feature               | 14    |  
#   | rows          | 175   |   | word            | 94    |   | object             | 47    |   | moving         | 27    |   | repository            | 18    |   | squares               | 14    |  
#   | standard      | 175   |   | filter          | 91    |   | latent             | 45    |   | models         | 27    |   | matrices              | 18    |   | minutes               | 13    |  
#   | variables     | 167   |   | normal          | 89    |   | summarize          | 44    |   | binary         | 27    |   | quantileregressionfit | 18    |   | nearest               | 13    |  
#   | chance-driven | 161   |   | history         | 89    |   | statistical        | 44    |   | documents      | 27    |   | axis                  | 18    |   | layers                | 13    |  
#   | max           | 160   |   | network         | 88    |   | clusters           | 43    |   | dependent      | 26    |   | days                  | 18    |   | negative              | 13    |  
#   | neural        | 159   |   | quantile        | 86    |   | step               | 43    |   | verify         | 26    |   | meansquaredlosslayer  | 17    |   | crossentropylosslayer | 13    |  
#   | outliers      | 154   |   | partition       | 86    |   | nets               | 41    |   | terms          | 26    |   | label                 | 17    |   | contrastive           | 13    |  
#   | calculate     | 153   |   | recommender     | 85    |   | reduction          | 41    |   | plots          | 26    |   | meanabsolutelosslayer | 17    |   | types                 | 12    |  
#   | random        | 153   |   | randomstring    | 84    |   | apply              | 40    |   | image          | 25    |   | leastsquares          | 17    |   | tag                   | 12    |  
#   | regression    | 145   |   | recommend       | 81    |   | retrieve           | 39    |   | summary        | 25    |   | operating             | 17    |   | categorical           | 12    |  
#   | driven        | 143   |   | explain         | 78    |   | entries            | 39    |   | histogram      | 25    |   | svd                   | 17    |   | decision              | 12    |  
#   | chance        | 143   |   | decoder         | 76    |   | generator          | 39    |   | degree         | 24    |   | neighbors             | 17    |   | curve                 | 12    |  
#   | topics        | 142   |   | load            | 76    |   | entropy            | 38    |   | cross-tabulate | 24    |   | receiver              | 17    |   | collection            | 12    |  
#   | compute       | 141   |   | recommendation  | 75    |   | resample           | 38    |   | probabilities  | 24    |   | remove                | 17    |   | tree                  | 12    |  
#   | items         | 138   |   | thesaurus       | 73    |   | extend             | 38    |   | add            | 23    |   | weights               | 17    |   | nearestneighbors      | 11    |  
#   | train         | 137   |   | current         | 72    |   | networks           | 37    |   | iterations     | 23    |   | contrastivelosslayer  | 17    |   | input                 | 11    |  
#   | workflow      | 133   |   | list            | 72    |   | classifiers        | 37    |   | assert         | 23    |   | characteristic        | 17    |   | resampling            | 11    |  
#   | min           | 133   |   | wide            | 71    |   | normalization      | 37    |   | false          | 23    |   | rate                  | 16    |   | vector                | 11    |  
#   | random-driven | 131   |   | dimension       | 70    |   | classification     | 35    |   | minute         | 23    |   | synonyms              | 16    |   | gradientboostedtrees  | 11    |  
#   | randomreal    | 131   |   | extract         | 70    |   | cross              | 34    |   | divide         | 23    |   | hour                  | 16    |   | curves                | 11    |  
#   | names         | 126   |   | quantiles       | 67    |   | graph              | 34    |   | split          | 22    |   | audio                 | 16    |   | errors                | 11    |  
#   | randomized    | 126   |   | chain           | 67    |   | rescale            | 33    |   | basis          | 22    |   | symbolic              | 16    |   | squared               | 11    |  
#   | arbitrary     | 125   |   | format          | 65    |   | drill              | 32    |   | cosine         | 22    |   | inverse               | 16    |   | holdvaluefromleft     | 11    |  
#   | recommended   | 124   |   | recommendations | 64    |   | netregression      | 32    |   | idf            | 21    |   | testing               | 16    |   | logical               | 10    |  
#   | classifier    | 122   |   | frequency       | 63    |   | arrays             | 32    |   | tabulate       | 21    |   | equal                 | 16    |   | day                   | 10    |  
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
# +                           +                             +                                +                            +                                   +                                   +
```

------

## Data split

```perl6
srand(83);
my %splitGroups = @wCommands.categorize({ $_.value });
%splitGroups>>.elems
```
```
# {Classification => 670, LatentSemanticAnalysis => 670, NeuralNetworkCreation => 670, QuantileRegression => 670, RandomTabularDataset => 670, Recommendations => 670}
```

```perl6
my %split = %splitGroups.map( -> $g { $g.key => %( ['training', 'testing'] Z=> take-drop($g.value, 0.75)) });
%split>>.elems
```
```
# {Classification => 2, LatentSemanticAnalysis => 2, NeuralNetworkCreation => 2, QuantileRegression => 2, RandomTabularDataset => 2, Recommendations => 2}
```

```perl6
my %split2;
for %split.kv -> $k, $v { 
	%split2<training> = %split2<training>.append(|$v<training>); 
	%split2<testing> = %split2<testing>.append(|$v<testing>);
};
%split2>>.elems
```
```
# {testing => 1002, training => 3018}
```

```perl6
.raku.say for %split2<training>.pick(6)
```
```
# :DeconvolutionLayer("NeuralNetworkCreation")
# "load the data vl74 data" => "LatentSemanticAnalysis"
# "recommend for history zmy : 716.822" => "Recommendations"
# "recommend over profile lwvp -> 685.714" => "Recommendations"
# "assign cross entropy loss layer" => "NeuralNetworkCreation"
# "create random-driven dataset and" => "RandomTabularDataset"
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
%wordTallies2 = %wordTallies.grep({ $_.value ≥ 6 && $_.key.chars > 1 && $_.key !(elem) stopwords-iso('English')});
%wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 257
```

```perl6
my %knownWords = Set(%wordTallies3);
%knownWords.elems
```
```
# 257
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
# "compute 238.974 topics" => "LatentSemanticAnalysis"
# ["compute", "topics", "LatentSemanticAnalysis"]
```

Here we convert all training data commands into trie-phrases:

```perl6
my $tStart = now;

my @training = %split2<training>.map({ make-trie-basket($_, %knownWords) }).Array;

say "Time to process traning commands: {now - $tStart}."
```
```
# Time to process traning commands: 0.261616447.
```

Here we make the trie:

```perl6
$tStart = now;

my $trDSL = @training.&trie-create.node-probabilities;

say "Time to make the DSL trie: {now - $tStart}."
```
```
# Time to make the DSL trie: 0.347756765.
```

Here are the trie node counts:

```perl6
$trDSL.node-counts
```
```
# {Internal => 4841, Leaves => 1594, Total => 6435}
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
# Total time to classify with the DSL trie: 8.453450677.
# Time per classification: 0.008436577521956087.
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
# | Classification         |       65       |           1            |                       |         11         |          62          |        7        | 21 |
# | LatentSemanticAnalysis |       19       |           50           |                       |         1          |          87          |        9        | 1  |
# | NeuralNetworkCreation  |       2        |                        |           78          |         37         |          34          |        1        | 15 |
# | QuantileRegression     |       38       |                        |           1           |         47         |          57          |        7        | 17 |
# | RandomTabularDataset   |                |                        |                       |         1          |         165          |        1        |    |
# | Recommendations        |       11       |           1            |                       |                    |                      |       136       | 19 |
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
# | Classification         |    0.389222    |        0.005988        |                       |      0.065868      |       0.371257       |     0.041916    | 0.125749 |
# | LatentSemanticAnalysis |    0.113772    |        0.299401        |                       |      0.005988      |       0.520958       |     0.053892    | 0.005988 |
# | NeuralNetworkCreation  |    0.011976    |                        |        0.467066       |      0.221557      |       0.203593       |     0.005988    | 0.089820 |
# | QuantileRegression     |    0.227545    |                        |        0.005988       |      0.281437      |       0.341317       |     0.041916    | 0.101796 |
# | RandomTabularDataset   |                |                        |                       |      0.005988      |       0.988024       |     0.005988    |          |
# | Recommendations        |    0.065868    |        0.005988        |                       |                    |                      |     0.814371    | 0.113772 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
```

Here we show a sample of confused (misclassified) commands:

```perl6
srand(883);
to-pretty-table(@actualPredicted.grep({ $_<actual> ne $_<predicted> }).pick(12).sort({ $_<command> }), field-names=><actual predicted command>, align=>'l')
```
```
# +------------------------+----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
# | actual                 | predicted            | command                                                                                                                                                                       |
# +------------------------+----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
# | LatentSemanticAnalysis | RandomTabularDataset | partition data into paragraphs                                                                                                                                                |
# | LatentSemanticAnalysis | RandomTabularDataset | partition text into words                                                                                                                                                     |
# | QuantileRegression     | Classification       | rescale the axes                                                                                                                                                              |
# | Recommendations        | Classification       | retrieve a5kfsct4h from context                                                                                                                                               |
# | Recommendations        | NA                   | show the value                                                                                                                                                                |
# | QuantileRegression     | Classification       | summarize the data summarize data rescale axes do QuantileRegression for probability list 55.8396 55.8396 55.8396 55.8396 and the 786.362 786.362 786.362 786.362 probability |
# | NeuralNetworkCreation  | RandomTabularDataset | train                                                                                                                                                                         |
# | NeuralNetworkCreation  | RandomTabularDataset | train                                                                                                                                                                         |
# | LatentSemanticAnalysis | RandomTabularDataset | transform item word matrix entries functions frequency together with frequency , frequency and cosine                                                                         |
# | LatentSemanticAnalysis | RandomTabularDataset | transform the item word matrix entries the frequency , frequency together with max normalization                                                                              |
# | Classification         | RandomTabularDataset | xtabs for data                                                                                                                                                                |
# | Classification         | Recommendations      | xtabs label column vs input column test data data                                                                                                                             |
# +------------------------+----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

By examining the confusion matrix we can conclude that the classifier is good enough.

-----

## Association rules

In this section we go through the association rules finding outlined above. 
We do not present the classifier with frequent sets, but experiments with 

```{perl6, eval=FALSE}
my @labels = unique(@wCommands>>.value)
```
```
# [Classification LatentSemanticAnalysis NeuralNetworkCreation QuantileRegression RandomTabularDataset Recommendations]
```

```{perl6, eval=FALSE)
my $tStart = now;

my @baskets = @wCommands.map({ ($_.key.split(/\s | ','/)>>.trim.grep({ $_.chars > 0 && $_ ~~ /<:L>+/ && $_ !(elem) stopwords-iso('English')})).Array.append($_.value) }).Array;

say "Number of baskets: {@baskets.elems}";

say "Time to process baskets {now - $tStart}."
```
```
# Number of baskets: 4020
# Time to process baskets 16.899949751.
```

```{perl6, eval=FALSE)
records-summary(@baskets>>.elems)
```
```
# +--------------------+
# | numerical          |
# +--------------------+
# | Min    => 1        |
# | Mean   => 5.871891 |
# | Max    => 60       |
# | Median => 5        |
# | 1st-Qu => 3        |
# | 3rd-Qu => 6        |
# +--------------------+
```

```{perl6, eval=FALSE}
my $tStart = now;

my @freqSets = frequent-sets(@baskets.grep({ 3 < $_.elems < 40 }).Array, min-support => 0.005, min-number-of-items => 2, max-number-of-items => 6):counts;

say "\t\tNumber of frequent sets: {@freqSets.elems}.";

my $tEnd = now;
say "Timing: {$tEnd - $tStart}."
```
```
# Number of frequent sets: 3444.
# Timing: 270.399003228.
```

```{perl6, eval=FALSE}
.say for @freqSets.pick(12)
```
```
# (create data random-driven tabular) => 17
# (RandomTabularDataset random rows values) => 17
# (create frame randomized) => 17
# (RandomTabularDataset data random) => 110
# (QuantileRegression calculate outliers time) => 18
# (RandomTabularDataset create frame) => 59
# (frame randomized) => 43
# (arbitrary generate set) => 17
# (RandomTabularDataset chance driven tabular variables) => 17
# (driven frame tabular) => 28
# (RandomTabularDataset random rows) => 32
# (data form set) => 20
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
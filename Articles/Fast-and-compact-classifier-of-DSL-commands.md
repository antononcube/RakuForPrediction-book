# Fast and compact classifier of DSL commands
***AKA "Fairly fast and accurate trie-based classifier of DSL commands"***  

Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
July 2022


## Introduction

In this (computational Markdown) document we show how to derive with Raku a fast and simple 
Machine Learning (ML) classifier that classifies natural language commands made with 
Domain Specific Languages (DSLs) of a set of computational workflows.

For example, such classifier should classify the command *"calculate document term matrix"*
as a Latent Semantic Analysis (LSA) workflow command. (And, say, give it the label "LatentSemanticAnalysis".) 

The primary motivation for making DSL-classifier is to speed up the parsing of specifications that
belong to a (somewhat) large collection of workflow DSLs. (For example, the Raku package [AAp5] has twelve workflows.)

*Remark:* Such classifier is used in the Mathematica package provided by the 
["NLP Template Engine" project](https://github.com/antononcube/NLP-Template-Engine), [AAr2, AAv1]. 

Here is a mind-map that summarizes the methodology of ML classifier making, [AA1]:

![](https://raw.githubusercontent.com/antononcube/SimplifiedMachineLearningWorkflows-book/master/Diagrams/Making-competitions-classifiers-mind-map.png)

Here is a "big picture" flow-chart that *encompasses* the procedures outlined and implemented in this documents:

![](https://github.com/antononcube/NLP-Template-Engine/raw/main/Documents/Diagrams/General/Computation-workflow-type-classifier-making.png)

This article can be seen as an extension of the article 
["Trie-based classifiers evaluation"](https://rakuforprediction.wordpress.com/2022/07/07/trie-based-classifiers-evaluation/), 
[AA2].

### DSL specifications

Here are example of computational DSL specifications for the workflows 
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
each of them is to parse the given DSL specification completely.

------

## Procedures outlines

In this section we outline: 

- The brute force DSL parsing procedure

- The modification of the brute force procedure by using the DSL-classifier

- The derivation of the DSL-classifier

- Possible applications of Association Rule Learning algorithms

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

### Derivation of a DSL-classifier

1. For each of the DSLs generate at least a few hundred random commands using their grammars.
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

Here we load the Raku packages used below:

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

Read the text data -- the labeled DSL commands -- from a CSV file (using `example-dataset` from 
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
# +--------------------------------+-------------------------------+
# | Command                        | Workflow                      |
# +--------------------------------+-------------------------------+
# | summarize data         => 27   | Recommendations        => 870 |
# | summarize the data     => 25   | NeuralNetworkCreation  => 870 |
# | train                  => 16   | RandomTabularDataset   => 870 |
# | graph                  => 14   | QuantileRegression     => 870 |
# | drill                  => 13   | Classification         => 870 |
# | do quantile regression => 13   | LatentSemanticAnalysis => 870 |
# | net regression         => 13   |                               |
# | (Other)                => 5099 |                               |
# +--------------------------------+-------------------------------+
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

**Remark:** The random labeled DSL commands ingested above were generated using the grammars of the project
[ConversationalAgents at GitHub](https://github.com/antononcube/ConversationalAgents), [AAr1],
and the function `GrammarRandomSentences` of the Mathematica package 
["FunctionalParsers.m"](https://github.com/antononcube/MathematicaForPrediction/blob/master/FunctionalParsers.m), [AAp12]. 

**Remark:** Currently it is very hard to generate random sentences using grammars in Raku.
That is also true for other grammar systems. (If that kind of functionality exists, it is usually added
much latter in development phase.) I am hopeful that the
[Raku AST project](https://news.perlfoundation.org/post/2022-02-raku-ast-grant)
is going to greatly facilitate grammar-based random sentence generation.

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
# | Min    => 1         |
# | Mean   => 11.189731 |
# | 3rd-Qu => 2         |
# | 1st-Qu => 1         |
# | Median => 1         |
# | Max    => 2828      |
# +---------------------+
```

Here we filter the word tallies to be only with words that are:
- Have frequency ten or higher
- Have at least two characters
- Dictionary words 
- Not English stop words (using the function `stopwords-iso` from ["Lingua::StopwordsISO"](https://raku.land/cpan:ANTONOV/Lingua::StopwordsISO), [AAp6])

```perl6
my %wordTallies2 = %wordTallies.grep({ $_.value ≥ 10 && $_.key.chars > 1 && $_.key ∈ %dictionaryWords && $_.key ∉ stopwords-iso('English')});
%wordTallies2.elems
```
```
# 173
```

Instead of checking for dictionary words -- or in conjunction -- we can filter to have only words 
that made of letters and dashes:

```perl6
my %wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 172
```

Here we tabulate the most frequent words (in descending order):

```perl6
my @tbls = do for %wordTallies3.pairs.sort(-*.value).rotor(40) { to-pretty-table(transpose([$_>>.key, $_>>.value])
.map({ %(<word count>.Array Z=> $_.Array) }), align => 'l', field-names => <word count>).Str }
to-pretty-table([%( ^@tbls.elems Z=> @tbls),], field-names => (0 ..^ @tbls.elems)>>.Str, align => 'l', :!header, vertical-char => ' ', horizontal-char => ' ');
```
```
# +                         +                            +                            +                         +
#   +-------------+-------+   +----------------+-------+   +----------------+-------+   +-------------+-------+  
#   | word        | count |   | word           | count |   | word           | count |   | word        | count |  
#   +-------------+-------+   +----------------+-------+   +----------------+-------+   +-------------+-------+  
#   | data        | 1432  |   | workflow       | 121   |   | latent         | 54    |   | cosine      | 26    |  
#   | tabular     | 513   |   | recommendation | 120   |   | extend         | 52    |   | dependent   | 26    |  
#   | set         | 485   |   | normal         | 120   |   | generator      | 52    |   | curve       | 26    |  
#   | create      | 444   |   | form           | 118   |   | verify         | 51    |   | class       | 25    |  
#   | generate    | 416   |   | term           | 112   |   | fit            | 48    |   | input       | 24    |  
#   | pipeline    | 341   |   | variable       | 110   |   | summary        | 45    |   | count       | 24    |  
#   | frame       | 331   |   | history        | 109   |   | step           | 44    |   | method      | 23    |  
#   | values      | 330   |   | partition      | 107   |   | plot           | 43    |   | basis       | 23    |  
#   | context     | 329   |   | semantic       | 106   |   | add            | 43    |   | inverse     | 22    |  
#   | display     | 256   |   | thesaurus      | 105   |   | repository     | 39    |   | minutes     | 22    |  
#   | names       | 254   |   | explain        | 100   |   | rescale        | 38    |   | false       | 21    |  
#   | matrix      | 243   |   | wide           | 99    |   | assert         | 38    |   | maximum     | 21    |  
#   | layer       | 242   |   | filter         | 95    |   | reduction      | 37    |   | minute      | 20    |  
#   | neural      | 226   |   | network        | 94    |   | sum            | 36    |   | temporal    | 19    |  
#   | random      | 225   |   | recommend      | 93    |   | modify         | 36    |   | hours       | 19    |  
#   | max         | 224   |   | model          | 87    |   | drill          | 35    |   | sequence    | 19    |  
#   | profile     | 215   |   | load           | 87    |   | remove         | 35    |   | steps       | 19    |  
#   | compute     | 191   |   | format         | 86    |   | image          | 35    |   | total       | 19    |  
#   | train       | 183   |   | extract        | 85    |   | divide         | 34    |   | absolute    | 18    |  
#   | standard    | 177   |   | transform      | 84    |   | terms          | 34    |   | categorical | 18    |  
#   | arbitrary   | 176   |   | chain          | 83    |   | symbolic       | 34    |   | element     | 18    |  
#   | batch       | 174   |   | function       | 82    |   | tabulate       | 33    |   | audio       | 17    |  
#   | size        | 173   |   | frequency      | 82    |   | binary         | 33    |   | map         | 17    |  
#   | calculate   | 172   |   | current        | 81    |   | chart          | 33    |   | hour        | 17    |  
#   | randomized  | 169   |   | decoder        | 80    |   | reduce         | 33    |   | validating  | 16    |  
#   | regression  | 167   |   | list           | 78    |   | classification | 32    |   | fraction    | 16    |  
#   | loss        | 166   |   | ensemble       | 77    |   | histogram      | 31    |   | squared     | 16    |  
#   | classifier  | 163   |   | initialize     | 74    |   | equal          | 30    |   | collection  | 16    |  
#   | assign      | 160   |   | entropy        | 74    |   | roc            | 30    |   | true        | 15    |  
#   | column      | 158   |   | object         | 73    |   | receiver       | 30    |   | validation  | 15    |  
#   | driven      | 158   |   | dimension      | 70    |   | moving         | 30    |   | testing     | 14    |  
#   | chance      | 158   |   | analysis       | 69    |   | characteristic | 30    |   | scalar      | 14    |  
#   | min         | 157   |   | summarize      | 65    |   | interpolation  | 30    |   | ramp        | 14    |  
#   | time        | 147   |   | retrieve       | 64    |   | ingest         | 30    |   | probability | 14    |  
#   | consumption | 146   |   | percent        | 61    |   | operating      | 30    |   | ctc         | 14    |  
#   | echo        | 138   |   | apply          | 61    |   | boolean        | 30    |   | measurement | 13    |  
#   | document    | 133   |   | normalization  | 59    |   | idf            | 30    |   | synonym     | 13    |  
#   | item        | 130   |   | cross          | 59    |   | axis           | 28    |   | day         | 13    |  
#   | word        | 128   |   | graph          | 56    |   | split          | 27    |   | days        | 12    |  
#   | series      | 124   |   | statistical    | 55    |   | degree         | 27    |   | tag         | 12    |  
#   +-------------+-------+   +----------------+-------+   +----------------+-------+   +-------------+-------+  
# +                         +                            +                            +                         +
```

------

## Data split

In this section we split the data into training and testing parts. The split is stratified per DSL.

Here we:
- Categorize the DSL commands according to their DSL label 
- Tabulate the corresponding number of commands per label

```perl6
srand(83);
my %splitGroups = @wCommands.categorize({ $_.value });
to-pretty-table([%splitGroups>>.elems,])
```
```
# +------------------------+--------------------+-----------------+----------------------+----------------+-----------------------+
# | LatentSemanticAnalysis | QuantileRegression | Recommendations | RandomTabularDataset | Classification | NeuralNetworkCreation |
# +------------------------+--------------------+-----------------+----------------------+----------------+-----------------------+
# |          870           |        870         |       870       |         870          |      870       |          870          |
# +------------------------+--------------------+-----------------+----------------------+----------------+-----------------------+
```

Here each category is:
- Randomly shuffled 
- Split into training and testing parts with the ratio 0.75 (using the function `take-drop` from ["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), [AAp3])
- The corresponding number of elements are tabulated

```perl6
my %split = %splitGroups.map( -> $g { $g.key => %( ['training', 'testing'] Z=> take-drop($g.value.pick(*), 0.75)) });
to-pretty-table(%split.map({ $_.key => $_.value>>.elems }))
```
```
# +------------------------+---------+----------+
# |                        | testing | training |
# +------------------------+---------+----------+
# | Classification         |   217   |   653    |
# | LatentSemanticAnalysis |   217   |   653    |
# | NeuralNetworkCreation  |   217   |   653    |
# | QuantileRegression     |   217   |   653    |
# | RandomTabularDataset   |   217   |   653    |
# | Recommendations        |   217   |   653    |
# +------------------------+---------+----------+
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
# "modify symbolic columns into categorical" => "Classification"
# "cross tabulate feature variable against label variable in validating data data" => "Classification"
# "cross-tabulate input variable vs 836 column" => "Classification"
# "consider wvpx4 data of yhj5v" => "Classification"
# "create random tabular dataset for" => "RandomTabularDataset"
# "list the names of the models" => "NeuralNetworkCreation"
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

Here we make a "known words" set using the "frequent enough" words of the training data:

```perl6
%wordTallies = %split2<training>>>.key.map({ $_.split(/ \s | ',' /) }).&flatten>>.trim>>.lc.&tally;
%wordTallies2 = %wordTallies.grep({ $_.value ≥ 12 && $_.key.chars > 1 && $_.key ∉ stopwords-iso('English')});
%wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 216
```

```perl6
my %knownWords = Set(%wordTallies3);
%knownWords.elems
```
```
# 216
```

Here we define sub that converts a command into trie-phrase: 

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
# "ingest the fxya8dn6 time series" => "QuantileRegression"
# ["ingest", "series", "time", "QuantileRegression"]
```

Here we convert all training data commands into trie-phrases:

```perl6
my $tStart = now;

my @training = %split2<training>.map({ make-trie-basket($_, %knownWords) }).Array;

say "Time to process traning commands: {now - $tStart}."
```
```
# Time to process traning commands: 0.346154476.
```

Here we make the trie:

```perl6
$tStart = now;

my $trDSL = @training.&trie-create.node-probabilities;

say "Time to make the DSL trie: {now - $tStart}."
```
```
# Time to make the DSL trie: 0.57843593.
```

Here are the trie node counts:

```perl6
$trDSL.node-counts
```
```
# {Internal => 5444, Leaves => 1844, Total => 7288}
```

Here is an example classification of a command:

```perl6
$trDSL.classify(make-trie-basket('show the outliers', %knownWords), prop => 'Probabilities'):!verify-key-existence
```
```
# {Classification => 0.59375, QuantileRegression => 0.40625}
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
say "Total time to classify {%split2<testing>.elems} tests with the DSL trie: {$tEnd - $tStart}.";
say "Time per classification: {($tEnd - $tStart)/@actualPredicted.elems}."
```
```
# Total time to classify 1302 tests with the DSL trie: 1.135035722.
# Time per classification: 0.00087176322734255.
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
# | Classification         |      165       |           6            |           1           |         16         |          12          |        13       | 4  |
# | LatentSemanticAnalysis |                |          176           |                       |         14         |          14          |        12       | 1  |
# | NeuralNetworkCreation  |       2        |           5            |          195          |         1          |                      |        3        | 11 |
# | QuantileRegression     |       17       |           9            |           5           |        172         |          3           |        10       | 1  |
# | RandomTabularDataset   |                |                        |                       |         3          |         214          |                 |    |
# | Recommendations        |                |           4            |           1           |         8          |          6           |       187       | 11 |
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
# | Classification         |    0.760369    |        0.027650        |        0.004608       |      0.073733      |       0.055300       |     0.059908    | 0.018433 |
# | LatentSemanticAnalysis |                |        0.811060        |                       |      0.064516      |       0.064516       |     0.055300    | 0.004608 |
# | NeuralNetworkCreation  |    0.009217    |        0.023041        |        0.898618       |      0.004608      |                      |     0.013825    | 0.050691 |
# | QuantileRegression     |    0.078341    |        0.041475        |        0.023041       |      0.792627      |       0.013825       |     0.046083    | 0.004608 |
# | RandomTabularDataset   |                |                        |                       |      0.013825      |       0.986175       |                 |          |
# | Recommendations        |                |        0.018433        |        0.004608       |      0.036866      |       0.027650       |     0.861751    | 0.050691 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
```

By examining the confusion matrices and we can conclude that the classifier is good enough.

**Remark:** We examine the diagonals of the matrices and what are the most frequent confusions.  

**Remark:** We addition to the confusion matrix we can do compute the Top-K query statistics -- not done here.
(Top-2 query statistic is answering the question: "Is the expected label in the top 2 most probable labels?")

Here we show a sample of confused (misclassified) commands:

```perl6
srand(883);
to-pretty-table(@actualPredicted.grep({ $_<actual> ne $_<predicted> }).pick(12).sort({ $_<command> }), field-names=><actual predicted command>, align=>'l')
```
```
# +------------------------+------------------------+-------------------------------------------+
# | actual                 | predicted              | command                                   |
# +------------------------+------------------------+-------------------------------------------+
# | Classification         | RandomTabularDataset   | consider data the o4v76yi of k8gb9dzc     |
# | LatentSemanticAnalysis | RandomTabularDataset   | consider the data the 4pw5a               |
# | Recommendations        | LatentSemanticAnalysis | create put into context as soipzak        |
# | Recommendations        | RandomTabularDataset   | create with vn85o4e                       |
# | QuantileRegression     | Classification         | find the bottom the outliers              |
# | Classification         | RandomTabularDataset   | get data the 9u16pdk8h data for 5cb37hutm |
# | QuantileRegression     | Classification         | give summaries                            |
# | Recommendations        | NA                     | give the tag types                        |
# | Classification         | NA                     | into 752.578 / 370.503                    |
# | NeuralNetworkCreation  | NA                     | show output ports                         |
# | LatentSemanticAnalysis | Recommendations        | show value for the context element iwm    |
# | QuantileRegression     | Classification         | summarize the data                        |
# +------------------------+------------------------+-------------------------------------------+
```

**Remark:** We observe that a certain proportion of the misclassified commands are ambiguous -- they do not belong to one DSL.

-----

## Association rules

In this section we go through the association rules finding outlined above. 

**Remark:** We do not present the trie classifier making and results with frequent sets, 
but I can (bravely) declare that experiments with trie classifiers made with the words 
of found frequent sets produce very similar results as the trie classifiers with word-tallies.

Here we process the "word baskets" made from the DSL commands and append corresponding DSL workflow labels:

```{perl6, eval=FALSE}
my $tStart = now;

my @baskets = @wCommands.map({ ($_.key.split(/\s | ','/)>>.trim.grep({ $_.chars > 0 && $_ ~~ /<:L>+/ && $_ ∈ %dictionaryWords && $_ ∉ stopwords-iso('English')})).Array.append($_.value) }).Array;

say "Number of baskets: {@baskets.elems}";

say "Time to process baskets {now - $tStart}."
```

```{perl6, eval=FALSE}
# Number of baskets: 5220
# Time to process baskets 17.622710602.
```

Here is a sample of the baskets:

```{perl6, eval=FALSE}
.say for @baskets.pick(6) 
```

```{perl6, eval=FALSE}
# [transform symbolic numeric Classification]
# [echo data time series data graph QuantileRegression]
# [verify Classification]
# [compute moving average QuantileRegression]
# [calculate rescale add context time series data default step QuantileRegression]
# [partition LatentSemanticAnalysis]
```

Here is a summary of the basket sizes:

```{perl6, eval=FALSE}
records-summary(@baskets>>.elems)
```

```{perl6, eval=FALSE}
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

```{perl6, eval=FALSE}
my $tStart = now;

my @freqSets = frequent-sets(@baskets.grep({ 3 < $_.elems }).Array, min-support => 0.005, min-number-of-items => 2, max-number-of-items => 6):counts;

say "\t\tNumber of frequent sets: {@freqSets.elems}.";

my $tEnd = now;
say "Timing: {$tEnd - $tStart}."
```

```{perl6, eval=FALSE}
# Number of frequent sets: 5110.
# Timing: 138.428897789.
```

Here is a sample of the found frequent sets:

```{perl6, eval=FALSE}
.say for @freqSets.pick(12)
```

```{perl6, eval=FALSE}
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

## Conclusion

We also experimented with a Recommender-based Classifier (RC) -- the accuracy results with RC were slightly better (4±2%) than the trie-based classifier,
but RC is ≈10 times slower. We plan to discuss RC training and results in a subsequent article.

Since we find the performance of the trie-based classifier satisfactory -- both accuracy-wise and speed-wise --
we make a classifier with all of the DSL commands data. See the resource file 
["dsl-trie-classifier.raku"](https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation/blob/main/resources/dsl-trie-classifier.raku), 
of [AAp5].

```perl6
my $trie-to-export = [|%split2<training>, |%split2<testing>].map({ make-trie-basket($_, %knownWords) }).Array.&trie-create;
$trie-to-export.node-counts;
```
```
# {Internal => 6702, Leaves => 2218, Total => 8920}
```

------

## References

### Articles

[AA1] Anton Antonov,
["A monad for classification workflows"](https://mathematicaforprediction.wordpress.com/2018/05/15/a-monad-for-classification-workflows/),
(2018),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov,
["Trie-based classifiers evaluation"](https://rakuforprediction.wordpress.com/2022/07/07/trie-based-classifiers-evaluation/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com/2022/07/07/trie-based-classifiers-evaluation/).

### Packages

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

[AAp11] Anton Antonov,
[Functional parsers Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/FunctionalParsers.m),
(2014),
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

### Repositories

[AAr1] Anton Antonov,
[ConversationalAgents project](https://github.com/antononcube/ConversationalAgents),
(2017-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAr2] Anton Antonov,
[NLP Template Engine](https://github.com/antononcube/NLP-Template-Engine),
(2021-2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov, 
["NLP Template Engine, Part 1"](https://youtu.be/a6PvmZnvF9I), 
(2021), 
[Simplified Machine Learning Workflows at YouTube](https://www.youtube.com/playlist?list=PLke9UbqjOSOi1fc0NkJTdK767cL9XHJF0).

[AAv2] Anton Antonov
["Raku for Prediction"](https://www.youtube.com/watch?v=frpCBjbQtnA),
(2021),
[TRC-2021](https://conf.raku.org/2021).



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
# +--------------------------------+-------------------------------+
# | Command                        | Workflow                      |
# +--------------------------------+-------------------------------+
# | summarize data         => 27   | LatentSemanticAnalysis => 870 |
# | summarize the data     => 25   | Classification         => 870 |
# | train                  => 16   | Recommendations        => 870 |
# | graph                  => 14   | QuantileRegression     => 870 |
# | drill                  => 13   | RandomTabularDataset   => 870 |
# | do quantile regression => 13   | NeuralNetworkCreation  => 870 |
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

------

## Word tallies

```perl6
my %wordTallies = @wCommands>>.key.map({ $_.split(/ \s | ',' /) }).&flatten>>.trim>>.lc.&tally;
%wordTallies.elems
```
```
# 4090
```

```perl6
records-summary(%wordTallies.values.List)
```
```
# +---------------------+
# | numerical           |
# +---------------------+
# | Min    => 1         |
# | Max    => 2828      |
# | 3rd-Qu => 2         |
# | 1st-Qu => 1         |
# | Median => 1         |
# | Mean   => 11.189731 |
# +---------------------+
```

```perl6
my %wordTallies2 = %wordTallies.grep({ $_.value >= 10 && $_.key.chars > 1 && $_.key !(elem) stopwords-iso('English')});
%wordTallies2.elems
```
```
# 274
```

```perl6
my %wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ [<:L> | '-']+ $ /});
%wordTallies3.elems
```
```
# 256
```

```perl6
my @tbls = do for %wordTallies3.pairs.sort(-*.value).rotor(40) { to-pretty-table(transpose([$_>>.key, $_>>.value])
.map({ %(<word count>.Array Z=> $_.Array) }), align => 'l', field-names => <word count>).Str }
to-pretty-table([%( ^@tbls.elems Z=> @tbls),], field-names => (0 ..^ @tbls.elems)>>.Str, align => 'l', :!header, vertical-char => ' ', horizontal-char => ' ');
```
```
# +                           +                            +                                +                            +                          +                                   +
#   +---------------+-------+   +----------------+-------+   +--------------------+-------+   +----------------+-------+   +--------------+-------+   +-----------------------+-------+  
#   | word          | count |   | word           | count |   | word               | count |   | word           | count |   | word         | count |   | word                  | count |  
#   +---------------+-------+   +----------------+-------+   +--------------------+-------+   +----------------+-------+   +--------------+-------+   +-----------------------+-------+  
#   | data          | 1432  |   | chance         | 158   |   | function           | 82    |   | add            | 43    |   | axes         | 27    |   | tanh                  | 17    |  
#   | tabular       | 513   |   | min            | 157   |   | current            | 81    |   | plots          | 40    |   | dependent    | 26    |   | hour                  | 17    |  
#   | set           | 485   |   | recommended    | 148   |   | decoder            | 80    |   | repository     | 39    |   | curve        | 26    |   | quantileregressionfit | 17    |  
#   | create        | 444   |   | time           | 147   |   | list               | 78    |   | assert         | 38    |   | characters   | 26    |   | audio                 | 17    |  
#   | generate      | 416   |   | consumption    | 146   |   | ensemble           | 77    |   | rescale        | 38    |   | matrices     | 26    |   | sections              | 17    |  
#   | pipeline      | 341   |   | randomstring   | 146   |   | functions          | 74    |   | reduction      | 37    |   | cosine       | 26    |   | collection            | 16    |  
#   | frame         | 331   |   | echo           | 138   |   | initialize         | 74    |   | modify         | 36    |   | class        | 25    |   | validating            | 16    |  
#   | values        | 330   |   | document       | 133   |   | entropy            | 74    |   | netregression  | 36    |   | equals       | 25    |   | meanabsolutelosslayer | 16    |  
#   | context       | 329   |   | item           | 130   |   | object             | 73    |   | sum            | 36    |   | count        | 24    |   | curves                | 16    |  
#   | dataset       | 323   |   | word           | 128   |   | dimension          | 70    |   | arrays         | 35    |   | input        | 24    |   | squared               | 16    |  
#   | columns       | 310   |   | series         | 124   |   | analysis           | 69    |   | cross-tabulate | 35    |   | xtabs        | 24    |   | fraction              | 16    |  
#   | display       | 256   |   | workflow       | 121   |   | summarize          | 65    |   | drill          | 35    |   | synonyms     | 23    |   | tokens                | 15    |  
#   | names         | 254   |   | recommendation | 120   |   | retrieve           | 64    |   | image          | 35    |   | svd          | 23    |   | contrastivelosslayer  | 15    |  
#   | variables     | 244   |   | normal         | 120   |   | apply              | 61    |   | remove         | 35    |   | summaries    | 23    |   | properties            | 15    |  
#   | matrix        | 243   |   | form           | 118   |   | percent            | 61    |   | terms          | 34    |   | errors       | 23    |   | crossentropylosslayer | 15    |  
#   | layer         | 242   |   | recommender    | 114   |   | networks           | 60    |   | texts          | 34    |   | basis        | 23    |   | validation            | 15    |  
#   | neural        | 226   |   | term           | 112   |   | cross              | 59    |   | divide         | 34    |   | method       | 23    |   | meansquaredlosslayer  | 15    |  
#   | random        | 225   |   | variable       | 110   |   | quantileregression | 59    |   | symbolic       | 34    |   | minutes      | 22    |   | true                  | 15    |  
#   | max           | 224   |   | history        | 109   |   | recommendations    | 59    |   | tabulate       | 33    |   | inverse      | 22    |   | testing               | 14    |  
#   | outliers      | 223   |   | partition      | 107   |   | normalization      | 59    |   | chart          | 33    |   | squares      | 22    |   | ramp                  | 14    |  
#   | profile       | 215   |   | semantic       | 106   |   | classifiers        | 57    |   | reduce         | 33    |   | paragraphs   | 22    |   | scalar                | 14    |  
#   | compute       | 191   |   | poisson        | 106   |   | graph              | 56    |   | binary         | 33    |   | resampling   | 22    |   | records               | 14    |  
#   | train         | 183   |   | thesaurus      | 105   |   | statistical        | 55    |   | chapters       | 33    |   | leastsquares | 22    |   | probability           | 14    |  
#   | standard      | 177   |   | randomreal     | 101   |   | latent             | 54    |   | classification | 32    |   | false        | 21    |   | ctc                   | 14    |  
#   | arbitrary     | 176   |   | explain        | 100   |   | extend             | 52    |   | documents      | 32    |   | iterations   | 21    |   | weights               | 13    |  
#   | batch         | 174   |   | wide           | 99    |   | generator          | 52    |   | histogram      | 31    |   | maximum      | 21    |   | day                   | 13    |  
#   | size          | 173   |   | quantile       | 97    |   | verify             | 51    |   | ingest         | 30    |   | minute       | 20    |   | synonym               | 13    |  
#   | calculate     | 172   |   | filter         | 95    |   | generators         | 51    |   | equal          | 30    |   | neighbors    | 20    |   | naivebayes            | 13    |  
#   | rows          | 171   |   | network        | 94    |   | entries            | 49    |   | characteristic | 30    |   | steps        | 19    |   | measurement           | 13    |  
#   | randomized    | 169   |   | recommend      | 93    |   | models             | 49    |   | receiver       | 30    |   | temporal     | 19    |   | dates                 | 13    |  
#   | regression    | 167   |   | epochs         | 88    |   | clusters           | 48    |   | idf            | 30    |   | timestamp    | 19    |   | ctclosslayer          | 13    |  
#   | items         | 166   |   | model          | 87    |   | fit                | 48    |   | moving         | 30    |   | hours        | 19    |   | sentences             | 13    |  
#   | loss          | 166   |   | load           | 87    |   | nets               | 48    |   | interpolation  | 30    |   | sequence     | 19    |   | rate                  | 12    |  
#   | chance-driven | 164   |   | rounds         | 86    |   | quantiles          | 46    |   | operating      | 30    |   | total        | 19    |   | types                 | 12    |  
#   | classifier    | 163   |   | format         | 86    |   | summary            | 45    |   | boolean        | 30    |   | dimensions   | 19    |   | randomforest          | 12    |  
#   | assign        | 160   |   | extract        | 85    |   | lsi                | 45    |   | roc            | 30    |   | categorical  | 18    |   | contrastive           | 12    |  
#   | topics        | 160   |   | transform      | 84    |   | step               | 44    |   | axis           | 28    |   | absolute     | 18    |   | naive                 | 12    |  
#   | random-driven | 159   |   | chain          | 83    |   | knots              | 44    |   | degree         | 27    |   | element      | 18    |   | negative              | 12    |  
#   | driven        | 158   |   | encoder        | 83    |   | resample           | 43    |   | split          | 27    |   | nmf          | 18    |   | tag                   | 12    |  
#   | column        | 158   |   | frequency      | 82    |   | plot               | 43    |   | probabilities  | 27    |   | map          | 17    |   | nearest               | 12    |  
#   +---------------+-------+   +----------------+-------+   +--------------------+-------+   +----------------+-------+   +--------------+-------+   +-----------------------+-------+  
# +                           +                            +                                +                            +                          +                                   +
```

------

## Data split

```perl6
srand(83);
my %splitGroups = @wCommands.categorize({ $_.value });
%splitGroups>>.elems
```
```
# {Classification => 870, LatentSemanticAnalysis => 870, NeuralNetworkCreation => 870, QuantileRegression => 870, RandomTabularDataset => 870, Recommendations => 870}
```

```perl6
my %split = %splitGroups.map( -> $g { $g.key => %( ['training', 'testing'] Z=> take-drop($g.value.pick(*), 0.75)) });
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
# {testing => 1302, training => 3918}
```

```perl6
.raku.say for %split2<training>.pick(6)
```
```
# "suggest using the history ylqgfdap8 : 815.774 together with h7qwmic : 482.972 and h7qwmic : 482.972 , and h7qwmic : 482.972" => "Recommendations"
# "find the variable importance estimates" => "Classification"
# "extract statistical thesaurus with 137.999 number of nearest neighbors per term" => "LatentSemanticAnalysis"
# "display word item histogram" => "LatentSemanticAnalysis"
# "verify the FalseNegativeRate of 3ckb equals 469.499" => "Classification"
# "dimension reduction into 115.181 columns by SVD" => "Classification"
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
# 210
```

```perl6
my %knownWords = Set(%wordTallies3);
%knownWords.elems
```
```
# 210
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
# "suggest using profile t68lu -> 679.836" => "Recommendations"
# ["profile", "Recommendations"]
```

Here we convert all training data commands into trie-phrases:

```perl6
my $tStart = now;

my @training = %split2<training>.map({ make-trie-basket($_, %knownWords) }).Array;

say "Time to process traning commands: {now - $tStart}."
```
```
# Time to process traning commands: 0.339330079.
```

Here we make the trie:

```perl6
$tStart = now;

my $trDSL = @training.&trie-create.node-probabilities;

say "Time to make the DSL trie: {now - $tStart}."
```
```
# Time to make the DSL trie: 0.496344776.
```

Here are the trie node counts:

```perl6
$trDSL.node-counts
```
```
# {Internal => 5328, Leaves => 1813, Total => 7141}
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
# Total time to classify with the DSL trie: 0.975970635.
# Time per classification: 0.0007495934216589862.
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
# | Classification         |      175       |           9            |                       |         15         |          10          |        4        | 4  |
# | LatentSemanticAnalysis |       4        |          183           |                       |         19         |          10          |        1        |    |
# | NeuralNetworkCreation  |                |                        |          199          |         2          |                      |        4        | 12 |
# | QuantileRegression     |       24       |           12           |           5           |        158         |          6           |        11       | 1  |
# | RandomTabularDataset   |                |                        |                       |                    |         217          |                 |    |
# | Recommendations        |       1        |           10           |           3           |         17         |          5           |       164       | 17 |
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
# | Classification         |    0.806452    |        0.041475        |                       |      0.069124      |       0.046083       |     0.018433    | 0.018433 |
# | LatentSemanticAnalysis |    0.018433    |        0.843318        |                       |      0.087558      |       0.046083       |     0.004608    |          |
# | NeuralNetworkCreation  |                |                        |        0.917051       |      0.009217      |                      |     0.018433    | 0.055300 |
# | QuantileRegression     |    0.110599    |        0.055300        |        0.023041       |      0.728111      |       0.027650       |     0.050691    | 0.004608 |
# | RandomTabularDataset   |                |                        |                       |                    |       1.000000       |                 |          |
# | Recommendations        |    0.004608    |        0.046083        |        0.013825       |      0.078341      |       0.023041       |     0.755760    | 0.078341 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
```

Here we show a sample of confused (misclassified) commands:

```perl6
srand(883);
to-pretty-table(@actualPredicted.grep({ $_<actual> ne $_<predicted> }).pick(12).sort({ $_<command> }), field-names=><actual predicted command>, align=>'l')
```
```
# +------------------------+------------------------+--------------------------------------------------------------+
# | actual                 | predicted              | command                                                      |
# +------------------------+------------------------+--------------------------------------------------------------+
# | Classification         | LatentSemanticAnalysis | add into context as vyil0k                                   |
# | Classification         | LatentSemanticAnalysis | calculate measurement test results                           |
# | Recommendations        | NeuralNetworkCreation  | display the tags                                             |
# | QuantileRegression     | Recommendations        | echo summaries                                               |
# | QuantileRegression     | Recommendations        | echo the context value for rtgn8                             |
# | Classification         | Recommendations        | echo validating together with train and validation summaries |
# | Recommendations        | QuantileRegression     | get bnid from context                                        |
# | QuantileRegression     | RandomTabularDataset   | get dataset that has id x08gm5                               |
# | Recommendations        | NA                     | give tag types                                               |
# | LatentSemanticAnalysis | Classification         | load text collection ze96p                                   |
# | Recommendations        | NA                     | make                                                         |
# | QuantileRegression     | Recommendations        | make a workflow                                              |
# +------------------------+------------------------+--------------------------------------------------------------+
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
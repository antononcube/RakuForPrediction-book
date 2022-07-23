# Fast and simple DSL classifier

Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
July 2022


## Introduction

In this (computational Markdown) document we show how to derive with Raku a fast and simple 
Machine Learning (ML) classifier that classifies natural language commands into 
Domain Specific Language (DSL) labels.

For example, such classifier should classify the command:

```
calculate item term matrix
```

as a Latent Semantic Analysis (LSA) workflow command. (And give it, say, the label `LatentSemanticAnalysis`.) 

The primary motivation for making DSL-classifier is to speed up the parsing specifications that
belong to a (somewhat) large collection of workflows. (For example, the Raku package [AAp5] has twelve workflows.)

------

# Procedures outline

In this section we outline: 

- The brute force DSL parsing procedure

- The modification of the brute force procedure by using the DSL-classifier

- The derivation of the DSL-classifier

### Brute force DSL parsing

### Parsing with the help of a DSL-classifier

### Derivation of the DSL-classifier

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
# | summarize data                => 18   | RandomTabularDataset   => 670 |
# | summarize the data            => 18   | LatentSemanticAnalysis => 670 |
# | drill                         => 13   | NeuralNetworkCreation  => 670 |
# | graph                         => 11   | Recommendations        => 670 |
# | train                         => 10   | Classification         => 670 |
# | plots                         => 9    | QuantileRegression     => 670 |
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
# | Min    => 1         |
# | Mean   => 11.145068 |
# | 1st-Qu => 1         |
# | Median => 1         |
# | 3rd-Qu => 3         |
# | Max    => 2356      |
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
my %wordTallies3 = %wordTallies2.grep({ $_.key ~~ / ^ (<:L> | '-')+ $ /});
%wordTallies3.elems
```
```
# 244
```

```perl6
my @tbls = do for %wordTallies3.pairs.sort(-*.value).rotor(40) {to-pretty-table(transpose([$_>>.key, $_>>.value]).map({ %(<word count>.Array Z=> $_.Array) }), align => 'l', field-names=><word count>).Str}
to-pretty-table( [%( ^@tbls.elems Z=> @tbls ),], field-names => (0..^@tbls.elems)>>.Str, align => 'l', header=> False, vertical-char => ' ', horizontal-char => ' ');
```
```
# +                           +                             +                                +                            +                                   +                                   +
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
#   | word          | count |   | word            | count |   | word               | count |   | word           | count |   | word                  | count |   | word                  | count |  
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
#   | data          | 1145  |   | time            | 120   |   | form               | 61    |   | drill          | 32    |   | idf                   | 21    |   | steps                 | 15    |  
#   | tabular       | 404   |   | column          | 118   |   | functions          | 60    |   | xtabs          | 31    |   | tabulate              | 21    |   | maximum               | 15    |  
#   | set           | 391   |   | loss            | 116   |   | initialize         | 60    |   | axes           | 31    |   | timestamp             | 20    |   | records               | 15    |  
#   | create        | 362   |   | document        | 114   |   | ensemble           | 58    |   | chart          | 31    |   | temporal              | 20    |   | sentences             | 15    |  
#   | generate      | 348   |   | batch           | 113   |   | encoder            | 56    |   | summaries      | 30    |   | tokens                | 20    |   | sections              | 15    |  
#   | frame         | 303   |   | variable        | 112   |   | analysis           | 55    |   | interpolation  | 30    |   | ingest                | 20    |   | tanh                  | 15    |  
#   | pipeline      | 271   |   | assign          | 112   |   | epochs             | 55    |   | probability    | 29    |   | hours                 | 20    |   | training              | 15    |  
#   | dataset       | 257   |   | size            | 110   |   | transform          | 53    |   | plot           | 29    |   | boolean               | 20    |   | sum                   | 15    |  
#   | values        | 248   |   | item            | 106   |   | quantileregression | 53    |   | reduce         | 29    |   | ctc                   | 19    |   | ctclosslayer          | 15    |  
#   | context       | 225   |   | consumption     | 104   |   | model              | 52    |   | lsi            | 28    |   | paragraphs            | 19    |   | ramp                  | 14    |  
#   | columns       | 215   |   | poisson         | 104   |   | percent            | 50    |   | class          | 28    |   | method                | 19    |   | equals                | 14    |  
#   | layer         | 215   |   | echo            | 101   |   | function           | 50    |   | total          | 28    |   | chapters              | 19    |   | map                   | 14    |  
#   | profile       | 200   |   | semantic        | 99    |   | rounds             | 48    |   | generators     | 28    |   | nmf                   | 19    |   | sequence              | 14    |  
#   | display       | 194   |   | term            | 96    |   | knots              | 47    |   | count          | 28    |   | dimensions            | 18    |   | absolute              | 14    |  
#   | matrix        | 192   |   | word            | 94    |   | object             | 47    |   | texts          | 28    |   | days                  | 18    |   | feature               | 14    |  
#   | standard      | 175   |   | series          | 94    |   | fit                | 47    |   | moving         | 27    |   | quantileregressionfit | 18    |   | squares               | 14    |  
#   | rows          | 175   |   | filter          | 91    |   | latent             | 45    |   | binary         | 27    |   | repository            | 18    |   | crossentropylosslayer | 13    |  
#   | variables     | 167   |   | normal          | 89    |   | summarize          | 44    |   | models         | 27    |   | roc                   | 18    |   | negative              | 13    |  
#   | chance-driven | 161   |   | history         | 89    |   | statistical        | 44    |   | documents      | 27    |   | axis                  | 18    |   | layers                | 13    |  
#   | max           | 160   |   | network         | 88    |   | step               | 43    |   | terms          | 26    |   | matrices              | 18    |   | nearest               | 13    |  
#   | neural        | 159   |   | quantile        | 86    |   | clusters           | 43    |   | dependent      | 26    |   | meansquaredlosslayer  | 17    |   | contrastive           | 13    |  
#   | outliers      | 154   |   | partition       | 86    |   | reduction          | 41    |   | plots          | 26    |   | meanabsolutelosslayer | 17    |   | minutes               | 13    |  
#   | calculate     | 153   |   | recommender     | 85    |   | nets               | 41    |   | verify         | 26    |   | leastsquares          | 17    |   | tree                  | 12    |  
#   | random        | 153   |   | randomstring    | 84    |   | apply              | 40    |   | summary        | 25    |   | svd                   | 17    |   | types                 | 12    |  
#   | regression    | 145   |   | recommend       | 81    |   | retrieve           | 39    |   | histogram      | 25    |   | receiver              | 17    |   | curve                 | 12    |  
#   | chance        | 143   |   | explain         | 78    |   | entries            | 39    |   | image          | 25    |   | contrastivelosslayer  | 17    |   | categorical           | 12    |  
#   | driven        | 143   |   | load            | 76    |   | generator          | 39    |   | probabilities  | 24    |   | characteristic        | 17    |   | collection            | 12    |  
#   | topics        | 142   |   | decoder         | 76    |   | entropy            | 38    |   | degree         | 24    |   | label                 | 17    |   | tag                   | 12    |  
#   | compute       | 141   |   | recommendation  | 75    |   | extend             | 38    |   | cross-tabulate | 24    |   | neighbors             | 17    |   | decision              | 12    |  
#   | items         | 138   |   | thesaurus       | 73    |   | resample           | 38    |   | divide         | 23    |   | operating             | 17    |   | vector                | 11    |  
#   | train         | 137   |   | list            | 72    |   | networks           | 37    |   | false          | 23    |   | weights               | 17    |   | squared               | 11    |  
#   | min           | 133   |   | current         | 72    |   | classifiers        | 37    |   | assert         | 23    |   | remove                | 17    |   | gradientboostedtrees  | 11    |  
#   | workflow      | 133   |   | wide            | 71    |   | normalization      | 37    |   | iterations     | 23    |   | hour                  | 16    |   | nearestneighbors      | 11    |  
#   | random-driven | 131   |   | extract         | 70    |   | classification     | 35    |   | minute         | 23    |   | testing               | 16    |   | holdvaluefromleft     | 11    |  
#   | randomreal    | 131   |   | dimension       | 70    |   | cross              | 34    |   | add            | 23    |   | audio                 | 16    |   | curves                | 11    |  
#   | randomized    | 126   |   | chain           | 67    |   | graph              | 34    |   | split          | 22    |   | synonyms              | 16    |   | resampling            | 11    |  
#   | names         | 126   |   | quantiles       | 67    |   | rescale            | 33    |   | cosine         | 22    |   | symbolic              | 16    |   | input                 | 11    |  
#   | arbitrary     | 125   |   | format          | 65    |   | modify             | 32    |   | basis          | 22    |   | rate                  | 16    |   | errors                | 11    |  
#   | recommended   | 124   |   | recommendations | 64    |   | netregression      | 32    |   | accuracies     | 21    |   | equal                 | 16    |   | properties            | 10    |  
#   | classifier    | 122   |   | frequency       | 63    |   | arrays             | 32    |   | shuffling      | 21    |   | inverse               | 16    |   | day                   | 10    |  
#   +---------------+-------+   +-----------------+-------+   +--------------------+-------+   +----------------+-------+   +-----------------------+-------+   +-----------------------+-------+  
# +                           +                             +                                +                            +                                   +                                   +
```


-----

## Association rules

```perl6
my @labels = unique(@wCommands>>.value)
```
```
# [Classification LatentSemanticAnalysis NeuralNetworkCreation QuantileRegression RandomTabularDataset Recommendations]
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
# "how many nets" => "NeuralNetworkCreation"
# "do Fit" => "QuantileRegression"
# "display layers list" => "NeuralNetworkCreation"
# "find the data outliers" => "Classification"
# "initialize the network tsi5wbko give arrays total element count chain with the dot layer over 976.063 -> catenate layer for Total list available networks chain with TransposeLayer [ Tanh ] give names of available models create the neural model state of 4ml0v train the neural net 932.328 hours batch size 383 batch size 383 701 rounds 65.4363 minute 65.4363 second" => "NeuralNetworkCreation"
# "join recommended items with dataset jkf0i6s8 via the column tzog6l8ypv explain recommendation with the consumption profile" => "Recommendations"
```

------

## Trie creation

```perl6
my @labels = unique(@wCommands>>.value)
```
```
# [Classification LatentSemanticAnalysis NeuralNetworkCreation QuantileRegression RandomTabularDataset Recommendations]
```

```perl6
my %knownWords = Set(%wordTallies2);
%knownWords.elems
```
```
# 270
```

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

```perl6
make-trie-basket($rb, %knownWords).raku
```
```
#ERROR: Variable '$rb' is not declared.  Perhaps you forgot a 'sub' if this was
#ERROR: intended to be part of a signature?
# Nil
```

```perl6
my $tStart = now;

my @training = %split2<training>.map({ make-trie-basket($_, %knownWords) }).Array;

say "Time to process traning commands: {now - $tStart}."
```
```
# Time to process traning commands: 0.279050712.
```

```perl6
$tStart = now;

my $trDSL = @training.&trie-create.node-probabilities;

say "Time to make the DSL trie: {now - $tStart}."
```
```
# Time to make the DSL trie: 0.373691604.
```

Here are the trie node counds:

```perl6
$trDSL.node-counts
```
```
# {Internal => 4912, Leaves => 1611, Total => 6523}
```

------

## Confusion matrix

In this section we put together the confusion matrix of derived trie classifier over the testing data.

First we define a function that gives actual and predicted DSL-labels for given training rules:

```perl6
sub make-cf-couple2(Pair $p) {
    my $query = make-trie-basket($p.key, %knownWords);
    my $lbl = $trDSL.classify($query, :!verify-key-existence);
    %(actual => $p.value, predicted => ($lbl ~~ Str) ?? $lbl !! 'NA')
}
```
```
# &make-cf-couple2
```

```perl6
my $tStart = now;

my @actualPredicted = %split2<testing>.map({ make-cf-couple2($_) }).Array;

my $tEnd = now;
say "Total time to classify with the DSL trie: {$tEnd - $tStart}.";
say "Time per classification: {($tEnd - $tStart)/@actualPredicted.elems}."
```
```
# Total time to classify with the DSL trie: 9.384452351.
# Time per classification: 0.009365720909181637.
```

Here is the confusion matrix:

```perl6
my $ct = cross-tabulate(@actualPredicted, "actual", "predicted");
to-pretty-table($ct, field-names=>@labels.sort.Array.append('NA'))
```
```
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----+
# |                        | Classification | LatentSemanticAnalysis | NeuralNetworkCreation | QuantileRegression | RandomTabularDataset | Recommendations | NA |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----+
# | Classification         |      113       |           1            |                       |         11         |          34          |        7        | 1  |
# | LatentSemanticAnalysis |       70       |           66           |                       |                    |          21          |        9        | 1  |
# | NeuralNetworkCreation  |       34       |                        |           80          |         34         |          1           |        3        | 15 |
# | QuantileRegression     |       65       |                        |           1           |         60         |          30          |        7        | 4  |
# | RandomTabularDataset   |                |                        |                       |         1          |         165          |        1        |    |
# | Recommendations        |       16       |           1            |                       |                    |                      |       139       | 11 |
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
# | Classification         |    0.676647    |        0.005988        |                       |      0.065868      |       0.203593       |     0.041916    | 0.005988 |
# | LatentSemanticAnalysis |    0.419162    |        0.395210        |                       |                    |       0.125749       |     0.053892    | 0.005988 |
# | NeuralNetworkCreation  |    0.203593    |                        |        0.479042       |      0.203593      |       0.005988       |     0.017964    | 0.089820 |
# | QuantileRegression     |    0.389222    |                        |        0.005988       |      0.359281      |       0.179641       |     0.041916    | 0.023952 |
# | RandomTabularDataset   |                |                        |                       |      0.005988      |       0.988024       |     0.005988    |          |
# | Recommendations        |    0.095808    |        0.005988        |                       |                    |                      |     0.832335    | 0.065868 |
# +------------------------+----------------+------------------------+-----------------------+--------------------+----------------------+-----------------+----------+
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
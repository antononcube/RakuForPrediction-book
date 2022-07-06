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
# |      10      |      3rd       |     male     |        died       |
# |      20      |      3rd       |     male     |        died       |
# |      40      |      1st       |    female    |      survived     |
# |      -1      |      3rd       |     male     |        died       |
# |      50      |      1st       |     male     |      survived     |
# +--------------+----------------+--------------+-------------------+
```

Here is a summary:

```perl6
use Data::Summarizers;
records-summary(@dsTitanic)
```
```
# +---------------+-----------------+----------------+-------------------+----------------+
# | passengerSex  | id              | passengerClass | passengerSurvival | passengerAge   |
# +---------------+-----------------+----------------+-------------------+----------------+
# | male   => 843 | 97      => 1    | 3rd => 709     | died     => 809   | 20      => 334 |
# | female => 466 | 1064    => 1    | 1st => 323     | survived => 500   | -1      => 263 |
# |               | 925     => 1    | 2nd => 277     |                   | 30      => 258 |
# |               | 244     => 1    |                |                   | 40      => 190 |
# |               | 611     => 1    |                |                   | 50      => 88  |
# |               | 1192    => 1    |                |                   | 60      => 57  |
# |               | 1305    => 1    |                |                   | 0       => 56  |
# |               | (Other) => 1302 |                |                   | (Other) => 63  |
# +---------------+-----------------+----------------+-------------------+----------------+
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

**Remark:** It is better to do stratified sampling, i.e. apply `take-drop` per each label. 

Here we make a trie with the training data:

```perl6
my $trTitanic = $dsTraining.map({ $_.<passengerClass passengerSex passengerAge passengerSurvival> }).Array.&trie-create;
$trTitanic.node-counts
```
```
# {Internal => 63, Leaves => 84, Total => 147}
```

Here is an example decision classification:

```perl6
$trTitanic.classify(<1st female>)
```
```
# survived
```

Here is an example probabilities classification:

```perl6
$trTitanic.classify(<2nd male>, prop=>'Probs')
```
```
# {died => 0.8602941176470589, survived => 0.1397058823529412}
```

We want to classify across all testing data, but not all testing data records might be present in the trie. Let us check
that such testing records are few:

```perl6
$dsTesting.grep({ !$trTitanic.is-key($_<passengerClass passengerSex passengerAge>) }).elems
```
```
# 0
```

Let us remove the records that cannot be classified:

```perl6
$dsTesting = $dsTesting.grep({ $trTitanic.is-key($_<passengerClass passengerSex passengerAge>) })
```
```
# ({id => 538, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 1070, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 240, passengerAge => 30, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 33, passengerAge => 30, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 559, passengerAge => 20, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 288, passengerAge => 60, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 1064, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 204, passengerAge => 30, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 727, passengerAge => 30, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 1006, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1000, passengerAge => -1, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 307, passengerAge => 50, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 728, passengerAge => 70, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1215, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1120, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 926, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 890, passengerAge => 30, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 403, passengerAge => 30, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 502, passengerAge => 10, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 1065, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 1205, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 252, passengerAge => 20, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 488, passengerAge => 60, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 813, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 266, passengerAge => 30, passengerClass => 1st, passengerSex => male, passengerSurvival => survived} {id => 944, passengerAge => 40, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 1284, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 904, passengerAge => -1, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 1232, passengerAge => 30, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 332, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 310, passengerAge => 30, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 972, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 153, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => survived} {id => 1188, passengerAge => 0, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 174, passengerAge => 30, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 364, passengerAge => -1, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 870, passengerAge => 30, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 322, passengerAge => 60, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 1279, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1063, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 710, passengerAge => 20, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 419, passengerAge => 50, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 685, passengerAge => 30, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 127, passengerAge => 40, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 89, passengerAge => 30, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 554, passengerAge => 20, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 197, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => survived} {id => 465, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 834, passengerAge => 50, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1195, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 988, passengerAge => -1, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 269, passengerAge => 20, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 405, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 126, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 1041, passengerAge => 20, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 1201, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 740, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 421, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 751, passengerAge => 30, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 630, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1023, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 712, passengerAge => 30, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1025, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 436, passengerAge => 40, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 534, passengerAge => 20, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 464, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 596, passengerAge => -1, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 825, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1303, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 425, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 46, passengerAge => 40, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 47, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 945, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 259, passengerAge => 30, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 1036, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 1087, passengerAge => 30, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 424, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 769, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1247, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 220, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => survived} {id => 1086, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 97, passengerAge => 50, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 701, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 82, passengerAge => 70, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 243, passengerAge => 30, passengerClass => 1st, passengerSex => female, passengerSurvival => survived} {id => 325, passengerAge => 30, passengerClass => 2nd, passengerSex => female, passengerSurvival => survived} {id => 107, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 295, passengerAge => 50, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 1040, passengerAge => -1, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 928, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 88, passengerAge => 30, passengerClass => 1st, passengerSex => male, passengerSurvival => survived} {id => 1009, passengerAge => 40, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 1048, passengerAge => 20, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 665, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 770, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1163, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 263, passengerAge => 50, passengerClass => 1st, passengerSex => male, passengerSurvival => died} {id => 1170, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 598, passengerAge => -1, passengerClass => 2nd, passengerSex => male, passengerSurvival => survived} {id => 63, passengerAge => 50, passengerClass => 1st, passengerSex => male, passengerSurvival => died} ...)
```

Here classify all testing records:

```perl6
my @testingRecords = $dsTesting.map({ $_.<passengerClass passengerSex passengerAge> }).Array;
my @clRes = $trTitanic.classify(@testingRecords).Array;
@clRes = @clRes.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? "NA" !! $_ })
```
```
# [died died died survived survived died died died died died died died died died died died died survived survived died died survived died died died died died died survived died survived died died survived died died died died died died survived died survived died survived survived died died died died died died died died survived died died died died died died died died died survived died died died died died died died died survived died survived died died died died died died died died survived survived died died died died died died survived died died died died died died died ...]
```

Here is a tally of the classification results

```perl6
tally(@clRes)
```
```
# {died => 208, survived => 54}
```

Here we make a Receiver Operating Characteristic (ROC) record, [AA5, AAp4]:

```perl6
use ML::ROCFunctions;
my %roc = to-roc-hash('survived', 'died', select-columns( $dsTesting, 'passengerSurvival')>>.values.flat, @clRes)
```
```
# {FalseNegative => 47, FalsePositive => 6, TrueNegative => 161, TruePositive => 48}
```

-------

## Trie classification with ROC plots

In the next cell we classify all testing data records. For each record:

- Get probabilities hash for each record
- Add to that hash the actual label
- Make sure the hash has both survival labels

```perl6
use Hash::Merge;
my @clRes = 
do for [|$dsTesting] -> $r {
    my $res = [|$trTitanic.classify( $r<passengerClass passengerSex passengerAge>,  prop => 'Probs' ), Actual => $r<passengerSurvival>].Hash;
    merge-hash( { died => 0, survived => 0}, $res)
}
```
```
# [{Actual => died, died => 0.868421052631579, survived => 0.13157894736842105} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.6, survived => 0.4} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.11538461538461539, survived => 0.8846153846153846} {Actual => died, died => 0.875, survived => 0.125} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => died, died => 0.6, survived => 0.4} {Actual => died, died => 0.5, survived => 0.5} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0.56, survived => 0.44} {Actual => died, died => 0.5862068965517241, survived => 0.41379310344827586} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => survived, died => 0.7901234567901234, survived => 0.20987654320987653} {Actual => survived, died => 0.18181818181818182, survived => 0.8181818181818182} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => survived, died => 0.03333333333333333, survived => 0.9666666666666667} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0.6, survived => 0.4} {Actual => died, died => 0.6470588235294118, survived => 0.35294117647058826} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.56, survived => 0.44} {Actual => died, died => 0.5, survived => 0.5} {Actual => died, died => 0.8918918918918919, survived => 0.10810810810810811} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => survived, died => 0.35294117647058826, survived => 0.6470588235294118} {Actual => died, died => 0.6, survived => 0.4} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.7901234567901234, survived => 0.20987654320987653} {Actual => died, died => 0.875, survived => 0.125} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => survived, died => 0.4727272727272727, survived => 0.5272727272727272} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.5, survived => 0.5} {Actual => died, died => 0.5714285714285714, survived => 0.42857142857142855} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.11538461538461539, survived => 0.8846153846153846} {Actual => survived, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => died, died => 0.868421052631579, survived => 0.13157894736842105} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.56, survived => 0.44} {Actual => died, died => 0.6666666666666666, survived => 0.3333333333333333} {Actual => died, died => 0.8918918918918919, survived => 0.10810810810810811} {Actual => died, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => survived, died => 0.4727272727272727, survived => 0.5272727272727272} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => died, died => 0.8918918918918919, survived => 0.10810810810810811} {Actual => died, died => 0.7901234567901234, survived => 0.20987654320987653} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.7901234567901234, survived => 0.20987654320987653} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 1, survived => 0} {Actual => survived, died => 0.11538461538461539, survived => 0.8846153846153846} {Actual => died, died => 0.8918918918918919, survived => 0.10810810810810811} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.868421052631579, survived => 0.13157894736842105} {Actual => died, died => 0.5714285714285714, survived => 0.42857142857142855} {Actual => died, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.5, survived => 0.5} {Actual => died, died => 0.868421052631579, survived => 0.13157894736842105} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.5862068965517241, survived => 0.41379310344827586} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 1, survived => 0} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.18181818181818182, survived => 0.8181818181818182} {Actual => died, died => 0.7647058823529411, survived => 0.23529411764705882} {Actual => died, died => 0.5862068965517241, survived => 0.41379310344827586} {Actual => survived, died => 0.56, survived => 0.44} {Actual => died, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => survived, died => 0.6, survived => 0.4} {Actual => died, died => 0.6470588235294118, survived => 0.35294117647058826} {Actual => survived, died => 0.4727272727272727, survived => 0.5272727272727272} {Actual => survived, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => died, died => 0.8571428571428571, survived => 0.14285714285714285} {Actual => survived, died => 0.8928571428571429, survived => 0.10714285714285714} {Actual => died, died => 0.5862068965517241, survived => 0.41379310344827586} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => survived, died => 1, survived => 0} {Actual => died, died => 0.5862068965517241, survived => 0.41379310344827586} ...]
```

Here we obtain the range of the label "survived":

```perl6
my @vals = flatten(select-columns(@clRes, 'survived')>>.values);
(min(@vals), max(@vals))
```
```
# (0 1)
```

Here we make list of decision thresholds:

```perl6
my @thRange = min(@vals), min(@vals) + (max(@vals)-min(@vals))/30 ... max(@vals);
records-summary(@thRange)
```
```
# +-------------------------------+
# | numerical                     |
# +-------------------------------+
# | Mean   => 0.5000000000000001  |
# | Min    => 0                   |
# | Max    => 0.9999999999999999  |
# | 3rd-Qu => 0.7666666666666666  |
# | Median => 0.49999999999999994 |
# | 1st-Qu => 0.2333333333333333  |
# +-------------------------------+
```

In the following cell for each threshold:

- For each classification hash decide on "survived" the corresponding value is greater or equal to the threshold
- Make threshold's ROC-hash

```perl6
my @rocs = @thRange.map(-> $th { to-roc-hash('survived', 'died', 
                                                select-columns(@clRes, 'Actual')>>.values.flat, 
                                                select-columns(@clRes, 'survived')>>.values.flat.map({ $_ >= $th ?? 'survived' !! 'died' })) });
```
```
# [{FalseNegative => 0, FalsePositive => 167, TrueNegative => 0, TruePositive => 95} {FalseNegative => 4, FalsePositive => 147, TrueNegative => 20, TruePositive => 91} {FalseNegative => 4, FalsePositive => 147, TrueNegative => 20, TruePositive => 91} {FalseNegative => 4, FalsePositive => 147, TrueNegative => 20, TruePositive => 91} {FalseNegative => 10, FalsePositive => 80, TrueNegative => 87, TruePositive => 85} {FalseNegative => 15, FalsePositive => 59, TrueNegative => 108, TruePositive => 80} {FalseNegative => 15, FalsePositive => 59, TrueNegative => 108, TruePositive => 80} {FalseNegative => 20, FalsePositive => 44, TrueNegative => 123, TruePositive => 75} {FalseNegative => 24, FalsePositive => 37, TrueNegative => 130, TruePositive => 71} {FalseNegative => 24, FalsePositive => 34, TrueNegative => 133, TruePositive => 71} {FalseNegative => 25, FalsePositive => 34, TrueNegative => 133, TruePositive => 70} {FalseNegative => 28, FalsePositive => 28, TrueNegative => 139, TruePositive => 67} {FalseNegative => 28, FalsePositive => 28, TrueNegative => 139, TruePositive => 67} {FalseNegative => 35, FalsePositive => 11, TrueNegative => 156, TruePositive => 60} {FalseNegative => 47, FalsePositive => 9, TrueNegative => 158, TruePositive => 48} {FalseNegative => 47, FalsePositive => 9, TrueNegative => 158, TruePositive => 48} {FalseNegative => 53, FalsePositive => 1, TrueNegative => 166, TruePositive => 42} {FalseNegative => 53, FalsePositive => 1, TrueNegative => 166, TruePositive => 42} {FalseNegative => 53, FalsePositive => 1, TrueNegative => 166, TruePositive => 42} {FalseNegative => 53, FalsePositive => 1, TrueNegative => 166, TruePositive => 42} {FalseNegative => 55, FalsePositive => 0, TrueNegative => 167, TruePositive => 40} {FalseNegative => 55, FalsePositive => 0, TrueNegative => 167, TruePositive => 40} {FalseNegative => 55, FalsePositive => 0, TrueNegative => 167, TruePositive => 40} {FalseNegative => 55, FalsePositive => 0, TrueNegative => 167, TruePositive => 40} {FalseNegative => 55, FalsePositive => 0, TrueNegative => 167, TruePositive => 40} {FalseNegative => 65, FalsePositive => 0, TrueNegative => 167, TruePositive => 30} {FalseNegative => 65, FalsePositive => 0, TrueNegative => 167, TruePositive => 30} {FalseNegative => 71, FalsePositive => 0, TrueNegative => 167, TruePositive => 24} {FalseNegative => 71, FalsePositive => 0, TrueNegative => 167, TruePositive => 24} {FalseNegative => 74, FalsePositive => 0, TrueNegative => 167, TruePositive => 21} {FalseNegative => 83, FalsePositive => 0, TrueNegative => 167, TruePositive => 12}]
```

Here is the obtained ROC-hash table:

```perl6
to-pretty-table(@rocs)
```
```
# +--------------+---------------+--------------+---------------+
# | TruePositive | FalsePositive | TrueNegative | FalseNegative |
# +--------------+---------------+--------------+---------------+
# |      95      |      167      |      0       |       0       |
# |      91      |      147      |      20      |       4       |
# |      91      |      147      |      20      |       4       |
# |      91      |      147      |      20      |       4       |
# |      85      |       80      |      87      |       10      |
# |      80      |       59      |     108      |       15      |
# |      80      |       59      |     108      |       15      |
# |      75      |       44      |     123      |       20      |
# |      71      |       37      |     130      |       24      |
# |      71      |       34      |     133      |       24      |
# |      70      |       34      |     133      |       25      |
# |      67      |       28      |     139      |       28      |
# |      67      |       28      |     139      |       28      |
# |      60      |       11      |     156      |       35      |
# |      48      |       9       |     158      |       47      |
# |      48      |       9       |     158      |       47      |
# |      42      |       1       |     166      |       53      |
# |      42      |       1       |     166      |       53      |
# |      42      |       1       |     166      |       53      |
# |      42      |       1       |     166      |       53      |
# |      40      |       0       |     167      |       55      |
# |      40      |       0       |     167      |       55      |
# |      40      |       0       |     167      |       55      |
# |      40      |       0       |     167      |       55      |
# |      40      |       0       |     167      |       55      |
# |      30      |       0       |     167      |       65      |
# |      30      |       0       |     167      |       65      |
# |      24      |       0       |     167      |       71      |
# |      24      |       0       |     167      |       71      |
# |      21      |       0       |     167      |       74      |
# |      12      |       0       |     167      |       83      |
# +--------------+---------------+--------------+---------------+
```

Here is the corresponding ROC plot:

```perl6
use Text::Plot; 
text-list-plot(roc-functions('FPR')(@rocs), roc-functions('TPR')(@rocs),
                width => 70, height => 25, 
                xLabel => 'FPR', yLabel => 'TPR' )
```
```
# +---+-----------+-----------+------------+-----------+-----------+---+        
# |                                                                    |        
# +                                                                *   +  1.00  
# |                                                         *          |        
# |                                *                                   |        
# |                                                                    |        
# |                         *                                          |        
# +                   *                                                +  0.80  
# |               * *                                                  |        
# |             *                                                      |        
# |       *                                                            |        
# +                                                                    +  0.60 T
# |                                                                    |       P
# |      *                                                             |       R
# |                                                                    |        
# |   *                                                                |        
# +                                                                    +  0.40  
# |                                                                    |        
# |   *                                                                |        
# |   *                                                                |        
# +   *                                                                +  0.20  
# |                                                                    |        
# |   *                                                                |        
# |                                                                    |        
# +---+-----------+-----------+------------+-----------+-----------+---+        
#     0.00        0.20        0.40         0.60        0.80        1.00       
#                                  FPR
```

We can see the Trie classifier has reasonable prediction abilities -- 
we get ≈ 75% True Positive Rate (TPR) with for relatively small False Positive Rate (FPR), ≈ 20%. 

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


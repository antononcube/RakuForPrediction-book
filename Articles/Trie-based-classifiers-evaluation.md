# Trie based classifiers evaluation

## Introduction

In this document we show how to evaluate TriesWithFrequencies, [AA5, AAp7], based classifiers created over well known
Machine Learning (ML) datasets. The computations are done with packages from [Raku's ecosystem](https://raku.land).

The classifiers based on TriesWithFrequencies can be seen as some sort of Naive Bayesian Classifiers (NBCs).

We use the workflow summarized in this flowchart:

![](https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MarkdownDocuments/Diagrams/A-monad-for-classification-workflows/Classification-workflow-horizontal-layout.jpg)

For more details on classification workflows see the article 
["A monad for classification workflows"](https://mathematicaforprediction.wordpress.com/2018/05/15/a-monad-for-classification-workflows/).
[AA1].

### Document execution

This is a "computable Markdown document" -- the Raku cells are (context-consecutively) evaluated with the
["literate programming"](https://en.wikipedia.org/wiki/Literate_programming)
package
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AA2, AAp5].

**Remark:** This document *can be* also made using the Mathematica-and-Raku connector, [AA3], 
but by utilizing the package "Text::Plot", [AAp6, AA8], to produce (informative enough) graphs, that is "less needed."    

------

## Data

Here we get Titanic data using the package "Data::Reshapers", [AA3, AAp2]:

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
# |      80      |      1st       |     male     |      survived     |
# |      20      |      2nd       |     male     |        died       |
# |      20      |      3rd       |     male     |        died       |
# |      70      |      1st       |     male     |        died       |
# |      30      |      2nd       |     male     |        died       |
# +--------------+----------------+--------------+-------------------+
```

Here is a summary:

```perl6
use Data::Summarizers;
records-summary(@dsTitanic)
```
```
# +----------------+---------------+-------------------+-----------------+----------------+
# | passengerAge   | passengerSex  | passengerSurvival | id              | passengerClass |
# +----------------+---------------+-------------------+-----------------+----------------+
# | 20      => 334 | male   => 843 | died     => 809   | 483     => 1    | 3rd => 709     |
# | -1      => 263 | female => 466 | survived => 500   | 1176    => 1    | 1st => 323     |
# | 30      => 258 |               |                   | 370     => 1    | 2nd => 277     |
# | 40      => 190 |               |                   | 1014    => 1    |                |
# | 50      => 88  |               |                   | 1173    => 1    |                |
# | 60      => 57  |               |                   | 821     => 1    |                |
# | 0       => 56  |               |                   | 200     => 1    |                |
# | (Other) => 63  |               |                   | (Other) => 1302 |                |
# +----------------+---------------+-------------------+-----------------+----------------+
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

Here is a mosaic plot that corresponds to the trie above:

![](./Diagrams/Trie-based-classifiers-evaluation/Titanic-mosaic-plot.png)

(The plot is made with Mathematica.)

-------

## Trie classifier

In order to make certain reproducibility statements for the kind of experiments
shown here, we use random seeding (with `srand`) before any computations that use pseudo-random numbers.
Meaning, one would expect Raku code that starts with an `srand` statement (e.g. `srand(889)`)
to produce the same pseudo random numbers if it is executed multiple times (without changing it.)

**Remark:** Per [this comment](https://stackoverflow.com/a/71631427/14163984) it seems that 
a setting of `srand` guarantees the production of reproducible between runs random sequences 
on the particular combination of hardware-OS-software Raku is executed on.

```perl6
srand(889)
```
```
# 889
```

Here we split the data into training and testing data:

```perl6
my ($dsTraining, $dsTesting) = take-drop( @dsTitanic.pick(*), floor(0.8 * @dsTitanic.elems));
say $dsTraining.elems;
say $dsTesting.elems;
```
```
# 1047
# 262
```

(The function `take-drop` is from "Data::Reshapers". It follows Mathematica's 
[`TakeDrop`](https://reference.wolfram.com/language/ref/TakeDrop.html), [WRI1].)

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
# {Internal => 63, Leaves => 85, Total => 148}
```

Here is an example *decision*-classification:

```perl6
$trTitanic.classify(<1st female>)
```
```
# survived
```

Here is an example *probabilities*-classification:

```perl6
$trTitanic.classify(<2nd male>, prop=>'Probs')
```
```
# {died => 0.849624060150376, survived => 0.15037593984962405}
```

We want to classify across all testing data, but not all testing data records might be present in the trie. 
Let us check that such testing records are few (or none):

```perl6
$dsTesting.grep({ !$trTitanic.is-key($_<passengerClass passengerSex passengerAge>) }).elems
```
```
# 0
```

Let us remove the records that cannot be classified:

```perl6
$dsTesting = $dsTesting.grep({ $trTitanic.is-key($_<passengerClass passengerSex passengerAge>) });
$dsTesting.elems
```
```
# 262
```

Here we classify all testing records (and show a few of the results):

```perl6
my @testingRecords = $dsTesting.map({ $_.<passengerClass passengerSex passengerAge> }).Array;
my @clRes = $trTitanic.classify(@testingRecords).Array;
@clRes.head(5)
```
```
# (survived died survived died died)
```

Here is a tally of the classification results:

```perl6
tally(@clRes)
```
```
# {died => 176, survived => 86}
```

(The function `tally` is from "Data::Summarizers". It follows Mathematica's 
[`Tally`](https://reference.wolfram.com/language/ref/Tally.html), [WRI2].)

Here we make a Receiver Operating Characteristic (ROC) record, [AA5, AAp4]:

```perl6
use ML::ROCFunctions;
my %roc = to-roc-hash('survived', 'died', select-columns( $dsTesting, 'passengerSurvival')>>.values.flat, @clRes)
```
```
# {FalseNegative => 37, FalsePositive => 15, TrueNegative => 139, TruePositive => 71}
```

-------

## Trie classification with ROC plots

In the next code cell we classify all testing data records. For each record:

- Get probabilities hash
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
# [{Actual => survived, died => 0.35294117647058826, survived => 0.6470588235294118} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.5714285714285714, survived => 0.42857142857142855} {Actual => survived, died => 0.48, survived => 0.52} {Actual => died, died => 0.5172413793103449, survived => 0.4827586206896552} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0.6296296296296297, survived => 0.37037037037037035} {Actual => died, died => 0.8857142857142857, survived => 0.11428571428571428} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.8857142857142857, survived => 0.11428571428571428} {Actual => survived, died => 0.48, survived => 0.52} {Actual => survived, died => 0.926829268292683, survived => 0.07317073170731707} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => survived, died => 0.45098039215686275, survived => 0.5490196078431373} {Actual => survived, died => 0.8857142857142857, survived => 0.11428571428571428} {Actual => died, died => 0.5172413793103449, survived => 0.4827586206896552} {Actual => died, died => 0.5238095238095238, survived => 0.47619047619047616} {Actual => died, died => 0.8125, survived => 0.1875} {Actual => died, died => 0.6190476190476191, survived => 0.38095238095238093} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 1, survived => 0} {Actual => died, died => 0.926829268292683, survived => 0.07317073170731707} {Actual => survived, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.926829268292683, survived => 0.07317073170731707} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => survived, died => 0.16666666666666666, survived => 0.8333333333333334} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => survived, died => 0.07692307692307693, survived => 0.9230769230769231} {Actual => died, died => 0.8787878787878788, survived => 0.12121212121212122} {Actual => survived, died => 0.6296296296296297, survived => 0.37037037037037035} {Actual => died, died => 0.6153846153846154, survived => 0.38461538461538464} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0.8125, survived => 0.1875} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.6153846153846154, survived => 0.38461538461538464} {Actual => survived, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0.09523809523809523, survived => 0.9047619047619048} {Actual => died, died => 0.7906976744186046, survived => 0.20930232558139536} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.926829268292683, survived => 0.07317073170731707} {Actual => survived, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.8857142857142857, survived => 0.11428571428571428} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.07692307692307693, survived => 0.9230769230769231} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.75, survived => 0.25} {Actual => survived, died => 0.7906976744186046, survived => 0.20930232558139536} {Actual => died, died => 0.75, survived => 0.25} {Actual => survived, died => 0.45098039215686275, survived => 0.5490196078431373} {Actual => survived, died => 0.35294117647058826, survived => 0.6470588235294118} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.8787878787878788, survived => 0.12121212121212122} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.5172413793103449, survived => 0.4827586206896552} {Actual => died, died => 0.8787878787878788, survived => 0.12121212121212122} {Actual => died, died => 0.6190476190476191, survived => 0.38095238095238093} {Actual => died, died => 0.6153846153846154, survived => 0.38461538461538464} {Actual => survived, died => 0.16666666666666666, survived => 0.8333333333333334} {Actual => died, died => 0.8787878787878788, survived => 0.12121212121212122} {Actual => died, died => 0.48, survived => 0.52} {Actual => died, died => 0.6153846153846154, survived => 0.38461538461538464} {Actual => survived, died => 0.07692307692307693, survived => 0.9230769230769231} {Actual => survived, died => 0.16666666666666666, survived => 0.8333333333333334} {Actual => died, died => 0.5172413793103449, survived => 0.4827586206896552} {Actual => died, died => 0.8181818181818182, survived => 0.18181818181818182} {Actual => survived, died => 0.48, survived => 0.52} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.865546218487395, survived => 0.13445378151260504} {Actual => died, died => 0.7906976744186046, survived => 0.20930232558139536} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.35294117647058826, survived => 0.6470588235294118} {Actual => died, died => 0.6153846153846154, survived => 0.38461538461538464} {Actual => died, died => 0.8857142857142857, survived => 0.11428571428571428} {Actual => survived, died => 0.09523809523809523, survived => 0.9047619047619048} {Actual => died, died => 0.48, survived => 0.52} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => survived, died => 0.07692307692307693, survived => 0.9230769230769231} {Actual => died, died => 0.7906976744186046, survived => 0.20930232558139536} {Actual => died, died => 0.75, survived => 0.25} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0.16666666666666666, survived => 0.8333333333333334} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.8888888888888888, survived => 0.1111111111111111} {Actual => survived, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => survived, died => 0.45098039215686275, survived => 0.5490196078431373} {Actual => died, died => 0.09523809523809523, survived => 0.9047619047619048} {Actual => died, died => 0.9203539823008849, survived => 0.07964601769911504} {Actual => died, died => 0.96, survived => 0.04} {Actual => survived, died => 0, survived => 1} {Actual => survived, died => 0, survived => 1} {Actual => died, died => 0, survived => 1} ...]
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
# | Max    => 0.9999999999999999  |
# | 3rd-Qu => 0.7666666666666666  |
# | 1st-Qu => 0.2333333333333333  |
# | Min    => 0                   |
# | Median => 0.49999999999999994 |
# | Mean   => 0.5000000000000001  |
# +-------------------------------+
```

In the following code cell for each threshold:

- For each classification hash decide on "survived" if the corresponding value is greater or equal to the threshold
- Make threshold's ROC-hash

```perl6
my @rocs = @thRange.map(-> $th { to-roc-hash('survived', 'died', 
                                                select-columns(@clRes, 'Actual')>>.values.flat, 
                                                select-columns(@clRes, 'survived')>>.values.flat.map({ $_ >= $th ?? 'survived' !! 'died' })) });
```
```
# [{FalseNegative => 0, FalsePositive => 154, TrueNegative => 0, TruePositive => 108} {FalseNegative => 1, FalsePositive => 150, TrueNegative => 4, TruePositive => 107} {FalseNegative => 1, FalsePositive => 147, TrueNegative => 7, TruePositive => 107} {FalseNegative => 10, FalsePositive => 116, TrueNegative => 38, TruePositive => 98} {FalseNegative => 13, FalsePositive => 84, TrueNegative => 70, TruePositive => 95} {FalseNegative => 19, FalsePositive => 64, TrueNegative => 90, TruePositive => 89} {FalseNegative => 24, FalsePositive => 61, TrueNegative => 93, TruePositive => 84} {FalseNegative => 25, FalsePositive => 51, TrueNegative => 103, TruePositive => 83} {FalseNegative => 28, FalsePositive => 46, TrueNegative => 108, TruePositive => 80} {FalseNegative => 28, FalsePositive => 46, TrueNegative => 108, TruePositive => 80} {FalseNegative => 29, FalsePositive => 46, TrueNegative => 108, TruePositive => 79} {FalseNegative => 29, FalsePositive => 46, TrueNegative => 108, TruePositive => 79} {FalseNegative => 34, FalsePositive => 31, TrueNegative => 123, TruePositive => 74} {FalseNegative => 34, FalsePositive => 28, TrueNegative => 126, TruePositive => 74} {FalseNegative => 34, FalsePositive => 28, TrueNegative => 126, TruePositive => 74} {FalseNegative => 37, FalsePositive => 15, TrueNegative => 139, TruePositive => 71} {FalseNegative => 45, FalsePositive => 11, TrueNegative => 143, TruePositive => 63} {FalseNegative => 51, FalsePositive => 4, TrueNegative => 150, TruePositive => 57} {FalseNegative => 51, FalsePositive => 4, TrueNegative => 150, TruePositive => 57} {FalseNegative => 51, FalsePositive => 4, TrueNegative => 150, TruePositive => 57} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 53, FalsePositive => 3, TrueNegative => 151, TruePositive => 55} {FalseNegative => 61, FalsePositive => 3, TrueNegative => 151, TruePositive => 47} {FalseNegative => 61, FalsePositive => 3, TrueNegative => 151, TruePositive => 47} {FalseNegative => 83, FalsePositive => 1, TrueNegative => 153, TruePositive => 25} {FalseNegative => 83, FalsePositive => 1, TrueNegative => 153, TruePositive => 25} {FalseNegative => 84, FalsePositive => 1, TrueNegative => 153, TruePositive => 24}]
```

Here is the obtained ROC-hash table:

```perl6
to-pretty-table(@rocs)
```
```
# +--------------+---------------+---------------+--------------+
# | TrueNegative | FalseNegative | FalsePositive | TruePositive |
# +--------------+---------------+---------------+--------------+
# |      0       |       0       |      154      |     108      |
# |      4       |       1       |      150      |     107      |
# |      7       |       1       |      147      |     107      |
# |      38      |       10      |      116      |      98      |
# |      70      |       13      |       84      |      95      |
# |      90      |       19      |       64      |      89      |
# |      93      |       24      |       61      |      84      |
# |     103      |       25      |       51      |      83      |
# |     108      |       28      |       46      |      80      |
# |     108      |       28      |       46      |      80      |
# |     108      |       29      |       46      |      79      |
# |     108      |       29      |       46      |      79      |
# |     123      |       34      |       31      |      74      |
# |     126      |       34      |       28      |      74      |
# |     126      |       34      |       28      |      74      |
# |     139      |       37      |       15      |      71      |
# |     143      |       45      |       11      |      63      |
# |     150      |       51      |       4       |      57      |
# |     150      |       51      |       4       |      57      |
# |     150      |       51      |       4       |      57      |
# |     151      |       53      |       3       |      55      |
# |     151      |       53      |       3       |      55      |
# |     151      |       53      |       3       |      55      |
# |     151      |       53      |       3       |      55      |
# |     151      |       53      |       3       |      55      |
# |     151      |       53      |       3       |      55      |
# |     151      |       61      |       3       |      47      |
# |     151      |       61      |       3       |      47      |
# |     153      |       83      |       1       |      25      |
# |     153      |       83      |       1       |      25      |
# |     153      |       84      |       1       |      24      |
# +--------------+---------------+---------------+--------------+
```

Here is the corresponding ROC plot:

```perl6
use Text::Plot; 
text-list-plot(roc-functions('FPR')(@rocs), roc-functions('TPR')(@rocs),
                width => 70, height => 25, 
                x-label => 'FPR', y-label => 'TPR' )
```
```
# +---+-----------+-----------+-----------+------------+-----------+---+        
# |                                                                    |        
# +                                                             ** *   +  1.00  
# |                                                                    |        
# |                                                 *                  |        
# |                                    *                               |        
# |                                                                    |        
# +                            *                                       +  0.80  
# |                       *   *                                        |        
# |                     *                                              |        
# |              **                                                    |        
# |         *                                                          |       T
# +                                                                    +  0.60 P
# |       *                                                            |       R
# |    *                                                               |        
# |    *                                                               |        
# |                                                                    |        
# +    *                                                               +  0.40  
# |                                                                    |        
# |                                                                    |        
# |                                                                    |        
# |                                                                    |        
# |   *                                                                |        
# +                                                                    +  0.20  
# +---+-----------+-----------+-----------+------------+-----------+---+        
#     0.00        0.20        0.40        0.60         0.80        1.00       
#                                  FPR
```

We can see the Trie classifier has reasonable prediction abilities -- 
we get ≈ 75% True Positive Rate (TPR) with relatively small False Positive Rate (FPR), ≈ 20%. 

Here is a ROC plot made with Mathematica (using a different Trie over Titanic data):

![](./Diagrams/Trie-based-classifiers-evaluation/Titanic-Trie-classifier-ROC-plot.png)


-------

## Improvements

For simplicity the workflow above was kept "naive." A better workflow would include:

- Stratified partitioning of training and testing data
- K-fold cross-validation
- Variable significance finding
- Specifically for Tries with frequencies: using different order of variables while constructing the trie

**Remark:** K-fold cross-validation can be "simply" achieved by running this document multiple times using
different random seeds.

-------

## References

### Articles

[AA1] Anton Antonov,
["A monad for classification workflows"](https://mathematicaforprediction.wordpress.com/2018/05/15/a-monad-for-classification-workflows/),
(2018),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov,
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA4] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA5] Anton Antonov,
["ML::TriesWithFrequencies"](https://rakuforprediction.wordpress.com/2022/06/22/mltrieswithfrequencies/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA6] Anton Antonov,
["Data::Generators"](https://rakuforprediction.wordpress.com/2022/06/25/datagenerators/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA7] Anton Antonov,
["ML::ROCFunctions"](https://rakuforprediction.wordpress.com/2022/06/30/mlrocfunctions/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA8] Anton Antonov,
["Text::Plot"](https://rakuforprediction.wordpress.com/2022/07/05/textplot/),
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

### Functions

[WRI1] Wolfram Research (2015), 
[TakeDrop](https://reference.wolfram.com/language/ref/TakeDrop.html), 
Wolfram Language function, (updated 2015).

[WRI2] Wolfram Research (2007), 
[Tally](https://reference.wolfram.com/language/ref/Tally.html), 
Wolfram Language function.




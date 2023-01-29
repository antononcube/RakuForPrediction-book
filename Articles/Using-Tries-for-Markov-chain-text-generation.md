# Using Tries for Markov chain text generation

Anton Antonov   
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction)   
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com)   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
January 2023

## Introduction

In this notebook we discuss the derivation and utilization of 
[Markov chains](https://en.wikipedia.org/wiki/Markov_chain) 
for random text generation. The Markov chains are computed, represented, and utilized with the data structure 
[Tries with frequencies](https://mathematicaforprediction.wordpress.com/?s=tries+with+frequencies), [AA2, AAp1, AAv1]. 
([Tries](https://en.wikipedia.org/wiki/Trie) are also known as "prefix trees.")

We can say that for a given text we use Tries with frequencies to derive language models, and we generate ***new,
plausible text*** using those language models.

In a previous article, [AA1], I discussed how text generation with Markov chains can be implemented with 
Wolfram Language (WL) sparse arrays.

**Remark:** Tries with frequencies can be also implemented with WL's 
[`Tree`](https://reference.wolfram.com/language/ref/Tree.html) structure. 
The implementation in [AAp5] -- which corresonds to [AAp1] -- relies only on 
[`Association`](https://reference.wolfram.com/language/guide/Associations.html), though. 
Further, during the Wolfram Technology Conference 2022 I think I successfully convinced 
[Ian Ford](https://community.wolfram.com/web/ianf) to implement Tries with frequencies using WL's `Tree`.
(Ideally, at some point his implementation would be more scalable and faster than my WL implementation.)

**Remark:** We can say that this notebook provides examples of making language models that are (much) simpler 
than Chat GPT's models, as mentioned by Stephen Wolfram in [SWv1]. 
With these kind of models we can easily generate sentences, like,
["The house ate the lettuce." or "The chair was happy."](https://www.youtube.com/watch?v=zLnhg9kir3Q&t=650s), [SWv1].

**Remark:** The package "Text::Markov", [PP1], by Paweł Pabian also generates text via Markov chains by
using a specialized, "targeted" implementation. This document presents a way of doing Markov chains 
simulations using the general data structure Tries with frequencies.

**Remark:** Language models similar to the ones built below can be used to do phrase completion and contextual spell checking.
The package 
["ML::Spellchecker"](https://github.com/antononcube/Raku-ML-Spellchecker), [AAp4], 
uses that approach.

**Remark:** This (computational) Markdown document corresponds to the Mathematica notebook
["Using Prefix trees for Markov chain text generation"](https://community.wolfram.com/groups/-/m/t/2819012).

-----

## Load packages

Here we load the packages
["ML::TriesWithFrequencies"](["Text::Plot"](https://raku.land/zef:antononcube/ML::TriesWithFrequencies), [AAp1],
["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp2], and
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), [AAp3]:

```perl6
use ML::TriesWithFrequencies;
use Text::Plot;
use Data::Reshapers;
```
```
# (Any)
```

------

## Ingest text

Download
["OriginOfSpecies.txt.zip"](https://github.com/antononcube/SimplifiedMachineLearningWorkflows-book/blob/master/Data/OriginOfSpecies.txt.zip)
file and uzip it.

Get the text from that file:

```perl6
my $text = slurp($*HOME ~ '/Downloads/OriginOfSpecies.txt');
$text.chars
```
```
# 893121
```

Turn the text into separate words and punctuation characters::

```perl6
my $tstart = now;

my @words = $text.match(:g, / \w+ | <punct> /).map({ ~$_ })>>.lc;

my $tend = now;
say "Time to split into words: { $tend - $tstart }.";
```
```
# Time to split into words: 1.074823841.
```

Some statistics:

```perl6
say "Number of words: { @words.elems }.";
say "Number of unique words: { @words.Bag.elems }.";
```
```
# Number of words: 170843.
# Number of unique words: 6927.
```

Here is a sample:

```perl6
@words.head(32).raku;
```
```
# ("introduction", ".", "when", "on", "board", "h", ".", "m", ".", "s", ".", "'", "beagle", ",", "'", "as", "naturalist", ",", "i", "was", "much", "struck", "with", "certain", "facts", "in", "the", "distribution", "of", "the", "inhabitants", "of").Seq
```

Here is the plot that shows Pareto principle adherence to the word counts:

```perl6
text-pareto-principle-plot( @words.Bag.values.List, title => 'Word counts');
```
```
# Word counts                         
#     0.00           0.29          0.58           0.87        
# +---+--------------+-------------+--------------+----------+      
# |                                                          |      
# +               ****************************************   +  1.00
# |        ********                                          |      
# +     ****                                                 +  0.80
# |    **                                                    |      
# +   **                                                     +  0.60
# |   *                                                      |      
# |   *                                                      |      
# +   *                                                      +  0.40
# |   *                                                      |      
# +   *                                                      +  0.20
# |   *                                                      |      
# +                                                          +  0.00
# +---+--------------+-------------+--------------+----------+      
#     0.00           2000.00       4000.00        6000.00
```

**Remark:** We see typical Pareto principle manifestation: 
≈10% of the unique words correspond to ≈80% of all words in the text.

------

## Markov chain construction and utilization

Derive 2-grams:

```perl6
my $n = 2;
my @nGrams = @words.rotor($n => -1);
@nGrams.elems
```
```
# 170842
```

Here we create a trie using 2-grams:

```perl6
$tstart = now;

my $trWords = trie-create(@nGrams);

$tend = now;
say "Time to create the n-gram trie: { $tend - $tstart }.";
```
```
# Time to create the n-gram trie: 10.30988243.
```

Example of random n-gram generation:

```perl6
.say for $trWords.random-choice(6):drop-root;
```
```
# (than do)
# (extremely difficult)
# (these considerations)
# (a great)
# (any one)
# (less sterile)
```

Markov chain generation:

```perl6
my @generated = ['every', 'author'];

for ^30 -> $i {
    @generated = [|@generated.head(*- 1), |$trWords.retrieve([@generated.tail,]).random-choice:drop-root]
}

say @generated;
```
```
# [every author attempts to be strange contingencies are far more strictly littoral animals , owing to me to appear in comparison with hermaphrodites having had undergone a large amount of the great]
```

Here we modify the code line above into a sub that:

1. Generates and splices random n-grams until `$maxSentences` number sentences are obtained
2. Make the generated text more "presentable"

```perl6
sub text-generation($trWords, @startPhrase, UInt $maxSentences = 10) {
    my @generated = @startPhrase>>.lc;
    my $nSentences = 0;
    loop {
        my @ph = $trWords.retrieve([@generated.tail,]).random-choice:drop-root;
        if @ph.tail ∈ <. ? !> { $nSentences++ };
        @generated = [|@generated.head(*- 1), |@ph];
        if $nSentences == $maxSentences { last; }
    }

    @generated[0] = @generated[0].tc;

    my $res = @generated.join(' ').subst(/ \s (<punct>) /, { ~$0 }):g;
    my $res2 = $res.subst(/ ('.' | '!' | '?') ' ' (\w) /, {  $0 ~ ' ' ~ $1.uc }):g;
    return $res2;
}
```
```
# &text-generation
```

**Remark:** We consider a complete sentence to finish with period, question mark, or exclamatory mark (`<. ! ?>`).
Hence, the stopping criteria "counts" how many times those punctuation marks have been reached with the generated
n-grams.

Generate sentences:

```perl6
text-generation($trWords, <Consider the>, 3)
```
```
# Consider the cause other plants, the parent- when a short digression. Hence we have expected on the glacial period, owing to diverge in the destruction of the least possible. Yet suffered in the fact, of the use and this case of precious nectar out of their conditions, marvellous amount of this affinity, and permanent varieties have surmised that the several domestic breeds have descended from one hand, state of which rocky mountains of the victor to judge whether of affinity of the different varieties, so that i watched the bees alone had a single parent successful in huge fragments fall of the bees are either parent-- six or emeu, and has once begun to the nicotiana glutinosa, orders, both are not only with their migration of the arctic shells might be given of the secretion of the reptiles and for transport, the stock; for 30 days, a yellow seeds by every continent when slight successive generation; and it can easily err in our continents now find different varieties of equatorial south america to fill nearly related in successive modification is often separated than is conceivable extent that the conclusion.
```

------

## Using larger n-grams

Let us repeat the text generation above with larger n-grams (e.g. 4-grams).

Here generate the n-gram trie:

```perl6
my $n = 4;
my @nGrams = @words.rotor($n => -1);
my $trWords = trie-create(@nGrams);
$trWords.node-counts
```
```
# {Internal => 76219, Leaves => 53251, Total => 129470}
```

Generate text and show it:

```perl6
my $genText = text-generation($trWords, <Every author>, 6);
.trim.say for $genText.split(/ < . ! ? > /, :v).rotor(2)>>.join;
```
```
# Every author, from experiments made during different strains or sub- species, by the effects.
# Homologous parts of the same species should present varieties; so slightly, and are the parents( a) differed largely from the same part of the organisation, which has given several remarkable case of difficulty in a single pair, or africa under nearly constant.
# And from their common and swedish turnip.
# The resemblance in its crustacea, for here, as before the glacial epoch, and which is generally very few will transmit its unaltered likeness to a distant and isolated regions could be arranged by dr.
# Two distinct organs, such as many more individuals of the same bones in the different islands.
# The most common snapdragon( antirrhinum) a rudiment of a pistil; and kolreuter found that by alph.
# De beaumont, murchison, barrande, and have not be increased; and as modern, by the chest; and it was evident in natural history, when the same species.
# Watson, to any character derived from a single bone of a limb and branch and sub- marked and well fitted for them are varieties or three alone of that individual flower: for instance in south america, has run( more especially as all very long periods, that in allied groups, in order to show that an early age, or dependent on unknown element of a vast number of bears being rendered rudimentary occasionally differs from its embryo, but afterwards breeds from his selection by some way due to be grafted together?
# Why should the sepals, we can dimly seen or quite fertile together, where it exists, they must be assumed that, after a or of i think, see the contest soon decided: for here neither cattle, sheep, and would give two or three of these ants, by the best and safest clue.
# I must believe, than to the other silurian molluscs, even in the many cases will suffice.
# We possess no one will doubt that the continued habit.
# On naked submarine rocks and making fresh water change at least be asserted that all the groups within each area are related to those of the first union of the male sexual element of facts, otherwise would have done for sheep, etc.
# , a large stock from our european seas.
# In explaining the laws of variation have proceeded from one becomes rarer and english pointer have been ample time, become modified forms, increase in countless numbers would quickly become wholly extinct, prepare the transition of any kind must have occurred to me, there has been variable in the long endurance of the other, always induces weakness and sterility in ordinary combs it will be under unchanged conditions, at least, to be connected by the same species when self- fertilising hermaphrodites do occasionally intercross( if such fossiliferous masses can we suppose that natural selection, and a third, a, tenanted by no doubt had some former period under a physiological or by having adapted to the most frequently insisted on increasing in size of the genera and their primordial parent, and england; but a few ferns and a few centuries, through natural selection; and two seeds.
# Reflect for existence amongst all appear together from experiments made in the majority of their wood, the most vigorous species; by slowly acting and in this case it will have associated with several allied species.
# M.
# Is some variation.
```

**Remark:** Using longer n-grams generally produces longer sentences since the probability to "reach" the period
punctuation character with longer n-grams becomes smaller.

-------

## Language model adherence verification

Let us convince ourselves that the method`random-choice` produces words with distribution that correspond to the
trie it is invoked upon.

Here we make a trie for a certain set of words:

```perl6
my @words = ['bar' xx 6].append('bark' xx 3).append('bare' xx 2).append('cam' xx 3).append('came').append('camelia' xx 4);
my $ptrOriginal = trie-create-by-split(@words).node-probabilities;
$ptrOriginal.node-counts
```
```
# {Internal => 10, Leaves => 3, Total => 13}
```

Here we generate random words with using the trie above and make a new trie with them:

```perl6
my $ptrGenerated = trie-create($ptrOriginal.random-choice(120):drop-root).node-probabilities;
$ptrGenerated.node-counts
```
```
# {Internal => 10, Leaves => 3, Total => 13}
```

Here is a comparison table between the two tries:

```perl6
my %tries = Original => $ptrOriginal, Generated => $ptrGenerated;
say to-pretty-table([%tries>>.form,], field-names => <Original Generated>, align => 'l');
```
```
# +----------------------------------+----------------------------------+
# | Original                         | Generated                        |
# +----------------------------------+----------------------------------+
# | TRIEROOT => 1                    | TRIEROOT => 1                    |
# | ├─b => 0.5789473684210527        | ├─b => 0.55                      |
# | │ └─a => 1                       | │ └─a => 1                       |
# | │   └─r => 1                     | │   └─r => 1                     |
# | │     ├─e => 0.18181818181818182 | │     ├─e => 0.15151515151515152 |
# | │     └─k => 0.2727272727272727  | │     └─k => 0.2727272727272727  |
# | └─c => 0.42105263157894735       | └─c => 0.45                      |
# |   └─a => 1                       |   └─a => 1                       |
# |     └─m => 1                     |     └─m => 1                     |
# |       └─e => 0.625               |       └─e => 0.6296296296296297  |
# |         └─l => 0.8               |         └─l => 1                 |
# |           └─i => 1               |           └─i => 1               |
# |             └─a => 1             |             └─a => 1             |
# +----------------------------------+----------------------------------+
```

We see that the probabilities at the nodes are very similar. It is expected that with large number of generation words
nearly the same probabilities to be obtained.

------

## References

### Articles

[AA1] Anton Antonov, 
["Markov chains n-gram model implementation](https://mathematicaforprediction.wordpress.com/2014/01/25/markov-chains-n-gram-model-implementation/), 
(2014), 
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov, 
["Tries with frequencies for data mining"](https://mathematicaforprediction.wordpress.com/2013/12/06/tries-with-frequencies-for-data-mining/), 
(2013), 
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

### Packages

[AAp1] Anton Antonov,
[ML::TriesWithFrequencies Raku package](https://raku.land/zef:antononcube/ML::TriesWithFrequencies),
(2021-2023),
[raku.land/zef:antononcube](https://raku.land/zef:antononcube).

[AAp2] Anton Antonov,
[Text::Plot Raku package](https://raku.land/zef:antononcube/Text::Plot),
(2022),
[raku.land/zef:antononcube](https://raku.land/zef:antononcube).

[AAp3] Anton Antonov,
[Data::Reshaperes Raku package](https://raku.land/zef:antononcube/Data::Reshapers),
(2021-2023),
[raku.land/zef:antononcube](https://raku.land/zef:antononcube).

[AAp4] Anton Antonov,
["ML::Spellchecker"](https://github.com/antononcube/Raku-ML-Spellchecker),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov, 
[TriesWithFrequencies Mathematica package,](https://github.com/antononcube/MathematicaForPrediction/blob/master/TriesWithFrequencies.m),
(2018), 
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).


[PP1] Paweł Pabian,
[Text::Markov Raku package](https://raku.land/zef:bbkr/Text::Markov),
(2016-2023),
[raku.land/zef:bbkr](https://raku.land/zef:bbkr).

### Videos

[AAv1] Anton Antonov, 
["Prefix Trees with Frequencies for Data Analysis and Machine Learning"](https://www.youtube.com/watch?v=MdVp7t8xQbQ), 
(2017), 
Wolfram Technology Conference 2017.

[SWv1] Stephen Wolfram, 
["Stephen Wolfram Answers Live Questions About ChatGPT"](https://www.youtube.com/watch?v=zLnhg9kir3Q), 
(2023), 
[YouTube/Wolfram](https://www.youtube.com/@WolframResearch).
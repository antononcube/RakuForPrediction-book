# Outlier detection in a list of numbers

Anton Antonov   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
May 2022

## Introduction

Outlier identification is indispensable for data cleaning, normalization, and analysis.

I frequently include outlier identification in the interfaces and algorithms I make for search and recommendation engines. Another, fundamental application of 1D outlier detection is in algorithms for anomalies detection in time series. (See [AAv1, AAv2].)

My first introduction to outlier detection was through the book [“Mining Imperfect Data: Dealing with Contamination and Incomplete Records”](http://books.google.com/books/about/Mining_Imperfect_Data.html?id=4FH1QJFMRzEC) by Ronald K. Pearson, [RKP1].

This notebook shows examples of using the Raku package ["Statistics::OutlierIdentifiers"](https://github.com/antononcube/Raku-Statistics-OutlierIdentifiers), [AAp1]. There are related Mathematica and R packages; see [AAp2, AAp3].

**Remark:** This Mathematica notebook uses the Raku connection described in [AA2]. See the section "Setup" at the end. The Raku function for data summarization is described in [AA3].

------

## Outlier detection basics

The purpose of the outlier detection algorithms is to find those elements in a list of numbers that have values significantly higher or lower than the rest of the values.

Taking a certain number of elements with the highest values is not the same as an outlier detection, but it can be used as a replacement.

Let us consider the following set of 50 numbers:

```mathematica
SeedRandom[1212];
points = RandomVariate[GammaDistribution[5, 1], 50];
ResourceFunction["RecordsSummary"][points]
```

![1v3fe9820vj7e](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/1v3fe9820vj7e.png)

If we sort those numbers in descending order and plot them we get:

```mathematica
points = points // Sort // Reverse;
ListPlot[points, PlotStyle -> {PointSize[0.015]}, PlotTheme -> "Detailed", PlotRange -> All, Filling -> Axis, ImageSize -> Medium]
```

![1kpkp8mq0pg6j](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/1kpkp8mq0pg6j.png)

```mathematica
OutlierPosition[lsPoints]

(*{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 45, 46, 47, 48, 49, 50}*)
```

Let us use the following outlier detection algorithm:

1. Find all values in the list that are larger than the mean value multiplied by 1.5;

1. Then find the positions of these values in the list of numbers.

Let us show how we can implement that algorithm in Raku.

First we "transfer" the WL generated points to Raku:

```mathematica
RakuInputExecute["my @points = " <> ToRakuCode[points]];
```

Here is the summary:

```perl6
use Data::Summarizers;
records-summary(@points)

# +---------------------+
# | numerical           |
# +---------------------+
# | Max    => 9.82048   |
# | Mean   => 4.8709482 |
# | 3rd-Qu => 6.04842   |
# | Min    => 1.88537   |
# | 1st-Qu => 3.5015    |
# | Median => 4.44519   |
# +---------------------+
```

Here is the first step:

```perl6
@points.pairs.grep({ $_.value > 1.5 * mean(@points) })

(*"(0 => 9.82048 1 => 8.78346 2 => 8.55282 3 => 7.94426 4 => 7.6337 5 => 7.43507)"*)
```

Here we transfer the found outlier positions from Raku to WL:

```mathematica
pos = 1 + RakuInputExecute["@points.pairs.grep({ $_.value > 1.5 * mean(@points) })>>.key ==>encode-to-wl()"]

(*{1, 2, 3, 4, 5, 6}*)
```

Here we plot the data and the outliers:

```mathematica
ListPlot[{points, Transpose[{pos, points[[pos]]}]}, PlotStyle -> {{PointSize[0.02]}, {Red, PointSize[0.012]}}, Filling -> Axis, PlotRange -> All, PlotTheme -> "Detailed", ImageSize -> Medium, PlotLegends -> {"data", "outliers"}]
```

![08n44gi4n6adx](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/08n44gi4n6adx.png)

Instead of the mean value we can use another reference point, like the median value. 

Obviously, we can also use a multiplier different than 1.5.

## Using the package

First let us load the outlier identification package:

```perl6
use Statistics::OutlierIdentifiers;
```

We can find the outliers in a list of numbers with the function outlier-identifier (using the adverb "values"):

```perl6
outlier-identifier(@points):values

# (9.82048 8.78346 8.55282 7.94426 7.6337 7.43507 7.25105 7.18306 7.1653 6.66771 6.44773 6.27979 2.65329 2.59209 1.92725 1.88537)
```

The package has three functions for the calculation of outlier identifier parameters over a list of numbers:

```perl6
.say for (&hampel-identifier-parameters, &splus-quartile-identifier-parameters, &quartile-identifier-parameters).map({ $_ => $_.(@points) });

&hampel-identifier-parameters => (2.678434884 6.211945116)
&splus-quartile-identifier-parameters => (-0.31888 9.8688)
&quartile-identifier-parameters => (1.89827 6.99211)
```

Elements of the number list that are outside of the numerical interval made by one of these pairs of numbers are considered outliers.

In many cases we want only the top outliers or only the bottom outliers. We can use the functions top-outliers and bottom-outliers for that. Here is an example with for finding top outliers using the Hampel outlier identifier:

```perl6
@points ==> 
outlier-identifier(identifier => &top-outliers o &hampel-identifier-parameters ):values

# (9.82048 8.78346 8.55282 7.94426 7.6337 7.43507 7.25105 7.18306 7.1653 6.66771 6.44773 6.27979)
```

------

## Comparison

Here is a visual comparison of the three outlier identifiers in the package Statistics::OutlierIdentifiers:

Assume we have a (sorted) list of values: 

```perl6
my @vals = random-variate(NormalDistribution.new(:mean(12), :sd(6)), 600).sort;
records-summary(@vals)

# +------------------------------+
# | numerical                    |
# +------------------------------+
# | 1st-Qu => 7.83167266283631   |
# | Mean   => 11.93490153897063  |
# | Min    => -4.807707682102588 |
# | 3rd-Qu => 15.873759102570908 |
# | Median => 11.743637620896695 |
# | Max    => 31.0034374940894   |
# +------------------------------+
```

Here we get the Raku values into WL:

```mathematica
vals = RakuInputExecute["@vals==>encode-to-wl()"];
```

Here is a plot of the (sorted) values:

```mathematica
ListPlot[vals, PlotRange -> All, PlotTheme -> "Detailed"]
```

![0y61ylref7zde](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/0y61ylref7zde.png)

Here we find the outlier positions for each identifier:

```perl6
(&hampel-identifier-parameters, &splus-quartile-identifier-parameters, &quartile-identifier-parameters).map({ $_.name => outlier-identifier(@vals, identifier=>$_) }).Hash==>encode-to-wl()

# <|"hampel-identifier-parameters" -> {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43,44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76,77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599}, 
"splus-quartile-identifier-parameters" -> {0, 1, 2, 3, 596, 597, 598,599}, 
"quartile-identifier-parameters" -> {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599}|>
```

Here we assign the last Raku value -- a hash -- to a WL variable:

```mathematica
aOutliers = %;
```

Here is visual comparison of the three outlier detection algorithms:

```mathematica
vals2 = Transpose[{Range[Length[vals]], vals}];
ListPlot[{vals2, vals2[[aOutliers[#] + 1]]}, PlotLabel -> #, ImageSize -> Medium, PlotStyle -> {{}, {Red, PointSize[0.01]}}, PlotTheme -> "Detailed", PlotRange -> All] & /@ Sort[Keys[aOutliers]]
```

![01tqeugm6tcii](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/01tqeugm6tcii.png)

We can see that the Hampel outlier identifier is most "permissive" at labeling points as outliers, and the SPLUS quartile-based identifier is the most "conservative."

------

## Application example

Let us consider and application of outlier detection using one of the Raku challenges, 165, ["Task 2: Line of Best Fit"](https://theweeklychallenge.org/blog/perl-weekly-challenge-165/).

In this section we use the code given in the blog post ["Writing it down"](https://gfldex.wordpress.com/2022/05/21/writing-it-down/), [WP1].

### Data

Here we get the data:

```perl6
my $input = '333,129  39,189 140,156 292,134 393,52  160,166 362,122  13,193
                341,104 320,113 109,177 203,152 343,100 225,110  23,186 282,102
                284,98  205,133 297,114 292,126 339,112 327,79  253,136  61,169
                128,176 346,72  316,103 124,162  65,181 159,137 212,116 337,86
                215,136 153,137 390,104 100,180  76,188  77,181  69,195  92,186
                275,96  250,147  34,174 213,134 186,129 189,154 361,82  363,89';

my @points = $input.words».split(',')».Int;
@points.elems

(*"48"*)
```

Here we plot the points:

```mathematica
points = RakuInputExecute["@points==>encode-to-wl()"];
grData = ListPlot[points, PlotRange -> All, PlotStyle -> Gray, PlotTheme -> "Detailed", ImageSize -> Medium]
```

![10jw29bko1kjj](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/10jw29bko1kjj.png)

### Best fit line

Here we compute the best linear fit:

```perl6
my \term:<x²> := @points[*;0]».&(*²);
my \xy = @points[*;0] »*« @points[*;1];
my \Σx = [+] @points[*;0];
my \Σy = [+] @points[*;1];
my \term:<Σx²> = [+] x²;
my \Σxy = [+] xy;
my \N = +@points;

my $m = (N * Σxy - Σx * Σy) / (N * Σx² - (Σx)²);
my $b = (Σy - $m * Σx) / N;

say [$m, $b];

# [-0.2999565 200.132272536]
```

Here we get into WL the fitted line slope and offset computed above:

```mathematica
{m, b} = RakuInputExecute["[$m, $b]==>encode-to-wl()"];
```

Here we plot the best fit line:

```mathematica
grLine = Plot[x*m + b, {x, Min[points[[All, 1]]], Max[points[[All, 1]]]}];
Show[{grData, grLine}]
```

![0uhd1yjdca24j](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/0uhd1yjdca24j.png)

### Fit-wise outliers

Let us find the points that are the closest and are the most distant from the fitted line. 

First, we find the distances:

```perl6
my @diffs = @points.map({ my $y = $m * $_[0] + $b; abs($_[1] - $y ) / $y })
```

Here we find the top outliers:

```perl6
my @topPos = outlier-identifier(@diffs, identifier => (&top-outliers o &hampel-identifier-parameters));

(*"[0 3 4 6 13 21 25 34 40 41]"*)
```

Here we find the bottom outliers:

```perl6
my @bottomPos = outlier-identifier(@diffs, identifier => (&bottom-outliers o &hampel-identifier-parameters))

# [1 27 28 32]
```

Here is a plot with the data, the linear fit, and the found top and bottom outliers:

```mathematica
grTopOutliers = 
  ListPlot[points[[1 + RakuInputExecute["@topPos==>encode-to-wl()"]]], PlotStyle -> {PointSize[0.015], Blue}];
grBottomOutliers = 
  ListPlot[ points[[1 + RakuInputExecute["@bottomPos==>encode-to-wl()"]]], PlotStyle -> {PointSize[0.015], Red}];
Legended[ Show[{grData, grLine, grTopOutliers, grBottomOutliers}, ImageSize -> Large],  SwatchLegend[{Gray, Blue, Red}, {"data", "top outliers", "bottom outliers"}]]
```

![10g4x6f5c7z0i](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/10g4x6f5c7z0i.png)

------

## Setup

```mathematica
RakuMode[]
KillRakuProcess[]
StartRakuProcess["Raku" -> "~/.rakubrew/shims/raku"]
```

![0oelkun1d4hsw](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Articles/Diagrams/Outlier-detection-in-a-list-of-numbers/0oelkun1d4hsw.png)

### Serializers load

```mathematica
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/RakuDecoder.m"]
Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/Packages/WL/RakuEncoder.m"]
SetOptions[RakuInputExecute, Epilog -> FromRakuCode];
SetOptions[Dataset, MaxItems -> {Automatic, 40}];
```

### Load Raku packages

```perl6
use Data::Generators;
use Data::Reshapers;
use Data::Summarizers;
use Stats;
use Mathematica::Serializer;

use Statistics::OutlierIdentifiers; 
```

## Reference

### Articles, books

[AA1] Anton Antonov, ["Outlier detection in a list of numbers"](https://mathematicaforprediction.wordpress.com/2013/10/16/outlier-detection-in-a-list-of-numbers/), (2013), [MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov, ["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/), (2021), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov, ["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/), (2021), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[RKP1] Ronald K. Pearson, Mining Imperfect Data: Dealing with Contamination and Incomplete Records, 2005, SIAM. (Volume 93 of Other titles in applied mathematics.). ISBN 0898715822, 9780898715828.

[WP1] Wenzel P.P. Peppmeyer, ["Writing it down"](https://gfldex.wordpress.com/2022/05/21/writing-it-down/), (2022), [Playing Perl6 esc b6xA Raku at WordPress](https://gfldex.wordpress.com). 

### Packages

[AAp1] Anton Antonov, [Statistics::OutlierIdentifiers Raku package](https://github.com/antononcube/Raku-Statistics-OutlierIdentifiers), (2022), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, ["Implementation of one dimensional outlier identifying algorithms in Mathematica"](https://github.com/antononcube/MathematicaForPrediction/blob/master/OutlierIdentifiers.m), (2013), [MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp3] Anton Antonov, ["OutlierIdentifiers" R-package](https://github.com/antononcube/R-packages/tree/master/OutlierIdentifiers), (2019), [R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

### Videos

[AAv1] Anton Antonov, ["Anomalies, Breaks, and Outlier Detection in Time Series (in WL)"](https://www.youtube.com/watch?v=h_fLb6YU87c), (2020), [Wolfram Research Inc, at YouTube](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

[AAv2] Anton Antonov, ["Anomalies, Breaks, and Outlier Detection in Time Series (in R)"](https://www.youtube.com/watch?v=KL0sCSrWEkM), (2021), [A.Antonov channel at YouTube](https://www.youtube.com/channel/UC5qMPIsJeztfARXWdIw3Xzw).

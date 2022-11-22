# Interactive Mermaid diagrams generation via Markdown evaluation

## Introduction 

In this document (and related presentation) we discuss the interactive making of
[Mermaid-JS](https://mermaid-js.github.io/mermaid/) diagrams
via evaluation of code cells in Markdown documents.

The "interactive" changes are possible because of the following package updates:

- Markdown cells processed by ["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing), [AAp1],
  can have an argument that specifies the language of the output cells.
  - E.g. `output-lang=mermaid`.

- ["UML::Translators"](https://raku.land/zef:antononcube/UML::Translators), [AAp2], can generate
  Mermaid-JS specs.
  - (In addition to [PlantUML](https://plantuml.com) and WL specs.)

Further, the "interactivity" relies on the automatic re-rendering of the used
Integrate Development Environments (IDEs), like, 
[IntelliJ IDEA](https://www.jetbrains.com/idea/), 
[Commaide](https://commaide.com), or 
Visual Studio Code.

**Remark:** The preparation of this document and in the presentation, we use Command Line Interface (CLI) script
`file-code-chunks-eval` provided by
["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing).

**Remark:** ["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing)
also provides the script `cronify` that facilitates periodic execution of a shell command (with parameters.)
It heavily borrows ideas and code from the chapter "Silent Cron, a Cron Wrapper" of the book,
"Raku Fundamentals" by Moritz Lenz, [ML1]. 

**Remark:** After some experimentation the script `cronify` was *not* found to
be that useful for the "interactive" effect.  

-------

## Presentation plan

Here is a flowchart of the presentation:

```mermaid
graph TD
    CMD[Make new Markdown file]
    MDw>"Markdown document - work"]
    MDd>"Markdown document - display"]
    RC[/"Raku code"/]
    MJSC[/"Mermaid-JS code"/]
    RO[/"Raku output"/]
    EMD[Evaluate Markdown file]
    TCP("Text::CodeProcessing")
    FCCE[[file-code-chunks-eval]]
    CMD -.-> |create|MDw
    CMD ---> RC ---> EMD ---> MJSC
    EMD ---> RO
    MJSC ---> RC
    RO ---> RC
    MDw -.-> EMD
    EMD -.-> |create/update|MDd
    MDw -.- MDd
    EMD -..- |repeatedly|FCCE
    FCCE -.- TCP
    subgraph Documents
        MDw
        MDd
    end
    subgraph Steps
        CMD
        RC
        EMD
        MJSC
        RO
    end    
```

-------

## UML diagram

Here we load the package 
["UML::Translators"](https://raku.land/zef:antononcube/UML::Translators), [AAp2],
and derive the Mermaid-JS spec for "ML::Clustering":

```perl6
use UML::Translators;
to-uml-spec('ML::Clustering', format => 'mermaid')
```
```
# classDiagram
# class ML_Clustering_KMeans {
#   +BUILDALL()
#   +args-check()
#   +bray-curtis-distance()
#   +canberra-distance()
#   +chessboard-distance()
#   +cosine-distance()
#   +distance()
#   +euclidean-distance()
#   +find-clusters()
#   +hamming-distance()
#   +manhattan-distance()
#   +norm()
#   +squared-euclidean-distance()
# }
# ML_Clustering_KMeans --|> ML_Clustering_DistanceFunctions
# 
# 
# class ML_Clustering_DistanceFunctions {
#   <<role>>
#   +args-check()
#   +bray-curtis-distance()
#   +canberra-distance()
#   +chessboard-distance()
#   +cosine-distance()
#   +distance()
#   +euclidean-distance()
#   +manhattan-distance()
#   +squared-euclidean-distance()
# }
# 
# 
# class k_means {
#   <<routine>>
# }
# k_means --|> Routine
# k_means --|> Block
# k_means --|> Code
# k_means --|> Callable
# 
# 
# class find_clusters {
#   <<routine>>
# }
# find_clusters --|> Routine
# find_clusters --|> Block
# find_clusters --|> Code
# find_clusters --|> Callable
```

Here we create **directly** a Mermaid cell into the Markdown file:

```perl6, outputLang=mermaid, outputPrompt=NONE
use UML::Translators;
to-uml-spec('ML::Clustering', format => 'mermaid')
```
```mermaid
classDiagram
class ML_Clustering_KMeans {
  +BUILDALL()
  +args-check()
  +bray-curtis-distance()
  +canberra-distance()
  +chessboard-distance()
  +cosine-distance()
  +distance()
  +euclidean-distance()
  +find-clusters()
  +hamming-distance()
  +manhattan-distance()
  +norm()
  +squared-euclidean-distance()
}
ML_Clustering_KMeans --|> ML_Clustering_DistanceFunctions


class ML_Clustering_DistanceFunctions {
  <<role>>
  +args-check()
  +bray-curtis-distance()
  +canberra-distance()
  +chessboard-distance()
  +cosine-distance()
  +distance()
  +euclidean-distance()
  +manhattan-distance()
  +squared-euclidean-distance()
}


class k_means {
  <<routine>>
}
k_means --|> Routine
k_means --|> Block
k_means --|> Code
k_means --|> Callable


class find_clusters {
  <<routine>>
}
find_clusters --|> Routine
find_clusters --|> Block
find_clusters --|> Code
find_clusters --|> Callable
```

**Remark:** We use above the Markdown cell arguments `perl6, outputLang=mermaid, outputPrompt=NONE`. 

------

## Pie chart

Here we generate a dataset with random numerical columns

```perl6
use Data::Generators;
use Data::Reshapers;
my @tbl = random-tabular-dataset(12, 3, 
        column-names-generator => { &random-pet-name($_, method => &pick) },
        generators => [
            { random-variate(NormalDistribution.new( µ => 10, σ => 20), $_ ) },
            { random-variate(NormalDistribution.new( µ => 2, σ => 2), $_ ) },
            { random-variate(NormalDistribution.new( µ => 32, σ => 10), $_ ) }]);
say to-pretty-table(@tbl);
```
```
# +-----------+-----------+------------+
# |  Schmidt  | Loch Ness |  Atticus   |
# +-----------+-----------+------------+
# | -1.640302 | 28.378750 | 15.904661  |
# |  2.385714 | 38.302540 | 24.213946  |
# |  0.493925 | 38.725973 | 40.612606  |
# |  4.505899 | 30.662067 | 18.584966  |
# |  0.434399 | 16.541336 | 16.912362  |
# |  3.721586 | 44.420603 | 33.003731  |
# |  2.167267 | 34.555019 |  9.839326  |
# |  0.816624 | 25.008163 | -36.824675 |
# |  0.473044 | 32.095658 | 38.149468  |
# |  3.436236 | 23.021088 | 24.750144  |
# |  5.754028 | 38.892485 | 20.964051  |
# | -0.590391 | 23.630289 | -8.537537  |
# +-----------+-----------+------------+
```

Here sum the columns:

```perl6
@tbl.&transpose.map({ $_.key => [+] $_.value })
```
```
# (Loch Ness => 374.233971547851 Schmidt => 21.95802958385876 Atticus => 197.57304922350048)
```

Plot the sums with a Mermaid pie chart:

```perl6, outputLang=mermaid, outputPrompt=NONE
say 'pie showData';
say ' title My Great Pie Chart!';
@tbl.&transpose.map({ $_.key => [+] $_.value }).map({ say " {$_.key.raku} : {$_.value}" })
```
```mermaid
pie showData
 title My Great Pie Chart!
 "Loch Ness" : 374.233971547851
 "Schmidt" : 21.95802958385876
 "Atticus" : 197.57304922350048
```

------

## Make trie 

Here we make a prefix tree (trie):

```perl6
use ML::TriesWithFrequencies;
my $tr = trie-create-by-split( <bar bark bars balm cert cell> );
trie-say($tr);
```
```
# TRIEROOT => 6
# ├─b => 4
# │ └─a => 4
# │   ├─l => 1
# │   │ └─m => 1
# │   └─r => 3
# │     ├─k => 1
# │     └─s => 1
# └─c => 2
#   └─e => 2
#     ├─l => 1
#     │ └─l => 1
#     └─r => 1
#       └─t => 1
```

Here we just get nodes:

```perl6, outputPrompt=NONE
say 'mindmap';
say $tr.form.subst( / '├' | '─' | '└' | '│' | '└' /, ' '):g
```
```
mindmap
TRIEROOT => 6
  b => 4
    a => 4
      l => 1
        m => 1
      r => 3
        k => 1
        s => 1
  c => 2
    e => 2
      l => 1
        l => 1
      r => 1
        t => 1
```

Here we plot it with Mermaid-JS as a **mindmap** (requires version 9.2.2+):

```perl6, outputLang=mermaid, outputPrompt=NONE, eval=FALSE
say 'mindmap';
say $tr.form.subst( / '├' | '─' | '└' | '│' | '└' /, ' '):g;
```

Here we transform the trie into list of edges:

```perl6
my @edges = $tr.node-probabilities.root-to-leaf-paths>>.map({ "{$_.key}:{$_.value.Str}" }).map({ $_.rotor(2 => -1).map({ "{$_[0]} --> {$_[1]}" }) }).&flatten;
.say for @edges.unique; 
```
```
# TRIEROOT:1 --> b:0.6666666666666666
# b:0.6666666666666666 --> a:1
# a:1 --> r:0.75
# r:0.75 --> s:0.3333333333333333
# r:0.75 --> k:0.3333333333333333
# a:1 --> l:0.25
# l:0.25 --> m:1
# TRIEROOT:1 --> c:0.3333333333333333
# c:0.3333333333333333 --> e:1
# e:1 --> l:0.5
# l:0.5 --> l:1
# e:1 --> r:0.5
# r:0.5 --> t:1
```

Here we plot it with Mermaid-JS as a **graph**:

```perl6, outputLang=mermaid, outputPrompt=NONE
say 'graph TD';
.say for @edges.unique; 
```
```mermaid
graph TD
TRIEROOT:1 --> b:0.6666666666666666
b:0.6666666666666666 --> a:1
a:1 --> r:0.75
r:0.75 --> s:0.3333333333333333
r:0.75 --> k:0.3333333333333333
a:1 --> l:0.25
l:0.25 --> m:1
TRIEROOT:1 --> c:0.3333333333333333
c:0.3333333333333333 --> e:1
e:1 --> l:0.5
l:0.5 --> l:1
e:1 --> r:0.5
r:0.5 --> t:1
```

------

## References

### Articles

[AA1] Anton Antonov
["Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com/2022/11/05/conversion-and-evaluation-of-raku-files/).

[AA2] Anton Antonov
["Conversion and evaluation of Raku files"](https://rakuforprediction.wordpress.com/2022/11/05/conversion-and-evaluation-of-raku-files/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com/2022/11/05/conversion-and-evaluation-of-raku-files/).

[AA3] Anton Antonov,
["Generating UML diagrams for Raku namespaces](https://rakuforprediction.wordpress.com/2022/06/12/generating-uml-diagrams-for-raku-namespaces/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com/2022/11/05/conversion-and-evaluation-of-raku-files/).

### Books

[ML1] Moritz Lenz,
["Raku Fundamentals: A Primer with Examples, Projects, and Case Studies"](https://www.google.com/books/edition/Raku_Fundamentals/MvyRzQEACAAJ?hl=en),
2nd ed.
(2020),
Apress.

### Packages

[AAp1] Anton Antonov,
[Text::CodeProcessing Raku package](https://raku.land/zef:antononcube/Text::CodeProcessing),
(2021-2022),
[Zef ecosystem](https://raku.land/zef:antononcube).

[AAp2] Anton Antonov,
[UML::Translators Raku package](https://raku.land/zef:antononcube/UML::Translators),
(2021-2022),
[Zef ecosystem](https://raku.land/zef:antononcube).

### Videos

[AAv1] Anton Antonov
["Conversion and evaluation of Raku files"](https://www.youtube.com/watch?v=GJO7YqjGn6o),
(2022),
[Anton Antonov's channel at YouTube](https://www.youtube.com/@AAA4prediction).
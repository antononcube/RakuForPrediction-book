# Implementing Machine Learning algorithms in Raku

## Abstract

In this presentation we discuss the implementations of different Machine Learning (ML) algorithms in Raku.

The main themes of the presentation are:
- ML workflows demonstration
- Software engineering perspective on ML implementations
- ML algorithms utilization with Raku's unique features

Here is a mind-map of the presentation plan:

![](https://github.com/antononcube/RakuForPrediction-book/raw/main/Presentations/TRC-2022/org/TRC-2022-presentation-mind-map.png)

Here is a list of the considered ML algorithms:

- Fundamental data analysis
  - Outlier identifiers (["ML::OutlierIdentifiers"](https://raku.land/zef:antononcube/ML::OutlierIdentifiers))
  - Cross tabulation (["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers))
  - Summarization (["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers))
  - Pareto principle adherence
- Supervised learning
  - Classifiers
  - Receiver Operating Characteristics (ROCs) (["ML::ROCFunctions"](https://raku.land/zef:antononcube/ML::ROCFunctions))
- Unsupervised learning
  - Clustering (["ML::Clustering"](https://raku.land/zef:antononcube/ML::Clustering))
    - Distance functions
  - Tries with frequencies (["ML::TriesWithFrequencies"](https://raku.land/zef:antononcube/ML::TriesWithFrequencies))
  - Streams Blending Recommender (SBR) (["ML::StreamsBlendingRecommender"](https://raku.land/zef:antononcube/ML::StreamsBlendingRecommender))
  - Association Rule Learning (ARL) (["ML::AssociationRuleLearning"](https://raku.land/zef:antononcube/ML::AssociationRuleLearning))
  - Regression
  - Latent Semantic Analysis (LSA)

Here is a corresponding mind-map:

![](https://github.com/antononcube/RakuForPrediction-book/raw/main/Presentations/TRC-2022/org/Implementing-ML-algorithms-in-Raku-mind-map.png)

The documents
["Trie based classifiers evaluation"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/Trie-based-classifiers-evaluation.md),
[AA2], and
["Fast and compact classifier of DSL commands"](https://rakuforprediction.wordpress.com/2022/07/31/fast-and-compact-classifier-of-dsl-commands/),
[AA3],
provide example applications of the Raku packages mentioned above.

-------

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Trie based classifiers evaluation"](https://rakuforprediction.wordpress.com/2022/07/07/trie-based-classifiers-evaluation/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["Fast and compact classifier of DSL commands"](https://rakuforprediction.wordpress.com/2022/07/31/fast-and-compact-classifier-of-dsl-commands/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).


### Packages

#### Data wrangling

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

#### Domain Specific Languages

[AAp5] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[DSL::Shared Raku package](https://github.com/antononcube/Raku-DSL-Shared),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[DSL::Shared::Utilities::ComprehensiveTranslation Raku package](https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

#### Lingua

[AAp8] Anton Antonov,
[Lingua::Stem::Bulgarian Raku package](https://github.com/antononcube/Raku-Lingua-Stem-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp9] Anton Antonov,
[Lingua::StopwordsISO Raku package](https://github.com/antononcube/Raku-Lingua-StopwordsISO),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

#### Supervised Machine Learning

[AAp10] Anton Antonov,
[ML::ROCFunctions Raku package](https://github.com/antononcube/Raku-ML-ROCFunctions),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

#### Unsupervised Machine Learning

[AAp11] Anton Antonov,
[ML::AssociationRuleLearning Raku package](https://github.com/antononcube/Raku-ML-AssociationRuleLearning),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp12] Anton Antonov,
[ML::Clustering Raku package](https://github.com/antononcube/Raku-ML-Clustering),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp13] Anton Antonov,
[ML::StreamsBlendingRecommender Raku package](https://github.com/antononcube/Raku-ML-StreamsBlendingRecommender),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp14] Anton Antonov,
[ML::TriesWithFrequencies Raku package](https://github.com/antononcube/Raku-ML-TriesWithFrequencies),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

#### Other

[AAp15] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp16] Anton Antonov,
[UML::Translators Raku package](https://github.com/antononcube/Raku-UML-Translators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).
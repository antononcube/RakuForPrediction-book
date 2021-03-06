# Implementing Machine Learning algorithms in Raku

## Abstract

In this presentation we discuss the implementations of different Machine Learning (ML) algorithms in Raku.

The main themes of the presentation are:
- ML workflows demonstration
- Software engineering perspective on ML implementations
- ML algorithms utilization with Raku's unique features

Here is a list of the considered ML algorithms:

- Fundamental data analysis
  - Outlier identifiers ("ML::OutlierIdentifiers")
  - Cross tabulation ("Data::Reshapers")
  - Summarization ("Data::Summarizers")
  - Pareto principle adherence
- Supervised learning
  - Classifiers
  - Receiver Operating Characteristics (ROCs) ("ML::ROCFunctions")
- Unsupervised learning
  - Clustering
  - Tries with frequencies ("ML::TriesWithFrequencies")
  - Streams Blending Recommender (SBR) ("ML::StreamsBlendingRecommender")
  - Association Rule Learning (ARL) ("ML::AssociationRuleLearning")
  - Regression
  - Latent Semantic Analysis (LSA)

Here is a corresponding mind-map:

![](https://github.com/antononcube/RakuForPrediction-book/raw/main/Presentations/TRC-2022/org/Implementing-ML-algorithms-in-Raku-mind-map.png)

The document
["Trie based classifiers evaluation"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/Trie-based-classifiers-evaluation.md)
describes an example application of the Raku packages mentioned above.
-------

## References

*TBD...*

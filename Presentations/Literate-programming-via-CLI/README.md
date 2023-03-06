# Literate programming via CLI

In this presentation we demonstrate how to do 
["Literate programming"](https://en.wikipedia.org/wiki/Literate_programming)
in Raku via the command line.

**Anton Antonov   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
March 2023**

-------

## Steps and components

```mermaid
flowchart TD
    WD["Write document in Markdown<br/>(with Raku code)"]
    MDtoMDW[Convert to woven Markdown]
    MDWtoHTML[Convert to HTML]
    E["Examine<br/>code chunks results<br/>and<br/>D3.js graphics"]
    JSQ{Has<br/>D3.js?}
    TCP[["Text::CodeProcessing"]]
    MG[["Markdown::Grammar"]]
    DJS[["Java Script::D3"]]
    WD --> MDtoMDW
    MDtoMDW --> JSQ 
    JSQ --> |yes|MDWtoHTML
    JSQ --> |no|E
    MDWtoHTML --> E --> WD
    WD -.- |maybe|DJS
    MDtoMDW -.- TCP
    MDWtoHTML -.- MG
```

Here is a narration of the diagram above:

1. Write some text and code in a Markdown file

    - Program visualizations with ["JavaScript::D3"](https://raku.land/zef:antononcube/JavaScript::D3), [AAp2] 

2. Weave the Markdown file (i.e. "run it")
    
    - Using ["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing), [AAp3]

3. If the woven file the does not have D3.js graphics go to 5

4. Convert the woven Markdown file into HTML

    -  Using ["Markdown::Grammar"](https://raku.land/zef:antononcube/Markdown::Grammar), [AAp4]

5. Examine results

6. Go to 1 
    
    - Or finish "fiddling with it"

-------

## The conversions

The we use the document
["Cryptocurrencies-explorations.md"](./Documents/Cryptocurrencies-explorations.md)
(with Raku code over cryptocurrencies data.)

Here is the shell command:

```
file-code-chunks-eval Cryptocurrencies-explorations.md && 
  from-markdown Cryptocurrencies-explorations_woven.md -t html -o out.html && 
  open out.html
```

**Remark:** It is instructive to examine 
["Cryptocurrencies-explorations_woven.md"](./Documents/Cryptocurrencies-explorations_woven.md)
and compare it with
["Cryptocurrencies-explorations.md"](./Documents/Cryptocurrencies-explorations.md).

**Remark** The code chunks with graphics (using "JavaScript::D3") have to have the chunk option setting `results=asis`. 

**Remark** The "JavaScript::D3" commands have to have the option settings `format => 'html'` and `div-id => ...`. 

-------

## References

### Articles

[AA1] Anton Antonov
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov
["JavaScript::D3"](https://rakuforprediction.wordpress.com/2022/12/15/javascriptd3/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov
["Further work on the Raku-D3.js translation"](https://rakuforprediction.wordpress.com/2022/12/22/further-work-on-the-raku-to-d3-js-translation/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).
 
### Packages

[AAp1] Anton Antonov,
[Data::Cryptocurrencies Raku package](https://github.com/antononcube/Raku-Data-Cryptocurrencies),
(2023).
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[JavaScript::D3 Raku package](https://github.com/antononcube/Raku-JavaScript-D3),
(2022).
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021).
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Markdown::Grammar](https://github.com/antononcube/Raku-Markdown-Grammar),
(2022).
[GitHub/antononcube](https://github.com/antononcube).




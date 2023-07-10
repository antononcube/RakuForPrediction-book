# Generating documents via templates and LLMs

Anton Antonov   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
July 2023


## Introduction

We can use computation Markdown documents, [AA1, AAv1], as templates for generating "fully fledged"
documents using Large Language Model (LLMs), [AA2, Wk1].
 
The document execution can be done that via the Command Line Interface (CLI) of the package 
["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing), [AAp1], 
that has "code chunk" plug-ins for accessing the LLMs ChatGPT (OpenAI), [AAp2], and
[PaLM](https://developers.generativeai.google), [AAp3].

See the references for more details of the underlying mechanics. (Written in Raku, [AA1, AA2, AAp1÷AAp3].)

Here is a Markdown template:
["Simple guide via LLM template"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/Simple-guide-via-LLM-template.md), [AA3].

Here is a document obtained with that template:
["12 steps guide to quit Python"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/LLM-generated/12-steps-guide-to-quit-Python-via-PaLM.md), [AA4].


Here is a flowchart that summarizes the execution steps:

```mermaid
graph LR
   OpenAI{{OpenAI}}
   PaLM{{PaLM}}
   TCP[[Text::CodeProcessing]]
   WWWOpenAI[[WWW::OpenAI]] 
   WWWPaLM[[WWW::PaLM]]
   MDT[/Markdown<br>document<br>template/]
   MDR[/Markdown<br>document<br>result/]
   Gen12[Generate a list<br>via LLM]
   GenExps[Generate expansion<br>for each list item<br>via LLM]
   TCP -.-> WWWOpenAI <-.-> OpenAI
   TCP -.-> WWWPaLM <-.-> PaLM
   MDT --> Gen12 --> GenExps --> MDR
   MDT -.-> |CLI input|TCP
   TCP -.- |CLI output|MDR
   subgraph Evaluation
     Gen12
     GenExps
   end
   Evaluation -.- |Code chunk evaluation|TCP
```

----------

## Code cell examples

In this section we show with explanations the code cells of the template
["Simple guide via LLM template"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/Simple-guide-via-LLM-template.md), [AA3].

### LLM cells

Here is an example of an LLM access cell using ["WWW::OpenAI"](https://raku.land/zef:antononcube/WWW::OpenAI), [AAp2]:

````
```openai, format=values, temperature=1.4, max-tokens=800, results=asis, output-prompt=NONE, echo=FALSE
Generate a 12 steps outline for quiting addiction to programmaring Python (and replacing with Raku.)
```
````

Note that:

- All named parameters of `openai-completion` can be used as code chunk parameters.
- The code chunk specs `results=asis, output-prompt=NONE` make the output to be "seamlessly" included in the result document.
- The spec `echo=FALSE` "removes" the code chunk from the result document.


### Raku cells with LLM access 

Here is an example of Raku cell with a "LLM generation script" that expands
each of the items from the list obtained above.

````
```perl6, results=asis, output-prompt=NONE, echo=FALSE
my $txt = _.trim;
my $txtExpanded = do for $txt.split(/ ^^ \d+ /, :v, :skip-empty)>>.Str.rotor(2) -> $p {
    my $res = "-" x 120; 
    $res ~= "\n## {$p[0]}.";
    my $start = '';
    if $p[1] ~~ / '**' (.*?) '**'/ {
        $start = $0.Str;
        $res ~= ' ' ~ $start.subst( / <punct>+ $$/, '');
    };
    $res ~= "\n\n>... {$p[1].subst(/'**' $start '**'/, '').subst( / ^^ <punct>+ /, '')}"; 
    $res ~= "\n\n", openai-completion( "Expand upon: {$p[1]}", temperature => 1.45, max-tokens => 400, format=>'values' );
    #$res ~= "\n\n", palm-generate-text( "Expand upon: {$p[1]}", temperature => 0.75, max-tokens => 400, format=>'values' );
}

$txtExpanded.join("\n\n") 
```
````

Note that:
- With `_` we can access the last evaluated result "Text::CodeProcessing", [AAp1].
- Again the results are placed in the result notebook "as is."

The script relies on the assumptions that:
- List items are numbered (because of the formulation of the LLM request.)
- Very likely list items have a opening phrase in Markdown bold font spec.


------

## Variations

### Other templates 

Obviously, Markdown templates with other structures and interactions between the LLM cells and Raku cells.

For example, we can have a sequence of LLM cells that shape or direct the result document
in a certain way.  

### Multiple documents

Multiple documents can be obtained using:

- Different LLMs 
- Different LLM parameter values
- Same LLM parameter values, but with high LLM "temperature."

------

## References

### Articles

[AA1] Anton Antonov,
["Conversion and evaluation of Raku files"](https://rakuforprediction.wordpress.com/2022/11/05/conversion-and-evaluation-of-raku-files/),
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Racoons playing with pearls and onions"](https://rakuforprediction.wordpress.com/2023/03/12/racoons-playing-with-pearls-and-onions/),
(2023),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AAp3] Anton Antonov,
["Simple guide via LLM template"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/Simple-guide-via-LLM-template.md),
(2023),
[RakuForPrediction-book at GitHub/antononcube](https://github.com/antononcube/RakuForPrediction-book).

[AAp4] Anton Antonov,
["12 steps guide to quit Python"](https://github.com/antononcube/RakuForPrediction-book/blob/main/Articles/LLM-generated/12-steps-guide-to-quit-Python-via-PaLM.md),
(2023),
[RakuForPrediction-book at GitHub/antononcube](https://github.com/antononcube/RakuForPrediction-book).

[Wk1] Wikipedia entry, ["Large language model"](https://en.wikipedia.org/wiki/Large_language_model).


### Packages, repositories

[AAp1] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021-2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[WWW::PaLM Raku package](https://github.com/antononcube/Raku-WWW-PaLM),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

## Videos

[AAv1] Anton Antonov,
["Conversion and evaluation of Raku files"](https://www.youtube.com/watch?v=GJO7YqjGn6o),
(2022),
[YouTube/@AAA4Prediction](https://www.youtube.com/@AAA4prediction).

[AAv2] Anton Antonov,
["Racoons playing with pearls and onions"](https://www.youtube.com/watch?v=zlkoNZK8MpU),
(2023),
[YouTube/@AAA4Prediction](https://www.youtube.com/@AAA4prediction).

# TLDR LLM solutions for software manuals 
### ... aka ***"How to use software manuals effectively without reading them"*** 

#### Anton Antonov   
#### RakuForPrediction at WordPress   
#### RakuForPrediction-book at GitHub
#### August 2023

------

## Introduction

In this [Jupyter notebook](https://github.com/antononcube/RakuForPrediction-book/blob/main/Notebooks/Jupyter/TLDR-LLM-solutions-for-software-manuals.ipynb) we use [Large Language Model (LLM) functions](https://rakuforprediction.wordpress.com/2023/08/01/workflows-with-llm-functions/), [AAp1, AA1], for generating (hopefully) executable, correct, and harmless code for Operating System resources managements.

In order to be concrete and useful, we take the Markdown files of the articles ["It's time to rak!"](https://dev.to/lizmat/series/20329), [EM1], that explain the motivation and usage of the Raku module ["App::Rak"](https://raku.land/zef:lizmat/App::Rak), [EMp1], and we show how meaningful, file finding shell commands can be generated via LLMs exposed to the code-with-comments from those articles.

In other words, we prefer to apply the attitude Too Long; Didn't Read (TLDR) to the articles and related Raku module 
[README](https://github.com/lizmat/App-Rak/blob/main/README.md) (or user guide) file.
(Because "App::Rak" is useful, but it has too many parameters that we prefer not to learn that much about.)  

**Remark:** We say that "App::Rak" uses a Domain Specific Language (DSL), which is done with Raku's Command Line Interface (CLI) features.

### Procedure outline

1. Clone the corresponding [article repository](https://github.com/lizmat/articles)
2. Locate and ingest the "App::Rak" dedicated Markdown files
3. Extract code blocks from the Markdown files
   - Using ["Markdown::Grammar"](https://raku.land/zef:antononcube/Markdown::Grammar) functions
4. Get comment-and-code line pairs from the code blocks
   - Using Raku text manipulation capabilities
      - (After observing code examples) 
5. Generate from the comment-and-code pairs LLM few-shot training rules
6. Use the LLM example function to translate natural language commands into (valid and relevant) "App::Rak" DSL commands
   - With a few or a dozen natural language commands 
7. Use LLMs to generate natural language commands in order to test LLM-TLDR-er further 

Step 6 says how we do our TLDR -- we use LLM-translations of natural language commands.

### Alternative procedure

Instead of using Raku to process text we can make LLM functions for extracting the comment-and-code pairs.
(That is also shown below.)    

### Extensions

1. Using LLMs to generate:
    - Stress tests for "App::Rak"
    - Variants of the gathered commands
        - And make new training rules with them
    - EBNF grammars for gathered commands
2. Compare OpenAI and PaLM and or their different models 
    - Which one produces best results?
    - Which ones produce better result for which subsets of commands?

### Article's structure

The exposition below follows the outlines of procedure subsections above. 

The stress-testing extensions and EBNF generation extension have thier own sections: "Translating randomly generated commands" and "Grammar generation" respectively. 

**Remark:** The article/document/notebook was made with the Jupyter framework, using the Raku package ["Jupyter::Kernel"](https://raku.land/cpan:BDUGGAN/Jupyter::Kernel), [BD1].  

--------

## Setup


```raku
use Markdown::Grammar;
use Data::Reshapers;
use Data::Summarizers;
use LLM::Functions;
use Text::SubParsers;
```

------

## Workflow

### File names


```raku
my $dirName = $*HOME ~ '/GitHub/lizmat/articles';
my @fileNames = dir($dirName).grep(*.Str.contains('time-to-rak'));
@fileNames.elems
```




    4



### Texts ingestion

Here we ingest the text of each file:


```raku
my %texts = @fileNames.map({ $_.basename => slurp($_) });
%texts.elems
```




    4



Here are the number of characters per document:


```raku
%texts>>.chars
```




    {its-time-to-rak-1.md => 7437, its-time-to-rak-2.md => 8725, its-time-to-rak-3.md => 14181, its-time-to-rak-4.md => 9290}



Here are the number of words per document:


```raku
%texts>>.words>>.elems
```




    {its-time-to-rak-1.md => 1205, its-time-to-rak-2.md => 1477, its-time-to-rak-3.md => 2312, its-time-to-rak-4.md => 1553}



### Get Markdown code blocks

With the function `md-section-tree` we extract code blocks from Markdown documentation files into data structures amenable for further programmatic manipulation (in Raku.)
Here we get code blocks from each text:


```raku
my %docTrees = %texts.map({ $_.key => md-section-tree($_.value, modifier => 'Code', max-level => 0) });
%docTrees>>.elems
```




    {its-time-to-rak-1.md => 1, its-time-to-rak-2.md => 11, its-time-to-rak-3.md => 24, its-time-to-rak-4.md => 16}



Here we put all blocks into one array:


```raku
my @blocks = %docTrees.values.Array.&flatten;
@blocks.elems
```




    52



### Extract command-and-code line pairs

Here from each code block we parse-extract comment-and-code pairs and we form the LLM training rules:


```raku
my @rules;
@blocks.map({ 
    given $_ { 
        for m:g/ '#' $<comment>=(\V+) \n '$' $<code>=(\V+) \n / -> $m {
           @rules.push( ($m<comment>.Str.trim => $m<code>.Str.trim) ) 
         } } }).elems
```




    52



Here is the number of rules:


```raku
@rules.elems
```




    69



Here is a sample of the rules:


```raku
.say for @rules.pick(4)
```

    save --after-context as -A, requiring a value => rak --after-context=! --save=A
    Show all directory names from current directory down => rak --find --/file
    Reverse the order of the characters of each line => rak '*.flip' twenty
    Show number of files / lines authored by Scooby Doo => rak --blame-per-line '*.author eq "Scooby Doo"' --count-only


### Nice tabulation with LLM function

In order to tabulate "nicely" the rules in the Jupyter notebook, we make an LLM functions to produce an HTML table and then specify the corresponding "magic cell." 
(This relies on the Jupyter-magics features of [BDp1].) Here is an LLM conversion function, [AA1]:


```raku
my &ftbl = llm-function({"Convert the $^a table $^b into an HTML table."}, e=>llm-configuration('PaL<', max-tokens=>800))
```




    -> **@args, *%args { #`(Block|5361560043184) ... }



Here is the HTML table derivation:


```raku
%%html
my $tblHTML=&ftbl("plain text", to-pretty-table(@rules.pick(12).sort, align => 'l', field-names => <Key Value>))
```






<table>
  <tr>
    <th>Key</th>
    <th>Value</th>
  </tr>
  <tr>
    <td>Produce the frequencies of the letters in file "twenty"</td>
    <td>rak 'slip .comb' twenty --type=code --frequencies</td>
  </tr>
  <tr>
    <td>Search all files and all subdirectories</td>
    <td>rak foo *</td>
  </tr>
  <tr>
    <td>Search for literal string "foo" from the current directory</td>
    <td>rak foo</td>
  </tr>
  <tr>
    <td>Show all filenames from current directory on down</td>
    <td>rak --find --treasure</td>
  </tr>
  <tr>
    <td>Show all the lines that consist of "seven"</td>
    <td>rak ^seven$ twenty</td>
  </tr>
  <tr>
    <td>Show all unique "name" fields in JSON files</td>
    <td>rak --json-per-file '*<name>' --unique</td>
  </tr>
  <tr>
    <td>Show the lines ending with "o"</td>
    <td>rak o$ twenty</td>
  </tr>
  <tr>
    <td>add / change description -i at a later time</td>
    <td>rak --description='Do not care about case' --save=i</td>
  </tr>
  <tr>
    <td>look for literal string "foo", don't check case or accents</td>
    <td>rak foo -im</td>
  </tr>
  <tr>
    <td>remove the --frobnicate custom option</td>
    <td>rak --save=frobnicate</td>
  </tr>
  <tr>
    <td>same, with a regular expression</td>
    <td>rak '/ foo $/'</td>
  </tr>
  <tr>
    <td>save --ignorecase as -i, without description</td>
    <td>rak --ignorecase --save=i</td>
  </tr>
</table>



### Nice tabulation with "Markdown::Grammar"

Instead of using LLMs for HTML conversion it is more "productive" to use the HTML interpreter provided by "Markdown::Grammar":


```raku
%%html
sub to-html($x) { md-interpret($x.Str.lines[1..*-2].join("\n").subst('+--','|--', :g).subst('--+','--|', :g), actions=>Markdown::Actions::HTML.new) }
to-pretty-table(@rules.pick(12).sort) ==> to-html
```




<table>
<tr>
<th>Key</th>
<th>Value</th>
</tr>
<tr>
<td>Find files that have "lib" in their name from the current dir</td>
<td>rak lib --find</td>
</tr>
<tr>
<td>Look for strings containing y or Y</td>
<td>rak --type=contains --ignorecase Y twenty</td>
</tr>
<tr>
<td>Show all directory names from current directory down</td>
<td>rak --find --/file</td>
</tr>
<tr>
<td>Show all lines with numbers between 1 and 65</td>
<td>rak '/ \d+ <?{ 1 <= $/.Int <= 65 }> /'</td>
</tr>
<tr>
<td>Show the lines that contain "six" as a word</td>
<td>rak §six twenty</td>
</tr>
<tr>
<td>look for "Foo", while taking case into account</td>
<td>rak Foo</td>
</tr>
<tr>
<td>look for "foo" in all files</td>
<td>rak foo</td>
</tr>
<tr>
<td>produce extensive help on filesystem filters</td>
<td>rak --help=filesystem --pager=less</td>
</tr>
<tr>
<td>save --context as -C, setting a default of 2</td>
<td>rak --context='[2]' --save=C</td>
</tr>
<tr>
<td>save searching in Rakudo's committed files as --rakudo</td>
<td>rak --paths='~/Github/rakudo' --under-version-control --save=rakudo</td>
</tr>
<tr>
<td>search for "foo" and show 4 lines of context</td>
<td>rak foo -C=4</td>
</tr>
<tr>
<td>start rak with configuration file at /usr/local/rak-config.json</td>
<td>RAK_CONFIG=/usr/local/rak-config.json rak foo</td>
</tr>
</table>



**Remark:** Of course, in order to program the above sub we need *to know* how to use "Markdown::Grammar". Producing HTML tables with LLMs is much easier -- only knowledge of "spoken English" is required.   

### Code generation examples

Here we define an LLM function for generating "App::Rak" shell commands:


```raku
my &frak = llm-example-function(@rules, e => llm-evaluator('PaLM'))
```




    -> **@args, *%args { #`(Block|5361473489952) ... }




```raku
my @cmds = ['Find files that have ".nb" in their names', 'Find files that have ".nb"  or ".wl" in their names',
 'Show all directories of the parent directory', 'Give me files without extensions and that contain the phrase "notebook"', 
 'Show all that have extension raku or rakumod and contain Data::Reshapers'];

my @tbl = @cmds.map({ %( 'Command' => $_, 'App::Rak' => &frak($_) ) }).Array;

@tbl.&dimensions
```




    (5 2)



Here is a table showing the natural language commands and the corresponding translations to the "App::Rak" CLI DSL:


```raku
%%html
to-pretty-table(@tbl, align=>'l', field-names => <Command App::Rak>) ==> to-html
```




<table>
<tr>
<th>Command</th>
<th>App::Rak</th>
</tr>
<tr>
<td>Find files that have ".nb" in their names</td>
<td>rak --extensions=nb --find</td>
</tr>
<tr>
<td>Find files that have ".nb"  or ".wl" in their names</td>
<td>rak --find --extensions=nb,wl</td>
</tr>
<tr>
<td>Show all directories of the parent directory</td>
<td>rak --find --/file --parent</td>
</tr>
<tr>
<td>Give me files without extensions and that contain the phrase "notebook"</td>
<td>rak --extensions= --type=contains notebook</td>
</tr>
<tr>
<td>Show all that have extension raku or rakumod and contain Data::Reshapers</td>
<td>rak '/ Data::Reshapers /' --extensions=raku,rakumod</td>
</tr>
</table>



### Verification

Of course, the obtained "App::Rak" commands have to be verified to:
- Work  
- Produce expected results

We can program to this verification with Raku or with the Jupyter framework, but we not doing that here.
(We do the verification manually outside of this notebook.)

**Remark:** I tried a dozen of generated commands. Most *worked*. One did not work because of the current limitations of "App::Rak". Others needed appropriate nudging to produce the desired results.

Here is an example of command that produces code that "does not work":


```raku
&frak("Give all files that have extensions .nd and contain the command Classify")
```




    rak '*.nd <command> Classify' --extensions=nd



Here are a few more:


```raku
&frak("give the names of all files in the parent directory")
```




    rak --find --/file --/directory




```raku
&frak("Find all directories in the parent directory")
```




    rak --find --/file --parent



Here is a generated command that exposes an "App::Rak" [limitation](https://github.com/lizmat/App-Rak/issues/44):


```raku
&frak("Find all files in the parent directory")
```




    rak --find ..



-------

## Translating randomly generated commands

Consider testing the applicability of the approach by generating a "good enough" sample of natural language commands for finding files or directories.

We can generate such commands via LLM. Here we define an LLM function with two parameters the returns a Raku list:


```raku
my &fcg = llm-function({"Generate $^_a natural language commands for finding $^b in a file system. Give the commands as a JSON list."}, form => sub-parser('JSON'))
```




    -> **@args, *%args { #`(Block|5361560082992) ... }




```raku
my @gCmds1 = &fcg(4, 'files').flat;
@gCmds1.raku
```




    ["Find all files in the current directory", "Find all files with the .txt extension in the current directory", "Search for all files with the word 'report' in the file name", "Search for all files with the word 'data' in the file name in the Documents folder"]



Here are the corresponding translations to the "App::Rak" DSL:


```raku
%%html
my @tbl1 = @gCmds1.map({ %( 'Command' => $_, 'App::Rak' => &frak($_) ) }).Array;
@tbl1 ==> to-pretty-table(align=>'l', field-names => <Command App::Rak>) ==> to-html
```




<table>
<tr>
<th>Command</th>
<th>App::Rak</th>
</tr>
<tr>
<td>Find all files in the current directory</td>
<td>rak --find</td>
</tr>
<tr>
<td>Find all files with the .txt extension in the current directory</td>
<td>rak --extensions=txt</td>
</tr>
<tr>
<td>Search for all files with the word 'report' in the file name</td>
<td>rak report --find</td>
</tr>
<tr>
<td>Search for all files with the word 'data' in the file name in the Documents folder</td>
<td>rak data Documents</td>
</tr>
</table>



Let use redo the generation and translation using different specs: 


```raku
my @gCmds2 = &fcg(4, 'files that have certain extensions or contain certain words').flat;
@gCmds2.raku
```




    ["Find all files with the extension .txt", "Locate all files that have the word 'project' in their name", "Show me all files with the extension .jpg", "Find all files that contain the word 'report'"]




```raku
%%html
my @tbl2 = @gCmds2.map({ %( 'Command' => $_, 'App::Rak' => &frak($_) ) }).Array;
@tbl2 ==> to-pretty-table( align=>'l', field-names => <Command App::Rak>) ==> to-html
```




<table>
<tr>
<th>Command</th>
<th>App::Rak</th>
</tr>
<tr>
<td>Find all files with the extension .txt</td>
<td>rak --extensions=txt</td>
</tr>
<tr>
<td>Locate all files that have the word 'project' in their name</td>
<td>rak --find project</td>
</tr>
<tr>
<td>Show me all files with the extension .jpg</td>
<td>rak --extensions=jpg</td>
</tr>
<tr>
<td>Find all files that contain the word 'report'</td>
<td>rak report --find</td>
</tr>
</table>



**Remark:** Ideally, there would be an LLM-based system that 1) hallucinates "App::Rak" commands, 2) executes them, and 3) files GitHub issues if it thinks the results are sub-par.
(All done authomatically.) On a more practical note, we can use a system that has the first two components "only" to stress test "App::Rak".

-------

## Alternative programming with LLM

In this subsection we show how to extract comment-and-code pairs using LLM functions. (Instead of *working hard* with Raku regexes.)

Here is LLM function that specifies the extraction:


```raku
my &fcex = llm-function({"Extract consecutive line pairs in which the first start with '#' and second with '\$' from the text $_. Group the lines as key-value pairs and put them in JSON format."}, 
form => 'JSON') 
```




    -> **@args, *%args { #`(Block|5361473544264) ... }



Here are three code blocks:


```raku
%%html
my @focusInds = [3, 12, 45];
[@blocks[@focusInds],] ==> to-pretty-table(align=>'l') ==> to-html
```




<table>
<tr>
<th>0</th>
<th>1</th>
<th>2</th>
</tr>
<tr>
<td><code>`</code></td>
<td><code>`</code></td>
<td><code>`</code></td>
</tr>
<tr>
<td># Look for "ve" at the end of all lines in file "twenty"</td>
<td># Show the lines containing "ne"</td>
<td># List all known extensions</td>
</tr>
<tr>
<td>$ rak --type=ends-with ve twenty</td>
<td>$ rak ne twenty</td>
<td># rak --list-known-extensions</td>
</tr>
<tr>
<td>twenty</td>
<td>twenty</td>
<td><code>`</code></td>
</tr>
<tr>
<td>5:fi𝐯𝐞</td>
<td>1:o𝐧𝐞</td>
<td></td>
</tr>
<tr>
<td>12:twel𝐯𝐞</td>
<td>9:ni𝐧𝐞</td>
<td></td>
</tr>
<tr>
<td><code>`</code></td>
<td>19:ni𝐧𝐞teen</td>
<td></td>
</tr>
<tr>
<td></td>
<td><code>`</code></td>
<td></td>
</tr>
</table>



Here we extract the command-and-code lines from the code blocks:


```raku
%%html
&fcex(@blocks[@focusInds]) ==> to-pretty-table(align=>'l') ==> to-html
```




<table>
<tr>
<th>Value</th>
<th>Key</th>
</tr>
<tr>
<td># rak --list-known-extensions</td>
<td># List all known extensions</td>
</tr>
<tr>
<td>$ rak ne twenty</td>
<td># Show the lines containing "ne"</td>
</tr>
<tr>
<td>$ rak --type=ends-with ve twenty</td>
<td># Look for "ve" at the end of all lines in file "twenty"</td>
</tr>
</table>



-------

## Grammar generation

The "right way" of translating natural language DSLs to CLI DSLs like the one of "App::Rak" is to make a grammar for the natural language DSL and the corresponding interpreter.
This might be a lengthy process, so, we might consider replacing it, or jump-starting it, with LLM-basd grammar generation:
we ask an LLM to generate a grammar for a collection DSL sentences. (For example, the keys of the rules above.) 
In this subsection we make a "teaser" demonstration of latter approach.

Here we create an LLM function for generating grammars over collections of sentences:


```raku
my &febnf = llm-function({"Generate an $^a grammar for the collection of sentences:\n $^b "}, e => llm-configuration("OpenAI", max-tokens=>900))
```




    -> **@args, *%args { #`(Block|5060670827264) ... }



Here we generate an EBNF grammar for the "App::Rak" code-example commands:


```raku
my $ebnf = &febnf('EBNF', @rules>>.key)
```




     Look for the lines that contains two consecutive words that start with "ba" Show all the lines where the fifth character is "e"
    
    SentenceList → Sentence | SentenceList Sentence
    
    Sentence → ProduceResultsPipe | SpecifyLiteral | SpecifyRegExp | SaveIgnoreCase | SaveIgnoremark | AddChangeDescIgnoreCase | LiteralStringCheck | SaveWhitespace | SearchRakudo | SaveAfterContext | SaveBeforeContext | SaveContext | SearchContext | SmartCase | SearchCase | RemoveOption | StartRak | SearchFile | SearchSubDir | Extension | NoExtension | BehaviourFiles | HelpFilesystem | SearchDir | FindName | FindNumber | FindScooby | FindAnywhere | FindWord | FindStart | FindEnd | NumberCharacters | FindY | FindU | FindNE | FindSix | FindSeven | FindEight | FreqLetters | ShowContain | TitleCase | ReverseOrder | Optionally
    
    ProduceResultsPipe → "produce" "results" "without" "any" "highlighting"
    SpecifyLiteral → "specify" "a" "literal" "pattern" "at" "the" "end" "of" "a" "line"
    SpecifyRegExp → "same," "with" "a" "regular" "expression"
    SaveIgnoreCase → "save" "--ignorecase" "as" "-i," "without" "description"
    SaveIgnoremark → "save" "--ignoremark" "as" "-m," "with" "description"
    AddChangeDescIgnoreCase → "add" "/" "change" "description" "-i" "at" "a" "later" "time"
    LiteralStringCheck → "look" "for" "literal" "string" "\"foo\"," "don't" "check" "case" "or" "accents"
    SaveWhitespace → "save" "looking" "for" "whitespace" "at" "end" "of" "a" "line" "as" "--wseol"
    SearchRakudo → "search" "for" "'sub" "min'" "in" "Rakudo's" "source"
    SaveAfterContext → "save" "--after-context" "as" "-A," "requiring" "a" "value"
    SaveBeforeContext → "save" "--before-context" "as" "-B," "requiring" "a" "value"
    SaveContext → "save" "--context" "as" "-C," "setting" "a" "default" "of" "2"
    SearchContext → "search" "for" "\"foo\"" "and" "show" "two" "lines" "of" "context"
    SmartCase → "set" "up" "smartcase" "by" "default"
    SearchCase → "look" "for" "\"Foo\"," "while" "taking" "case" "into" "account"
    RemoveOption → "remove" "the" "--frobnicate" "custom" "option"
    CheckOption → "check" "there's" "no" "\"frobnicate\"" "option" "anymore"
    StartRak → "start" "rak" "with" "configuration" "file" "at" "/usr/local/rak-config.json"
    SearchFile → "look" "for" "\"foo\"" "in" "all" "files"
    SearchSubDir → "search" "all" "files" "and" "all" "subdirectories"
    Extension → "only" "accept" "files" "with" "the" ".bat" "extension"
    NoExtension → "only" "accept" "files" "without" "extension"
    BehaviourFiles → "only" "accept" "Raku" "and" "Markdown" "files" 
    HelpFilesystem → "produce" "extensive" "help" "on" "



------

## References

### Articles

[AA1] Anton Antonov, ["Workflows with LLM functions"](https://rakuforprediction.wordpress.com/2023/08/01/workflows-with-llm-functions/), (2023), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov, ["Graph representation of grammars"](https://rakuforprediction.wordpress.com/2023/07/06/graph-representation-of-grammars/), (2023), [RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[EM1] Elizabeth Mattijsen, ["It's time to rak! Series' Articles"](https://dev.to/lizmat/series/20329), (2022), [Lizmat series at Dev.to](https://dev.to/lizmat/series).

### Packages, repositories

[AAp1] Anton Antonov, [LLM::Functions Raku package](https://github.com/antononcube/Raku-LLM-Functions), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov, [WWW::PaLM Raku package](https://github.com/antononcube/Raku-WWW-PaLM), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov, [Text::SubParsers Raku package](https://github.com/antononcube/Raku-Text-SubParsers), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov, [Markdown::Grammar Raku package](https://github.com/antononcube/Raku-Markdown-Grammar), (2023), [GitHub/antononcube](https://github.com/antononcube).

[BDp1] Brian Duggan, [Jupyter::Kernel Raku package](https://raku.land/cpan:BDUGGAN/Jupyter::Kernel), (2017-2023), [GitHub/bduggan](https://github.com/bduggan/raku-jupyter-kernel).

[EMp1] Elizabeth Mattijsen, [App::Rak Raku package](https://github.com/lizmat/App-Rak), (2022-2023), [GitHub/lizmat](https://github.com/lizmat).

[EMr1] Elizabeth Mattijsen, [articles](https://github.com/lizmat/articles), (2018-2023) [GitHub/lizmat](https://github.com/lizmat).
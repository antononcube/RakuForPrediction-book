# Simple guide 

### ... LLM-based template

```perl6, results=hide, echo=FALSE
# In case those packages are not loaded by the LLM code chunks 
use WWW::PaLM;
use WWW::OpenAI;
```


## Simply put

```openai, format=values, temperature=1.25, max-tokens=800, results=asis, output-prompt=NONE, echo=FALSE
Generate a 12 steps outline for quiting addiction to Python programming and replacing it with Raku.
(Use bold prefixes and arabic numbers for the list items.)
```

```perl6, results=asis, output-prompt=NONE, echo=FALSE
# Expansions generation script

# Assuming that the list items are numbered with arabic numbers
my $txt = _.trim;
my $txtExpanded = do for $txt.split(/ ^^ \d+ /, :v, :skip-empty)>>.Str.rotor(2) -> $p {
    my $res = "-" x 6; 
    $res ~= "\n"; 
    $res ~= "\n## {$p[0]}.";
    my $start = '';
    if $p[1] ~~ / '**' (.*?) '**'/ {
        $start = $0.Str;
        $res ~= ' ' ~ $start.subst( / <punct>+ $$/, '');
    };
    $res ~= "\n\n>... {$p[1].subst(/'**' $start '**'/, '').subst( / ^^ <punct>+ /, '')}"; 
    #$res ~= "\n\n", openai-completion( "Expand upon: {$p[1]}", temperature => 1.45, max-tokens => 400, format=>'values' );
    $res ~= "\n\n", palm-generate-text( "Expand upon: {$p[1]}", temperature => 0.75, max-tokens => 400, format=>'values' );
}

$txtExpanded.join("\n\n") 
```
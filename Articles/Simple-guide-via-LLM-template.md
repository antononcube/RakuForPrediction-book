# Simple guide 

### ... LLM-based template

## Simply put

```openai, format=values, temperature=1.4, max-tokens=800, results=asis, output-prompt=NONE, echo=FALSE
Generate a 12 steps outline for quiting addiction to programmaring Python (and replacing with Raku.)
```

```perl6, results=asis, output-prompt=NONE, echo=FALSE
# Expansions generation script
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
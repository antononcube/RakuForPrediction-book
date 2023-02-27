# Testing workflows with Gherkin specifications

**Anton Antonov   
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com)   
[RakuForPrediction-book at GitHub](https://github.com/antononcube/RakuForPrediction-book)   
February 2023**

---

## Gherkin is ...

- The language of the [Cucumber framework](https://cucumber.io)

    - [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) (BDD)

- Used for non-technical and human readable difinitions of test cases

- Also:

```mathematica
WebImageSearch["Gherkin", Method -> "Google"]
```

![1uuhwlx2hfoys](Diagrams/1uuhwlx2hfoys.png)

---

## [Cucumber framework](https://cucumber.io)

![0hsretzy9b7z7](Diagrams/0hsretzy9b7z7.png)

---

## [Gherkin language](https://cucumber.io/docs/gherkin/reference/)

Gherkin uses a set of special keywords to give structure and meaning to executable specifications. Each keyword is translated to many spoken languages; in this reference we'll use English.

```gherkin
Feature: DateTime interpretation test

  Scenario: ISO date
    When 2032-10-01
    Then the result is DateTime
    And the year is "2032", month is "10", and date "1"
      
```

It is assumed some familiriaty with Gherkin...

---

## DateTime::Grammar examples

We are going to make tests for ["DateTime::Grammar"](https://github.com/antononcube/Raku-DateTime-Grammar).

CLI example:

```shell
datetime-interpretation 2003-03-25

(*"2003-03-25T00:00:00Z"*)
```

![1s1gbmcgh7y7h](Diagrams/1s1gbmcgh7y7h.png)

---

## Gherkin::Grammar workflow

Here is workflow we will follow in this presentation:

```mathematica
mrmMain = "flowchart TDWT[\"Write tests<br/>(using Gherkin)\"] FG[\"Add glue code<br/>(manual coding)\"]GTC[\"Generate test code<br/>(template)\"]ET[Execute tests]FF>Feature file]GG[[Gherkin::Grammar]]TF>Test file]WT --> GTC --> FGWT -.-> FFGTC -.- |gherkin-interpret|GGFF -.-> GGGG -.->  TFFG -.- TFFG --> ET";
plMain = ResourceFunction["MermaidJS"][mrmMain, "PDF"]
```

![17aykvkx00r49](Diagrams/17aykvkx00r49.png)

---

## Typical Cucumber workflow

```mathematica
ResourceFunction["MermaidJS"]["flowchart TDWT[\"Write tests<br/>(using Gherkin)\"] FG[Fill-in glue code]GC[Glue connection]ET[Execute tests]FF>Feature file]CF[[Cucumber framework]]TF>Test code]WT --> FGFG -.- |preparation|GCWT -.-> FFGC -.- |preparation|CFFF -.-> CFCF -.-> TFTF -.-> CFFG --> ETET -.-> |execution|GCGC -.-> |execution|CF", "PDF", ImageSize -> 700]
```

![0aax7pqf0zg0v](Diagrams/0aax7pqf0zg0v.png)

---

## Simple example

- Using ["DateTime::Grammar"](https://github.com/antononcube/Raku-DateTime-Grammar)

- Comma (IntelliJ) plug-in

- Feature file

    - ...with one scenario

- Generate template testing code

-  Comparison

- Modifications

---

## Complex example

- Extending the previous example

    - Multiple scenarios

    - Scenario outline / template

---

## Summary

```mathematica
plMain
```

![1nkw4wvynxtuh](Diagrams/1nkw4wvynxtuh.png)
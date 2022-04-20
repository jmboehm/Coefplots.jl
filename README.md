<h1>
  <p align="center">
    <img width="550" src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/assets/logo.svg">
  </p>
</h1>


[Coefplots](https://github.com/caibengbu/Coefplots.jl) aims to make available in Julia (part of) the functionalities of [the Stata command `coefplot`](http://repec.sowi.unibe.ch/stata/coefplot/getting-started.html). [Coefplots](https://github.com/caibengbu/Coefplots.jl) is built on [PGFPlotsX](https://github.com/KristofferC/PGFPlotsX.jl/tree/ada03510396af592e05b2e382a0c12ce37ee3cc8). Work in progress.

## Quick Start

Please refer to [our quick general tutorial](examples/quick_start.ipynb) and [our tutorial for event study plots](examples/esplot.ipynb).

## Installation
```
pkg> add https://github.com/caibengbu/Coefplots.jl.git
```
## To-do list
- [x] allow adding title and note
- [x] allow horizontal plots
- [ ] allow multiple regression plot together (figure side by side, align on label axis)
- [ ] allow multiple regression plot together (figure side by side, align on value axis)
- [x] allow multiple regression plot together (same figure, singlecoefplot side by side)
- [ ] *allow offset*
- [ ] *allow change lengend location*
- [x] allow yline
- [x] allow xline
- [x] allow yband
- [x] allow xband
- [ ] automate fontsize
- [x] allow color change
- [ ] allow node shape change
- [x] allow node fill opacity, draw opacity to be different
- [ ] allow grid
- [ ] allow NaN and Inf

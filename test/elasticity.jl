include("../src/Coefplots.jl")
using .Coefplots
# using Coefplots
using GLM
using DataFrames, CSV
using Random
using PGFPlotsX

Random.seed!(1234)
sector_names = ["01-05  Animal & Animal Products",
                "06-15  Vegetable Products",
                "16-24  Foodstuffs",
                "25-27  Mineral Products",
                "28-38  Chemicals & Allied Industries",
                "39-40  Plastics / Rubbers",
                "41-43  Raw Hides, Skins, Leather, & Furs",
                "44-49  Wood & Wood Products",
                "50-63  Textiles",
                "64-67  Footwear / Headgear",
                "68-71  Stone / Glass",
                "72-83  Metals",
                "84-85  Machinery / Electrical",
                "86-89  Transportation",
                "90-97  Miscellaneous"]

df = DataFrame(varname=Coefplots.latex_escape.(sector_names), b=rand(15), se = rand(15)./10, dof=10)
c = Coefplots.Coefplot(df; sorter=df.varname)
c.vertical=false
c.keepconnect=false
c.yticklabel.size=8
c.mark.mark="*"
c.errorbar.linetype=:solid
c.errorbar.linewidth=0.5
c.errormark.mark="none"
c.title.content="title"
c.xlabel.content = "elasticity"
c.ylabel.content = "HS Sectors"
c.title.content = "My fake plot of elasticity"
Coefplots.sortcoef!(c)
pgfsave("../assets/elasticity.svg", Coefplots.to_picture(c))
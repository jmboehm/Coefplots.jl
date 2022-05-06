function gen_default_preamble()
    preamble = []
    push!(preamble, "% Default preamble")
    push!(preamble, "\\usepackage{pgfplots}")
    push!(preamble, "\\pgfplotsset{compat=newest}")
    push!(preamble, "\\usepackage{lmodern}")
    push!(preamble, "\\usepackage[T1]{fontenc}")
    push!(preamble,"\\usepackage{sansmath}")
end

CUSTOM_PREAMBLE = String[]

push!(CUSTOM_PREAMBLE, gen_default_preamble()...)
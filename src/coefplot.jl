mutable struct Coefplot
    name::Union{Null,String}
    note::Union{Null,AbstractCaption}
    xtitle::Union{Null,String}
    ytitle::Union{Null,String}
    dict::OrderedDict{Symbol,SinglecoefPlot}
    options::CoefplotOption
    other_components::Vector{Any}
    width::Real
    height::Real
    vertical::Bool

    # create Coefplot from combining vec_singlecoefplot and name, note, xtitle, ytitle
    function Coefplot(dict::OrderedDict{Symbol,SinglecoefPlot},
                      xtitle::Union{Null,String}=Null(),
                      ytitle::Union{Null,String}=Null(),
                      name::Union{Null,String}=Null(),
                      note::Union{Null,AbstractCaption}=Null(),
                      options::CoefplotOption=default_coefplot_options(),
                      other_components::Vector{Any}=Vector{Any}(),
                      width::Real=240, # default value of width for tikz
                      height::Real=207) # default value of height for tikz
        new(name, note, xtitle, ytitle, dict, options, other_components, width, height, false)
    end
end

function setxtitle!(c::Coefplot, x::String)
    c.xtitle = x
    return c
end

function setytitle!(c::Coefplot, y::String)
    c.ytitle = y
    return c
end

function setname!(c::Coefplot, name::String)
    c.name = name
    return c
end

function includenote!(c::Coefplot, note::String)
    c.note = AbstractCaption(note, default_note_options(c))
    return c
end

function setcolor!(c::Coefplot, color::Color)
    for sc in values(c.dict)
        sc.options.dotcolor = color
        sc.options.linecolor = color
    end
    return c
end

function addcomponent!(c::Coefplot, v::T) where T <: Union{VLine,VBand,HLine,HBand}
    push!(c.other_components,v)
    return c
end

function clearcomponents!(c::Coefplot)
    c.other_components = Vector{Any}()
    return c
end

function transpose!(c::Coefplot)
    c.vertical = ~c.vertical
    xtitle = deepcopy(c.xtitle)
    c.xtitle = deepcopy(c.ytitle)
    c.ytitle = xtitle
    return c
end

function gen_other_option_from_coefplot(coefplot::Coefplot;seperate_line::Bool=false)
    singlecoefplots = values(coefplot.dict)
    xtick = [singlecoefplot.thiscoef_loc for singlecoefplot in singlecoefplots]
    xticklabels = [singlecoefplot.thiscoef_label for singlecoefplot in singlecoefplots]
    xmin, xmax = extrema(xtick)
    ymin = minimum([singlecoefplot.confint_lb for singlecoefplot in singlecoefplots])
    ymax = maximum([singlecoefplot.confint_ub for singlecoefplot in singlecoefplots])
    l_c = length(singlecoefplots)
    if l_c == 1
        xaxis_lb = xmin - 0.5
        xaxis_ub = xmax + 0.5
    else
        xaxis_lb = xmin - (xmax - xmin)/(l_c-1) * 0.5
        xaxis_ub = xmax + (xmax - xmin)/(l_c-1) * 0.5
    end
    yaxis_lb = ymin - (ymax - ymin)*0.1
    yaxis_ub = ymax + (ymax - ymin)*0.1
    labels_and_titles = PGFPlotsX.Options()
    labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    labels_and_titles[Symbol("title style")] = "{font=\\large}"
    if ~isnull(coefplot.xtitle)
        labels_and_titles[:xlabel] = coefplot.xtitle
    end 
    if ~isnull(coefplot.ytitle)
        labels_and_titles[:ylabel] = coefplot.ytitle
    end
    if ~isnull(coefplot.name)
        labels_and_titles[:title] = coefplot.name
    end
    if seperate_line
        sorted_xtick = sort(xtick)
        if coefplot.vertical
            other_options = PGFPlotsX.Options(
                :xmin => xaxis_lb, :xmax => xaxis_ub, 
                :ymin => yaxis_lb, :ymax => yaxis_ub, 
                :xtick => xtick, :xticklabels => xticklabels,
                Symbol("extra x ticks") => [(sorted_xtick[i]+sorted_xtick[i+1])/2 for i in 1:(length(sorted_xtick)-1)], 
                Symbol("extra x tick style") => "{grid=major,grid style={dashed,gray!25}}",
                Symbol("extra x tick labels") => "{}")
        else
            other_options = PGFPlotsX.Options(
                :ymin => xaxis_lb, :ymax => xaxis_ub, 
                :xmin => yaxis_lb, :xmax => yaxis_ub, 
                :ytick => xtick, :yticklabels => xticklabels,
                Symbol("extra y ticks") => [(sorted_xtick[i]+sorted_xtick[i+1])/2 for i in 1:(length(sorted_xtick)-1)],
                Symbol("extra y tick style") => "{grid=major,grid style={dashed,gray!25}}",
                Symbol("extra y tick labels") => "{}")
        end
    else
        if coefplot.vertical
            other_options = PGFPlotsX.Options(
                :xmin => xaxis_lb, :xmax => xaxis_ub, 
                :ymin => yaxis_lb, :ymax => yaxis_ub, 
                :xtick => xtick, :xticklabels => xticklabels)
        else
            other_options = PGFPlotsX.Options(
                :ymin => xaxis_lb, :ymax => xaxis_ub, 
                :xmin => yaxis_lb, :xmax => yaxis_ub, 
                :ytick => xtick, :yticklabels => xticklabels)
        end
    end
    return merge!(labels_and_titles,other_options)
end

default_note_options(p::Coefplot) = PGFPlotsX.Options(:name => "note", 
                                                      :anchor => "north west", 
                                                      :font => "{\\fontsize{4.5}{4.5}\\selectfont}",
                                                      Symbol("text width") => "$(p.width)pt", 
                                                      :at => "(current axis.outer south west)")

Base.getindex(coefplot::Coefplot, args...; kwargs...) = getindex(coefplot.dict, args...; kwargs...)
Base.setindex!(coefplot::Coefplot, args...; kwargs...) = (setindex!(coefplot.dict, args...; kwargs...); coefplot)
Base.delete!(coefplot::Coefplot, args...; kwargs...) = (delete!(coefplot.dict, args...; kwargs...); coefplot)
Base.haskey(coefplot::Coefplot, args...; kwargs...) = haskey(coefplot.dict, args...; kwargs...)
get_coefplot_options(c::Coefplot) = get_coefplot_options(c.options)
cpad(str::String,n::Int64,fill::String=" ") = rpad(lpad(str,(n+length(str))÷2, fill),n, fill)

function Base.show(io::IO, coefplot::Coefplot)
    # format a little
    ks = []
    locs = []
    pt_ests = []
    confints = []
    labels = []

    for (k,v) in coefplot.dict
        push!(ks,k)
        push!(locs, Printf.format(Printf.Format("%.4g"),v.thiscoef_loc))
        push!(pt_ests, Printf.format(Printf.Format("%.4g"),v.point_est))
        push!(confints, "("*Printf.format(Printf.Format("%.4g"),v.confint_lb)*", "*Printf.format(Printf.Format("%.4g"),v.confint_ub)*")")
        push!(labels, String.(v.thiscoef_label))
    end

    max_k_len = maximum(push!(length.(string.(ks)),3)) # length("Key") == 3
    max_loc_len = maximum(push!(length.(locs),8)) # length("Location") == 8
    max_pe_len = maximum(push!(length.(pt_ests),14)) # length("Point Estimate") == 14
    max_conf_len = maximum(push!(length.(confints),19)) # length("Confidence Interval") == 19
    max_label_len = maximum(push!(length.(labels),5)) # length("Label") == 5

    format_vec(key,loc,point_est,confint,label;fill=" ",sep="   ") = join([lpad(key, max_k_len, fill),
                                                        cpad(loc, max_loc_len, fill),
                                                        cpad(point_est, max_pe_len, fill),
                                                        cpad(confint, max_conf_len, fill),
                                                        cpad(label, max_label_len, fill)],sep)

    bottom_and_top_rule = format_vec("─", "─", "─", "─", "─"; fill="─", sep="───")
    width = length(bottom_and_top_rule)
    if ~isnull(coefplot.name)
        println(io, cpad("─── * Coefplot Name: "*coefplot.name*" * ───",width))
    else
        println(io, cpad("─── * Unnamed Coefplot * ───",width))
    end  
    println(io, bottom_and_top_rule)                                           
    subtitles = format_vec("Key", "Location", "Point Estimate", "Confidence Interval", "Label")
    println(io, subtitles)
    midrule = format_vec("─", "─", "─", "─", "─"; fill="─", sep="───")
    println(io, midrule)
    for i in 1:length(ks)
        item = format_vec(ks[i], locs[i], pt_ests[i], confints[i], labels[i])
        println(io, item)
    end
    println(io, bottom_and_top_rule)
end

function Base.pushfirst!(d::OrderedDict{Symbol,SinglecoefPlot}, p::Pair{Symbol,SinglecoefPlot} ...; overwrite::Bool=true, suppress::Bool=false)
    for pp in p
        if haskey(d,pp.first)
            if overwrite
                if ~suppress
                    @warn "label $(pp.first) already exists in the coefplot, overwriting ..."
                end
                push!(d,pp)
            end
            throw(KeyError("label $(pp.first) already exists in the coefplot, please relabel your coefficients, or specify overwrite=true."))
        else
            push!(d,pp)
        end
    end
    return d
end

function Base.push!(coefplot::Coefplot, other::Pair{Symbol, SinglecoefPlot} ...)
    all_keys = vcat(keys(coefplot.dict),[other[1] for this_other in other])
    @assert length(unique(all_keys)) == length(all_keys) "there are repeated keys!"
    push!(coefplot.dict, other...) # add new singlecoefplot to coefplot, will overwrite if key coincides
    coefplot
end

function copy_options!(coefplot::Coefplot, to_be_copyed::Coefplot, exceptions::Vector{Symbol})
    for fieldname in fieldnames(typeof(coefplot))
        if fieldname ∉ exceptions
            setfield!(coefplot,fieldname,getfield(to_be_copyed,fieldname))
        end
    end
    return coefplot
end

function copy_options!(coefplot::Coefplot, to_be_copyed::Coefplot, exception::Symbol=:dict)
    for fieldname in fieldnames(typeof(coefplot))
        if fieldname != exception
            setfield!(coefplot,fieldname,getfield(to_be_copyed,fieldname))
        end
    end
    return coefplot
end

function concat(coefplots::Vector{Coefplot})
    dict = OrderedDict{Symbol, SinglecoefPlot}()
    for coefplot in coefplots
        pushfirst!(dict,collect(coefplot.dict)...)
    end
    concated = Coefplot(dict)
    copy_options!(concated, coefplots[1])
    equidist!(concated;preserve_locorder=false)
end

function shift(pair::Pair{Symbol,SinglecoefPlot}, dist::Real)
    new_pair = deepcopy(pair)
    new_pair.second.thiscoef_loc = new_pair.second.thiscoef_loc + dist
    return new_pair
end

function shift(coefplot::Coefplot, dist::Real)
    new_coefplot = deepcopy(coefplot)
    new_coefplot.dict = OrderedDict([shift(kv,dist) for kv in coefplot.dict])
    return new_coefplot
end

check_if_all_singlecoefplot_options_conform(c::Coefplot) = @assert all_equal([sc.options for sc in values(c.dict)]) throw(AssertionError("nonconforming subplot options within the coefplot labelled" * string(c_symbol)))

function coefrename!(c::Coefplot,ps::Pair{Symbol,String}...;relabel=false,rename=true,sort=false,drop=true)
    # if rename or relabel are all false, return coefplot as it is
    if ~rename && ~relabel 
        return c
    end

    new_dict = OrderedDict{Symbol,SinglecoefPlot}()
    mapping_dict = Dict(ps)
    p_contained_in_c = all(broadcast(x -> haskey(c.dict,x),keys(mapping_dict))) # p (pairs) ⊆ c (coefplot)
    c_contained_in_p = all(broadcast(x -> haskey(mapping_dict,x),keys(c.dict))) # c ⊆ p
    @assert p_contained_in_c "exceptional key found in the pair input"
    is_partial_rename = ~ c_contained_in_p # given that p ⊆ c, if c ⊆ p means that this is a full rename.

    if is_partial_rename && sort && drop
        @info "the renaming is partial, sorting will drop coefficients that is not renamed..."
    elseif is_partial_rename && sort && ~drop
        throw(ArgumentError("the renaming is partial, can't sort without dropping"))
    end

    if sort # if sort, the new coefplot.dict will have the order of the ps
        for pp in ps
            this_singlecoefplot = deepcopy(c[pp.first])
            if rename
                this_singlecoefplot.thiscoef_label = pp.second
            end
            if relabel
                new_dict[Symbol(pp.second)] = this_singlecoefplot
            else
                new_dict[pp.first] = this_singlecoefplot
            end
        end
    else # if sort, the new coefplot.dict will have the old order
        for (k,v) in c.dict
            this_singlecoefplot = deepcopy(v)
            new_label = get(mapping_dict,k,v.thiscoef_label) # check if k has a new label, if not return the original label as a default
            if rename
                this_singlecoefplot.thiscoef_label = new_label
            end
            if relabel
                new_dict[Symbol(new_label)] = this_singlecoefplot
            else
                new_dict[k] = this_singlecoefplot
            end
        end
    end
    c.dict = new_dict
    return c
end

function coefrename(c::Coefplot,ps::Pair{Symbol,String}...;relabel=false,rename=true,sort=false,drop=true)
    new_c = deepcopy(c)
    coefrename!(new_c,ps...;relabel,rename,sort,drop)
end

function to_plotable(c::Coefplot)
    default_coefplot_options = gen_other_option_from_coefplot(c)
    specified_options = get_coefplot_options(c)
    options = merge(default_coefplot_options,specified_options)  # give options in coefplot attributes a higher priority
    Plotable(options, c.note, collect(c), c.other_components)
end

function Base.collect(c::Coefplot)
    scs = PGFPlotsX.TikzElement[]
    for sc in values(c.dict)
        push!(scs, get_line(sc, c.vertical))
        push!(scs, get_dot(sc, c.vertical))
    end
    return scs
end
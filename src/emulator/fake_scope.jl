Base.@kwdef struct FakeDSOX4034A <: Oscilloscope
    num_samples = 65104
end

function initialize(model::Type{FakeDSOX4034A})
    return Instr{model}(model(), "", TCPSocket(), true)
end

function initialize(model::FakeDSOX4034A)
    return Instr{typeof(model)}(model, "", TCPSocket(), true)
end

function get_data(instr::Instr{FakeDSOX4034A}, ch::Vector{Int}) 
    for num in ch
        if num < 1 || num > 4
            error("$num is not a valid channel")
        end
    end
    map(c->get_data(instr, c), ch)
end

num_samples(i::Instr{FakeDSOX4034A}) = i.model.num_samples


function get_data(instr::Instr{FakeDSOX4034A}, ch::Int; scope_stats=false)
    samples = num_samples(instr)
    info = ScopeInfo(
        "8bit", 
        "Normal", 
        samples,
        7.68e-8, 
        -0.0025, 
        0.0, 
        0.0167364, 
        1.28425, 
        128.0, 
        "", 
        "", 
        "", 
        ch
    )

    volt = if ch == 1
            map(sin, collect(range(0, stop=6pi, length=samples))) .* V
        elseif ch == 2
            map(cos, collect(range(0, stop=6pi, length=samples))) .* V
        elseif ch == 3
            map(x->abs(sin(x)) / -3, collect(range(0, stop=16pi, length=samples))) .* V
        else
            map(x->abs(sin(x)) / 3, collect(range(0, stop=16pi, length=samples))) .* V
    end
    time = collect(range(-0.0025, stop=0.0025, length=samples)) * s
    return ScopeData(info, volt, time)
end


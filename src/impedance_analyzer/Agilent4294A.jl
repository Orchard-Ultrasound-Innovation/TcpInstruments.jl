"""
http://literature.cdn.keysight.com/litweb/pdf/04294-90061.pdf
# Available functions
- `initialize()`
- `terminate()`
- [`get_impedance`](@ref)
- [`get_bandwidth`](@ref)
- [`set_bandwidth`](@ref)
- [`get_volt_ac`](@ref)
- [`set_volt_ac`](@ref)
- [`get_channel`](@ref)
- [`set_channel`](@ref)
"""
struct Agilent4294A <: ImpedanceAnalyzer end

"""
    get_bandwidth(instr)

Returns bandwidth level (1-5)

# Returns
- `Int`: Between 1 and 5

1. (Initial value) Specifies bandwidth 1 (shortest measurement time)
2. Specifies bandwidth 2
3. Specifies bandwidth 3
4. Specifies bandwidth 4
5. Specifies bandwidth 5 (longest measurement time, accurate
measurement).
"""
get_bandwidth(i::Instr{Agilent4294A}) = i_query(i, "BWFACT?")

"""
    set_bandwith(instr, n)

Sets bandwidth level (1-5)

# Arguments
- `n::Int`: Desired bandwidth level (between 1 and 5)
"""
function set_bandwidth(i::Instr{Agilent4294A}, n)
    !(n in 1:5) && error("$n must be an int between 1 and 5")
    write(i, "BWFACT $n")
end

"""
    get_volt_ac(instr)

Returns oscillator (ac) voltage
"""
get_volt_ac(i::Instr{Agilent4294A}) = f_query(i, "POWE?") * V

"""
    set_volt_ac(instr, voltage)

# Arguments
- `voltage`: Desired voltage, range for voltage setting: 5E-3 to 1
"""
set_volt_ac(i::Instr{Agilent4294A}, n::Voltage) = write(i, "POWE $(raw(n))"*"V")


"""
    get_impedance(Instr{Agilent4294A})
Gets the impedance from the impedance analyser. This function doesn't change any settings on
the device, it only grabs data using the current settings.
"""
function get_impedance(obj::Instr{Agilent4294A})
    data = query(obj, "OUTPDTRC?"; timeout=20)
    data = split(data, ',')
    arr = Array{Complex, 1}()
    get_f(i) = parse(Float64, data[i])
    for i in 1:Int(length(data) / 2)
        real_i = i * 2 - 1
        img_i = i * 2
        push!(arr, get_f(real_i) + get_f(img_i)im)
    end
    return arr * R
end


@recipe function f(impedance::Array{typeof((1.0 + 0im)R), 1}; complex=false)
    title := "Impedance"
    layout := (2, 1)
    real_label, imag_label = if complex
        "Real", "Imaginary"
    else
        "Amplitude", "Phase"
    end
    label := [real_label, imag_label]
    @series begin
        subplot := 1
        label := real_label
        legend := :outertopright
        return complex ?  real(impedance) : abs.(impedance)
    end
    @series begin
        title := ""
        subplot := 2
        label := imag_label
        legend := :outertopright
        linecolor := :red
        return complex ?  imag(impedance) : rad2deg.(angle.(impedance))
    end
end

"""
    get_channel(i::Instr{Agilent4294A})
Returns which channel is currently active, either 1 or 2.

"""
get_channel(i::Instr{Agilent4294A}) = query(i, "TRAC?") == "A" ? 1 : 2

"""
    set_channel(i::Instr{Agilent4294A}, n::Int)
Sets which channel the impedance analyser is using. `n` must be 1 or 2.
"""
function set_channel(i::Instr{Agilent4294A}, n::Int)
    !(n in [1,2]) && error("Channel cannot be: $n (must be 1 or 2)")
    n == 1 ? write(i, "TRAC A") :  write(i, "TRAC B")
end

include("AgilentDSOX4024A.jl")
include("AgilentDSOX4034A.jl")
include("scope_common.jl")



#const SignalGenAndScope = Union{AgilentDSOX4024A, Keysight33612A}

# Priority 1 when defined
#instrument_reset(obj::Instr{AgilentDSOX4024A})    = write(obj, "*RST for 402")
# Priority 2
#instrument_reset(obj::Instr{T}) where (T <: SignalGenAndScope)   = write(obj, "*RST for SpecialGroup")
# Priority 3
#instrument_reset(obj::Instr{T}) where (T <: Oscilloscope)   = write(obj, "*RST for Oscilloscope")

#instrument_reset(obj::Instr{AgilentDSOX4034A})    = write(obj, "*RST for 403")

# Include model specific files here


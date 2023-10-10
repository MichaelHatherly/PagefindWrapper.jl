module PagefindWrapper

using LazyArtifacts

export pagefind

"""
    pagefind(; extended::Bool=false)

Return a `Cmd` object for the `pagefind` binary. If `extended` is `true` then
the `pagefind_extended` binary will be returned. Note that the extended version
of the binary is a lazy artifact and will only be downloaded when the `Cmd` is
run for the first time.
"""
function pagefind(; extended::Bool = false)
    artifact_path = extended ? artifact"pagefind_extended" : artifact"pagefind"
    binary = extended ? "pagefind_extended" : "pagefind"
    ext = Sys.iswindows() ? ".exe" : ""
    path = joinpath(artifact_path, "$(binary)$(ext)")
    return Cmd(Cmd([path]); env = copy(ENV)) # Somewhat replicating JLLWrapper behavior.
end

"""
    help()

Print the help message for the `pagefind` binary. This is a convenience
function that is equivalent to passing the `--help` flag to the `pagefind`
binary.
"""
help(io::IO = stdout) = print(io, readchomp(`$(pagefind()) --help`))

"""
    version()

The version of the `pagefind` binary. This does not correspond to the version
of this wrapper package.
"""
version() = VersionNumber(last(split(readchomp(`$(pagefind()) --version`))))

end # module PagefindWrapper

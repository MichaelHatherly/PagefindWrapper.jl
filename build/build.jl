import CodecZlib
import Pkg
import SHA
import Tar

pagefind_repo = "https://github.com/CloudCannon/pagefind"

latest_stable_release = mktempdir() do dir
    cd(dir) do
        run(`git clone $pagefind_repo`)
        cd("pagefind") do
            text = strip(readchomp(`git tag --sort=-creatordate `))
            tags = VersionNumber.(split(text, '\n'))
            stable_releases = filter(x -> x.build == x.prerelease == (), tags)
            return first(stable_releases)
        end
    end
end

@info "Latest stable version" latest_stable_release

binary_name(extended) = "pagefind$(extended ? "_extended" : "")"
artifact_url(version, triplet, extended) =
    "https://github.com/CloudCannon/pagefind/releases/download/v$(version)/$(binary_name(extended))-v$(version)-$(triplet).tar.gz"
artifact_sha_url(version, triplet, extended) =
    "https://github.com/CloudCannon/pagefind/releases/download/v$(version)/$(binary_name(extended))-v$(version)-$(triplet).tar.gz.sha256"

triplets = [
    "aarch64-apple-darwin" => Pkg.BinaryPlatforms.MacOS(:aarch64),
    "aarch64-unknown-linux-musl" => Pkg.BinaryPlatforms.Linux(:aarch64),
    "x86_64-apple-darwin" => Pkg.BinaryPlatforms.MacOS(:x86_64),
    "x86_64-pc-windows-msvc" => Pkg.BinaryPlatforms.Windows(:x86_64),
    "x86_64-unknown-linux-musl" => Pkg.BinaryPlatforms.Linux(:x86_64),
]

function create_artifacts(version)
    artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
    if isfile(artifact_toml)
        rm(artifact_toml)
    end
    touch(artifact_toml)
    for extended in (false, true)
        for (triple, platform) in triplets
            url = artifact_url(version, triple, extended)
            @info "downloading" url

            tar_gz = open(download(url))
            tar = CodecZlib.GzipDecompressorStream(tar_gz)
            tree_hash = Base.SHA1(Tar.tree_hash(tar))

            sha_url = artifact_sha_url(version, triple, extended)
            sha, _ = split(read(download(sha_url), String), ' '; limit = 2)

            @info "file summary" url tree_hash sha

            Pkg.Artifacts.bind_artifact!(
                artifact_toml,
                binary_name(extended),
                tree_hash,
                platform = platform,
                force = true,
                lazy = extended,
                download_info = Tuple[(url, sha)],
            )
        end
    end
end

create_artifacts(latest_stable_release)

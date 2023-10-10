using PagefindWrapper, Test

@testset "PagefindWrapper" begin
    @test sprint(PagefindWrapper.help) == readchomp(`$(PagefindWrapper.pagefind()) --help`)
    @test PagefindWrapper.version() isa VersionNumber
    for extended in (false, true)
        bin = pagefind(; extended)
        mktempdir() do dir
            cd(dir) do
                mkdir("public")
                write(
                    joinpath("public", "index.html"),
                    """
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <title>Test</title>
                        <link href="/favicon.ico" rel="icon shortcut">
                        <link href="/style.css" rel="stylesheet">
                    </head>

                    <body data-pagefind-body>
                        <h1>Test</h1>
                    </body>

                    </html>
                    """,
                )
                run(`$bin --site public`)
                @test isfile(joinpath(dir, "public", "pagefind", "pagefind.js"))
            end
        end
    end
end

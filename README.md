# PagefindWrapper.jl

A tiny wrapper package for the [Pagefind CLI](https://github.com/CloudCannon/pagefind)
for ease of use from within Julia-based web projects. To quote the Pagefind homepage:

> Pagefind is a fully static search library that aims to perform well on large
> sites, while using as little of your users’ bandwidth as possible, and
> without hosting any infrastructure.

This package exports the `pagefind()` function which provides the path to the
bundled Pagefind CLI tool. It also provides a lazy artifact for the "extended"
version of Pagefind which supports additional languages. This lazy artifact
will only download at runtime when first called.

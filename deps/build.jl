using BinaryProvider # requires BinaryProvider 0.4.0 or later

const forcecompile = get(ENV, "JULIA_SPECIALFUNCTIONS_BUILD_SOURCE", "false") == "true"

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get(filter(!isequal("verbose"), ARGS), 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libopenspecfun"], :openspecfun),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaPackaging/Yggdrasil/releases/download/OpenSpecFun-v0.5.3+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-gnu-gcc4.tar.gz",
         "5d464227f3d45721747b21f71287614480d8b8048ae05feb44636f15b1fa0bfa"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-gnu-gcc7.tar.gz",
         "54e2c7f571ef991534aef07c0c5da1a52b29d775d4d608d2fe0b2936337a8ccf"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-gnu-gcc8.tar.gz",
         "260fa67e1903706f904445092280a984f9a2e0b97a3c5c9c289a961ddde3c9a6"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-musl-gcc4.tar.gz",
         "c18eb4a5140780ea78ac335c5c103617415fb5b009ab145c0d23831a8d52ed32"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-musl-gcc7.tar.gz",
         "ee6b805784bff8e0f3fab4fec8fee7e42fc5301e11459c21ea78680ad3b14a6c"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.aarch64-linux-musl-gcc8.tar.gz",
         "d362508cf6ac755719d2ce92a514f3465f48e75f1009eb3a7a6e3ff22c246177"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-gnueabihf-gcc4.tar.gz",
         "c5a5942a3bad5e65ec46533d87df747cf25d8e5e8b756d4bec592cdef6e0b2ce"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-gnueabihf-gcc7.tar.gz",
         "198663ea65dfb9563fb94641dc0974996f96818f35a878e14728186fb3d5d6bc"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-gnueabihf-gcc8.tar.gz",
         "b293d95c6ed2d0b60efbd45a59499f13df2bf5424c2660ad32c529eae4e10d2a"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-musleabihf-gcc4.tar.gz",
         "e8c56849d2814b493dc688e39e91ed402ffab96bd21791e74befaf4449587561"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-musleabihf-gcc7.tar.gz",
         "3578d09f65c52e78cc721043774988616e59b70f68bdab7233171c95b07f86f2"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.arm-linux-musleabihf-gcc8.tar.gz",
         "55dc2d0317da8c72942a050fca22637b3f715989ed9babdffd5407e3ce85957b"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-gnu-gcc4.tar.gz",
         "b8a0b32c3f28eb663f7cf44fa047211781fa770bb6e63d9931c083293ab99528"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-gnu-gcc7.tar.gz",
         "e15e699e16a5371122f55db2689dcea7066816b63c0b18fd3f66e04a612a3e70"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-gnu-gcc8.tar.gz",
         "98fb54908383119682f9a1544fb3ebc4b9af212ec4cfb4f10fb4611256a35128"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-musl-gcc4.tar.gz",
         "4eed4d21100b2849991c8d93cbed89979c007ed99a7dffb2e19616e9970b9715"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-musl-gcc7.tar.gz",
         "f52b4b867e3b1d3f8f968e5cf24268d154f9017955bd5880f49bf389a251161e"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-linux-musl-gcc8.tar.gz",
         "169d56320b7c5f0df8f74d6dd4303195eeb2700e8a3032379cbec4f58d755b2b"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-w64-mingw32-gcc4.tar.gz",
         "ceb767e8f71d1094b16d9a866f83ffd2769a57532a4bd79fc1b7586062263f16"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-w64-mingw32-gcc7.tar.gz",
         "4779208e2340000d0ca7039b07fcef3a5ae58326e98b60beb79c7532bdbc05d7"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.i686-w64-mingw32-gcc8.tar.gz",
         "965ed911f2479917ff0bffc43137854e370ee961c5c3d03dd63d38ea23b855b6"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.powerpc64le-linux-gnu-gcc4.tar.gz",
         "966687bd725dfb954f8f8b6fdaf597d57a21718eacecb9249ad17fed0575b424"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.powerpc64le-linux-gnu-gcc7.tar.gz",
         "b016d073e293ee11182760489856e40970c718cb422185e5f71e31a027aeb2d8"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.powerpc64le-linux-gnu-gcc8.tar.gz",
         "beabf985b77943f77ab4a3eff413e5e689945c49a1d3a5c0c8e1f11188f9ea7a"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-apple-darwin14-gcc4.tar.gz",
         "2e3706c0ba8c5820d327859f5cf8ece7085e8cf7e6f744e2a0a25d913086aa79"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-apple-darwin14-gcc7.tar.gz",
         "be099a699c445f3bb94ccd421e3674e04adb8c9a85cdc48ea2b3e29b85c6a7bb"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-apple-darwin14-gcc8.tar.gz",
         "d7e546d83e3e501f52587ed27796bae6c53d483d947cd07af97e00f000634a92"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-gnu-gcc4.tar.gz",
         "80a34541ab787872f8c9685db9be8eeca30b7959f29223555d4cbfb5d6a4893b"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-gnu-gcc7.tar.gz",
         "870bb918dc7a39550829daefd507b53d9748c9039a52a072d7d535143cd6731c"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-gnu-gcc8.tar.gz",
         "c8838499cc2f16845f10697da72e38eb8ea222cea00fbe6d0f2c72b573c4a997"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-musl-gcc4.tar.gz",
         "2775ed11e0a79e3e6941de1d6aa7f8095090bc8ffcf986b8d588fe04d3151185"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-musl-gcc7.tar.gz",
         "bb803c5ae7c7fd55cba257d6d49ad21638a421ac92a08da7be7bff86eda9593e"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-linux-musl-gcc8.tar.gz",
         "8525a0f6fb54c1903f8e127275772ea846c6a81baedfd618e6bb60eef2d14f9b"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-unknown-freebsd11.1-gcc4.tar.gz",
         "145a4846031f52f0777678eacbda0727649fe96f52695f101d67802539bb206a"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-unknown-freebsd11.1-gcc7.tar.gz",
         "fb5b344a33dd7dfac5ff9a0b8d27caf5d5e9613f63e07bfed96a8acf6d311ba3"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-unknown-freebsd11.1-gcc8.tar.gz",
         "dd944fa05a3ffde46ba88ffefbf9de62a97dea3ce43aac44fd4f8e1a5df9261c"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc4)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-w64-mingw32-gcc4.tar.gz",
         "5b5ec3851b4d0ef8c802b6333259a4939c045ab8478f6f8b671b2129f5a02a86"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc7)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-w64-mingw32-gcc7.tar.gz",
         "248a39a24cb36c7be5f6a2d8470f7b43ccddb026d8813e48139ea0b3eb978c3b"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc8)) =>
        ("$bin_prefix/OpenSpecFun.v0.5.3.x86_64-w64-mingw32-gcc8.tar.gz",
         "316b7beec8b7962d9114b309133863a95f80c3c04e368ebb4db76240a9594c93"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(p->!satisfied(p; verbose=verbose), products)
to_download = choose_download(download_info, platform_key_abi())
if to_download !== nothing && !forcecompile
    if !isinstalled(to_download...; prefix=prefix)
        # Download and install binaries
        install(to_download...; prefix=prefix, force=true, verbose=verbose)
        unsatisfied = any(p->!satisfied(p; verbose=verbose), products)
    end
    if unsatisfied
        rm(joinpath(@__DIR__, "usr", "lib"); force=true, recursive=true)
    end
end
if unsatisfied || forcecompile
    include("scratch.jl")
else
    # Write out a deps.jl file that will contain mappings for our products
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products; verbose=verbose)
end

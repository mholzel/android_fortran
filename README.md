This repo contains a script that can be used to build standalone toolchains for Android that include `gfortran`. Specifically, the `build_standalone_toolchains.sh` script in the main directory will build standalone toolchains for 

- `arm`
- `arm64`
- `x86`
- `x86_64`
- `mips`
- `mips64`

The resulting toolchains will be created in a `standalone_toolchains` folder, and these toolchains will be compressed and put into the `archives` folder for portability. 

There are two other important features of this repo:

1. In [`releases`](https://github.com/jeti/android_fortran/releases), we have put the compressed standalone toolchains. You don't actually need to run the build script yourself. In fact, the build script takes about an hour on a fast machine with a fast connection. The standalone toolchains are called `xxx.7z`, while some intermediate files used to build the toolchains are called `xxx-partial.7z`. You don't need the partial toolchains unless you are building the standalone toolchains from scratch. 
2. The `test` folder contains a script `build.sh` which builds simple hello world programs in C, C++, and Fortran using all of the standalone toolchains. You can't actually run the executables on your machine (since they were compiled for Android), but you should at least be able to build the executables using the standalone toolchains that we create.  
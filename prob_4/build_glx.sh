#!/bin/bash

CC=clang++-3.5
TARGET=problem_4
COMMON=../common
SOURCE=(
	$COMMON/platform_glx.cpp
	$COMMON/util_gl.cpp
	$COMMON/prim_rgb_view.cpp
	$COMMON/get_file_size.cpp
	problem_4.cpp
	main.cpp
)
CFLAGS=(
	-ansi
	-Wno-logical-op-parentheses
	-Wno-bitwise-op-parentheses
	-Wno-parentheses
	-I$COMMON
	-pipe
	-fno-exceptions
	-fno-rtti
	-march=native
	-mtune=native
# For non-native or tweaked architecture targets, uncomment the correct target architecture
# AMD Bobcat:
#	-march=btver1
#	-mtune=btver1
# AMD Jaguar:
#	-march=btver2
#	-mtune=btver2
# note: Jaguars have 4-wide SIMD, so our avx256 code is not beneficial to them
#	-mno-avx
# Intel Core2
#	-march=core2
#	-mtune=core2
# Intel Nehalem
#	-march=corei7
#	-mtune=corei7
# Intel Sandy Bridge
#	-march=corei7-avx
#	-mtune=corei7-avx
# Intel Ivy Bridge
#	-march=core-avx-i
#	-mtune=core-avx-i
# Instruct GL headers to properly define their prototypes
	-DGLX_GLXEXT_PROTOTYPES
	-DGLCOREARB_PROTOTYPES
	-DGL_GLEXT_PROTOTYPES
# Framegrab rate
#	-DFRAMEGRAB_RATE=30
# Case-specific optimisation
	-DMINIMAL_TREE=1
# Show on screen what was rendered
	-DVISUALIZE=1
# Vector aliasing control
#	-DVECTBASE_MINIMISE_ALIASING=1
# High-precision ray reciprocal direction
	-DRAY_HIGH_PRECISION_RCP_DIR=1
# Use a linear distribution of directions across the hemisphere rather than proper angular such
#	-DCHEAP_LINEAR_DISTRIBUTION=1
# Number of workforce threads (normally equating the number of logical cores)
	-DWORKFORCE_NUM_THREADS=8
# Make workforce threads sticky (NUMA, etc)
#	-DWORKFORCE_THREADS_STICKY=1
# Colorize the output of individual threads
#	-DCOLORIZE_THREADS=1
# Threading model 'division of labor' alternatives: 0, 1, 2
	-DDIVISION_OF_LABOR_VER=2
# Bounce computation alternatives for variable-permute-disabled ISAs (e.g. all SSE revisions): 0, 1, 2
	-DBOUNCE_COMPUTE_VER=1
# Number of AO rays per pixel
	-DAO_NUM_RAYS=64
# Enable tweaks targeting Mesa quirks
#	-DOUTDATED_MESA=1
# Draw octree cells instead of octree content
#	-DDRAW_TREE_CELLS=1
# Clang static code analysis:
#	--analyze
	-DCLANG_QUIRK_0001=1
)
LFLAGS=(
# Alias some glibc6 symbols to older ones for better portability
#	-Wa,-defsym,memcpy=memcpy@GLIBC_2.2.5
#	-Wa,-defsym,__sqrtf_finite=__sqrtf_finite@GLIBC_2.2.5
	-L/usr/lib/fglrx
	-L/usr/lib64/nvidia
	-lstdc++
	-ldl
	-lrt
	-lGL
	-lX11
	-lpthread
#	-lpng12
)

if [[ $1 == "debug" ]]; then
	CFLAGS+=(
		-Wall
		-O0
		-g
		-DDEBUG
	)
else
	CFLAGS+=(
# Enable some optimisations that may or may not be enabled by the global optimisation level of choice in this compiler version
		-ffast-math
		-fstrict-aliasing
		-fstrict-overflow
		-funroll-loops
		-fomit-frame-pointer
		-O3
		-flto
		-DNDEBUG
	)
fi

BUILD_CMD=$CC" -o "$TARGET" "${CFLAGS[@]}" "${SOURCE[@]}" "${LFLAGS[@]}
echo $BUILD_CMD
CCC_ANALYZER_CPLUSPLUS=1 $BUILD_CMD

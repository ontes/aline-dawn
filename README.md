# Building Dawn with Zig
## Build Instructions
Clone the repo including submodules and run `zig build -Drelease-fast` to build shared `webgpu-dawn` in release mode. Latest version of Zig is the only dependency.
## Status
**Linux:** Everything works.

**Windows:** DirectX backend is broken, build with `-Denable-d3d12=false`. Vulkan backend runs fine.

**Mac:** Not tested.

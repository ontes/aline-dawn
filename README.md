# Building Dawn with Zig
## Build Instructions
Clone the repo including submodueles and run `zig build -Drelease-fast` to build a shared library in release mode.
## Status
**Linux:** Everything works.  
**Windows:** DirectX is broken, build with `-Denable-d3d12=false`.
**Mac:** Not tested.

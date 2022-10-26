# Building Dawn with Zig
## Build Instructions
Clone the repo including submodueles and run `zig build` to build a shared library.
## Status
**Linux:** Everything works.  
**Windows:** DirectX is broken, build with `-Denable-d3d12=false`. Shared library is broken for unknown reason.  
**Mac:** Not tested.

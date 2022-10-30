const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const os_tag = target.os_tag orelse @import("builtin").target.os.tag;
    const c_flags = &[_][]const u8{ "-std=c++17", "-g0", "-fvisibility=hidden" };

    const enable_d3d12 = b.option(bool, "enable-d3d12", "enable DirectX 12 backend") orelse (os_tag == .windows);
    const enable_metal = b.option(bool, "enable-metal", "enable Metal backend") orelse (os_tag == .macos);
    const enable_null = b.option(bool, "enable-null", "enable Null backend") orelse true;
    const enable_opengl = b.option(bool, "enable-opengl", "enable OpenGL backend") orelse (os_tag == .linux);
    const enable_opengles = b.option(bool, "enable-opengles", "enable OpenGL ES backend") orelse (os_tag == .linux);
    const enable_vulkan = b.option(bool, "enable-vulkan", "enable Vulkan backend") orelse (os_tag == .windows or os_tag == .linux);
    const use_wayland = b.option(bool, "use-wayland", "use Wayland") orelse false;
    const use_x11 = b.option(bool, "use-x11", "use X11") orelse (os_tag == .linux);

    const lib = b.addStaticLibrary("dawn", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);

    lib.linkLibCpp();

    lib.addIncludePath("include"); // additional headers for cross-platform compilation

    if (os_tag == .windows)
        lib.defineCMacro("_DEBUG", null); // workaround for release mode on windows

    { // based on dawn/src/dawn/common/BUILD.gn
        lib.addIncludePath("dawn");
        lib.addIncludePath("dawn/src");
        lib.addIncludePath("dawn-gen/src");
        lib.addIncludePath("dawn/include");
        lib.addIncludePath("dawn-gen/include");

        if (enable_d3d12)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_D3D12", null);
        if (enable_metal)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_METAL", null);
        if (enable_null)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_NULL", null);
        if (enable_opengl or enable_opengles)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_OPENGL", null);
        if (enable_opengl)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_DESKTOP_GL", null);
        if (enable_opengles)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_OPENGLES", null);
        if (enable_vulkan)
            lib.defineCMacro("DAWN_ENABLE_BACKEND_VULKAN", null);
        if (use_wayland)
            lib.defineCMacro("DAWN_USE_WAYLAND", null);
        if (use_x11)
            lib.defineCMacro("DAWN_USE_X11", null);

        const src_dir = "dawn/src/dawn/common/";
        const gen_dir = "dawn-gen/src/dawn/common/";
        lib.addCSourceFiles(&.{
            src_dir ++ "Assert.cpp",
            src_dir ++ "DynamicLib.cpp",
            src_dir ++ "GPUInfo.cpp",
            src_dir ++ "Log.cpp",
            src_dir ++ "Math.cpp",
            src_dir ++ "RefCounted.cpp",
            src_dir ++ "Result.cpp",
            src_dir ++ "SlabAllocator.cpp",
            src_dir ++ "SystemUtils.cpp",
            gen_dir ++ "GPUInfo_autogen.cpp",
        }, c_flags);
        if (os_tag == .macos)
            lib.addCSourceFile(src_dir ++ "SystemUtils_mac.mm", c_flags);
        if (os_tag == .windows)
            lib.addCSourceFile(src_dir ++ "WindowsUtils.cpp", c_flags);
        if (enable_vulkan)
            lib.addIncludePath("vulkan-headers/include");
        // if (os_tag == .android)
        //     lib.linkSystemLibrary("log");
    }

    { // based on dawn/src/dawn/platform/BUILD.gn
        const src_dir = "dawn/src/dawn/platform/";
        lib.addCSourceFiles(&.{
            src_dir ++ "DawnPlatform.cpp",
            src_dir ++ "WorkerThread.cpp",
            src_dir ++ "tracing/EventTracer.cpp",
        }, c_flags);
    }

    { // based on dawn/src/dawn/native/BUILD.gn
        const src_dir = "dawn/src/dawn/native/";
        const gen_dir = "dawn-gen/src/dawn/native/";
        lib.addCSourceFiles(&.{
            src_dir ++ "DawnNative.cpp",
            src_dir ++ "Adapter.cpp",
            src_dir ++ "ApplyClearColorValueWithDrawHelper.cpp",
            src_dir ++ "AsyncTask.cpp",
            src_dir ++ "AttachmentState.cpp",
            src_dir ++ "BackendConnection.cpp",
            src_dir ++ "BindGroup.cpp",
            src_dir ++ "BindGroupLayout.cpp",
            src_dir ++ "BindingInfo.cpp",
            src_dir ++ "Blob.cpp",
            src_dir ++ "BlobCache.cpp",
            src_dir ++ "BuddyAllocator.cpp",
            src_dir ++ "BuddyMemoryAllocator.cpp",
            src_dir ++ "Buffer.cpp",
            src_dir ++ "CacheKey.cpp",
            src_dir ++ "CacheRequest.cpp",
            src_dir ++ "CachedObject.cpp",
            src_dir ++ "CallbackTaskManager.cpp",
            src_dir ++ "CommandAllocator.cpp",
            src_dir ++ "CommandBuffer.cpp",
            src_dir ++ "CommandBufferStateTracker.cpp",
            src_dir ++ "CommandEncoder.cpp",
            src_dir ++ "CommandValidation.cpp",
            src_dir ++ "Commands.cpp",
            src_dir ++ "CompilationMessages.cpp",
            src_dir ++ "ComputePassEncoder.cpp",
            src_dir ++ "ComputePipeline.cpp",
            src_dir ++ "CopyTextureForBrowserHelper.cpp",
            src_dir ++ "CreatePipelineAsyncTask.cpp",
            src_dir ++ "Device.cpp",
            src_dir ++ "DynamicUploader.cpp",
            src_dir ++ "EncodingContext.cpp",
            src_dir ++ "Error.cpp",
            src_dir ++ "ErrorData.cpp",
            src_dir ++ "ErrorInjector.cpp",
            src_dir ++ "ErrorScope.cpp",
            src_dir ++ "ExternalTexture.cpp",
            src_dir ++ "Features.cpp",
            src_dir ++ "Format.cpp",
            src_dir ++ "IndirectDrawMetadata.cpp",
            src_dir ++ "IndirectDrawValidationEncoder.cpp",
            src_dir ++ "Instance.cpp",
            src_dir ++ "InternalPipelineStore.cpp",
            src_dir ++ "Limits.cpp",
            src_dir ++ "ObjectBase.cpp",
            src_dir ++ "ObjectContentHasher.cpp",
            src_dir ++ "PassResourceUsage.cpp",
            src_dir ++ "PassResourceUsageTracker.cpp",
            src_dir ++ "PerStage.cpp",
            src_dir ++ "Pipeline.cpp",
            src_dir ++ "PipelineCache.cpp",
            src_dir ++ "PipelineLayout.cpp",
            src_dir ++ "PooledResourceMemoryAllocator.cpp",
            src_dir ++ "ProgrammableEncoder.cpp",
            src_dir ++ "QueryHelper.cpp",
            src_dir ++ "QuerySet.cpp",
            src_dir ++ "Queue.cpp",
            src_dir ++ "RefCountedWithExternalCount.cpp",
            src_dir ++ "RenderBundle.cpp",
            src_dir ++ "RenderBundleEncoder.cpp",
            src_dir ++ "RenderEncoderBase.cpp",
            src_dir ++ "RenderPassEncoder.cpp",
            src_dir ++ "RenderPipeline.cpp",
            src_dir ++ "ResourceMemoryAllocation.cpp",
            src_dir ++ "RingBufferAllocator.cpp",
            src_dir ++ "Sampler.cpp",
            src_dir ++ "ScratchBuffer.cpp",
            src_dir ++ "ShaderModule.cpp",
            src_dir ++ "StagingBuffer.cpp",
            src_dir ++ "StreamImplTint.cpp",
            src_dir ++ "Subresource.cpp",
            // src_dir ++ "Surface.cpp",
            "Surface.cpp", // does not require windows core headers
            src_dir ++ "SwapChain.cpp",
            src_dir ++ "Texture.cpp",
            src_dir ++ "TintUtils.cpp",
            src_dir ++ "Toggles.cpp",
            src_dir ++ "VertexFormat.cpp",
            src_dir ++ "stream/BlobSource.cpp",
            src_dir ++ "stream/ByteVectorSink.cpp",
            src_dir ++ "stream/Stream.cpp",
            src_dir ++ "utils/WGPUHelpers.cpp",
            src_dir ++ "webgpu_absl_format.cpp",
            gen_dir ++ "ChainUtils_autogen.cpp",
            gen_dir ++ "ProcTable.cpp",
            gen_dir ++ "wgpu_structs_autogen.cpp",
            gen_dir ++ "ValidationUtils_autogen.cpp",
            gen_dir ++ "webgpu_absl_format_autogen.cpp",
            gen_dir ++ "webgpu_StreamImpl_autogen.cpp",
            gen_dir ++ "ObjectType_autogen.cpp",
        }, c_flags);

        if (use_x11) {
            lib.linkSystemLibrary("X11");
            lib.addCSourceFile(src_dir ++ "XlibXcbFunctions.cpp", c_flags);
        }
        if (os_tag == .windows) {
            lib.linkSystemLibrary("user32");
            // fix issues in dxcapi.h
            lib.defineCMacro("_Maybenull_", "");
            lib.defineCMacro("CROSS_PLATFORM_UUIDOF(interface, spec)", "");
        }
        if (enable_d3d12) {
            lib.linkSystemLibrary("dxguid");
            lib.addCSourceFiles(&.{
                src_dir ++ "d3d12/D3D12Backend.cpp",
                src_dir ++ "d3d12/AdapterD3D12.cpp",
                src_dir ++ "d3d12/BackendD3D12.cpp",
                src_dir ++ "d3d12/BindGroupD3D12.cpp",
                src_dir ++ "d3d12/BindGroupLayoutD3D12.cpp",
                src_dir ++ "d3d12/BlobD3D12.cpp",
                src_dir ++ "d3d12/BufferD3D12.cpp",
                src_dir ++ "d3d12/CPUDescriptorHeapAllocationD3D12.cpp",
                src_dir ++ "d3d12/CommandAllocatorManager.cpp",
                src_dir ++ "d3d12/CommandBufferD3D12.cpp",
                src_dir ++ "d3d12/CommandRecordingContext.cpp",
                src_dir ++ "d3d12/ComputePipelineD3D12.cpp",
                src_dir ++ "d3d12/D3D11on12Util.cpp",
                src_dir ++ "d3d12/D3D12Error.cpp",
                src_dir ++ "d3d12/D3D12Info.cpp",
                src_dir ++ "d3d12/DeviceD3D12.cpp",
                src_dir ++ "d3d12/ExternalImageDXGIImpl.cpp",
                src_dir ++ "d3d12/FenceD3D12.cpp",
                src_dir ++ "d3d12/GPUDescriptorHeapAllocationD3D12.cpp",
                src_dir ++ "d3d12/HeapAllocatorD3D12.cpp",
                src_dir ++ "d3d12/HeapD3D12.cpp",
                src_dir ++ "d3d12/NativeSwapChainImplD3D12.cpp",
                src_dir ++ "d3d12/PageableD3D12.cpp",
                src_dir ++ "d3d12/PipelineLayoutD3D12.cpp",
                src_dir ++ "d3d12/PlatformFunctions.cpp",
                src_dir ++ "d3d12/QuerySetD3D12.cpp",
                src_dir ++ "d3d12/QueueD3D12.cpp",
                src_dir ++ "d3d12/RenderPassBuilderD3D12.cpp",
                src_dir ++ "d3d12/RenderPipelineD3D12.cpp",
                src_dir ++ "d3d12/ResidencyManagerD3D12.cpp",
                src_dir ++ "d3d12/ResourceAllocatorManagerD3D12.cpp",
                src_dir ++ "d3d12/ResourceHeapAllocationD3D12.cpp",
                src_dir ++ "d3d12/SamplerD3D12.cpp",
                src_dir ++ "d3d12/SamplerHeapCacheD3D12.cpp",
                src_dir ++ "d3d12/ShaderModuleD3D12.cpp",
                src_dir ++ "d3d12/ShaderVisibleDescriptorAllocatorD3D12.cpp",
                src_dir ++ "d3d12/StagingBufferD3D12.cpp",
                src_dir ++ "d3d12/StagingDescriptorAllocatorD3D12.cpp",
                src_dir ++ "d3d12/StreamImplD3D12.cpp",
                src_dir ++ "d3d12/SwapChainD3D12.cpp",
                src_dir ++ "d3d12/TextureCopySplitter.cpp",
                src_dir ++ "d3d12/TextureD3D12.cpp",
                src_dir ++ "d3d12/UtilsD3D12.cpp",
            }, c_flags);
        }
        if (enable_metal) {
            lib.linkFrameworkWeak("Metal");
            lib.linkFramework("Cocoa");
            lib.linkFramework("IOKit");
            lib.linkFramework("IOSurface");
            lib.linkFramework("QuartzCore");
            lib.addCSourceFiles(&.{
                src_dir ++ "metal/MetalBackend.mm",
                src_dir ++ "Surface_metal.mm",
                src_dir ++ "metal/BackendMTL.mm",
                src_dir ++ "metal/BindGroupLayoutMTL.mm",
                src_dir ++ "metal/BindGroupMTL.mm",
                src_dir ++ "metal/BufferMTL.mm",
                src_dir ++ "metal/CommandBufferMTL.mm",
                src_dir ++ "metal/CommandRecordingContext.mm",
                src_dir ++ "metal/ComputePipelineMTL.mm",
                src_dir ++ "metal/DeviceMTL.mm",
                src_dir ++ "metal/PipelineLayoutMTL.mm",
                src_dir ++ "metal/QuerySetMTL.mm",
                src_dir ++ "metal/QueueMTL.mm",
                src_dir ++ "metal/RenderPipelineMTL.mm",
                src_dir ++ "metal/SamplerMTL.mm",
                src_dir ++ "metal/ShaderModuleMTL.mm",
                src_dir ++ "metal/StagingBufferMTL.mm",
                src_dir ++ "metal/SwapChainMTL.mm",
                src_dir ++ "metal/TextureMTL.mm",
                src_dir ++ "metal/UtilsMetal.mm",
            }, c_flags);
        }
        if (enable_null) {
            lib.addCSourceFiles(&.{
                src_dir ++ "null/NullBackend.cpp",
                src_dir ++ "null/DeviceNull.cpp",
            }, c_flags);
        }
        if (enable_opengl or enable_opengles or enable_vulkan) {
            lib.addCSourceFiles(&.{src_dir ++ "SpirvValidation.cpp"}, c_flags);
        }
        if (enable_opengl or enable_opengles) {
            lib.addIncludePath("dawn/third_party/khronos");
            lib.addCSourceFiles(&.{
                src_dir ++ "opengl/OpenGLBackend.cpp",
                src_dir ++ "opengl/AdapterGL.cpp",
                src_dir ++ "opengl/BackendGL.cpp",
                src_dir ++ "opengl/BindGroupGL.cpp",
                src_dir ++ "opengl/BindGroupLayoutGL.cpp",
                src_dir ++ "opengl/BufferGL.cpp",
                src_dir ++ "opengl/CommandBufferGL.cpp",
                src_dir ++ "opengl/ComputePipelineGL.cpp",
                src_dir ++ "opengl/ContextEGL.cpp",
                src_dir ++ "opengl/DeviceGL.cpp",
                src_dir ++ "opengl/EGLFunctions.cpp",
                src_dir ++ "opengl/GLFormat.cpp",
                src_dir ++ "opengl/NativeSwapChainImplGL.cpp",
                src_dir ++ "opengl/OpenGLFunctions.cpp",
                src_dir ++ "opengl/OpenGLVersion.cpp",
                src_dir ++ "opengl/PersistentPipelineStateGL.cpp",
                src_dir ++ "opengl/PipelineGL.cpp",
                src_dir ++ "opengl/PipelineLayoutGL.cpp",
                src_dir ++ "opengl/QuerySetGL.cpp",
                src_dir ++ "opengl/QueueGL.cpp",
                src_dir ++ "opengl/RenderPipelineGL.cpp",
                src_dir ++ "opengl/SamplerGL.cpp",
                src_dir ++ "opengl/ShaderModuleGL.cpp",
                src_dir ++ "opengl/SwapChainGL.cpp",
                src_dir ++ "opengl/TextureGL.cpp",
                src_dir ++ "opengl/UtilsEGL.cpp",
                src_dir ++ "opengl/UtilsGL.cpp",
                gen_dir ++ "opengl/OpenGLFunctionsBase_autogen.cpp",
            }, c_flags);
        }
        if (enable_vulkan) {
            lib.addIncludePath("vulkan-headers/include");
            lib.addCSourceFiles(&.{
                src_dir ++ "vulkan/VulkanBackend.cpp",
                src_dir ++ "vulkan/AdapterVk.cpp",
                src_dir ++ "vulkan/BackendVk.cpp",
                src_dir ++ "vulkan/BindGroupLayoutVk.cpp",
                src_dir ++ "vulkan/BindGroupVk.cpp",
                src_dir ++ "vulkan/BufferVk.cpp",
                src_dir ++ "vulkan/CommandBufferVk.cpp",
                src_dir ++ "vulkan/ComputePipelineVk.cpp",
                src_dir ++ "vulkan/DescriptorSetAllocator.cpp",
                src_dir ++ "vulkan/DeviceVk.cpp",
                src_dir ++ "vulkan/FencedDeleter.cpp",
                src_dir ++ "vulkan/NativeSwapChainImplVk.cpp",
                src_dir ++ "vulkan/PipelineCacheVk.cpp",
                src_dir ++ "vulkan/PipelineLayoutVk.cpp",
                src_dir ++ "vulkan/QuerySetVk.cpp",
                src_dir ++ "vulkan/QueueVk.cpp",
                src_dir ++ "vulkan/RenderPassCache.cpp",
                src_dir ++ "vulkan/RenderPipelineVk.cpp",
                src_dir ++ "vulkan/ResourceHeapVk.cpp",
                src_dir ++ "vulkan/ResourceMemoryAllocatorVk.cpp",
                src_dir ++ "vulkan/SamplerVk.cpp",
                src_dir ++ "vulkan/ShaderModuleVk.cpp",
                src_dir ++ "vulkan/StagingBufferVk.cpp",
                src_dir ++ "vulkan/StreamImplVk.cpp",
                src_dir ++ "vulkan/SwapChainVk.cpp",
                src_dir ++ "vulkan/TextureVk.cpp",
                src_dir ++ "vulkan/UtilsVulkan.cpp",
                src_dir ++ "vulkan/VulkanError.cpp",
                src_dir ++ "vulkan/VulkanExtensions.cpp",
                src_dir ++ "vulkan/VulkanFunctions.cpp",
                src_dir ++ "vulkan/VulkanInfo.cpp",
                src_dir ++ "vulkan/external_memory/MemoryService.cpp",
            }, c_flags);
            if (os_tag == .windows)
                lib.defineCMacro("VK_USE_PLATFORM_WIN32_KHR", null);
            if (os_tag == .linux and use_x11)
                lib.defineCMacro("VK_USE_PLATFORM_XCB_KHR", null);
            if (os_tag == .linux and use_wayland)
                lib.defineCMacro("VK_USE_PLATFORM_WAYLAND_KHR", null);
            // if (os_tag == .android)
            //     lib.defineCMacro("VK_USE_PLATFORM_ANDROID_KHR", null);
            if (os_tag == .fuchsia)
                lib.defineCMacro("VK_USE_PLATFORM_FUCHSIA", null);
            if (os_tag == .macos)
                lib.defineCMacro("VK_USE_PLATFORM_METAL_EXT", null);

            // if (os_tag == .chromeos) {
            //     lib.addCSourceFiles(&.{
            //         src_dir ++ "vulkan/external_memory/MemoryServiceDmaBuf.cpp",
            //         src_dir ++ "vulkan/external_semaphore/SemaphoreServiceFD.cpp",
            //     }, c_flags);
            //     lib.defineCMacro("DAWN_USE_SYNC_FDS", null);
            // } else if (os_tag == .android) {
            //     lib.addCSourceFiles(&.{
            //         src_dir ++ "vulkan/external_memory/MemoryServiceAHardwareBuffer.cpp",
            //         src_dir ++ "vulkan/external_semaphore/SemaphoreServiceFD.cpp",
            //     }, c_flags);
            // }
            if (os_tag == .linux) {
                lib.addCSourceFiles(&.{
                    src_dir ++ "vulkan/external_memory/MemoryServiceOpaqueFD.cpp",
                    src_dir ++ "vulkan/external_semaphore/SemaphoreServiceFD.cpp",
                }, c_flags);
            } else if (os_tag == .fuchsia) {
                lib.addCSourceFiles(&.{
                    src_dir ++ "vulkan/external_memory/MemoryServiceZirconHandle.cpp",
                    src_dir ++ "vulkan/external_semaphore/SemaphoreServiceZirconHandle.cpp",
                }, c_flags);
            } else {
                lib.addCSourceFiles(&.{
                    src_dir ++ "vulkan/external_memory/MemoryServiceNull.cpp",
                    src_dir ++ "vulkan/external_semaphore/SemaphoreServiceNull.cpp",
                }, c_flags);
            }
            // if (enable_vulkan_validation_layers)
            // if (enable_vulkan_loader)
            // if (use_swiftshader)
        }
    }

    { // based on dawn/src/tint/BUILD.gn
        const src_dir = "dawn/src/tint/";
        lib.addCSourceFiles(&.{
            src_dir ++ "ast/access.cc",
            src_dir ++ "ast/address_space.cc",
            src_dir ++ "ast/alias.cc",
            src_dir ++ "ast/array.cc",
            src_dir ++ "ast/assignment_statement.cc",
            src_dir ++ "ast/ast_type.cc",
            src_dir ++ "ast/atomic.cc",
            src_dir ++ "ast/attribute.cc",
            src_dir ++ "ast/binary_expression.cc",
            src_dir ++ "ast/binding_attribute.cc",
            src_dir ++ "ast/bitcast_expression.cc",
            src_dir ++ "ast/block_statement.cc",
            src_dir ++ "ast/bool.cc",
            src_dir ++ "ast/bool_literal_expression.cc",
            src_dir ++ "ast/break_if_statement.cc",
            src_dir ++ "ast/break_statement.cc",
            src_dir ++ "ast/builtin_attribute.cc",
            src_dir ++ "ast/builtin_value.cc",
            src_dir ++ "ast/call_expression.cc",
            src_dir ++ "ast/call_statement.cc",
            src_dir ++ "ast/case_selector.cc",
            src_dir ++ "ast/case_statement.cc",
            src_dir ++ "ast/compound_assignment_statement.cc",
            src_dir ++ "ast/const.cc",
            src_dir ++ "ast/continue_statement.cc",
            src_dir ++ "ast/depth_multisampled_texture.cc",
            src_dir ++ "ast/depth_texture.cc",
            src_dir ++ "ast/disable_validation_attribute.cc",
            src_dir ++ "ast/discard_statement.cc",
            src_dir ++ "ast/enable.cc",
            src_dir ++ "ast/expression.cc",
            src_dir ++ "ast/extension.cc",
            src_dir ++ "ast/external_texture.cc",
            src_dir ++ "ast/f16.cc",
            src_dir ++ "ast/f32.cc",
            src_dir ++ "ast/fallthrough_statement.cc",
            src_dir ++ "ast/float_literal_expression.cc",
            src_dir ++ "ast/for_loop_statement.cc",
            src_dir ++ "ast/function.cc",
            src_dir ++ "ast/group_attribute.cc",
            src_dir ++ "ast/i32.cc",
            src_dir ++ "ast/id_attribute.cc",
            src_dir ++ "ast/identifier_expression.cc",
            src_dir ++ "ast/if_statement.cc",
            src_dir ++ "ast/increment_decrement_statement.cc",
            src_dir ++ "ast/index_accessor_expression.cc",
            src_dir ++ "ast/int_literal_expression.cc",
            src_dir ++ "ast/internal_attribute.cc",
            src_dir ++ "ast/interpolate_attribute.cc",
            src_dir ++ "ast/invariant_attribute.cc",
            src_dir ++ "ast/let.cc",
            src_dir ++ "ast/literal_expression.cc",
            src_dir ++ "ast/location_attribute.cc",
            src_dir ++ "ast/loop_statement.cc",
            src_dir ++ "ast/matrix.cc",
            src_dir ++ "ast/member_accessor_expression.cc",
            src_dir ++ "ast/module.cc",
            src_dir ++ "ast/multisampled_texture.cc",
            src_dir ++ "ast/node.cc",
            src_dir ++ "ast/override.cc",
            src_dir ++ "ast/parameter.cc",
            src_dir ++ "ast/phony_expression.cc",
            src_dir ++ "ast/pipeline_stage.cc",
            src_dir ++ "ast/pointer.cc",
            src_dir ++ "ast/return_statement.cc",
            src_dir ++ "ast/sampled_texture.cc",
            src_dir ++ "ast/sampler.cc",
            src_dir ++ "ast/stage_attribute.cc",
            src_dir ++ "ast/statement.cc",
            src_dir ++ "ast/static_assert.cc",
            src_dir ++ "ast/storage_texture.cc",
            src_dir ++ "ast/stride_attribute.cc",
            src_dir ++ "ast/struct.cc",
            src_dir ++ "ast/struct_member.cc",
            src_dir ++ "ast/struct_member_align_attribute.cc",
            src_dir ++ "ast/struct_member_offset_attribute.cc",
            src_dir ++ "ast/struct_member_size_attribute.cc",
            src_dir ++ "ast/switch_statement.cc",
            src_dir ++ "ast/texel_format.cc",
            src_dir ++ "ast/texture.cc",
            src_dir ++ "ast/type_decl.cc",
            src_dir ++ "ast/type_name.cc",
            src_dir ++ "ast/u32.cc",
            src_dir ++ "ast/unary_op.cc",
            src_dir ++ "ast/unary_op_expression.cc",
            src_dir ++ "ast/var.cc",
            src_dir ++ "ast/variable.cc",
            src_dir ++ "ast/variable_decl_statement.cc",
            src_dir ++ "ast/vector.cc",
            src_dir ++ "ast/void.cc",
            src_dir ++ "ast/while_statement.cc",
            src_dir ++ "ast/workgroup_attribute.cc",
            src_dir ++ "castable.cc",
            src_dir ++ "clone_context.cc",
            src_dir ++ "debug.cc",
            src_dir ++ "demangler.cc",
            src_dir ++ "diagnostic/diagnostic.cc",
            src_dir ++ "diagnostic/formatter.cc",
            src_dir ++ "diagnostic/printer.cc",
            src_dir ++ "inspector/entry_point.cc",
            src_dir ++ "inspector/inspector.cc",
            src_dir ++ "inspector/resource_binding.cc",
            src_dir ++ "inspector/scalar.cc",
            src_dir ++ "number.cc",
            src_dir ++ "program.cc",
            src_dir ++ "program_builder.cc",
            src_dir ++ "program_id.cc",
            src_dir ++ "reader/reader.cc",
            src_dir ++ "resolver/const_eval.cc",
            src_dir ++ "resolver/dependency_graph.cc",
            src_dir ++ "resolver/init_conv_intrinsic.cc",
            src_dir ++ "resolver/intrinsic_table.cc",
            src_dir ++ "resolver/resolver.cc",
            src_dir ++ "resolver/sem_helper.cc",
            src_dir ++ "resolver/uniformity.cc",
            src_dir ++ "resolver/validator.cc",
            src_dir ++ "source.cc",
            src_dir ++ "symbol.cc",
            src_dir ++ "symbol_table.cc",
            src_dir ++ "text/unicode.cc",
            src_dir ++ "transform/add_block_attribute.cc",
            src_dir ++ "transform/add_empty_entry_point.cc",
            src_dir ++ "transform/array_length_from_uniform.cc",
            src_dir ++ "transform/binding_remapper.cc",
            src_dir ++ "transform/builtin_polyfill.cc",
            src_dir ++ "transform/calculate_array_length.cc",
            src_dir ++ "transform/canonicalize_entry_point_io.cc",
            src_dir ++ "transform/clamp_frag_depth.cc",
            src_dir ++ "transform/combine_samplers.cc",
            src_dir ++ "transform/decompose_memory_access.cc",
            src_dir ++ "transform/decompose_strided_array.cc",
            src_dir ++ "transform/decompose_strided_matrix.cc",
            src_dir ++ "transform/disable_uniformity_analysis.cc",
            src_dir ++ "transform/expand_compound_assignment.cc",
            src_dir ++ "transform/first_index_offset.cc",
            src_dir ++ "transform/for_loop_to_loop.cc",
            src_dir ++ "transform/localize_struct_array_assignment.cc",
            src_dir ++ "transform/manager.cc",
            src_dir ++ "transform/module_scope_var_to_entry_point_param.cc",
            src_dir ++ "transform/multiplanar_external_texture.cc",
            src_dir ++ "transform/num_workgroups_from_uniform.cc",
            src_dir ++ "transform/pad_structs.cc",
            src_dir ++ "transform/promote_initializers_to_let.cc",
            src_dir ++ "transform/promote_side_effects_to_decl.cc",
            src_dir ++ "transform/remove_continue_in_switch.cc",
            src_dir ++ "transform/remove_phonies.cc",
            src_dir ++ "transform/remove_unreachable_statements.cc",
            src_dir ++ "transform/renamer.cc",
            src_dir ++ "transform/robustness.cc",
            src_dir ++ "transform/simplify_pointers.cc",
            src_dir ++ "transform/single_entry_point.cc",
            src_dir ++ "transform/spirv_atomic.cc",
            src_dir ++ "transform/std140.cc",
            src_dir ++ "transform/substitute_override.cc",
            src_dir ++ "transform/transform.cc",
            src_dir ++ "transform/unshadow.cc",
            src_dir ++ "transform/unwind_discard_functions.cc",
            src_dir ++ "transform/utils/get_insertion_point.cc",
            src_dir ++ "transform/utils/hoist_to_decl_before.cc",
            src_dir ++ "transform/var_for_dynamic_index.cc",
            src_dir ++ "transform/vectorize_matrix_conversions.cc",
            src_dir ++ "transform/vectorize_scalar_matrix_initializers.cc",
            src_dir ++ "transform/vertex_pulling.cc",
            src_dir ++ "transform/while_to_loop.cc",
            src_dir ++ "transform/zero_init_workgroup_memory.cc",
            src_dir ++ "utils/debugger.cc",
            src_dir ++ "utils/string.cc",
            src_dir ++ "writer/append_vector.cc",
            src_dir ++ "writer/array_length_from_uniform_options.cc",
            src_dir ++ "writer/check_supported_extensions.cc",
            src_dir ++ "writer/flatten_bindings.cc",
            src_dir ++ "writer/float_to_string.cc",
            src_dir ++ "writer/generate_external_texture_bindings.cc",
            src_dir ++ "writer/text.cc",
            src_dir ++ "writer/text_generator.cc",
            src_dir ++ "writer/writer.cc",
            src_dir ++ "sem/abstract_float.cc",
            src_dir ++ "sem/abstract_int.cc",
            src_dir ++ "sem/abstract_numeric.cc",
            src_dir ++ "sem/array.cc",
            src_dir ++ "sem/atomic.cc",
            src_dir ++ "sem/behavior.cc",
            src_dir ++ "sem/block_statement.cc",
            src_dir ++ "sem/bool.cc",
            src_dir ++ "sem/break_if_statement.cc",
            src_dir ++ "sem/builtin.cc",
            src_dir ++ "sem/builtin_type.cc",
            src_dir ++ "sem/call.cc",
            src_dir ++ "sem/call_target.cc",
            src_dir ++ "sem/constant.cc",
            src_dir ++ "sem/depth_multisampled_texture.cc",
            src_dir ++ "sem/depth_texture.cc",
            src_dir ++ "sem/expression.cc",
            src_dir ++ "sem/external_texture.cc",
            src_dir ++ "sem/f16.cc",
            src_dir ++ "sem/f32.cc",
            src_dir ++ "sem/for_loop_statement.cc",
            src_dir ++ "sem/function.cc",
            src_dir ++ "sem/i32.cc",
            src_dir ++ "sem/if_statement.cc",
            src_dir ++ "sem/index_accessor_expression.cc",
            src_dir ++ "sem/info.cc",
            src_dir ++ "sem/loop_statement.cc",
            src_dir ++ "sem/materialize.cc",
            src_dir ++ "sem/matrix.cc",
            src_dir ++ "sem/member_accessor_expression.cc",
            src_dir ++ "sem/module.cc",
            src_dir ++ "sem/multisampled_texture.cc",
            src_dir ++ "sem/node.cc",
            src_dir ++ "sem/parameter_usage.cc",
            src_dir ++ "sem/pointer.cc",
            src_dir ++ "sem/reference.cc",
            src_dir ++ "sem/sampled_texture.cc",
            src_dir ++ "sem/sampler.cc",
            src_dir ++ "sem/statement.cc",
            src_dir ++ "sem/storage_texture.cc",
            src_dir ++ "sem/struct.cc",
            src_dir ++ "sem/switch_statement.cc",
            src_dir ++ "sem/texture.cc",
            src_dir ++ "sem/type.cc",
            src_dir ++ "sem/type_conversion.cc",
            src_dir ++ "sem/type_initializer.cc",
            src_dir ++ "sem/type_manager.cc",
            src_dir ++ "sem/u32.cc",
            src_dir ++ "sem/variable.cc",
            src_dir ++ "sem/vector.cc",
            src_dir ++ "sem/void.cc",
            src_dir ++ "sem/while_statement.cc",
        }, c_flags);

        lib.defineCMacro("TINT_BUILD_WGSL_READER", null);
        lib.addCSourceFiles(&.{
            src_dir ++ "reader/wgsl/lexer.cc",
            src_dir ++ "reader/wgsl/parser.cc",
            src_dir ++ "reader/wgsl/parser_impl.cc",
            src_dir ++ "reader/wgsl/token.cc",
        }, c_flags);

        lib.defineCMacro("TINT_BUILD_WGSL_WRITER", null);
        lib.addCSourceFiles(&.{
            src_dir ++ "writer/wgsl/generator.cc",
            src_dir ++ "writer/wgsl/generator_impl.cc",
        }, c_flags);

        lib.defineCMacro("TINT_BUILD_SPV_READER", null);
        lib.addCSourceFiles(&.{
            src_dir ++ "reader/spirv/construct.cc",
            src_dir ++ "reader/spirv/entry_point_info.cc",
            src_dir ++ "reader/spirv/enum_converter.cc",
            src_dir ++ "reader/spirv/function.cc",
            src_dir ++ "reader/spirv/namer.cc",
            src_dir ++ "reader/spirv/parser.cc",
            src_dir ++ "reader/spirv/parser_impl.cc",
            src_dir ++ "reader/spirv/parser_type.cc",
            src_dir ++ "reader/spirv/usage.cc",
        }, c_flags);

        if (enable_vulkan) {
            lib.defineCMacro("TINT_BUILD_SPV_WRITER", null);
            lib.addCSourceFiles(&.{
                src_dir ++ "writer/spirv/binary_writer.cc",
                src_dir ++ "writer/spirv/builder.cc",
                src_dir ++ "writer/spirv/function.cc",
                src_dir ++ "writer/spirv/generator.cc",
                src_dir ++ "writer/spirv/generator_impl.cc",
                src_dir ++ "writer/spirv/instruction.cc",
                src_dir ++ "writer/spirv/operand.cc",
            }, c_flags);
        }

        if (enable_metal) {
            lib.defineCMacro("TINT_BUILD_MSL_WRITER", null);
            lib.addCSourceFiles(&.{
                src_dir ++ "writer/msl/generator.cc",
                src_dir ++ "writer/msl/generator_impl.cc",
            }, c_flags);
        }

        if (enable_d3d12) {
            lib.defineCMacro("TINT_BUILD_HLSL_WRITER", null);
            lib.addCSourceFiles(&.{
                src_dir ++ "writer/hlsl/generator.cc",
                src_dir ++ "writer/hlsl/generator_impl.cc",
            }, c_flags);
        }

        if (enable_opengl or enable_opengles) {
            lib.defineCMacro("TINT_BUILD_GLSL_WRITER", null);
            lib.addCSourceFiles(&.{
                src_dir ++ "writer/glsl/generator.cc",
                src_dir ++ "writer/glsl/generator_impl.cc",
            }, c_flags);
        }
    }

    { // based on spirv-tools/BUILD.gn, NOTE: only builds files that Dawn requires
        lib.addIncludePath("spirv-tools");
        lib.addIncludePath("spirv-tools-gen");
        lib.addIncludePath("spirv-tools/include");
        lib.addIncludePath("spirv-headers/include");

        const src_dir = "spirv-tools/source/";
        lib.addCSourceFiles(&.{
            src_dir ++ "assembly_grammar.cpp",
            src_dir ++ "binary.cpp",
            src_dir ++ "diagnostic.cpp",
            src_dir ++ "disassemble.cpp",
            src_dir ++ "enum_string_mapping.cpp",
            src_dir ++ "ext_inst.cpp",
            src_dir ++ "extensions.cpp",
            src_dir ++ "libspirv.cpp",
            src_dir ++ "name_mapper.cpp",
            src_dir ++ "opcode.cpp",
            src_dir ++ "operand.cpp",
            src_dir ++ "parsed_operand.cpp",
            src_dir ++ "print.cpp",
            src_dir ++ "spirv_endian.cpp",
            src_dir ++ "spirv_target_env.cpp",
            src_dir ++ "spirv_validator_options.cpp",
            src_dir ++ "table.cpp",
            src_dir ++ "text.cpp",
            src_dir ++ "text_handler.cpp",
            src_dir ++ "util/parse_number.cpp",
            src_dir ++ "util/string_utils.cpp",
            src_dir ++ "val/basic_block.cpp",
            src_dir ++ "val/construct.cpp",
            src_dir ++ "val/function.cpp",
            src_dir ++ "val/instruction.cpp",
            src_dir ++ "val/validate.cpp",
            src_dir ++ "val/validate_adjacency.cpp",
            src_dir ++ "val/validate_annotation.cpp",
            src_dir ++ "val/validate_arithmetics.cpp",
            src_dir ++ "val/validate_atomics.cpp",
            src_dir ++ "val/validate_barriers.cpp",
            src_dir ++ "val/validate_bitwise.cpp",
            src_dir ++ "val/validate_builtins.cpp",
            src_dir ++ "val/validate_capability.cpp",
            src_dir ++ "val/validate_cfg.cpp",
            src_dir ++ "val/validate_composites.cpp",
            src_dir ++ "val/validate_constants.cpp",
            src_dir ++ "val/validate_conversion.cpp",
            src_dir ++ "val/validate_debug.cpp",
            src_dir ++ "val/validate_decorations.cpp",
            src_dir ++ "val/validate_derivatives.cpp",
            src_dir ++ "val/validate_execution_limitations.cpp",
            src_dir ++ "val/validate_extensions.cpp",
            src_dir ++ "val/validate_function.cpp",
            src_dir ++ "val/validate_id.cpp",
            src_dir ++ "val/validate_image.cpp",
            src_dir ++ "val/validate_instruction.cpp",
            src_dir ++ "val/validate_interfaces.cpp",
            src_dir ++ "val/validate_layout.cpp",
            src_dir ++ "val/validate_literals.cpp",
            src_dir ++ "val/validate_logicals.cpp",
            src_dir ++ "val/validate_memory.cpp",
            src_dir ++ "val/validate_memory_semantics.cpp",
            src_dir ++ "val/validate_mesh_shading.cpp",
            src_dir ++ "val/validate_misc.cpp",
            src_dir ++ "val/validate_mode_setting.cpp",
            src_dir ++ "val/validate_non_uniform.cpp",
            src_dir ++ "val/validate_primitives.cpp",
            src_dir ++ "val/validate_ray_query.cpp",
            src_dir ++ "val/validate_ray_tracing.cpp",
            src_dir ++ "val/validate_scopes.cpp",
            src_dir ++ "val/validate_small_type_uses.cpp",
            src_dir ++ "val/validate_type.cpp",
            src_dir ++ "val/validation_state.cpp",
            src_dir ++ "opt/basic_block.cpp",
            src_dir ++ "opt/build_module.cpp",
            src_dir ++ "opt/cfg.cpp",
            src_dir ++ "opt/const_folding_rules.cpp",
            src_dir ++ "opt/constants.cpp",
            src_dir ++ "opt/debug_info_manager.cpp",
            src_dir ++ "opt/decoration_manager.cpp",
            src_dir ++ "opt/def_use_manager.cpp",
            src_dir ++ "opt/dominator_tree.cpp",
            src_dir ++ "opt/feature_manager.cpp",
            src_dir ++ "opt/fold.cpp",
            src_dir ++ "opt/folding_rules.cpp",
            src_dir ++ "opt/function.cpp",
            src_dir ++ "opt/instruction.cpp",
            src_dir ++ "opt/instruction_list.cpp",
            src_dir ++ "opt/ir_context.cpp",
            src_dir ++ "opt/ir_loader.cpp",
            src_dir ++ "opt/loop_descriptor.cpp",
            src_dir ++ "opt/module.cpp",
            src_dir ++ "opt/scalar_analysis.cpp",
            src_dir ++ "opt/scalar_analysis_simplification.cpp",
            src_dir ++ "opt/struct_cfg_analysis.cpp",
            src_dir ++ "opt/type_manager.cpp",
            src_dir ++ "opt/types.cpp",
            src_dir ++ "opt/value_number_table.cpp",
        }, c_flags);
    }

    { // based on abseil-cpp/absl/strings/BUILD.bazel, NOTE: only builds files that Dawn requires
        lib.addIncludePath("abseil-cpp");

        const src_dir = "abseil-cpp/absl/";
        lib.addCSourceFiles(&.{
            src_dir ++ "strings/ascii.cc",
            src_dir ++ "strings/charconv.cc",
            src_dir ++ "strings/match.cc",
            src_dir ++ "strings/numbers.cc",
            src_dir ++ "strings/internal/charconv_bigint.cc",
            src_dir ++ "strings/internal/charconv_parse.cc",
            src_dir ++ "strings/internal/memutil.cc",
            src_dir ++ "strings/internal/str_format/arg.cc",
            src_dir ++ "strings/internal/str_format/bind.cc",
            src_dir ++ "strings/internal/str_format/extension.cc",
            src_dir ++ "strings/internal/str_format/float_conversion.cc",
            src_dir ++ "strings/internal/str_format/output.cc",
            src_dir ++ "strings/internal/str_format/parser.cc",
            src_dir ++ "base/internal/raw_logging.cc",
            src_dir ++ "numeric/int128.cc",
        }, c_flags);
    }

    const webgpu_lib = b.addSharedLibrary("webgpu_dawn", null, .unversioned);
    webgpu_lib.setTarget(target);
    webgpu_lib.setBuildMode(mode);

    webgpu_lib.defineCMacro("WGPU_IMPLEMENTATION", null);
    webgpu_lib.defineCMacro("WGPU_SHARED_LIBRARY", null);
    webgpu_lib.addIncludePath("dawn-gen/include");
    webgpu_lib.addCSourceFile("dawn-gen/src/dawn/native/webgpu_dawn_native_proc.cpp", c_flags);
    webgpu_lib.linkLibrary(lib);

    webgpu_lib.install();
}

# Visual Studio and Intel Install Plan

## Current assumptions
- C: is the fastest single drive and should host Windows, the core IDE, and hot-path developer tooling.
- D: is a fast RAID0 workspace and should host large shared SDKs, caches, models, and bulk toolchains.
- Network is a 1 Gb fiber connection, so redownloading installers and tool packages is cheap compared with consuming premium local SSD space.
- The active OneDrive root is on C:, not D:.
- The current D: usage is mostly pagefile, models, and program data, not synced user files.

## Installation locations
Use these choices on the first Visual Studio install while the installer still allows path changes.

- Visual Studio IDE: keep on C:
- Shared components, tools, and SDKs: D:\VS\Shared
- Download cache: D:\VS\Cache
- Repositories and working trees: D:\Dev or D:\ai-hub
- Intel oneAPI, OpenVINO, and VTune: D:\Intel
- VTune result folders: D:\Perf\VTune

## Why this split
- Visual Studio's core binaries and the active compiler path benefit most from the fastest local SSD and lowest-latency path.
- Shared SDKs and caches grow quickly and update often, so they belong on the larger secondary workspace volume.
- Intel toolkits are large and can be reinstalled without affecting the OS, so they should stay off the system drive when possible.
- With 1 Gb fiber, keeping a permanent giant installer cache is optional; favor reproducibility and convenience over hoarding every downloaded package.

## Network implications
1. Keep the Visual Studio download cache on D:, not C:.
2. It is reasonable to keep the cache only while stabilizing the toolchain, then prune it later.
3. Prefer online installers unless you are intentionally building an offline recovery kit.
4. For package managers, keep active caches on D: if they grow large, but do not over-optimize small caches just because bandwidth is available.

## Minimal Visual Studio install
Start with a small install and add only what supports the current priorities.

### Workloads to install now
1. Desktop development with C++
2. Python development
3. Data storage and processing

### Add only if needed soon
1. ASP.NET and web development

### Skip for now
1. Unity
2. .NET MAUI
3. Android/mobile workloads
4. Office/Microsoft 365 development
5. Game development workloads

Unity can be added later when Meta Quest 3 work becomes active.

## Individual Visual Studio components
Confirm these are included or add them explicitly.

1. GitHub Copilot
2. Windows 11 SDK 26100
3. MSVC x64/x86 latest toolset
4. CMake tools for Windows
5. vcpkg package manager
6. SQL Server Data Tools only if you want SQL project support inside Visual Studio
7. LLVM/Clang only if you expect to compare toolchains or need Clang-specific workflows

## Intel tooling plan
If diagnostics and profiling are the goal, start with VTune-oriented tooling rather than a maximal Intel install.

### Install now
1. Intel oneAPI Base Toolkit
2. Intel VTune Profiler

### Install after that only if required
1. OpenVINO
2. Deep Learning Essentials

## Pagefile guidance
The current system is manually configured to use a fixed 96 GB pagefile on D:.

Recommended steady-state configuration:
1. C: system-managed pagefile
2. D: no pagefile

Reason:
- Paging is dominated by latency and random I/O behavior more than headline sequential throughput.
- A cross-drive pagefile strategy only helps if it reduces contention in a measurable way.
- Test results should drive the choice; do not keep the D-only pagefile if it does not measurably improve performance.

## Suggested test sequence
Use VTune and disk benchmarks to compare one variable at a time.

### Baseline before pagefile changes
1. Record current pagefile layout
2. Run PerformanceTest disk benchmarks
3. Run CrystalDiskMark with a fixed profile
4. Capture one VTune baseline for storage-heavy or compile-heavy activity

### After pagefile reset
1. Change to C: system-managed pagefile
2. Remove D: pagefile
3. Reboot
4. Re-run the same disk benchmarks
5. Re-run the same VTune capture
6. Compare only like-for-like runs

## Install order
1. Install VS Code Insiders on C:
2. Sign into GitHub with the Copilot-entitled account
3. Install Visual Studio Community with the minimal workload set
4. Set shared components to D:\VS\Shared
5. Set download cache to D:\VS\Cache
6. Install Intel oneAPI Base Toolkit and VTune to D:\Intel
7. Add OpenVINO only after the profiling baseline is captured

## Validation checklist
1. Visual Studio launches and detects the selected toolchains
2. `cl`, `cmake`, and Python are available where expected
3. VTune can create and save a result under D:\Perf\VTune
4. Disk benchmarks are archived before and after the pagefile change
5. Pagefile configuration is documented after the final decision
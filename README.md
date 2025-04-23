# zig-coz

A Zig package for adding Coz progress points to a zig project for the Coz causal profiler.

Here is an excellent [video](https://www.youtube.com/watch?app=desktop&v=r-TLSBdHe1A) about what Coz is.

This is a learning exercise for me, any suggestions for improvements or corrections is appreciated!

## Licensing

- `include/coz.h` is sourced from [Coz](https://github.com/plasma-umass/coz) and licensed [here](https://github.com/plasma-umass/coz/blob/master/LICENSE.md).
- Other files (`coz_interface.c`, `coz_interface.h`, `coz_interface.zig`, etc.) are licensed under [APACHE](https://www.apache.org/licenses/LICENSE-2.0).
- See the [LICENSE](LICENSE-APACHE) file for details.

## Attribution

This package includes `coz.h` from the Coz project (https://github.com/plasma-umass/coz), Copyright 2015 Charlie Curtsinger.

## Installation

```shell
zig fetch --save https://github.com/JbKipp/zig-coz/archive/refs/heads/master.tar.gz
```

## Usage

In `build.zig`:
```zig
pub fn build(b: *std.Build) void {
    
    //  ...

    // Add Coz dependency
    const coz_dep = b.dependency("zig_coz", .{
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(coz_dep.artifact("zig_coz"));
    exe.addIncludePath(coz_dep.path("include"));
    exe.linkSystemLibrary("dl");
    exe.linkLibC();

    exe.root_module.addImport("zig_coz", coz_dep.module("zig_coz"));
    
    //  ...
}

```

Simple `main.zig` example.

```zig

const std = @import("std");
const coz = @import("zig_coz");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var i: u32 = 0;
    coz.coz_begin("loop_start");
    while (i < 1000000) : (i += 1) {
        // Simulate some work
        var sum: u64 = 0;
        for (0..100) |_| {
            sum += i;
        }
        coz.coz_progress("iteration");
        try stdout.print("Iteration {}\n", .{i});
    }
    coz.coz_end("loop_start");
}
```

## Docker

For those interested in running coz in docker (no idea as to the accuracy of the results) here is a method. Add these files
to your project root. Take note and understand the ramifications of using `cap_add: -SYS_ADMIN`

`Dockerfile`:

```dockerfile

FROM debian:latest

RUN apt-get update && apt-get install coz-profiler -y

```

`docker-compose.yml`:
```yaml

services:
  example_service:
    build: .
    user: "1000:1000"
    cap_add:
      - SYS_ADMIN
    volumes:
      - ./:/app
    working_dir: /app
    command:
      - "coz"
      - "run"
      - "-o"
      - "profile.coz"
      - "---"
      - "./zig-out/bin/my-binary-name"
```

Running:

```shell
docker compose -f docker-compose.yml -p example_service up -d example_service
```

Should result in a `profile.coz` file in your project root, which can be viewed [here](https://plasma-umass.org/coz/)
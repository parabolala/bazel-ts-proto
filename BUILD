load("@rules_proto//proto:defs.bzl", "proto_library")
load("@build_bazel_rules_nodejs//:index.bzl", "pkg_npm")
load("@rules_proto_grpc//:defs.bzl", "proto_plugin")
load("@npm//@bazel/typescript:index.bzl", "ts_library", "ts_project")
load("//:protobuf-ts-proto-library.bzl", "protobuf_ts_proto")

exports_files(["rules_nodejs.patch"])

proto_plugin(
    name = "protobuf-ts-plugin",
    outputs = [
        "{protopath}.ts",
    ],
    protoc_plugin_name = "ts",
    tool = "@npm//@protobuf-ts/plugin/bin:protoc-gen-ts",
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test_proto",
    srcs = [
        "test.proto",
        "test2.proto",
    ],
)

# Produces example.ts in the default outputs, but it can't be referenced
# explicitly.
protobuf_ts_proto(
    name = "example_ts_proto",
    protos = ["test_proto"],
    verbose = 1,
)

# Produces .d.ts and .js from the given .ts.
ts_project(
    name = "tsconfig",
    tsconfig = {
        "compilerOptions": {
            "lib": ["es6", "dom"],
        },
    },
    srcs = ["example_ts_proto"],
    declaration = True,
)

ts_library(
    tsconfig = ":tsconfig_tsconfig.json",
    name = "lib",
    srcs = [":example_ts_proto"],
    deps = [
        "@npm//@protobuf-ts/runtime",
    ],
)

# Extract .js from .ts.
filegroup(
    name = "lib_js_only",
    srcs = [
        ":lib",
    ],
    output_group = "es5_sources",
)

# Extract .d.ts from .ts.
filegroup(
    name = "lib_dts_only",
    srcs = [
        ":lib",
    ],
)

# Packages the produced .d.ts and .js.
pkg_npm(
    name = "npm-pkg",
    package_name = "test",
    srcs = [],
    deps = [
        ":package.json",
        ":lib_js_only",
        ":lib_dts_only",
        "patches/@bazel+typescript+3.2.2.patch",
    ],
)

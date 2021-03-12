load("@rules_proto//proto:defs.bzl", "proto_library")
load("@build_bazel_rules_nodejs//:index.bzl", "pkg_npm")
load("@rules_proto_grpc//:defs.bzl", "proto_plugin")
load("@npm//@bazel/typescript:index.bzl", "ts_project")
load("//:protobuf-ts-proto-library.bzl", "compile_ts_proto", "extract_ts_source")

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
    srcs = ["test.proto"],
)

# Produces example.ts in the default outputs, but it can't be referenced
# explicitly.
compile_ts_proto(
    name = "example",
    protos = [":test_proto"],
    verbose = 1,
)

# Moved example.ts from the ProtoCompileInfo.output_files[0] into the out file.
extract_ts_source(
    name = "example_ts",
    ts_proto = ":example",
    out = "example.ts",
)

# Produces .d.ts and .js from the given .ts.
ts_project(
    tsconfig = {
        "compilerOptions": {
            "lib": ["es6", "dom"],
        },
    },
    declaration = True,
    srcs = [
        ":example.ts",
    ],
    deps = [
        "@npm//@protobuf-ts/runtime",
    ],
)

# Packages the produced .d.ts and .js.
pkg_npm(
    name = "npm-pkg",
    package_name = "test",
    srcs = [],
    deps = [
        ":package.json",
        ":tsconfig",
    ],
)

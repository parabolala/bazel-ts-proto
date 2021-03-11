load("@rules_proto//proto:defs.bzl", "proto_library")
load("//:protobuf-ts-proto-library.bzl", "example_compile")
load("@build_bazel_rules_nodejs//:index.bzl", "pkg_npm")

proto_library(
    name = "test_proto",
    srcs = ["test.proto"],
)

pkg_npm(
    name = "npm-pkg",
    package_name = "test",
    srcs = [],
    deps = [
        ":package.json",
        ":example",
    ],
)

load("@rules_proto_grpc//:defs.bzl", "proto_plugin")

proto_plugin(
    name = "ts_plugin",
    outputs = [
        "{protopath}.ts",
    ],
    protoc_plugin_name = "ts",
    tool = "@npm//@protobuf-ts/plugin/bin:protoc-gen-ts",
    visibility = ["//visibility:public"],
)

example_compile(
    name = "example",
    protos = [":test_proto"],
    verbose = 1,
)

load("@npm//@bazel/typescript:index.bzl", "ts_project")

#ts_project(
#    tsconfig = {},
#    declaration = True,
#    #srcs = [":example"],
#)

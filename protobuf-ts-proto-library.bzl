load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(
    "@rules_proto_grpc//:defs.bzl",
    "ProtoCompileInfo",
    "ProtoLibraryAspectNodeInfo",
    "ProtoPluginInfo",
    "proto_compile_aspect_attrs",
    "proto_compile_aspect_impl",
    "proto_compile_attrs",
    "proto_compile_impl",
)

TS_PLUGIN = "//:protobuf-ts-plugin"

# Create aspect
example_aspect = aspect(
    implementation = proto_compile_aspect_impl,
    provides = [ProtoLibraryAspectNodeInfo],
    attr_aspects = ["deps"],
    attrs = dict(
        proto_compile_aspect_attrs,
        _plugins = attr.label_list(
            doc = "List of protoc plugins to apply",
            providers = [ProtoPluginInfo],
            default = [
                Label(TS_PLUGIN),
            ],
        ),
        _prefix = attr.string(
            doc = "String used to disambiguate aspects when generating outputs",
            default = "example_aspect",
        ),
    ),
    toolchains = ["@rules_proto_grpc//protobuf:toolchain_type"],
)

# Create compile rule to apply aspect
_rule = rule(
    implementation = proto_compile_impl,
    attrs = dict(
        proto_compile_attrs,
        protos = attr.label_list(
            mandatory = False,  # TODO: set to true in 4.0.0 when deps removed below
            providers = [ProtoInfo],
            doc = "List of labels that provide the ProtoInfo provider (such as proto_library from rules_proto)",
        ),
        deps = attr.label_list(
            mandatory = False,
            providers = [ProtoInfo, ProtoLibraryAspectNodeInfo],
            aspects = [example_aspect],
            doc = "DEPRECATED: Use protos attr",
        ),
        _plugins = attr.label_list(
            providers = [ProtoPluginInfo],
            default = [
                Label(TS_PLUGIN),
            ],
            doc = "List of protoc plugins to apply",
        ),
        out = attr.output(),
    ),
    toolchains = [str(Label("@rules_proto_grpc//protobuf:toolchain_type"))],
)

# Create macro for converting attrs and passing to compile
def protobuf_ts_proto(**kwargs):
    _rule(
        verbose_string = "{}".format(kwargs.get("verbose", 0)),
        **kwargs
    )

def _extract_ts_source_impl(ctx):
    pci = ctx.attr.ts_proto[ProtoCompileInfo]

    outputs = []

    for d, fs in pci.output_files.items():
        command = ""
        for f in fs.to_list():
            output = ctx.actions.declare_file(f.short_path)
            command = "cp %s %s" % (f.path, output.path)
            ctx.actions.run_shell(
                outputs = [output],
                inputs = fs,
                command = command,
            )
            outputs.append(output)
    return [DefaultInfo(
        files = depset(outputs),
    )]

extract_ts_source = rule(
    implementation = _extract_ts_source_impl,
    attrs = dict(
        ts_proto = attr.label(
            mandatory = True,
            providers = [ProtoCompileInfo],
        ),
    ),
)

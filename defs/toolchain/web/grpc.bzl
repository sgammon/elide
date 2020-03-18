##
# Copyright © 2020, The Gust Framework Authors. All rights reserved.
#
# The Gust/Elide framework and tools, and all associated source or object computer code, except where otherwise noted,
# are licensed under the Zero Prosperity license, which is enclosed in this repository, in the file LICENSE.txt. Use of
# this code in object or source form requires and implies consent and agreement to that license in principle and
# practice. Source or object code not listing this header, or unless specified otherwise, remain the property of
# Elide LLC and its suppliers, if any. The intellectual and technical concepts contained herein are proprietary to
# Elide LLC and its suppliers and may be covered by U.S. and Foreign Patents, or patents in process, and are protected
# by trade secret and copyright law. Dissemination of this information, or reproduction of this material, in any form,
# is strictly forbidden except in adherence with assigned license requirements.
##

#
# Code in this file was temporarily inlined from `grpc-web`, in order to facilitate workarounds for the bug filed at
# https://github.com/grpc/grpc-web/issues/575.
#

load(
    "//defs/toolchain/proto:closure_proto_library.bzl",
    "INJECTED_PROTO_ROOTS",
    "closure_proto_aspect",
)
load(
    "@io_bazel_rules_closure//closure/private:defs.bzl",
    "CLOSURE_JS_TOOLCHAIN_ATTRS",
    "unfurl",
)
load(
    "@io_bazel_rules_closure//closure/compiler:closure_js_library.bzl",
    "create_closure_js_library",
)

def _generate_closure_grpc_web_src_progress_message(name):
    # TODO(yannic): Add a better message?
    return "Generating gRPC web bindings %s" % name

def _generate_closure_grpc_web_srcs(
        actions,
        protoc,
        protoc_gen_grpc_web,
        import_style,
        mode,
        sources,
        transitive_sources,
        source_roots):
    all_sources = [src for src in sources] + [src for src in transitive_sources.to_list()]
    proto_include_paths = [("-I%s" % (p)) for p in source_roots] + INJECTED_PROTO_ROOTS

    grpc_web_out_common_options = ",".join([
        "import_style={}".format(import_style),
        "mode={}".format(mode),
    ])

    files = []
    for src in sources:
        name = "{}.grpc.js".format(
            ".".join(src.path.split("/")[-1].split(".")[:-1]),
        )
        js = actions.declare_file(name)
        files.append(js)

        args = proto_include_paths + [
            "--plugin=protoc-gen-grpc-web={}".format(protoc_gen_grpc_web.path),
            "--grpc-web_out={options},out={out_file}:{path}".format(
                options = grpc_web_out_common_options,
                out_file = name,
                path = js.path[:js.path.rfind("/")],
            ),
            src.path,
        ]

        actions.run(
            tools = [protoc_gen_grpc_web],
            inputs = all_sources,
            outputs = [js],
            executable = protoc,
            arguments = args,
            progress_message =
                _generate_closure_grpc_web_src_progress_message(name),
        )

    return files

_error_multiple_deps = "".join([
    "'deps' attribute must contain exactly one label ",
    "(we didn't name it 'dep' for consistency). ",
    "We may revisit this restriction later.",
])

def _closure_grpc_web_library_impl(ctx):
    if len(ctx.attr.deps) > 1:
        # TODO(yannic): Revisit this restriction.
        fail(_error_multiple_deps, "deps")

    dep = ctx.attr.deps[0]

    srcs = _generate_closure_grpc_web_srcs(
        actions = ctx.actions,
        protoc = ctx.executable._protoc,
        protoc_gen_grpc_web = ctx.executable._protoc_gen_grpc_web,
        import_style = ctx.attr.import_style,
        mode = ctx.attr.mode,
        sources = dep[ProtoInfo].direct_sources,
        transitive_sources = dep[ProtoInfo].transitive_imports,
        source_roots = dep[ProtoInfo].transitive_proto_path.to_list(),
    )

    deps = unfurl(ctx.attr.deps, provider = "closure_js_library")
    deps += [
        ctx.attr._grpc_web_abstractclientbase,
        ctx.attr._grpc_web_clientreadablestream,
        ctx.attr._grpc_web_error,
        ctx.attr._grpc_web_grpcwebclientbase,
    ]

    suppress = [
        "misplacedTypeAnnotation",
        "unusedPrivateMembers",
        "reportUnknownTypes",
        "strictDependencies",
        "extraRequire",
    ]

    library = create_closure_js_library(
        ctx = ctx,
        srcs = srcs,
        deps = deps,
        suppress = suppress,
        lenient = False,
    )
    return struct(
        exports = library.exports,
        closure_js_library = library.closure_js_library,
        # The usual suspects are exported as runfiles, in addition to raw source.
        runfiles = ctx.runfiles(files = srcs),
    )

closure_grpc_web_library = rule(
    implementation = _closure_grpc_web_library_impl,
    attrs = dict({
        "deps": attr.label_list(
            mandatory = True,
            providers = [ProtoInfo, "closure_js_library"],
            # The files generated by this aspect are required dependencies.
            aspects = [closure_proto_aspect],
        ),
        "import_style": attr.string(
            default = "closure",
            values = ["closure"],
        ),
        "mode": attr.string(
            default = "grpcwebtext",
            values = ["grpcwebtext", "grpcweb"],
        ),

        # internal only
        # TODO(yannic): Convert to toolchain.
        "_protoc": attr.label(
            default = Label("@com_google_protobuf//:protoc"),
            executable = True,
            cfg = "host",
        ),
        "_protoc_gen_grpc_web": attr.label(
            default = Label("@com_github_grpc_grpc_web//javascript/net/grpc/web:protoc-gen-grpc-web"),
            executable = True,
            cfg = "host",
        ),
        "_grpc_web_abstractclientbase": attr.label(
            default = Label("@com_github_grpc_grpc_web//javascript/net/grpc/web:abstractclientbase"),
        ),
        "_grpc_web_clientreadablestream": attr.label(
            default = Label("@com_github_grpc_grpc_web//javascript/net/grpc/web:clientreadablestream"),
        ),
        "_grpc_web_error": attr.label(
            default = Label("@com_github_grpc_grpc_web//javascript/net/grpc/web:error"),
        ),
        "_grpc_web_grpcwebclientbase": attr.label(
            default = Label("@com_github_grpc_grpc_web//javascript/net/grpc/web:grpcwebclientbase"),
        ),
    }, **CLOSURE_JS_TOOLCHAIN_ATTRS),
)
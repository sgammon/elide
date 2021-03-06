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

load(
    "//defs/toolchain/java:rules.bzl",
    _jdk_binary = "jdk_binary",
    _jdk_library = "jdk_library",
    _micronaut_library = "micronaut_library",
    _micronaut_service = "micronaut_service",
    _micronaut_controller = "micronaut_controller",
    _micronaut_application = "micronaut_application",
    _micronaut_interceptor = "micronaut_interceptor",
    _micronaut_native_configset = "micronaut_native_configset",
)

load(
    "//defs/toolchain/java:testing.bzl",
    _jdk_test = "jdk_test",
    _micronaut_test = "micronaut_test",
)

load(
    "//defs/toolchain/python:rules.bzl",
    _py_binary = "py_binary",
    _py_library = "py_library",
    _werkzeug_library = "werkzeug_library",
    _werkzeug_application = "werkzeug_application",
)

load(
    "//defs/toolchain/python:testing.bzl",
    _py_test = "py_test",
    _werkzeug_test = "werkzeug_test",
)

load(
    "//defs/toolchain/node:rules.bzl",
    _feathers_app = "feathers_app",
    _feathers_library = "feathers_library",
)


jdk_test = _jdk_test
jdk_binary = _jdk_binary
jdk_library = _jdk_library
micronaut_test = _micronaut_test
micronaut_library = _micronaut_library
micronaut_service = _micronaut_service
micronaut_controller = _micronaut_controller
micronaut_application = _micronaut_application
micronaut_interceptor = _micronaut_interceptor
micronaut_native_configset = _micronaut_native_configset

py_test = _py_test
py_binary = _py_binary
py_library = _py_library
werkzeug_test = _werkzeug_test
werkzeug_library = _werkzeug_library
werkzeug_application = _werkzeug_application

feathers_app = _feathers_app
feathers_library = _feathers_library
feathers_controller = _feathers_library

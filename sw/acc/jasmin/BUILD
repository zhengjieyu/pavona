# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//rules:acc.bzl", "acc_library", "acc_sim_test")
load("//rules:jasmin.bzl", "jasmin_library")

package(default_visibility = ["//visibility:public"])

jasmin_library(
    name = "mul256",
    src = "mul256.jazz",
    includes = ["mul256.jinc"],
    tags = ["manual"],
)

acc_sim_test(
    name = "mul256_test",
    srcs = ["mul256_test.s"],
    exp = "mul256_test.exp",
    tags = ["manual"],
    deps = [":mul256"],
)

# mod_mul_256x256 of P-256 in Jasmin, called from the unmodified P-256 code.
#
# Build with --//sw/acc/jasmin:enable_p256_mod_mul to make //sw/acc/crypto:p256_base,
# and so run_p256 and the cryptolib, use it.

bool_flag(
    name = "enable_p256_mod_mul",
    build_setting_default = False,
)

config_setting(
    name = "p256_mod_mul_enabled",
    flag_values = {":enable_p256_mod_mul": "true"},
)

jasmin_library(
    name = "p256_mod_mul",
    src = "p256_mod_mul.jazz",
    includes = ["mul256.jinc"],
    tags = ["manual"],
)

# The shim spills exactly w0 to w8, so fail if the Jasmin code uses more.
sh_test(
    name = "p256_mod_mul_regs_test",
    srcs = ["check_wdrs.sh"],
    args = [
        "$(location :p256_mod_mul_asm)",
        "8",
    ],
    data = [":p256_mod_mul_asm"],
    tags = ["manual"],
)

# p256_base without its own mod_mul_256x256, which the shim provides instead.
acc_library(
    name = "p256_base_jasmin",
    srcs = ["//sw/acc/crypto:p256_base.s"],
    copts = ["-DP256_JASMIN_MOD_MUL"],
    tags = ["manual"],
)

acc_library(
    name = "p256_mod_mul_shim",
    srcs = ["p256_mod_mul_shim.s"],
    tags = ["manual"],
)

# Drop-in replacement for //sw/acc/crypto:p256_base_asm.
filegroup(
    name = "p256_base_with_jasmin",
    srcs = [
        ":p256_base_jasmin",
        ":p256_mod_mul",
        ":p256_mod_mul_shim",
    ],
    tags = ["manual"],
)

# The ECDSA tests of //sw/acc/crypto/tests on the Jasmin version, without
# needing the flag.

acc_sim_test(
    name = "p256_ecdsa_sign_test",
    srcs = ["//sw/acc/crypto/tests:p256_ecdsa_sign_test.s"],
    exp = "//sw/acc/crypto/tests:p256_ecdsa_sign_test.exp",
    tags = ["manual"],
    deps = [
        ":p256_base_with_jasmin",
        "//sw/acc/crypto:p256_isoncurve",
        "//sw/acc/crypto:p256_sign",
        "//sw/acc/crypto:trigger_fault_if_fg0_z",
        "//sw/acc/crypto:trigger_fault_if_not_fg0_z",
    ],
)

acc_sim_test(
    name = "p256_ecdsa_verify_test",
    srcs = ["//sw/acc/crypto/tests:p256_ecdsa_verify_test.s"],
    exp = "//sw/acc/crypto/tests:p256_ecdsa_verify_test.exp",
    tags = ["manual"],
    deps = [
        ":p256_base_with_jasmin",
        "//sw/acc/crypto:p256_isoncurve",
        "//sw/acc/crypto:p256_verify",
        "//sw/acc/crypto:trigger_fault_if_fg0_z",
        "//sw/acc/crypto:trigger_fault_if_not_fg0_z",
    ],
)

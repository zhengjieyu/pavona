/* Copyright zeroRISC Inc. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Glue between the register convention of p256_base.s and the Jasmin calling
   convention, so that the existing P-256 code can call the Jasmin
   p256_mod_mul_256x256_jazz. Assemble p256_base.s with -DP256_JASMIN_MOD_MUL
   to drop its own mod_mul_256x256. */

.section .text

/**
 * 256-bit modular multiplication for P-256 coordinate and scalar fields.
 *
 * Same interface as mod_mul_256x256 in p256_base.s, except that x2 and x3 are
 * also clobbered. All P-256 callers reload x2 and x3 before using them.
 *
 * The Jasmin code takes its arguments in w0 to w3, returns in w0 and
 * clobbers w0 to w8, which callers expect to be preserved. Those are spilled
 * to DMEM around the call.
 *
 * @param[in]  w24: a, first 256 bit operand (a * b < 2^256 * m)
 * @param[in]  w25: b, second 256 bit operand (a * b < 2^256 * m)
 * @param[in]  w29: m, modulus, curve order n or finite field modulus p
 * @param[in]  w28: u, lower 256 bit of Barrett constant for m
 * @param[in]  MOD: m
 * @param[out]  w19: c, result
 *
 * clobbered registers: x2 to x3, w19 to w25, acc
 * clobbered flag groups: FG0
 */
.globl mod_mul_256x256
.type mod_mul_256x256, @function
mod_mul_256x256:
  /* dmem[mod_mul_jazz_spill] <= w0 to w8 */
  la        x3, mod_mul_jazz_spill
  li        x2, 0
  bn.sid    x2++, 0(x3)
  bn.sid    x2++, 32(x3)
  bn.sid    x2++, 64(x3)
  bn.sid    x2++, 96(x3)
  bn.sid    x2++, 128(x3)
  bn.sid    x2++, 160(x3)
  bn.sid    x2++, 192(x3)
  bn.sid    x2++, 224(x3)
  bn.sid    x2++, 256(x3)

  /* w0 <= a * b mod m */
  bn.mov    w0, w24
  bn.mov    w1, w25
  bn.mov    w2, w29
  bn.mov    w3, w28
  jal       x1, p256_mod_mul_256x256_jazz
  bn.mov    w19, w0

  /* w0 to w8 <= dmem[mod_mul_jazz_spill] */
  la        x3, mod_mul_jazz_spill
  li        x2, 0
  bn.lid    x2++, 0(x3)
  bn.lid    x2++, 32(x3)
  bn.lid    x2++, 64(x3)
  bn.lid    x2++, 96(x3)
  bn.lid    x2++, 128(x3)
  bn.lid    x2++, 160(x3)
  bn.lid    x2++, 192(x3)
  bn.lid    x2++, 224(x3)
  bn.lid    x2++, 256(x3)

  ret

.section .bss

/* Spill area for w0 to w8. */
.balign 32
mod_mul_jazz_spill:
  .zero 288

(**
 * Copyright (c) 2017, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
*)

let is_method_interceptable ~is_generated namespace ast_class original_id =
  let open Hhbc_options in
  let difs = dynamic_invoke_functions !compiler_options in
  not is_generated &&
    (jit_enable_rename_function !compiler_options ||
       (not (SSet.is_empty difs) &&
          let class_id, _ = Hhbc_id.Class.elaborate_id namespace ast_class.Ast.c_name in
          let class_name = Hhbc_id.Class.to_unmangled_string class_id in
          let method_name = Hhbc_id.Method.to_raw_string original_id in
          let name = String.lowercase_ascii (class_name ^ "::" ^ method_name) in
          SSet.mem name difs))

let is_function_interceptable ~is_generated namespace ast_fun =
  let open Hhbc_options in
  let difs = dynamic_invoke_functions !compiler_options in
  not is_generated &&
    ((not (repo_authoritative !compiler_options) &&
        (jit_enable_rename_function !compiler_options)) ||
        (not (SSet.is_empty difs) &&
           let fq_id, _ =
             Hhbc_id.Function.elaborate_id_with_builtins namespace ast_fun.Ast.f_name in
           let name = String.lowercase_ascii (Hhbc_id.Function.to_raw_string fq_id) in
           SSet.mem name difs))

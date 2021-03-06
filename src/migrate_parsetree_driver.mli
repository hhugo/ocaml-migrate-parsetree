open Migrate_parsetree_versions

(** {1 State a rewriter can access} *)

type extra = ..

type config = {
  tool_name       : string;
  include_dirs    : string list;
  load_path       : string list;
  debug           : bool;
  for_package     : string option;
  (** Additional parameters that can be passed by a caller of
      [rewrite_{signature,strucutre}] to a specific register rewriter. *)
  extras          : extra list;
}

val make_config
  :  tool_name:string
  -> ?include_dirs:string list
  -> ?load_path:string list
  -> ?debug:bool
  -> ?for_package:string
  -> ?extras:extra list
  -> unit
  -> config

type cookies

val get_cookie
  : cookies
  -> string
  -> 'types ocaml_version -> 'types get_expression option

val set_cookie
  : cookies
  -> string
  -> 'types ocaml_version -> 'types get_expression
  -> unit

(** {1 Registering rewriters} *)

type 'types rewriter = config -> cookies -> 'types get_mapper

val register
  :  name:string
  -> ?reset_args:(unit -> unit) -> ?args:(Arg.key * Arg.spec * Arg.doc) list
  -> 'types ocaml_version -> 'types rewriter
  -> unit

(** {1 Running registered rewriters} *)

val run_as_ast_mapper : string list -> Ast_mapper.mapper

val run_as_ppx_rewriter : unit -> 'a

val run_main : unit -> 'a

(** {1 Manual mapping} *)

type some_signature =
  | Sig : (module Migrate_parsetree_versions.OCaml_version with
            type Ast.Parsetree.signature = 'concrete) * 'concrete -> some_signature

type some_structure =
  | Str : (module Migrate_parsetree_versions.OCaml_version with
            type Ast.Parsetree.structure = 'concrete) * 'concrete -> some_structure

val migrate_some_signature
  :  'version ocaml_version
  -> some_signature
  -> 'version get_signature

val migrate_some_structure
  :  'version ocaml_version
  -> some_structure
  -> 'version get_structure

val rewrite_signature
  :  config
  -> 'version ocaml_version
  -> 'version get_signature
  -> some_signature

val rewrite_structure
  :  config
  -> 'version ocaml_version
  -> 'version get_structure
  -> some_structure


open Parsetree

type t =
  { name : string ;
    priority : int ;
    matcher : (core_type * core_type) -> (core_type * core_type) list option ;
    builder : expression list -> expression }

let make ~name ?(priority=0) ~matcher ~builder () =
  { name ; priority ; matcher ; builder }

let name_ rule = rule.name
let match_ rule = rule.matcher
let build_ rule = rule.builder

module IMap = Map.Make(struct type t = int let compare = compare end)
let rules : t list IMap.t ref = ref IMap.empty

let register rule =
  rules :=
    IMap.update
      rule.priority
      (function
       | None -> Some [rule]
       | Some rules -> Some (rule :: rules))
      !rules

let fold f =
  IMap.fold
    (fun _ rules x ->
      List.fold_left
        (fun x rule ->
          f rule x)
        x
        rules)
    !rules

let fold_by_priority f =
  IMap.fold
    (fun _ rules x ->
      f rules x)
    !rules

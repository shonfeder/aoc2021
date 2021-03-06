open Containers

module type Domain = sig
  type t

  val of_string : string -> t

  val count_fish : t -> int

  (* Pass time by one unit (day) *)
  val tick : t -> unit
end

module Solver (D : Domain) = struct
  let solve : string Array.t -> string Zlist.t -> int =
   fun params lines ->
    let days =
      params.(1)
      |> Int.of_string
      |> Option.get_exn_or "Invalid days: expected int"
    in
    let st = Zlist.head lines |> Option.get_exn_or "empty file" |> D.of_string in
    let () =
      for _ = 1 to days do
        D.tick st
      done
    in
    D.count_fish st
end

module D : Domain = struct
  type t = int Array.t

  let of_string s =
    let st = Array.make 9 0 in
    let () =
      s
      |> String.split_on_char ','
      |> List.iter (fun nstr ->
             let n = Int.of_string_exn nstr in
             st.(n) <- succ st.(n))
    in
    st

  let count_fish st = Array.fold_left ( + ) 0 st

  let tick st =
    let expired_counters = st.(0) in
    Array.iteri (fun i counter -> if i <> 0 then st.(i - 1) <- counter) st;
    st.(8) <- expired_counters;
    st.(6) <- st.(6) + expired_counters
end

include Solver (D)

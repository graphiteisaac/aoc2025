(* Read a whole file in as a string *)
let read_file filename =
  let ic = open_in filename in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic;
  s

(* Read file as list of lines *)
let read_lines filename =
  let ic = open_in filename in
  let rec read_all acc =
    try
      let line = input_line ic in
      read_all (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_all []

(* Split string by character *)
let split_on_char c s = String.split_on_char c s

(* Convert string to int list *)
let ints_of_string s = List.filter_map int_of_string_opt (split_on_char ' ' s)

(* Parse every int in a string, seperated by a space. *)
let parse_ints s =
  s |> String.split_on_char ' '
  |> List.filter (fun x -> String.trim x <> "")
  |> List.filter_map int_of_string_opt

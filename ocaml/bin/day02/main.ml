type product_range = {
  left : string;
  left_len : int;
  right : string;
  right_len : int;
}

let parse input =
  String.split_on_char ',' input
  |> List.map (fun item ->
         match String.split_on_char '-' item with
         | [ left; right ] ->
             {
               left = String.trim left;
               left_len = String.length left;
               right = String.trim right;
               right_len = String.length right;
             }
         | _ -> { left = ""; left_len = 0; right = ""; right_len = 0 })

(* OCaml is coool. Range iterators without allocating a list? Wow *)
let iter_range a b f =
  let rec loop i =
    if i > b then
      ()
    else (
      f i;
      loop (i + 1))
  in
  loop a

let is_num_mirrored n =
  let str = string_of_int n in
  let len = String.length str in
  if len mod 2 <> 0 then
    false
  else
    let half = len / 2 in
    let left = String.sub str 0 half in
    let right = String.sub str half half in
    left = right

let solve_part1 (input : product_range list) =
  let rec loop acc = function
    | [] -> acc
    | range :: rest ->
        (* Skip odd and equal left/right range pairs, they are impossible. *)
        if range.left_len mod 2 = 1 && range.left_len = range.right_len then
          loop acc rest
        else
          let start_ = int_of_string range.left in
          let end_ = int_of_string range.right in
          let new_acc = ref acc in

          iter_range start_ end_ (fun item ->
              if is_num_mirrored item then
                new_acc := !new_acc + item);
          loop !new_acc rest
  in
  loop 0 input

let solve_part2 _input = 0

let () =
  let input = Helpers.read_file "../gleam/input/2025/2.txt" |> parse in
  Printf.printf "Part 1: %d\n" (solve_part1 input);
  Printf.printf "Part 2: %d\n" (solve_part2 input)

let part_one input =
  print_endline input;
  0

let part_two _input = 0
let parse input = input

let () =
  let input = Helpers.read_file "../gleam/inputs/2025/01.txt" |> parse in
  Printf.printf "Part 1: %d\n" (part_one input);
  Printf.printf "Part 2: %d\n" (part_two input)

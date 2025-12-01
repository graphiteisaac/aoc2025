let file = "../gleam/input/2025/1.txt"

type rotation =
  | Left of int
  | Right of int

let part_one (input : rotation list) =
  let rec loop (count, current) = function
    | [] -> count
    | rotation :: rest ->
        let new_rotation =
          match rotation with
          | Left degrees ->
              let n = current - degrees in
              if n < 0 then
                (abs n / 100 * 100) + n
              else
                n
          | Right degrees -> (current + degrees) mod 100
        in
        let new_accum =
          if new_rotation = 0 then
            (count + 1, new_rotation)
          else
            (count, new_rotation)
        in
        loop new_accum rest
  in
  loop (0, 50) input

let part_two _input = 0

let parse input =
  List.map
    (fun value ->
      let dir = value.[0] in
      let num = int_of_string (String.sub value 1 (String.length value - 1)) in

      match dir with
      | 'R' -> Right num
      | 'L' -> Left num
      | _ -> Left 0)
    input

let () =
  let input = Helpers.read_lines file |> parse in
  Printf.printf "Part 1: %d\n" (part_one input);
  Printf.printf "Part 2: %d\n" (part_two input)

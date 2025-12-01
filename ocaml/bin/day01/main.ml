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

let part_two (input : rotation list) =
  let rec loop (count, current) = function
    | [] -> count
    | rotation :: rest -> (
        match rotation with
        | Left degrees ->
            let updated = current - degrees in
            let new_position = updated mod 100 in
            let num_zeroes =
              let updated_f = float updated /. 100.0 in
              match current with
              | 0 -> int_of_float (ceil updated_f) |> ( ~- )
              | _ -> int_of_float (floor updated_f) |> ( ~- )
            in
            let next_count, next_pos =
              if new_position > 0 then
                (count + num_zeroes, new_position)
              else if new_position = 0 then
                (count + num_zeroes + 1, new_position)
              else
                (count + num_zeroes, 100 + new_position)
            in
            loop (next_count, next_pos) rest
        | Right degrees ->
            let updated = current + degrees in
            let num_zeroes =
              let updated_f = float updated /. 100.0 in
              int_of_float (floor updated_f)
            in

            let next_count = count + num_zeroes in
            let next_pos = updated mod 100 in
            loop (next_count, next_pos) rest)
  in
  loop (0, 50) input

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

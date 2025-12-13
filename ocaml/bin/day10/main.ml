open Stdlib
module IntMap = Map.Make (Int)
module IntSet = Set.Make (Int)

type machine = {
  light_diagram : int;
  buttons : int list list;
  joltages : int list;
}

type state = {
  lights : int;
  presses : int;
}

let parse input =
  let lines =
    String.split_on_char '\n' input
    |> List.filter (fun s -> String.length s > 0)
  in
  List.map
    (fun line ->
      let fields = String.split_on_char ' ' line in
      match fields with
      | light_diagram :: rest -> (
          let light_diagram =
            String.sub light_diagram 1 (String.length light_diagram - 2)
            |> String.to_seq
            |> Seq.fold_left
                 (fun (acc, i) c ->
                   match c with
                   | '.' -> (acc, i + 1)
                   | '#' -> (acc lor (1 lsl i), i + 1)
                   | _ -> (acc, i + 1))
                 (0, 0)
            |> fst
          in

          let parse_field f =
            String.sub f 1 (String.length f - 2)
            |> String.split_on_char ',' |> List.map int_of_string
          in

          let rev_rest = List.rev rest in
          match rev_rest with
          | joltages :: buttons_rev ->
              let joltages = parse_field joltages in
              let buttons = List.rev buttons_rev |> List.map parse_field in
              { light_diagram; buttons; joltages }
          | _ -> failwith "Expected at least 2 fields")
      | _ -> failwith "Expected at least two fields")
    lines

let rec add_ones n acc =
  if n = 0 then
    acc
  else
    add_ones (n land (n - 1)) (acc + 1)

let rec min_presses joltages joltage_drop_map joltage_parity_map =
  if List.for_all (fun x -> x = 0) joltages then
    Ok 0
  else if List.exists (fun x -> x < 0) joltages then
    Error ()
  else
    let parity =
      List.fold_left (fun acc x -> (2 * acc) + (x mod 2)) 0 joltages
    in
    match IntMap.find_opt parity joltage_parity_map with
    | None -> Error ()
    | Some button_combinations ->
        List.fold_left
          (fun min_acc button_combinations ->
            match IntMap.find_opt button_combinations joltage_drop_map with
            | None -> failwith "Invalid combination"
            | Some joltage_drops -> (
                let new_joltages =
                  List.map2 (fun j d -> (j - d) / 2) joltages joltage_drops
                in
                match
                  min_presses new_joltages joltage_drop_map joltage_parity_map
                with
                | Ok new_min -> (
                    let new_min = add_ones button_combinations (2 * new_min) in
                    match min_acc with
                    | Ok cur_min when cur_min < new_min -> min_acc
                    | _ -> Ok new_min)
                | Error () -> min_acc))
          (Error ()) button_combinations

let rec breadth_search current_level visited buttons target =
  match current_level with
  | [] -> 0
  | state :: rest ->
      if state.lights = target then
        state.presses
      else
        let next_states, new_visited =
          List.fold_left
            (fun (states, v) button ->
              let new_lights = state.lights lxor button in
              if IntSet.mem new_lights v then
                (states, v)
              else
                let new_state =
                  { lights = new_lights; presses = state.presses + 1 }
                in
                (states @ [ new_state ], IntSet.add new_lights v))
            ([], visited) buttons
        in
        breadth_search (rest @ next_states) new_visited buttons target

let solve_schematic schematic =
  let buttons =
    List.map
      (fun button -> List.fold_left (fun acc i -> acc lor (1 lsl i)) 0 button)
      schematic.buttons
  in
  breadth_search
    [ { lights = 0; presses = 0 } ]
    (IntSet.singleton 0) buttons schematic.light_diagram

let solve_part1 machines =
  List.fold_left
    (fun acc schematic -> acc + solve_schematic schematic)
    0 machines

let solve_part2 machines =
  List.map
    (fun m ->
      let num_buttons = List.length m.buttons in
      let joltage_drop_map, joltage_parity_map =
        List.init (1 lsl num_buttons) (fun i -> i)
        |> List.fold_left
             (fun (jdm, jpm) button_combination ->
               let joltage_drops =
                 List.mapi
                   (fun i _ ->
                     List.fold_left
                       (fun (acc, j) b ->
                         let count =
                           if
                             (1 lsl j) land button_combination <> 0
                             && List.mem i b
                           then
                             acc + 1
                           else
                             acc
                         in
                         (count, j + 1))
                       (0, 0) m.buttons
                     |> fst)
                   m.joltages
               in
               let parity =
                 List.fold_left
                   (fun acc i -> (2 * acc) + (i mod 2))
                   0 joltage_drops
               in
               let jdm' = IntMap.add button_combination joltage_drops jdm in
               let jpm' =
                 IntMap.update parity
                   (function
                     | None -> Some [ button_combination ]
                     | Some bcs -> Some (button_combination :: bcs))
                   jpm
               in
               (jdm', jpm'))
             (IntMap.empty, IntMap.empty)
      in
      match min_presses m.joltages joltage_drop_map joltage_parity_map with
      | Ok min -> min
      | Error () -> failwith "No solution found for machine")
    machines
  |> List.fold_left ( + ) 0

let () =
  let input = Helpers.read_file "../gleam/input/2025/10.txt" |> parse in
  Printf.printf "Part 1: %d\n" (solve_part1 input);
  Printf.printf "Part 2: %d\n" (solve_part2 input)

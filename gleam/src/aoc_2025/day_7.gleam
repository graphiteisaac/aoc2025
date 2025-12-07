import gleam/bool
import gleam/list
import gleam/set
import gleam/string

pub fn parse(input: String) -> #(Int, set.Set(#(Int, Int))) {
  let assert [first_line, ..lines] = string.split(input, "\n")
  let start_position = string.length(first_line) / 2

  let splitter_positions =
    list.index_fold(lines, set.new(), fn(accum, line, y) {
      list.index_fold(
        string.to_graphemes(line),
        accum,
        fn(inner_accum, char, x) {
          case char {
            "^" -> set.insert(inner_accum, #(y, x))
            _ -> inner_accum
          }
        },
      )
      |> set.union(accum)
    })
  #(start_position, splitter_positions)
}

fn split_beams(
  beams: set.Set(#(Int, Int)),
  board: set.Set(#(Int, Int)),
  accum: Int,
) -> Int {
  use <- bool.guard(set.size(board) == 0, accum)

  let #(new_beams, to_remove, split_count) =
    set.fold(beams, #(set.new(), 0, 0), fn(acc, beam) {
      let #(y, x) = beam
      case set.contains(board, #(y + 1, x)) {
        True -> {
          #(
            acc.0
              |> set.insert(#(y + 1, x - 1))
              |> set.insert(#(y + 1, x + 1)),
            y + 1,
            acc.2 + 1,
          )
        }
        False -> #(set.insert(acc.0, #(y + 1, x)), acc.1, acc.2)
      }
    })
  let to_remove =
    set.filter(board, fn(i) { i.0 == to_remove })
    |> set.to_list
  let new_board = set.drop(board, to_remove)
  split_beams(new_beams, new_board, accum + split_count)
}

pub fn pt_1(input: #(Int, set.Set(#(Int, Int)))) {
  let #(starting_position, board) = input

  let beams = set.from_list([#(0, starting_position)])

  split_beams(beams, board, 0)
}

pub fn pt_2(input: #(Int, set.Set(#(Int, Int)))) {
  todo as "part 2 not implemented"
}

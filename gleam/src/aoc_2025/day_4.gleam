import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> Set(#(Int, Int)) {
  let rows = string.split(input, "\n")
  use accum, row, y <- list.index_fold(rows, set.new())
  use accum, char, x <- list.index_fold(string.to_graphemes(row), accum)

  case char {
    "@" -> set.insert(accum, #(y, x))
    _ -> accum
  }
}

fn adjacent(coord: #(Int, Int)) {
  let #(y, x) = coord

  [
    #(y - 1, x - 1),
    #(y - 1, x),
    #(y - 1, x + 1),
    #(y, x - 1),
    #(y, x + 1),
    #(y + 1, x - 1),
    #(y + 1, x),
    #(y + 1, x + 1),
  ]
}

fn is_available(map: Set(#(Int, Int)), coordinate: #(Int, Int)) -> Bool {
  let check_spots = adjacent(coordinate)

  list.fold(check_spots, 0, fn(accum, coord) {
    case set.contains(map, coord) {
      True -> accum + 1
      False -> accum
    }
  })
  < 4
}

pub fn pt_1(input: Set(#(Int, Int))) {
  input
  |> set.fold(0, fn(accum, coordinate) {
    case is_available(input, coordinate) {
      True -> accum + 1
      False -> accum
    }
  })
}

fn repeated_remove(input: #(Set(#(Int, Int)), Int), coordinate: #(Int, Int)) {
  let #(grid, remove_count) = input
  case set.contains(grid, coordinate) && is_available(grid, coordinate) {
    True ->
      list.fold(
        adjacent(coordinate),
        #(set.delete(grid, coordinate), remove_count + 1),
        repeated_remove,
      )
    False -> input
  }
}

pub fn pt_2(input: Set(#(Int, Int))) {
  let removal_count = 0
  set.fold(input, #(input, removal_count), repeated_remove).1
}

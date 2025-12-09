import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(position) {
    let assert [x, y] =
      string.split(position, ",") |> list.filter_map(int.parse)
    #(x, y)
  })
}

pub type Area {
  Area(corner_1: #(Int, Int), corner_2: #(Int, Int), area: Int)
}

fn calculate_area(pair: #(#(Int, Int), #(Int, Int))) -> Int {
  let #(#(x1, y1), #(x2, y2)) = pair

  { int.absolute_value(x2 - x1) + 1 } * { int.absolute_value(y2 - y1) + 1 }
}

pub fn pt_1(input: List(#(Int, Int))) {
  input
  |> list.combination_pairs
  |> list.map(calculate_area)
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.first
  |> result.unwrap(0)
}

pub fn pt_2(input: List(#(Int, Int))) {
  input
  |> list.combination_pairs
  |> list.map(calculate_area)
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.first
  |> result.unwrap(0)
}

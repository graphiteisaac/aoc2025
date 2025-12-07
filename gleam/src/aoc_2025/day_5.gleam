import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type FreshnessRange {
  FreshnessRange(start: Int, end: Int)
}

pub fn parse(input: String) -> #(List(FreshnessRange), List(Int)) {
  let assert Ok(#(ranges, ingredients)) = string.split_once(input, "\n\n")
  let ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(item) {
      let assert Ok([start, end]) =
        string.split(item, "-") |> list.try_map(int.parse)
      FreshnessRange(start:, end:)
    })

  let ingredients =
    ingredients
    |> string.split("\n")
    |> list.try_map(int.parse)
    |> result.unwrap([])

  #(ranges, ingredients)
}

fn is_fresh(ranges: List(FreshnessRange), ingredient: Int) -> Bool {
  case ranges {
    [] -> False
    [FreshnessRange(start:, end:), ..]
      if ingredient >= start && ingredient <= end
    -> True
    [_, ..rest] -> is_fresh(rest, ingredient)
  }
}

pub fn pt_1(input: #(List(FreshnessRange), List(Int))) -> Int {
  let #(ranges, ingredients) = input

  ingredients
  |> list.fold(0, fn(accum, ingredient) {
    case is_fresh(ranges, ingredient) {
      True -> accum + 1
      False -> accum
    }
  })
}

pub fn pt_2(input: #(List(FreshnessRange), List(Int))) {
  todo as "part 2 not implemented"
}

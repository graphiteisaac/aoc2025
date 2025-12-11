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

fn minmax(a: Int, b: Int) -> #(Int, Int) {
  case a < b {
    True -> #(a, b)
    False -> #(b, a)
  }
}

pub fn pt_2(input: List(#(Int, Int))) {
  let segments = list.window_by_2(input)

  let #(h_segs, v_segs) =
    list.partition(segments, fn(seg) {
      let #(#(_, y1), #(_, y2)) = seg
      y1 == y2
    })

  input
  |> list.combination_pairs
  |> list.filter(fn(pair) {
    let #(#(x1, y1), #(x2, y2)) = pair
    let #(min_x, max_x) = minmax(x1, x2)
    let #(min_y, max_y) = minmax(y1, y2)

    let h_ok =
      !list.any(h_segs, fn(seg) {
        let #(#(sx1, sy), #(sx2, _)) = seg
        let seg_min_x = int.min(sx1, sx2)
        let seg_max_x = int.max(sx1, sx2)

        sy > min_y
        && sy < max_y
        && !{ seg_max_x <= min_x || seg_min_x >= max_x }
      })

    let v_ok =
      !list.any(v_segs, fn(seg) {
        let #(#(sx, sy1), #(_, sy2)) = seg
        let seg_min_y = int.min(sy1, sy2)
        let seg_max_y = int.max(sy1, sy2)

        sx > min_x
        && sx < max_x
        && !{ seg_max_y <= min_y || seg_min_y >= max_y }
      })

    h_ok && v_ok
  })
  |> list.map(calculate_area)
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.first
  |> result.unwrap(0)
}

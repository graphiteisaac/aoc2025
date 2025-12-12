import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Region {
  Region(width: Int, height: Int, presents: Dict(Int, Int))
}

pub type Problem =
  #(Dict(Int, Int), List(Region))

pub fn parse(input: String) -> Problem {
  let split =
    string.split(input, "\n\n")
    |> list.reverse

  let presents =
    split
    |> list.drop(1)
    |> list.reverse
    |> list.index_fold(dict.new(), fn(acc, present, i) {
      dict.insert(
        acc,
        i,
        list.count(string.split(present, ""), fn(x) { x == "#" }),
      )
    })

  let regions =
    split
    |> list.first
    |> result.unwrap("")
    |> string.split("\n")
    |> list.map(fn(region) {
      let assert Ok(#(dims, presents)) = string.split_once(region, ": ")
      let assert [width, height] =
        string.split(dims, "x") |> list.filter_map(int.parse)

      Region(
        width:,
        height:,
        presents: list.index_fold(
          string.split(presents, " "),
          dict.new(),
          fn(acc, count, idx) {
            let assert Ok(count) = int.parse(count)
            dict.insert(acc, idx, count)
          },
        ),
      )
    })

  #(presents, regions)
}

fn will_fit(region: Region, shapes: Dict(Int, Int)) {
  let filled_size =
    dict.fold(region.presents, 0, fn(acc, shape_id, quantity) {
      case dict.get(shapes, shape_id) {
        Ok(size) -> acc + size * quantity
        Error(_) -> acc
      }
    })

  region.width * region.height >= filled_size
}

pub fn pt_1(problem: Problem) {
  let #(present_shapes, regions) = problem

  regions
  |> list.filter(will_fit(_, present_shapes))
  |> list.length
}

pub fn pt_2(_: Problem) {
  // Congratulations :D
  1
}

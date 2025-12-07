import gleam/int
import gleam/list
import gleam/string

pub type Operation {
  Add
  Multiply
}

pub fn parse(input: String) -> #(List(Operation), List(String)) {
  let assert [operations, ..lines] = string.split(input, "\n") |> list.reverse
  let operations =
    operations
    |> string.split(" ")
    |> list.filter_map(fn(x) {
      case x {
        "+" -> Ok(Add)
        "*" -> Ok(Multiply)
        _ -> Error(Nil)
      }
    })

  #(operations, lines)
}

pub fn pt_1(input: #(List(Operation), List(String))) {
  let #(ops, lines) = input
  let sheets =
    lines
    |> list.map(fn(s) {
      string.split(s, " ")
      |> list.filter_map(int.parse)
    })
    |> list.transpose
    |> list.zip(ops)

  use acc, #(numbers, op) <- list.fold(sheets, 0)

  acc
  + case op {
    Add -> int.sum(numbers)
    Multiply -> int.product(numbers)
  }
}

fn accumulate_columns(
  items: List(List(String)),
  buffer: List(List(String)),
  acc: List(List(List(String))),
) -> List(List(List(String))) {
  case items, buffer {
    [], [] -> acc
    [], _ -> list.reverse([buffer, ..acc])
    [first, ..rest], _ ->
      case list.all(first, fn(char) { char == " " }), buffer {
        True, [] -> accumulate_columns(rest, [], acc)
        True, _ -> accumulate_columns(rest, [], [list.reverse(buffer), ..acc])
        False, _ ->
          accumulate_columns(rest, [list.reverse(first), ..buffer], acc)
      }
  }
}

pub fn pt_2(input: #(List(Operation), List(String))) {
  let #(ops, lines) = input
  let sheets =
    lines
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> accumulate_columns([], [])
    |> list.map(fn(x) {
      x
      |> list.filter_map(fn(b) {
        string.join(b, "")
        |> string.trim
        |> int.parse
      })
      |> list.reverse
    })
    |> list.zip(ops)

  use acc, #(numbers, op) <- list.fold(sheets, 0)

  acc
  + case op {
    Add -> int.sum(numbers)
    Multiply -> int.product(numbers)
  }
}

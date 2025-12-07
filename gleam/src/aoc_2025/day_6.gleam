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
      |> list.filter_map(fn(x) {
        case x {
          " " -> Error(Nil)
          n -> int.parse(n)
        }
      })
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

pub fn pt_2(input: #(List(Operation), List(String))) {
  todo as "part 2 not implemented"
}

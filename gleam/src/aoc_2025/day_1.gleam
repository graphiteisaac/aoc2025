import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Rotation {
  Left(degrees: Int)
  Right(degrees: Int)
}

pub fn parse(input: String) -> List(Rotation) {
  use item <- list.map(string.split(input, "\n"))
  case item {
    "L" <> deg -> Left(result.unwrap(int.parse(deg), 0))
    "R" <> deg -> Right(result.unwrap(int.parse(deg), 0))
    _ -> Left(0)
  }
}

pub fn pt_1(input: List(Rotation)) {
  list.fold(input, #(0, 50), fn(accum, rotation) {
    let new_rotation = case rotation {
      Left(degrees:) ->
        case accum.1 - degrees {
          n if n < 0 -> { { int.absolute_value(n) / 100 } * 100 } + n
          n -> n
        }

      Right(degrees:) -> { accum.1 + degrees } % 100
    }

    case new_rotation {
      0 -> #(accum.0 + 1, new_rotation)
      _ -> #(accum.0, new_rotation)
    }
  }).0
}

pub fn pt_2(input: List(Rotation)) {
  list.fold(input, #(0, 50), fn(accum, rotation) {
    let current_position = accum.1

    case rotation {
      Left(turns) -> {
        let updated = current_position - turns
        let new_position = updated % 100
        let num_zeroes =
          case current_position {
            0 -> float.ceiling(int.to_float(updated) /. 100.0)
            _ -> float.floor(int.to_float(updated) /. 100.0)
          }
          |> float.round
          |> int.negate

        case new_position {
          n if n > 0 -> #(accum.0 + num_zeroes, new_position)
          n if n == 0 -> #(accum.0 + num_zeroes + 1, new_position)
          _ -> #(accum.0 + num_zeroes, 100 + new_position)
        }
      }
      Right(turns) -> {
        let updated = turns + current_position
        let num_zeroes =
          float.floor(int.to_float(updated) /. 100.0)
          |> float.round

        #(accum.0 + num_zeroes, updated % 100)
      }
    }
  }).0
}

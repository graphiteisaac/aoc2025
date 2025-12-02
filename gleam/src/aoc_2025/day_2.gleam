import gleam/int
import gleam/list
import gleam/string

pub type ProductRange {
  ProductRange(start: Int, start_len: Int, end: Int, end_len: Int)
}

pub fn parse(input: String) -> List(ProductRange) {
  use item <- list.map(string.split(input, ","))
  let assert Ok(#(start, end)) = string.split_once(item, "-")
  let start_len = string.length(start)
  let end_len = string.length(end)
  let assert Ok(start) = int.parse(start)
  let assert Ok(end) = int.parse(end)

  ProductRange(start:, start_len:, end:, end_len:)
}

pub fn pt_1(input: List(ProductRange)) {
  do_pt1(input, 0)
}

fn do_pt1(input: List(ProductRange), sum: Int) {
  case input {
    [] -> sum
    [head, ..rest] -> {
      case head.start_len, head.end_len {
        // Skip this repetition as there cannot be duplicate numbers
        // if they are the same digit-length (nowhere in 111-999 is there an even number of digits)
        a, b if a % 2 == 1 && a == b -> do_pt1(rest, sum)

        _, _ -> {
          let new_sum =
            list.fold(list.range(head.start, head.end), sum, fn(accum, item) {
              let string_of = int.to_string(item)
              case string.length(string_of) {
                length if length % 2 == 0 -> {
                  case
                    string.drop_end(string_of, length / 2)
                    == string.drop_start(string_of, length / 2)
                  {
                    False -> accum
                    True -> accum + item
                  }
                }
                _ -> accum
              }
            })
          do_pt1(rest, new_sum)
        }
      }
    }
  }
}

pub fn pt_2(input: List(ProductRange)) {
  do_pt2(input, 0)
}

fn get_divisors(n: Int) -> List(Int) {
  // echo #(n, n / 2, list.range(1, n / 2))
  use digit <- list.filter(list.range(1, n / 2))
  n % digit == 0
}

fn is_invalid_repeating(num_string: String) -> Bool {
  let total_len = string.length(num_string)

  get_divisors(total_len)
  |> list.any(fn(pattern_len) {
    let pattern = string.slice(num_string, 0, pattern_len)
    let repetitions = total_len / pattern_len
    let repeated = string.repeat(pattern, repetitions)
    repeated == num_string
  })
}

fn do_pt2(input: List(ProductRange), sum: Int) {
  case input {
    [] -> sum
    [head, ..rest] -> {
      let new_sum =
        list.fold(list.range(head.start, head.end), sum, fn(accum, item) {
          let string_of = int.to_string(item)

          case is_invalid_repeating(string_of), string.length(string_of) {
            _, 1 -> accum
            True, _ -> accum + item
            False, _ -> accum
          }
        })

      do_pt2(rest, new_sum)
    }
  }
}

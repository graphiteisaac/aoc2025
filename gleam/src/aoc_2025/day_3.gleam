import gleam/int
import gleam/list
import gleam/string

pub type BatteryBank {
  BatteryBank(max_joltage: Int, batteries: List(Int))
}

pub fn parse(input: String) -> List(BatteryBank) {
  use str_bank <- list.map(string.split(input, "\n"))

  let graphemes = string.to_graphemes(str_bank)
  let digits = list.filter_map(graphemes, int.parse)
  BatteryBank(max_joltage: 0, batteries: digits)
}

pub fn pt_1(input: List(BatteryBank)) -> Int {
  list.map(input, fn(bank) {
    let len = list.length(bank.batteries)

    let #(max_left, max_left_index, all_digits) =
      list.index_fold(bank.batteries, #(-1, 0, []), fn(acc, digit, index) {
        let #(current_max, max_index, digits_accumulator) = acc

        let new_digits = [digit, ..digits_accumulator]
        case index < len - 1 && digit > current_max {
          True -> #(digit, index, new_digits)
          False -> #(current_max, max_index, new_digits)
        }
      })

    let remaining =
      all_digits
      |> list.reverse
      |> list.drop(max_left_index + 1)

    let max_right = list.fold(remaining, -1, int.max)
    BatteryBank(..bank, max_joltage: max_left * 10 + max_right)
  })
  |> list.fold(0, fn(acc, bank) { acc + bank.max_joltage })
}

pub fn pt_2(_input: List(BatteryBank)) -> Int {
  0
}

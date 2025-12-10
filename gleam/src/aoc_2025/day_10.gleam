import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import shellout

pub type Schematic {
  Schematic(
    // Bitmask
    indicators: Int,
    buttons: List(List(Int)),
    joltage_requirements: List(Int),
  )
}

// This is fine, this is... fine.
pub fn parse(input: String) -> List(Schematic) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(lights, rest)) = string.split_once(line, " ")
    let assert Ok(#(buttons, jolts)) = string.split_once(rest, " {")
    let joltage_requirements =
      jolts
      |> string.drop_end(1)
      |> string.split(",")
      |> list.filter_map(int.parse)

    let indicators =
      lights
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.split("")
      |> list.index_fold(0, fn(acc, char, idx) {
        case char {
          "." -> acc
          "#" -> int.bitwise_or(acc, int.bitwise_shift_left(1, idx))
          _ -> acc
        }
      })

    let buttons =
      buttons
      |> string.split(" ")
      |> list.map(fn(btns) {
        btns
        |> string.drop_start(1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.filter_map(int.parse)
      })

    Schematic(indicators:, buttons:, joltage_requirements:)
  })
}

type State {
  State(lights: Int, presses: Int)
}

pub fn solve_schematic(schematic: Schematic) {
  breadth_search(
    [State(0, 0)],
    set.from_list([0]),
    list.map(schematic.buttons, fn(button) {
      list.fold(button, 0, fn(acc, idx) {
        int.bitwise_or(acc, int.bitwise_shift_left(1, idx))
      })
    }),
    schematic.indicators,
  )
}

fn breadth_search(
  current_level: List(State),
  visited: Set(Int),
  buttons: List(Int),
  target: Int,
) -> Int {
  case current_level {
    [] -> 0

    [state, ..rest] -> {
      case state.lights == target {
        True -> state.presses
        False -> {
          // Mash every button to generate the next set of states

          let #(next_states, new_visited) =
            list.fold(buttons, #([], visited), fn(acc, button) {
              let #(states, v) = acc
              let new_lights = int.bitwise_exclusive_or(state.lights, button)
              case set.contains(v, new_lights) {
                True -> #(states, v)
                False -> {
                  let new_state = State(new_lights, state.presses + 1)
                  // Change this line - append instead of prepend:
                  #(list.append(states, [new_state]), set.insert(v, new_lights))
                }
              }
            })

          breadth_search(
            list.append(rest, next_states),
            new_visited,
            buttons,
            target,
          )
        }
      }
    }
  }
}

pub fn pt_1(input: List(Schematic)) {
  list.fold(input, 0, fn(acc, schematic) { acc + solve_schematic(schematic) })
}

pub fn pt_2(input: List(Schematic)) {
  // Shout out to Lily from the Gleam discord for providing this wicked z3 stuff I am too stupid to understand
  // Tomorrow I'm going to look into linear algebra, lol

  use acc, m <- list.fold(input, 0)

  let formula =
    "(set-logic LIA) (set-option :produce-models true)"
    <> list.index_fold(m.buttons, "", fn(acc, _, i) {
      acc
      <> " (declare-const x"
      <> int.to_string(i)
      <> " Int) (assert (>= x"
      <> int.to_string(i)
      <> " 0))"
    })
    <> list.index_fold(m.joltage_requirements, "", fn(acc, target, counter_idx) {
      acc
      <> " (assert (= (+"
      <> list.index_fold(m.buttons, "", fn(inner_acc, button, button_idx) {
        case list.contains(button, counter_idx) {
          True -> inner_acc <> " x" <> int.to_string(button_idx)
          False -> inner_acc
        }
      })
      <> ") "
      <> int.to_string(target)
      <> "))"
    })
    <> " (minimize (+"
    <> list.index_fold(m.buttons, "", fn(acc, _, i) {
      acc <> " x" <> int.to_string(i)
    })
    <> ")) (check-sat) (get-objectives) (exit)"

  let output = case
    shellout.command(
      "sh",
      with: ["-euc", "echo '" <> formula <> "' | z3 -in"],
      in: ".",
      opt: [],
    )
  {
    Ok(output) -> output
    Error(#(i, output)) ->
      panic as {
        "Z3 command failed with exit status "
        <> int.to_string(i)
        <> " and output: "
        <> output
      }
  }
  let assert [_, " " <> n, ..] = string.split(output, ")")
  let assert Ok(n) = int.parse(n)
  acc + n
}

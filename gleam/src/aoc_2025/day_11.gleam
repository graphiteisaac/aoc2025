import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn parse(input: String) -> dict.Dict(String, List(String)) {
  input
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc, str) {
    let assert Ok(#(id, outputs)) = string.split_once(str, ": ")
    let outputs = string.split(outputs, " ")

    dict.insert(acc, id, outputs)
  })
}

fn memoised_path_search(
  from: String,
  target: String,
  servers: dict.Dict(String, List(String)),
  cache: dict.Dict(#(String, String), Int),
) -> #(Int, dict.Dict(#(String, String), Int)) {
  case dict.get(cache, #(from, target)) {
    Ok(path_length) -> #(path_length, cache)

    Error(Nil) -> {
      case from == target {
        True -> #(1, cache)
        False -> {
          let #(sum, cache) =
            dict.get(servers, from)
            |> result.unwrap([])
            |> list.fold(#(0, cache), fn(accum, cache_from) {
              let #(path_length, cache) = accum
              let #(next_length, cache) =
                memoised_path_search(cache_from, target, servers, cache)

              #(path_length + next_length, cache)
            })

          #(sum, dict.insert(cache, #(from, target), sum))
        }
      }
    }
  }
}

pub fn pt_1(servers: dict.Dict(String, List(String))) {
  memoised_path_search("you", "out", servers, dict.new()).0
}

pub fn pt_2(servers: dict.Dict(String, List(String))) {
  memoised_path_search("svr", "fft", servers, dict.new()).0
  * memoised_path_search("fft", "dac", servers, dict.new()).0
  * memoised_path_search("dac", "out", servers, dict.new()).0
}

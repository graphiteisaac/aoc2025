import gleam/bool
import gleam/list
import gleam/set
import gleam/string

pub type Server {
  Server(id: String, outputs: List(String))
}

pub fn parse(input: String) -> List(Server) {
  input
  |> string.split("\n")
  |> list.map(fn(str) {
    let assert Ok(#(id, outputs)) = string.split_once(str, ": ")
    let outputs = string.split(outputs, " ")

    Server(id:, outputs:)
  })
}

fn depth_search(
  server_id: String,
  destination: String,
  servers: List(Server),
  visited: set.Set(String),
  current_path: List(String),
) -> List(List(String)) {
  case server_id == destination {
    True -> [list.reverse(current_path)]
    False -> {
      let visited = set.insert(visited, server_id)

      let neighbours = case
        list.find(servers, fn(server) { server.id == server_id })
      {
        Ok(server) ->
          list.filter(server.outputs, fn(neighbour) {
            !set.contains(visited, neighbour)
          })
        Error(_) -> []
      }

      list.flat_map(neighbours, fn(neighbour) {
        depth_search(neighbour, destination, servers, visited, [
          neighbour,
          ..current_path
        ])
      })
    }
  }
}

pub fn pt_1(servers: List(Server)) {
  depth_search("you", "out", servers, set.new(), ["you"])
  |> list.length
}

pub fn pt_2(servers: List(Server)) {
  todo as "part 2 not implemented"
}

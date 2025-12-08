import gleam/int
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string

pub type Vec3 {
  Vec3(x: Int, y: Int, z: Int)
}

pub fn parse(input: String) -> List(Vec3) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [x, y, z] = string.split(line, ",") |> list.filter_map(int.parse)
    Vec3(x, y, z)
  })
}

fn square(i: Int) {
  i * i
}

fn euclidian_distance(dist_1: Vec3, dist_2: Vec3) -> Int {
  let Vec3(x1, y1, z1) = dist_1
  let Vec3(x2, y2, z2) = dist_2

  // Can I get away with not getting the sqrt?
  square(x2 - x1) + square(y2 - y1) + square(z2 - z1)
}

type CircuitPair {
  CircuitPair(from: Vec3, to: Vec3)
}

type State {
  State(
    available_connections: List(CircuitPair),
    connections: Set(CircuitPair),
    circuits: List(Set(Vec3)),
  )
}

fn connect_nearest(state: State) -> #(CircuitPair, State) {
  let assert [connection, ..available_connections] = state.available_connections
  let state = State(..state, available_connections:)
  let State(connections:, ..) = state

  case set.contains(state.connections, connection) {
    True -> connect_nearest(state)
    False -> {
      let connections = set.insert(connections, connection)
      let has_connections =
        list.partition(state.circuits, fn(circuit_set) {
          set.contains(circuit_set, connection.from)
          || set.contains(circuit_set, connection.to)
        })
      let circuits = case has_connections {
        #([circuit], circuits) -> [circuit, ..circuits]
        #([circuit1, circuit2], circuits) -> [
          set.union(circuit1, circuit2),
          ..circuits
        ]
        _ -> panic
      }
      #(connection, State(..state, connections:, circuits:))
    }
  }
}

fn pt1_loop(state: State, to_connect: Int) -> Int {
  case to_connect {
    0 ->
      list.map(state.circuits, set.size)
      |> list.sort(order.reverse(int.compare))
      |> list.take(3)
      |> int.product
    _ -> pt1_loop(connect_nearest(state).1, to_connect - 1)
  }
}

pub fn pt_1(input: List(Vec3)) {
  let available_connections =
    list.combination_pairs(input)
    |> list.map(fn(p) { CircuitPair(from: p.0, to: p.1) })
    |> list.sort(fn(a, b) {
      int.compare(
        euclidian_distance(a.from, a.to),
        euclidian_distance(b.from, b.to),
      )
    })
  let connections = set.new()
  let circuits = list.map(input, set.insert(set.new(), _))
  let state = State(available_connections:, connections:, circuits:)

  pt1_loop(state, list.length(input))
}

fn pt2_loop(state: State) {
  case connect_nearest(state) {
    #(CircuitPair(from:, to:), State(circuits: [_], ..)) -> from.x * to.x
    #(_, state) -> pt2_loop(state)
  }
}

pub fn pt_2(input: List(Vec3)) {
  let available_connections =
    list.combination_pairs(input)
    |> list.map(fn(p) { CircuitPair(from: p.0, to: p.1) })
    |> list.sort(fn(a, b) {
      int.compare(
        euclidian_distance(a.from, a.to),
        euclidian_distance(b.from, b.to),
      )
    })
  let connections = set.new()
  let circuits = list.map(input, set.insert(set.new(), _))
  let state = State(available_connections:, connections:, circuits:)
  pt2_loop(state)
}

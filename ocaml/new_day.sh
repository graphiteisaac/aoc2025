#!/bin/bash
DAY=$1
mkdir -p bin/day$DAY
cat > bin/day$DAY/dune << EOF
(executable
 (name main)
 (public_name day$DAY)
 (libraries helpers))
EOF

cat > bin/day$DAY/main.ml << EOF
let solve_part1 input =
  0

let solve_part2 input =
  0

let () =
  let input = Helpers.read_file "input/day$DAY.txt" in
  Printf.printf "Part 1: %d\n" (solve_part1 input);
  Printf.printf "Part 2: %d\n" (solve_part2 input)
EOF

mkdir -p input
touch input/day$DAY.txt
echo "Created day$DAY"

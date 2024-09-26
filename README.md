Here’s a sample `README.md` for your assignment:

---

# MIPS Code Generator using ANTLR

## Overview
This project implements a code generator for MIPS processors using ANTLR. It takes a high-level language as input and generates MIPS assembly code. The generated code is tested and simulated using the SPIM simulator.

## Prerequisites
- **ANTLR v4**: Used for parsing the input grammar and generating the MIPS assembly code.
- **Java**: To run the ANTLR-generated Java files.
- **SPIM Simulator**: Used to simulate the MIPS processor and test the generated assembly code.

## Getting Started

### 1. Install ANTLR
To install ANTLR, follow the instructions from the [official documentation](https://www.antlr.org/).

### 2. Clone the Repository
Clone the repository to your local machine:
```bash
git clone <repository-url>
cd <repository-folder>
```

### 3. Compile the ANTLR Grammar
To generate the Java classes from the grammar (`Cactus.g4`), use the following command:
```bash
antlr4 Cactus.g4
```

### 4. Compile the Java Files
Once the grammar is processed, compile the generated Java files and the driver program:
```bash
javac Cactus*.java
```

### 5. Running the Code Generator
Run the code generator using ANTLR’s `grun` tool with your input file:
```bash
grun Cactus program < input_file.txt > output_file.txt
```
Here, `input_file.txt` contains your high-level language program, and `output_file.txt` will contain the generated MIPS assembly code.

### 6. Testing with SPIM
To test the generated MIPS assembly code:
- Open SPIM simulator.
- Load the `output_file.txt` containing the generated assembly code.
- Run the simulation to verify the correctness of the generated code.

## Features
- **Register Allocation**: Manages general-purpose registers `$t0` to `$t9` for storing temporary values during computations.
- **Label Management**: Dynamically generates and manages labels for control flow constructs such as `if`, `while`, and `else` blocks.
- **Arithmetic and Boolean Expressions**: Supports common arithmetic operations (`+`, `-`, `*`, `/`, `%`) and boolean expressions (`&&`, `||`, `!`).
- **Input/Output**: Handles `READ` and `WRITE` statements to interact with the user via the console.
- **Memory Access**: Supports storing and loading values from memory locations.

## Grammar
The high-level language grammar is defined in `Cactus.g4`, which includes support for:
- Variable declarations
- Assignment statements
- Arithmetic and boolean expressions
- Control flow: `if`, `while`, `else`
- Input/output: `READ`, `WRITE`
- `RETURN` statement for program termination.

## Files
- **Cactus.g4**: ANTLR grammar file defining the syntax and rules of the input language.
- **Makefile**: Automates the process of generating the parser and running the code.

## Example

### Input (`input_file.txt`):
```
main() {
    int x;
    x = 10;
    write x;
}
```

### Generated MIPS Assembly (`output_file.txt`):
```
.data
x:    .word    0
.text
main:
    li    $t0, 10
    la    $t1, x
    sw    $t0, 0($t1)
    la    $t0, x
    lw    $t0, 0($t0)
    move  $a0, $t0
    li    $v0, 1
    syscall
    li    $v0, 10
    syscall
```

## Clean Up
To clean up generated files:
```bash
make clean
```

## License
This project is licensed under the MIT License.

---

Let me know if you'd like to add or modify any sections!

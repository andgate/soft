# Lambda Calculus Parser in Zig

A simple implementation of a lambda calculus parser written in Zig. This project provides a lexer and parser for basic lambda calculus expressions.

## Overview

This parser implements a basic lambda calculus grammar, supporting:

- Variables (single lowercase letters)
- Lambda abstractions (λx.M or \x.M)
- Applications ((M N))

## Grammar

The parser follows this grammar:

```
expr -> variable
      | λ variable . expr
      | ( expr expr )
```

## Usage

To use the parser, you can compile the project and run it with a lambda calculus expression as an argument. For example:

```
zig build run --expr "(\λx.x x) y"
```

This will parse the expression and print the result.

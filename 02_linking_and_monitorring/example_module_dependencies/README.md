# Example module dependencies

This is just an example how you can use multiple modules that're in different files.

## Start your IEx shell

Run `iex` in your (bash / zsh) shell.

## Compile your files

We recommend to compile your files in order. In the 2 attached sample files, it is recommended that you compile first [test_gs_two.ex](test_gs_two.ex), after which you can compile [test_gs_one.ex](test_gs_one.ex).

```elixir
iex> c "test_gs_two.ex"
[TestGsTwo]
iex> c "test_gs_one.ex"
[TestGsOne]
```

Or you can do this shorter with passing a list (`c ["test_gs_one.ex", "test_gs_two.ex"]`).

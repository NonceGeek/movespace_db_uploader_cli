# MoveSpaceDBUploaderCLI

The CLI Uploader for MoveSpaceDB.

Supportted formats:

- [x] documentation
  - [x] markdown
  - [ ] pdf
  - [ ] pics(by OCR)
- [x] json
- [x] codes
  - [x] `.sol`

## How to use it?

Params:

```
./movespace_db_uploader_cli --type [mddoc, code] --path [the_path_for_content] --metadata [the_path_for_metadata] --datasetid [dataset_id] --insert
```

Remember `EMBEDBASE_KEY` should be in the `env`!

Cmd examples:

```bash
$ ./movespace_db_uploader_cli --type mddoc --path example_data/eth/analysis/erc20.md --metadata example_data/eth/analysis/erc20.json --datasetid eth-smart-contracts-analysis --insert
$ ./movespace_db_uploader_cli --type code --path example_data/eth/sliced/erc20.json --datasetid eth-smart-contracts-sliced --insert
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `movespace_db_uploader_cli` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:movespace_db_uploader_cli, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/movespace_db_uploader_cli>.


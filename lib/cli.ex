defmodule MovespaceDbUploaderCli.CLI do
  @moduledoc """
    data operation of movespaceDB by CLI.
    files in `example_data` are the examples.
    TODO:
    - [x] code data
    - [ ] documentation data
    - [ ] pdf data
  """
  alias MovespaceDbUploaderCli.JsonUploader
  require Logger

  @embedbase_key System.get_env("EMBEDBASE_KEY")
  
  @doc """
    main entry.
  """
  def main(args) do
      {opts, _others, _others_2} =
      OptionParser.parse(args,
          strict: [path: :string, embedbaseid: :string, type: :string, insert: :boolean, delete: :boolean, metadata: :string],
          aliases: [f: :filepath, e: :embedbaseid, t: :type, i: :insert, d: :delete, m: :metadata])
      opts
      |> Enum.into(%{})
      |> handle_args()
  end

  def handle_args(%{insert: true, embedbaseid: embedbase_id, type: "code", path: path}) do
    # parse the code File
    # judge type by the file suffix.
    suffix = path |> String.split(".") |> Enum.fetch!(-1)
    case suffix do
      "json" -> # ethereum smart contract sliced
      JsonUploader.upload(embedbase_id, path)
    end
  end

  @doc """
  $ ./movespace_db_uploader_cli --insert --type code --path abc --embedbaseid abcde --metadata {"a": "b"}
  """
  def handle_args(%{insert: true, embedbaseid: embedbase_id, type: type, path: path, metadata: metadata}) 
    when type in ["mddoc", "code"] do
    metadata_decoded = metadata |> File.read!() |> Poison.decode!()
    # parse the code File
    # judge type by the file suffix.
    suffix = path |> String.split(".") |> Enum.fetch!(-1)
    case suffix do
      "sol" -> # text file
      handle_doc(embedbase_id, path, metadata_decoded)
      "md" -> # text file
      handle_doc(embedbase_id, path, metadata_decoded)
    end
  end

  def handle_doc(embedbase_id, path, metadata_decoded) do
    content = File.read!(path)
    EmbedbaseEx.insert_data(embedbase_id, content, metadata_decoded, @embedbase_key)
  end
    
end

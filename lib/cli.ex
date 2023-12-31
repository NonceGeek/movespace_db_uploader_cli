defmodule MovespaceDbUploaderCli.CLI do
  @moduledoc """
    data operation of movespaceDB by CLI.
    files in `example_data` are the examples.
    TODO:
    - [x] code data
    - [x] documentation data(API way)
    - [ ] pdf data
  """
  alias MovespaceDbUploaderCli.JsonUploader
  require Logger

  @embedbase_key System.get_env("EMBEDBASE_KEY")
  @api_gateway System.get_env("API_GATEWAY")
  @api_key System.get_env("API_KEY")
  # @api_gateway "https://faas.movespace.xyz"
  # @api_gateway "http://localhost:4003"
  
  @doc """
    main entry.
    TODO: reorg the types!
  """
  def main(args) do
      {opts, _others, _others_2} =
      OptionParser.parse(args,
          strict: [path: :string, datasetid: :string, type: :string, insert: :boolean, delete: :boolean, metadata: :string, filename: :string, bymovespace: :boolean, automatic: :boolean, transform: :boolean, to: :string],
          aliases: [f: :filepath, e: :datasetid, t: :type, i: :insert, d: :delete, m: :metadata, a: :automatic])
      opts
      |> Enum.into(%{})
      |> handle_args()
  end


  def handle_args(%{bymovespace: true, insert: true, automatic: true, datasetid: dataset_id, type: "mddoc", path: path}) do
    IO.puts inspect @api_key
    IO.puts inspect @api_gateway
    contents = MarkdownParser.split_file_by_struct(path)
    Enum.map(contents, fn %{content: content, metadata: metadata} ->
      MovespaceInteractor.insert_data(@api_key, @api_gateway, dataset_id, content, metadata)
      Logger.info("-- upload an item to vectorDB by API --")
    end)
  end

  def handle_args(%{bymovespace: true, insert: true, datasetid: dataset_id, type: "mddoc", path: path, filename: filename}) do
    contents = MarkdownParser.split_file(path)
    Enum.map(contents, fn %{content: content} ->
      MovespaceInteractor.insert_data(@api_key, @api_gateway, dataset_id, content, %{file_name: filename})
      Logger.info("-- upload an item to vectorDB by API --")
    end)
  end



  @doc """
    transform data from dataset to csv, so it could be manager by git.
  """
  def handle_args(%{bymovespace: true, transform: true,  datasetid: dataset_id, to: "csv"}) do
    csv_data_no_vector = MovespaceInteractor.get_all(:no_vector, @api_gateway, dataset_id)
    CSVWriter.write_csv_file(csv_data_no_vector, "#{dataset_id}_#{:os.system_time(:millisecond)}.csv")
    csv_data_vector = MovespaceInteractor.get_all(:vector, @api_gateway, dataset_id)
    CSVWriter.write_csv_file(csv_data_vector, "#{dataset_id}_#{:os.system_time(:millisecond)}_vector.csv")
  end

  def handle_args(%{insert: true, datasetid: dataset_id, type: "code", path: path}) do
    # parse the code File
    # judge type by the file suffix.
    suffix = path |> String.split(".") |> Enum.fetch!(-1)
    case suffix do
      "json" -> # ethereum smart contract sliced
      JsonUploader.upload(dataset_id, path)
    end
  end

  @doc """
    $ ./movespace_db_uploader_cli --insert --type code --path abc --datasetid abcde --metadata {"a": "b"}
  """
  def handle_args(%{insert: true, datasetid: dataset_id, type: type, path: path, metadata: metadata}) 
    when type in ["mddoc", "code"] do
    metadata_decoded = metadata |> File.read!() |> Poison.decode!()
    # parse the code File
    # judge type by the file suffix.
    suffix = path |> String.split(".") |> Enum.fetch!(-1)
    case suffix do
      "sol" -> # text file
      handle_doc(dataset_id, path, metadata_decoded)
      "md" -> # text file
      handle_doc(dataset_id, path, metadata_decoded)
    end
  end

  def handle_doc(dataset_id, path, metadata_decoded) do

    content = File.read!(path)
    EmbedbaseEx.insert_data(dataset_id, content, metadata_decoded, @embedbase_key)
  end
    
end

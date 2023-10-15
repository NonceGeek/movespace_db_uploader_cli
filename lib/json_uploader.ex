defmodule MovespaceDbUploaderCli.JsonUploader do

    require Logger
    @embedbase_key System.get_env("EMBEDBASE_KEY")


    def upload(dataset_id, file_path) do
        # get all the keys
        contract_json = read_file(file_path)
        source_url = Map.fetch!(contract_json, "source")
        contract_json
        |> Enum.map(fn {type, _} ->
            type
        end)
        |> Enum.reject(&(&1 == "source"))
        |> Enum.map(fn type ->
            upload_by_type(dataset_id, type, contract_json, source_url)
        end)
    end

    def read_file(file_path) do
        {:ok, raw} = File.read(file_path)
        Poison.decode!(raw)
    end

    def upload_by_type(dataset_id, type, contract_json, source_url) do
        items = Map.fetch!(contract_json, type)
        Enum.map(items, fn item ->
            Logger.info("--upload a item to vector DB--")
            EmbedbaseEx.insert_data(
                dataset_id, 
                item,  
                %{type: type, source: source_url}, 
                @embedbase_key
            )
        end)
    end

end
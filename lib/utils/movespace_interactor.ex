defmodule MovespaceInteractor do
    require Logger
    def insert_data(endpoint, dataset_id, data, metadata \\ %{}) do
        body =  %{
            params: [dataset_id, data, metadata]
        }
        # insert data into movespace by API.
        ExHttp.http_post(
            "#{endpoint}/api/v1/run?name=VectorAPI&func_name=insert_data", 
            body
        )
    end
    
    def get_all(endpoint, dataset_id) do
        # get data count.
        {:ok, %{"result" => count}} = 
        ExHttp.http_post(
            "#{endpoint}/api/v1/run?name=VectorAPI&func_name=get_count", 
            %{
                params: [dataset_id]
            }
        )

        # fetch all the data by Enum.
        Enum.reduce(1..count, [["id", "uuid", "data", "metadata", "vector"]], fn index, acc ->
            data = fetch_data(endpoint, dataset_id, index)
            acc ++ [data]
        end)

    end

    def fetch_data(endpoint, dataset_id, data_id) do
        {
            :ok,
            %{
            "result" => [id, uuid, data, _metadata, vector]}
        } = 
            ExHttp.http_post(
                "#{endpoint}/api/v1/run?name=VectorAPI&func_name=fetch_data_with_vector", 
                %{
                    params: [dataset_id, data_id]
                }
            )
        [id, uuid, data, Poison.encode!(vector)]
    end

end
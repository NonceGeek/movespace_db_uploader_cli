defmodule MarkdownParser do
    @moduledoc """
        parse the .md files by the para.
    """

    @doc """
        read and split the md file.
    """

    def split_file(file_path) do
        file =  File.read!(file_path)
        comments = 
            file
            |> Earmark.as_ast!() # to ast
            |> Enum.filter(fn elem -> elem |> Tuple.to_list |> Enum.fetch(0) == {:ok, :comment} end) # get all the comment.
            # |> Enum.chunk_by(fn elem -> elem |> Tuple.to_list |> Enum.fetch(0) == {:ok, :comment} end) # split by the comment.
            # |> Enum.chunk_every(2) # chunk content and comment.
            |> Enum.map(fn {:comment, [], [comment], %{comment: true}} 
                -> comment 
            end) # handle comment
        file
        |> handle_md_by_the_comments([], comments)
    end

    def handle_md_by_the_comments(file, acc, comments) do
        if comments == [] do
            acc
        else 
            {comment, rem} = List.pop_at(comments, 0)
            [bef, aft] = String.split(file, "<!--#{comment}-->")
            handle_md_by_the_comments(
                aft, # file = aft
                acc ++ [%{content: "#{bef}"}], # acc + new
                rem # comments =-1
            )
        end
    end

end
defmodule MarkdownParser do
    @moduledoc """
        parse the .md files by the para.
    """

    @doc """
        read and split the md file automatically by the struct.
    """
    def split_file_by_struct(file_path) do
        # ast it as a tree.
        tree =  file_path |> File.read!() |> Earmark.as_ast!()
        # get all `h2`
        formatted_tree = format_with_level(tree, "h2")
        # get all `h3`
        formatted_tree = 
            Enum.map(formatted_tree, fn %{head: head, body: body} -> 
            %{head: head, body: format_with_level(body, "h3")}
            # todo: more level
        end)
        # formatted_tree
        # tag `p`
        formatted_tree
        |> Enum.map(fn %{head: {_h2_level, [], [h2_content], %{}}, body: body} -> 
            Enum.map(body, fn %{head: {_h3_level, [], [h3_content], %{}}, body: elem_list} -> 
                elem_list
                |> Enum.filter(fn elem -> elem |> Tuple.to_list |> Enum.fetch!(0) == "p" end)
                |> Enum.map(fn p -> 
                    {"p", [], [content], %{}} = p
                    %{content: content, metadata: %{h2: h2_content, h3: h3_content}}
                end)
                
            end)
        end)
        |> List.flatten()
    end

    

    def format_with_level(tree, level) do
        all_h2 = tree |> Enum.filter(fn elem -> elem |> Tuple.to_list |> Enum.fetch!(0) == level end)

        Enum.map(all_h2, fn h2 -> 
            idx = Enum.find_index(all_h2, &(&1 == h2))
            h2_after = Enum.fetch(all_h2, idx + 1)
            if h2_after == :error do # it means it is the last one
                tree
                |> get_content(h2) 
                |> format_content()
            else
                {:ok, content} = h2_after
                tree
                |> get_content(h2, content) 
                |> format_content()
            end
        end)
    end

    def get_content(tree, h2, h2_after) do
        h2_index = Enum.find_index(tree, &(&1==h2))
        h2_after_index = Enum.find_index(tree, &(&1==h2_after))
        {_part_1, part_2} = Enum.split(tree, h2_index)
        {content, _part_3} = Enum.split(part_2, h2_after_index)
        content
    end


    def get_content(tree, h2) do
        h2_index = Enum.find_index(tree, &(&1==h2))
        {_part_1, part_2} = Enum.split(tree, h2_index)
        part_2
    end

    def format_content(content) do
        {[h2_part], others} = Enum.split(content, 1)
        %{head: h2_part, body: others}
    end

    @doc """
        read and split the md file by comment
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
            [bef, aft] = String.split(file, "<!--#{comment}-->", parts: 2)
            handle_md_by_the_comments(
                aft, # file = aft
                acc ++ [%{content: "#{bef}"}], # acc + new
                rem # comments =-1
            )
        end
    end

end
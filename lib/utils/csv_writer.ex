# this is our NimbleCSV parser which we define inline for tab-delimited CSV
NimbleCSV.define(CSVParser, separator: ",", escape: "\"")

defmodule CSVWriter do

#   @user_data [
#     ~w(Date Name Age City Comment),
#     ~w(2018-08-06 Heike 23 Köln Hallo👋),
#     ~w(2018-08-07 Jürgen 44 München 😸Tschüß❤️)
#   ]

  def write_csv_file(data, file_name) do
    File.write!(file_name, data_to_csv(data))
  end

  defp data_to_csv(data) do
    CSVParser.dump_to_iodata(data)
  end

end

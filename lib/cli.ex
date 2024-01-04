defmodule Imgspider.CLI do
  def main(args) do
    dest_flag = Enum.find_index(args, &(&1 in ["-o", "--dest"]))
    dest = dest_flag && Enum.at(args, dest_flag + 1)

    args =
      if dest == nil do
        args
      else
        args |> List.delete_at(dest_flag) |> List.delete_at(dest_flag)
      end

    cond do
      "--help" in args or "-h" in args ->
        usage("imgspider")

      dest_flag && dest == nil ->
        IO.puts("Expected a path to the location of images after -o or --dest")

      length(args) == 0 ->
        IO.puts("Expected either the name of a HTML file or the URL of a web-page to")
        IO.puts("download images.  Run with --help")

      length(args) > 2 ->
        IO.puts("Expected just a filename/URL to the webpage and maybe image regexp")
        IO.puts("with params.  Run with --help")

      true ->
        Supervisor.start_link(Imgspider, :shit)

        case args do
          [wp, regexp] ->
            IO.puts("Extract images from the " <> wp <> " using the following regexp: ")
            IO.puts(regexp)

            Imgspider.scrapping(wp, dest || ".", regexp)

          [wp] ->
            IO.puts("Extract images from the " <> wp)
            Imgspider.scrapping(wp, dest || ".")
        end
    end
  end

  defp usage(program) do
    IO.puts("Usage: " <> program <> " <file/URL> [regexp] [params]...")

    IO.puts("")
    IO.puts("Extract and download images from the web-page at <file/URL>.")
    IO.puts("URLs on images will be extracted with the default regexp or")
    IO.puts("with a given regexp")
    IO.puts("")

    IO.puts("--help")
    IO.puts("  print the help message and exit")
    IO.puts("")
    IO.puts("--dest (-o)")
    IO.puts("  change the destination of downloaded images")
  end
end

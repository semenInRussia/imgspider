defmodule Imgspider do
  use Supervisor

  @moduledoc """
  A spider which download images from the html file.
  """

  # The default directory where images will be located.
  @dest "."

  # The regexp which indicates the URL to the images.
  @img_src_regexp "https://[^\"]*?\\.(?:png|jpg)"

  # The amount of miliseconds on donwload of every image, when scrapping
  @download_timeout :infinity

  @impl Supervisor
  def init(_x) do
    children = [
      {
        Finch,
        name: __MODULE__, pools: %{:default => [count: 3]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def scrapping(file_or_url, dest \\ @dest, reg \\ @img_src_regexp) do
    with {:ok, body} <- read_file_or_url(file_or_url) do
      tasks =
        body
        |> matched_urls(reg)
        |> Enum.map(fn url -> Task.async(Imgspider, :download_img, [url, {}, [dest: dest]]) end)

      Task.await_many(tasks, :infinity)
    end
  end

  @doc """
  Download the image at URL with last part of URL path as the filename.

  If you need that filename of a file will be the path of filename in
  URL, pass {} as a filename.

  Opts can be the following:

  :rewrite_if_exists?
    should be True, if you expect download all files, including which
    alread downloaded

  :dest
    the destination directory in which file will be saved
  """
  def download_img(url, filename, opts \\ [])

  def download_img(url, {}, opts) do
    filename =
      url
      |> String.trim_trailing("/")
      |> String.split("/")
      |> List.last()

    download_img(url, filename, opts)
  end

  def download_img(url, filename, opts) do
    dest = Keyword.get(opts, :dest, @dest)

    unless File.exists?(dest) do
      File.mkdir(dest)
    end

    rie? = Keyword.get(opts, :rewrite_if_exists?, false)
    filename = Path.join(dest, filename)

    with true <- rie? or not File.exists?(filename),
         {:ok, bytes} <- get_req(url),
         {:ok, file} <- File.open(filename, [:write]),
         :ok <- IO.binwrite(file, bytes) do
      {:ok, :downloaded}
    else
      false -> {:ok, :skip}
      err -> err
    end
  end

  defp read_file_or_url(path) do
    if File.exists?(path) do
      File.read(path)
    else
      get_req(path)
    end
  end

  defp get_req(url) do
    res =
      Finch.build(:get, url)
      |> Finch.request(__MODULE__,
        receive_timeout: @download_timeout,
        pool_timeout: @download_timeout
      )

    case res do
      {:ok, res} -> {:ok, res.body}
      err -> err
    end
  end

  defp matched_urls(text, reg) do
    {:ok, rx} = Regex.compile(reg)
    Regex.scan(rx, text) |> Enum.map(&hd/1)
  end
end

defmodule Imgspider do
  use Supervisor

  @moduledoc """
  A spider which download images from the html file.
  """

  # The directory where images will be located.
  @dest "./imgs/"

  # The path to the file in which will be found images.
  @html_file "./html/spartak1.html"

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

  def scrapping(file) do
    tasks =
      file
      |> Imgspider.find_img_urls()
      |> Enum.map(fn url -> Task.async(Imgspider, :download_img, [url, {}]) end)

    Task.await_many(tasks, :infinity)
  end

  def download_img(url, {}) do
    download_img(url, rewrite_if_exists?: false)
  end

  @doc """
  Download the image at URL with last part of URL path as the filename.
  """
  def download_img(url, rewrite_if_exists?: rie?) do
    filename = String.split(url, "/") |> List.last()
    download_img(url, filename, rewrite_if_exists?: rie?)
  end

  @doc """
  Donwload the image at URL as filename.
  """
  def download_img(url, filename, rewrite_if_exists?: rie?) do
    unless File.exists?(@dest) do
      File.mkdir(@dest)
    end

    with true <- rie? or not File.exists?(filename),
         req <- Finch.build(:get, url),
         {:ok, res} <-
           Finch.request(req, __MODULE__,
             receive_timeout: @download_timeout,
             pool_timeout: @download_timeout
           ),
         bytes <- res.body,
         {:ok, file} <- File.open(Path.join(@dest, filename), [:write]),
         :ok <- IO.binwrite(file, bytes) do
      {:ok, :downloaded}
    else
      false -> {:ok, :skip}
      err -> err
    end
  end

  @doc """
  Find URLs to images inside the default HTML file.
  """
  def find_img_urls() do
    find_img_urls(@html_file)
  end

  @doc """
  Find URLs to images inside HTML file with the given filename.
  """
  def find_img_urls(filename) do
    with {:ok, content} <- File.read(filename) do
      Imgspider.matched_urls(content)
    end
  end

  def matched_urls(text) do
    {:ok, rx} = Regex.compile(@img_src_regexp)
    Regex.scan(rx, text) |> Enum.map(&hd/1)
  end
end

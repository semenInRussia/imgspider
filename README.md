# Imgspider

The programm to fastly extract and download all images from the HTML file.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `imgspider` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:imgspider, git: "https://github.com/semenInRussia/imgspider.git"}
  ]
end
```

<!-- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) -->
<!-- and published on [HexDocs](https://hexdocs.pm). Once published, the docs can -->
<!-- be found at <https://hexdocs.pm/imgspider>. -->


## Usage

Before use `Imgspider` you must start the `Imgspider` `Supervisor` to start all needed backends (now only one is needed is `Finch` to do HTTP queries), do anything like the following

```elixir
Supervisor.start_link(Imgspider, :shit)
```

or in your `<YourShit>.start_link()` write the following:

```elixir
children = [
  ...
  {Imgspider, :shit}
  ...
]
```

After that, you can fully enjoy the `Imgspider`.  For example, you can extract all pictures from the HTML file downloaded on your machine, for that use function `Imgspider.scrapping/3`

You can just download ALLLLL **jpg** and **png** files from the file, using the most convinence `Imgspider.scrapping/1` interface

```elixir
Imgspider.scrapping("index.html")
```

All pictures will be located inside the working directory.  All pictures means a pictures which are matched with regexp which starts with "https" and ended with "jpg" and "png".  You can change the destination and regexp using the first and second arguments respectively.


## About how it's working?

It's just extract pictures URLs from the HTML file, and do for every Picture a BEAM thread.

Erlang BEAM machine is so powerful, that a program can have 800 threads in one momementmeme!!!

## Contributing

No, don't do it, please, if you are dummy.  If you are normal man, can try!  GOOD LUCK

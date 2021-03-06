# Membrane MP3 Lame plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_mp3_lame_plugin.svg)](https://hex.pm/package/membrane_mp3_lame_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_mp3_lame_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_mp3_lame_plugin)

Module containing element that encodes raw audio to MPEG-1 layer 3 format.

For now, only encoding audio with 2 channels, s32le format and 44100 sample rate is supported.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

Add the following line to your `deps` in `mix.exs`. Run `mix deps.get`.

```elixir
{:membrane_mp3_lame_plugin, "~> 0.5.0"}
```

[Lame encoder library](http://lame.sourceforge.net) is required to use this element.
You can install it using the following commands:

### MacOS

```bash
brew install lame
```

### Ubuntu

```bash
sudo apt-get install libmp3lame-dev
```

### Arch, Manjaro

```bash
sudo pacman -S lame
```

### Fedora

```bash
sudo dnf install lame-devel
```

## Usage 
TODO

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_mp3_lame_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_mp3_lame_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)

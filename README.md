# Membrane.Element.Lame

[![Build Status](https://travis-ci.com/membraneframework/membrane-element-lame.svg?branch=master)](https://travis-ci.com/membraneframework/membrane-element-lame)

Module containing element that encodes raw audio to MPEG-1 layer 3 format.

For now, only encoding audio with 2 channels, s32le format and 41000 sample rate is supported.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

[Lame encoder library](http://lame.sourceforge.net) is required to use this element.

## Compilation on Unix systems

To compile NIF you have to make sure `ext/lame.pc` is visible to the pkg-config.
That can be achieved by adding `ext` directory path to the environment variable `PKG_CONFIG_PATH`
or by copying `ext/lame.pc` to the pkg-config dir (i.e. `/usr/lib/pkgconfig`)

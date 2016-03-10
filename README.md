# noflo-ccv [![Build Status](https://secure.travis-ci.org/noflo/noflo-ccv.png?branch=master)](http://travis-ci.org/noflo/noflo-ccv)

[NoFlo](http://noflojs.org/) components for [libccv](http://libccv.org).

For now supporting:

- `FindFaces`: Uses outdated JS port of libccv's Viola-Jones cascade detector
- `SCDDetect`: Uses C version of libccv's SURF-Cascade detector

# Dependencies

It expects [libccv](http://libccv.org) installed at `/usr/local/bin`.
See `.travis.yml` for Deb package names.

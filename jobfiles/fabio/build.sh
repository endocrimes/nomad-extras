#!/usr/bin/env bash

version=$1
if [[ -z $version ]]; then
  echo "Usage: build.sh VERSION BINSUFFIX" >&2
  exit 2
fi

suffix=$2
if [[ -z $suffix ]]; then
  echo "Usage: build.sh VERSION BINSUFFIX" >&2
  exit 2
fi

m4 -DVERSION="$version" -DBINNAME="fabio-$version-$suffix" ./fabio.nomad.m4 > fabio.nomad

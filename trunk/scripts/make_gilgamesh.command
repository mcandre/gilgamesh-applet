#!/usr/bin/env sh

CURRENT="$(dirname -- "$0")"

pp -o $CURRENT/bin/gilgamesh-macosx -B -M Error -M YAML -M Crypt::SSLeay -M WWW::Mechanize -M HTML::TokeParser $CURRENT/gilgamesh.pl

#!/bin/bash

echo "Installing Gilgamesh"
cp gilgamesh-applet.py  /usr/local/bin/gilgamesh-applet.py
cp gilgamesh-applet.server /usr/lib/bonobo/servers/GNOME_Gilgamesh.server
bonobo-server-run-query

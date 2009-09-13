#!/usr/bin/env python

# Alex Schoof
#
# PyGTK applet for gilgamesh 
# Based in part on http://polariscorp.free.fr/screenapplet.php

import sys
import os
import pygtk
pygtk.require('2.0')
import gtk
import gnomeapplet
import gilgamesh
import threading
import ConfigParser

configFileLocation = 'gilgamesh.ini'
mainImage = None
isUp = False
waitTimer = None
settings = {}

config=ConfigParser.ConfigParser()
config.readfp(open(configFileLocation))
settings={}
for key, value in config.items("Defaults"):
	settings[key]=value

def login():
	global waitTimer, settings

	if waitTimer:
		waitTimer.cancel()
	gilgamesh.login(settings)
	waitTimer = threading.Timer(int(settings["wait"]), gilgamesh.login, settings)
	waitTimer.start()

def force_refresh(*arguments, **keywords):
	mainImage.set_from_file("up.ico")
	isUp = True
	login()

def set_username(*arguments, **keywords):
	global settings

	settings['username'] =  os.popen('zenity --text "GMU Username :" --title "Change Username" --entry --entry-text "' + settings['username'] +'"').read()
	settings['username'] = settings['username'].replace('\n','')
	config.set('Defaults', 'username', settings['username'])
	config.write(open(configFileLocation, 'w'))

def set_password(*arguments, **keywords):
	global settings

	settings['password'] =  os.popen('zenity --text "GMU Password :" --title "Change Password" --entry --hide-text --entry-text "' + settings['password'] +'"').read()
	settings['password'] = settings['password'].replace('\n','')
	config.set('Defaults', 'password', settings['password'])
	config.write(open(configFileLocation, 'w'))

def menu (applet):
	propxml="""
		<popup name="button3">
		<menuitem name="Item 3" verb="refresh" label="_Refresh" />
		<menuitem name="Item 4" verb="username" label="_Change Username" />
		<menuitem name="Item 5" verb="password" label="_Change Password" />	
		</popup>
		"""
	verbs = [("refresh", force_refresh),("username", set_username),("password", set_password)]
	applet.setup_menu(propxml, verbs, None)

def sample_factory(applet, iid):
	global mainImage	

        event_box = gtk.EventBox()
        applet.add(event_box)
        event_box.show()

	mainImage = gtk.Image()	
	mainImage.set_from_file("down.ico")
        event_box.add(mainImage)
        mainImage.show()

        event_box.connect("button-press-event", applet_clicked,applet)

	applet.show_all()
	return True

def applet_clicked(self,event,applet):
	global mainImage, isUp, waitTimer

	if event.type == gtk.gdk.BUTTON_PRESS and event.button == 3:
		menu(applet)
	else:
		if isUp:
			mainImage.set_from_file("down.ico")
			isUp = False
			if waitTimer:
				waitTimer.cancel()
		else:
			mainImage.set_from_file("up.ico")
			isUp = True
			login()


if len(sys.argv) == 2:
	if sys.argv[1] == "run-in-window":
		main_window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		main_window.set_title("Python Applet")
		main_window.connect("destroy", gtk.main_quit)
		app = gnomeapplet.Applet()
		sample_factory(app, None)
		app.reparent(main_window)
		main_window.show_all()
		gtk.main()
		sys.exit()

gnomeapplet.bonobo_factory("OAFIID:GNOME_Gilgamesh_Factory",gnomeapplet.Applet.__gtype__,"Log into UAC/MUST", "0.1", sample_factory)

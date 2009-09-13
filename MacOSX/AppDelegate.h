//
//  AppDelegate.h
//  Gilgamesh
//
//  Created by Andrew Pennebaker on 4/6/09
//  Copyright 2009 YelloSoft

#import <Cocoa/Cocoa.h>

@interface AppDelegate: NSObject {
	NSUserDefaults *defaults;
	IBOutlet NSPanel *preferencesPanel;
	IBOutlet NSTextField *statusField;
	IBOutlet NSButton *applyButton;
	IBOutlet NSMenu *menu;
	NSStatusItem *statusItem;
	NSImage *upIcon;
	NSImage *downIcon;
	IBOutlet NSMenuItem *upMenuItem;
	IBOutlet NSMenuItem *downMenuItem;
	IBOutlet NSMenuItem *refreshMenuItem;
	IBOutlet NSMenuItem *preferencesMenuItem;
	IBOutlet NSMenuItem *aboutMenuItem;
	IBOutlet NSMenuItem *quitMenuItem;
	NSTimer *timer;
	BOOL successful;
}

-(void) addLoginItem;
-(void) deleteLoginItem;
-(void) update;
-(IBAction) refresh: (id) sender;
-(IBAction) apply: (id) sender;
-(IBAction) preferences: (id) sender;
-(IBAction) about: (id) sender;

@end
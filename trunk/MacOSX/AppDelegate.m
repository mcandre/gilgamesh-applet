//
//  AppDelegate.m
//  Gilgamesh
//
//  Created by Andrew Pennebaker on 4/6/09
//  Copyright 2009 YelloSoft

#import "AppDelegate.h"
#import "Gilgamesh.h"

@implementation AppDelegate

-(void) dealloc {
	[statusItem release];
	[super dealloc];
}

-(void) deleteLoginItem {
	NSString *deleteScript=[[NSBundle mainBundle] pathForResource:@"delete_login_item" ofType:@"applescript"];
	NSString *deleteLoginItemsCommand=[NSString stringWithFormat: @"/usr/bin/osascript %@ Gilgamesh", deleteScript];
	system([deleteLoginItemsCommand UTF8String]);
}

-(void) addLoginItem {
	[self deleteLoginItem];

	NSBundle *bundle=[NSBundle mainBundle];
	NSString *addScript=[bundle pathForResource:@"add_login_item" ofType:@"applescript"];
	NSString *applicationPath=[bundle bundlePath];
	NSString *addLoginItemsCommand=[NSString stringWithFormat: @"/usr/bin/osascript %@ %@", addScript, applicationPath];
	system([addLoginItemsCommand UTF8String]);
}

-(void) awakeFromNib {
	defaults=[[NSUserDefaults standardUserDefaults] retain];

	NSDictionary *dict=[
		NSDictionary dictionaryWithContentsOfFile:[
			[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"
	   ]
	];

	successful=NO;

	[defaults registerDefaults:dict];

	int wait=[defaults integerForKey:@"wait"];

	if ([defaults boolForKey:@"startMeAtLogin"]) {
		[self addLoginItem];
	}
	else {
		[self deleteLoginItem];
	}

	statusItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:menu];

	[statusItem setHighlightMode:YES];
	[statusItem setEnabled:YES];

	upIcon=[NSImage imageNamed:@"up.png"];
	downIcon=[NSImage imageNamed:@"down.png"];

	[statusItem setImage:downIcon];

	timer=[NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(update) userInfo:nil repeats:YES];

	if ([defaults boolForKey:@"firstTime"]) {
		[self preferences:nil];

		[defaults setBool:NO forKey:@"firstTime"];
	}
	else {
		[timer fire];
	}
}

-(void) update {
	[statusItem setTitle:@""];

	if ([Gilgamesh
		login: [defaults stringForKey:@"url"]
		url_wireless: [defaults stringForKey:@"url_wireless"]
		useragent:[defaults stringForKey:@"useragent"]
		success:[defaults stringForKey:@"success"]
		success_wireless:[defaults stringForKey:@"success_wireless"]
		timeout:[defaults integerForKey:@"timeout"]
		username:[defaults stringForKey:@"username"]
		password:[defaults stringForKey:@"password"]]
	) {
		[statusItem setImage:upIcon];
		successful=YES;
	}
	else {
		[statusItem setImage:downIcon];
		successful=NO;
	}
}

-(IBAction) refresh: (id) sender {
	[self update];
}

-(IBAction) apply: (id) sender {
	[self refresh:nil];

	if ([defaults boolForKey:@"startMeAtLogin"]) {
		[self addLoginItem];
	}
	else {
		[self deleteLoginItem];
	}

	if (successful) {
		[statusField setStringValue:@"Success"];
	}
	else {
		[statusField setStringValue:@"Bad username/password"];
	}
}

-(IBAction) preferences: (id) sender {
	NSApplication *app=[NSApplication sharedApplication];
	[app activateIgnoringOtherApps:YES];
	[preferencesPanel makeKeyAndOrderFront:sender];
}

-(IBAction) about: (id) sender {
	NSApplication *app=[NSApplication sharedApplication];
	[app activateIgnoringOtherApps:YES];
	[app orderFrontStandardAboutPanel:nil];
}

@end

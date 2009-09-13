//
// Gilgamesh.m
//
//  Created by Andrew Pennebaker on 4/6/09
//  Copyright 2009 YelloSoft

#import "Gilgamesh.h"

@implementation Gilgamesh

+(BOOL) login:(NSString*) url url_wireless:(NSString*) uw useragent:(NSString*) ua success:(NSString*) s success_wireless:(NSString*) sw timeout:(int) t username:(NSString*) u password:(NSString*) p {

	NSString *command=[NSString stringWithFormat:@"%@ -n \"%@\" \"%@\" \"%@\" \"%@\" \"%@\" \"%d\" \"%@\" \"%@\"",
		[[NSBundle mainBundle] pathForResource:@"gilgamesh-macosx" ofType:@""], url, uw, ua, s, sw, t, u, p
	];

	printf("Command: %s\n", [command UTF8String]);

	return system([command UTF8String])==0;
}

@end
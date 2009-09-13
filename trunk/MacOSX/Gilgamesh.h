//
//  Gilgamesh.h
//
//  Created by Andrew Pennebaker on 4/6/09
//  Copyright 2009 YelloSoft

#import <Cocoa/Cocoa.h>

@interface Gilgamesh: NSObject {}

+(BOOL) login:(NSString*) url url_wireless:(NSString*) uw useragent:(NSString*) ua success:(NSString*) s success_wireless:(NSString*) sw timeout:(int) t username:(NSString*) u password:(NSString*) p;

@end
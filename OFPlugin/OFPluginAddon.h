//
//  OFPluginAddon.h
//  OFPlugin
//
//  Created by Adam on 2013-08-14.
//  Copyright (c) 2013 admsyn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OFPluginAddon : NSMenuItem

@property (nonatomic, strong) NSString * addonPath;
@property (nonatomic, strong) NSString * addonName;

@end

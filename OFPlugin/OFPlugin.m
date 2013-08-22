//
//  OFPlugin.m
//  OFPlugin
//
//  Created by Adam on 2013-08-14.
//    Copyright (c) 2013 admsyn. All rights reserved.
//

#import "OFPlugin.h"
#import "OFPluginAddon.h"
#import "XcodeEditor.h"

@interface OFPlugin() {
	NSString * _addonsPath;
	NSMenu * _addonsListMenu;
	NSMenuItem * _addAddonItem;
}
@end

@implementation OFPlugin

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init]) {
		NSMenuItem * ofMenuItem = [[NSMenuItem alloc] initWithTitle:@"openFrameworks" action:@selector(menuSelected:) keyEquivalent:@""];
		[ofMenuItem setTarget:self];
		NSMenu * topLevelMenu = [[NSMenu alloc] initWithTitle:@"OF"];
		[ofMenuItem setSubmenu:topLevelMenu];
		
		NSMenuItem * addonsPathItem = [topLevelMenu addItemWithTitle:@"Set addons path..." action:@selector(setAddonsPath:) keyEquivalent:@""];
		[addonsPathItem setTarget:self];
		[addonsPathItem setEnabled:YES];
		
		_addAddonItem = [topLevelMenu addItemWithTitle:@"Add addon" action:@selector(menuSelected:) keyEquivalent:@""];
		_addonsListMenu = [[NSMenu alloc] initWithTitle:@"addon-list"];
		[_addAddonItem setTarget:self];
		
		_addonsPath = [@"~/workspace/openFrameworks/addons/" stringByExpandingTildeInPath];
		[_addAddonItem setSubmenu:_addonsListMenu];
		[self scanAddons];
		
		[[NSApp mainMenu] addItem:ofMenuItem];
    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)menuSelected:(id)sender
{
	
}

- (void)scanAddons
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_addonsListMenu removeAllItems];
		
		NSArray * allAddons = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_addonsPath error:nil];
		allAddons = [allAddons sortedArrayUsingComparator:^NSComparisonResult(NSString * a, NSString * b) {
			return [a compare:b];
		}];
		
		for(NSString * addon in allAddons) {
			if([addon rangeOfString:@"ofx"].location != NSNotFound) {
				OFPluginAddon * addonItem = [[OFPluginAddon alloc] initWithTitle:addon action:@selector(addAddon:) keyEquivalent:@""];
				[addonItem setAddonName:addon];
				[addonItem setAddonPath:[_addonsPath stringByAppendingString:addon]];
				[addonItem setTarget:self];
				[_addonsListMenu addItem:addonItem];
			}
		}
		
		[_addAddonItem setSubmenu:_addonsListMenu];
	});
}

// TODO: store last addon path in NSUserDefaults
- (void)setAddonsPath:(id)sender
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSOpenPanel * openPanel = [NSOpenPanel openPanel];
		[openPanel setDirectoryURL:[NSURL fileURLWithPath:[@"~" stringByExpandingTildeInPath]]];
		[openPanel setCanChooseDirectories:YES];
		[openPanel setTitle:@"Point me at your addons folder"];
		[openPanel beginWithCompletionHandler:^(NSInteger result) {
			NSURL * addonsURL = [[openPanel URLs] objectAtIndex:0];
			_addonsPath = [addonsURL path];
			[self scanAddons];
		}];
	});
}

// This is where you'd do your magic. Turns out XcodeEditor does not include the required magic.
- (void)addAddon:(OFPluginAddon *)addon
{
	NSWindowController * xcodeWindowController = [[NSApp keyWindow] windowController];
	NSString * currentXcodeproj = [[xcodeWindowController window] representedFilename];
	
	XCProject * project = [XCProject projectWithFilePath:currentXcodeproj];
	XCGroup * allAddonsGroup = [project groupWithPathFromRoot:@"addons"];
	[allAddonsGroup addGroupWithPath:addon.addonName];
	
	NSDirectoryEnumerator * addonDirectory = [[NSFileManager defaultManager] enumeratorAtPath:addon.addonPath];
	for(NSString * fileName in addonDirectory) {
		if([fileName characterAtIndex:0] == '.') return;
		if([fileName rangeOfString:@"example"].location != NSNotFound) return;
		
		// you'll need to look in Console.app to see this, it won't show up in the Xcode console
		NSLog(@"%@", fileName);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[project save];
	});
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	return YES;
}

@end

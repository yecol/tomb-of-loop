//
//  LCCKContactManager.m
//  LeanCloudChatKit-iOS
//
//  v0.7.15 Created by ElonChan (微信向我报BUG:chenyilong1010) on 16/3/10.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "LCCKContactManager.h"
#import "LCCKExampleConstants.h"

#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else

#import "LCChatKit.h"

#endif

@interface LCCKContactManager ()

@property(strong, nonatomic) NSMutableArray *contactIDs;

@end

@implementation LCCKContactManager

/**
 * create a singleton instance of LCCKContactManager
 */
+ (instancetype)defaultManager {
    static LCCKContactManager *_sharedLCCKContactManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLCCKContactManager = [[self alloc] init];
    });
    return _sharedLCCKContactManager;
}

- (NSMutableArray *)contactIDs {
    if (!_contactIDs) {
        _contactIDs = [NSMutableArray arrayWithContentsOfFile:[self storeFilePath]];
        if (!_contactIDs) {
            _contactIDs = [NSMutableArray array];
//            for (NSArray *contacts in __LCCKContactsOfSections) {
//                [_contactIDs addObjectsFromArray:contacts];
//            }
//            [_contactIDs writeToFile:[self storeFilePath] atomically:YES];
        }
    }
    NSLog(@"size = %lu", (unsigned long) _contactIDs.count);
    return _contactIDs;
}

- (void)initWith:(NSMutableArray *)contacts {
    [_contactIDs addObjectsFromArray:contacts];
    NSLog(@"_contactIDs, %@", _contactIDs);
    bool success = [_contactIDs writeToFile:[self storeFilePath] atomically:YES];
    NSLog(@"saved to file, %d", success);
}

- (NSArray *)fetchContactPeerIds {
    return self.contactIDs;
}

- (BOOL)existContactForPeerId:(NSString *)peerId {
    return [self.contactIDs containsObject:peerId];
}

- (BOOL)addContactForPeerId:(NSString *)peerId {
    if (!peerId) {
        return NO;
    }
    [self.contactIDs addObject:peerId];
    return [self saveContactIDs];
}

- (BOOL)removeContactForPeerId:(NSString *)peerId {
    if (!peerId) {
        return NO;
    }
    if (![self existContactForPeerId:peerId]) {
        return NO;
    }

    [self.contactIDs removeObject:peerId];

    return [self saveContactIDs];
}

- (BOOL)saveContactIDs {
    if (_contactIDs) {
        return [_contactIDs writeToFile:[self storeFilePath] atomically:YES];
    }
    return YES;
}

- (NSString *)storeFilePath {
//    NSString *fileName = [NSString stringWithFormat:@"LCCKContacts%@.plist", [LCChatKit sharedInstance].clientId];
    NSString *fileName = [NSString stringWithFormat:@"LCCKContacts.plist"];
    NSLog(@"file = %@", fileName);
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSLog(@"path = %@", path);
    return path;
}

@end

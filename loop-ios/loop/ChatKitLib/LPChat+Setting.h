//
//  LPChat+Setting.h
//  loop
//
//  Created by Yecol Hsu on 26/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LPChat.h"
#import <Foundation/Foundation.h>

@interface LPChat (Setting) //<MWPhotoBrowserDelegate>

/**
 *  初始化需要的设置
 */
- (void)lpchat_setting;
+ (void)lpchat_pushToViewController:(UIViewController *)viewController;
+ (void)lpchat_tryPresentViewControllerViewController:(UIViewController *)viewController;
+ (void)lpchat_clearLocalClientInfo;
+ (void)lpchat_changeGroupAvatarURLsForConversationId:(NSString *)conversationId
                                              shouldInsert:(BOOL)shouldInsert;
@end

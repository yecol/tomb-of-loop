//
//  LCCKConversationListViewController.m
//  LeanCloudChatKit-iOS
//
//  v0.7.15 Created by ElonChan (微信向我报BUG:chenyilong1010) on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "LCCKConversationListViewController.h"
#import "LCCKConstants.h"
#import "LCCKSessionService.h"
#import "LCCKConversationService.h"
#import "LCCKConversationListViewModel.h"

#import "LPChat.h"
#import "LCCKUtil.h"
#import "LCCKContactManager.h"
//#import "NSObject+LCCKHUD.h"

#if __has_include(<MJRefresh/MJRefresh.h>)

#import <MJRefresh/MJRefresh.h>

#else
#import "MJRefresh.h"
#endif

@interface LCCKConversationListViewController ()

@property(nonatomic, strong) NSMutableArray *conversations;
@property(nonatomic, copy) LCCKConversationListViewModel *conversationListViewModel;

@end

@implementation LCCKConversationListViewController

#pragma mark -
#pragma mark - UIViewController Life

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[LPChat sharedInstance];
    // add by yecol
//    [[LCChatKit sharedInstance] setDisableSingleSignOn:NO];
//    NSLog(@"yecolself111 tabbar =%@",self.tabBarController);sss

//    NSString *clientID = @"Bob";


    [LPChat invokeThisMethodAfterLoginSuccessWithClientId:[[AVUser currentUser] objectId] success:^{
        NSLog(@"logged in: username = @", [[AVUser currentUser] username]);
    }                                              failed:^(NSError *error) {
        NSLog(@"yecol said no - %@", error);
    }];

    // config for round corners for avatars.
    [[LCChatKit sharedInstance] setAvatarImageViewCornerRadiusBlock:^CGFloat(CGSize avatarImageViewSize) {
        if (avatarImageViewSize.height > 0) {
            return avatarImageViewSize.height / 2;
        }
        return 5;
    }];

    // bar item for begin a new conversation
    [self configureBarButtonItemStyle:LCCKBarButtonItemStyleAdd action:^(UIBarButtonItem *sender, UIEvent *event) {
        //
        [self createGroupConversation:sender];
    }];

    //finished add by yecol

    BOOL clientStatusOpened = [LCCKSessionService sharedInstance].client.status == AVIMClientStatusOpened;
    //NSAssert([LCCKSessionService sharedInstance].client.status == AVIMClientStatusOpened, @"client not opened");
    if (!clientStatusOpened) {
        [[LCCKSessionService sharedInstance] reconnectForViewController:self callback:nil];
    }


    self.navigationItem.title = @"Messages";
    self.tableView.delegate = self.conversationListViewModel;
    self.tableView.dataSource = self.conversationListViewModel;
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个 block
            [weakSelf.conversationListViewModel refresh];
            // 设置颜色
        }];
        header.stateLabel.textColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"TableView-PullRefresh-TextColor"];
        header.lastUpdatedTimeLabel.textColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"TableView-PullRefresh-TextColor"];
        header.backgroundColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"TableView-PullRefresh-BackgroundColor"];
        header;
    });
    self.tableView.backgroundColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"TableView-BackgroundColor"];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    !self.viewDidLoadBlock ?: self.viewDidLoadBlock(self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    !self.viewWillAppearBlock ?: self.viewWillAppearBlock(self, animated);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    !self.viewDidAppearBlock ?: self.viewDidAppearBlock(self, animated);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    !self.viewWillDisappearBlock ?: self.viewWillDisappearBlock(self, animated);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    !self.viewDidDisappearBlock ?: self.viewDidDisappearBlock(self, animated);
}

- (void)dealloc {
    !self.viewControllerWillDeallocBlock ?: self.viewControllerWillDeallocBlock(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    !self.didReceiveMemoryWarningBlock ?: self.didReceiveMemoryWarningBlock(self);
}

#pragma mark -
#pragma mark - LazyLoad Method

/**
 *  lazy load conversations
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)conversations {
    if (_conversations == nil) {
        _conversations = [[NSMutableArray alloc] init];
    }
    return _conversations;
}

/**
 *  lazy load conversationListViewModel
 *
 *  @return LCCKconversationListViewModel
 */
- (LCCKConversationListViewModel *)conversationListViewModel {
    if (_conversationListViewModel == nil) {
        LCCKConversationListViewModel *conversationListViewModel = [[LCCKConversationListViewModel alloc] initWithConversationListViewController:self];
        _conversationListViewModel = conversationListViewModel;
    }
    return _conversationListViewModel;
}

- (void)updateStatusView {
    if (!self.shouldCheckSessionStatus) {
        return;
    }
    BOOL isConnected = [LCCKSessionService sharedInstance].connect;
    if (isConnected) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.tableHeaderView = (UIView *) self.clientStatusView;
    }
}

- (void)refresh {
    [self.conversationListViewModel refresh];
}


// add by yecolr

- (void)createGroupConversation:(id)sender {
    [[self class] createNewConversationFromViewController:self];

}

+ (void)createNewConversationFromViewController:(UIViewController *)fromViewController {
    // FIXME: read contact list from local cache.

    NSString *userId = [[AVUser currentUser] objectId];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"1" forKey:@"type"];
    [dict setObject:@"500" forKey:@"limit"];
    [dict setObject:@"0" forKey:@"skip"];
    [dict setObject:userId forKey:@"userId"];
    [dict setObject:userId forKey:@"specifiedUserId"];


    [AVCloud rpcFunctionInBackground:@"getUserList" withParameters:dict block:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        NSLog(@"all persons = %@", objects);

        NSMutableArray *allPersonIds = [NSMutableArray array];
        for (AVUser *user in objects) {
            [allPersonIds addObject:user.objectId];
        }

        NSArray *users = [[LCChatKit sharedInstance] getCachedProfilesIfExists:allPersonIds
                                                               shouldSameCount:YES
                                                                         error:nil];
        NSString *currentClientID = [[LCChatKit sharedInstance] clientId];
        LCCKContactListViewController *contactListViewController =
                [[LCCKContactListViewController alloc]
                        initWithContacts:[NSSet setWithArray:users]
                                 userIds:[NSSet setWithArray:allPersonIds]
                         excludedUserIds:[NSSet setWithArray:@[currentClientID]]
                                    mode:LCCKContactListModeSingleSelection];

        contactListViewController.title = @"Begin Chat";

        [contactListViewController setSelectedContactCallback:^(UIViewController *viewController,
                NSString *peerId) {


            NSLog(@"should come to here.");
            if (!peerId || [peerId isEqual:@""]) {
                return;
            }

            [contactListViewController dismissViewControllerAnimated:true completion:nil];

            NSArray *peers = [NSArray arrayWithObject:peerId];
            //[self lcck_showMessage:@"创建群聊..." toView:fromViewController.view];
            [[LCChatKit sharedInstance]
                    createConversationWithMembers:peers
                                             type:LCCKConversationTypeGroup
                                           unique:YES
                                         callback:^(AVIMConversation *conversation, NSError *error) {
                                             //             [self lcck_hideHUDForView:fromViewController.view];
                                             if (conversation) {
                                                 NSLog(@"create conversation success");
                                                 //
                                                 //                 [self lcck_showSuccess:@"创建成功"
                                                 //                                 toView:fromViewController.view];
                                                 [self
                                                         exampleOpenConversationViewControllerWithConversaionId:
                                                                 conversation.conversationId
                                                                                       fromNavigationController:
                                                                                               fromViewController
                                                                                                       .navigationController];
                                             } else {
                                                 NSLog(@"create conversation failed.");
                                                 //                 [self lcck_showError:@"创建失败"
                                                 //                               toView:fromViewController.view];
                                             }
                                         }];
        }];


//    [contactListViewController setSelectedContactsCallback:^(UIViewController *viewController,
//                                                             NSArray<NSString *> *peerIds) {
//        if (!peerIds || peerIds.count == 0) {
//            return;
//        }
//        //[self lcck_showMessage:@"创建群聊..." toView:fromViewController.view];
//        [[LCChatKit sharedInstance]
//         createConversationWithMembers:peerIds
//         type:LCCKConversationTypeGroup
//         unique:YES
//         callback:^(AVIMConversation *conversation, NSError *error) {
////             [self lcck_hideHUDForView:fromViewController.view];
//             if (conversation) {
//                 NSLog(@"create conversation success");
////                 
////                 [self lcck_showSuccess:@"创建成功"
////                                 toView:fromViewController.view];
//                 [self
//                  exampleOpenConversationViewControllerWithConversaionId:
//                  conversation.conversationId
//                  fromNavigationController:
//                  fromViewController
//                  .navigationController];
//             } else {
//                 NSLog(@"create conversation failed.");
////                 [self lcck_showError:@"创建失败"
////                               toView:fromViewController.view];
//             }
//         }];
//    }];

//[[self navigationController] pushViewController:contactListViewController animated:YES];

        UINavigationController *navigationViewController =
                [[UINavigationController alloc] initWithRootViewController:contactListViewController];
        [[navigationViewController navigationBar] setTranslucent:NO];
        [fromViewController presentViewController:navigationViewController animated:YES completion:nil];

    }];
}


+ (void)exampleOpenConversationViewControllerWithConversaionId:(NSString *)conversationId
                                      fromNavigationController:
                                              (UINavigationController *)aNavigationController {

    NSLog(@"open a new conversation.");

    LCCKConversationViewController *conversationViewController =
            [[LCCKConversationViewController alloc] initWithConversationId:conversationId];
    conversationViewController.enableAutoJoin = YES;
    [conversationViewController
            setViewWillDisappearBlock:^(LCCKBaseViewController *viewController, BOOL aAnimated) {
//         [self lcck_hideHUDForView:viewController.view];
                NSLog(@"self.view will disappear");
            }];
    [conversationViewController
            setViewWillAppearBlock:^(LCCKBaseViewController *viewController, BOOL aAnimated) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                            animated:aAnimated];
            }];

    [aNavigationController pushViewController:conversationViewController animated:YES];
}


@end

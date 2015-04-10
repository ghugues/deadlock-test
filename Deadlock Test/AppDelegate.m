//
//  AppDelegate.m
//  Deadlock Test
//
//  Created by Guillaume on 30/03/2015.
//
//

#import "AppDelegate.h"
#import "ViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"PARSE_APPLICATION_ID" clientKey:@"PARSE_CLIENT_KEY"];
    [Parse setLogLevel:PFLogLevelDebug];
    [PFFacebookUtils initializeFacebook];

    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [PFFacebookUtils logInWithPermissions:@[@"public_profile"] block:^(PFUser *user, NSError *error) {
            if (!user || error) {
                NSLog(@"Login failed with error : %@", error);
            } else {
                NSLog(@"Login succeded.");
            }
        }];
    } else {
        NSLog(@"User already logged in.");
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

+ (void)fetchCurrentUser {
    [(AppDelegate *)[UIApplication sharedApplication].delegate fetchCurrentUser];
}

- (void)fetchCurrentUser
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser || !currentUser.objectId) {
        return;
    }

    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

    [currentUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object || error) {
            NSLog(@"Fetching current user %@ failed with error : %@", [PFUser currentUser], error);
        } else {
            NSLog(@"Fetching current user succeeded.");
        }
        [timer invalidate];
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }];
}

- (void)timerFireMethod:(NSTimer *)timer
{
//    static int count = 0;
//    NSLog(@"%s : %3d %@", __PRETTY_FUNCTION__, ++count, [PFUser currentUser].objectId);
    [PFUser currentUser].objectId;
}

@end

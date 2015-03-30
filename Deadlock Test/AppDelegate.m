//
//  AppDelegate.m
//  Deadlock Test
//
//  Created by Guillaume on 30/03/2015.
//
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface NSString (Additions)
+ (NSString *)stringWithRandomASCIICharactersWithLength:(NSUInteger)length;
@end


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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self synchronizeCurrentUser];
}

- (void)testDeadlock
{
    NSLog(@"testDeadlock ...");

    usleep(200);

    [self synchronizeCurrentUser];

    NSLog(@"No deadlock.");
}

- (void)synchronizeCurrentUser
{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser || !currentUser.objectId) {
        return;
    }

    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];

    [currentUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object || error) {
            NSLog(@"Fetching current user %@ failed with error : %@", [PFUser currentUser], error);
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
        } else {
            NSLog(@"Fetching current user succeeded.");
            [currentUser setObject:[NSString stringWithRandomASCIICharactersWithLength:10] forKey:@"randomValue"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded || error) {
                    NSLog(@"Saving currentUser %@ failed with error : %@", [PFUser currentUser], error);
                } else {
                    NSLog(@"Saving currentUser succeeded.");
                }
                [[UIApplication sharedApplication] endBackgroundTask:taskId];
            }];
        }
    }];
}

@end


@implementation NSString (Additions)

+ (NSString *)stringWithRandomASCIICharactersWithLength:(NSUInteger)length
{
    NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    NSUInteger charactersCount = characters.length;

    for (int i = 0; i < length; i++) {
        unichar randomChar = [characters characterAtIndex:arc4random_uniform((u_int32_t)charactersCount)];
        [randomString appendString:[NSString stringWithCharacters:&randomChar length:1]];
    }

    return [NSString stringWithString:randomString];
}

@end

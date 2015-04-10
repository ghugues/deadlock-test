//
//  AppDelegate.h
//  Deadlock Test
//
//  Created by Guillaume on 30/03/2015.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void)fetchCurrentUser;

@end

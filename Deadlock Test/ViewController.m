//
//  ViewController.m
//  Deadlock Test
//
//  Created by Guillaume on 30/03/2015.
//
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface NSArray (Additions)
- (BOOL)containsAllObjectsFromArray:(NSArray *)array;
@end


@implementation ViewController

- (IBAction)requestButtonAction:(id)sender
{
    [self requestFacebookReadPermissionsWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        [AppDelegate fetchCurrentUser];
    }];
}

- (void)requestFacebookReadPermissionsWithCompletionBlock:(void(^)(BOOL succeeded, NSError *error))completionBlock
{
    NSArray *facebookReadPermissions = @[@"public_profile", @"email", @"user_birthday", @"user_friends"];

    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (!error) {
            NSArray *currentPermissions = session.permissions;
            if (currentPermissions && [currentPermissions containsAllObjectsFromArray:facebookReadPermissions]) {
                NSLog(@"Read permissions are already present.");
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            }
            else {
                [session requestNewReadPermissions:facebookReadPermissions completionHandler:^(FBSession *session, NSError *error){
                    if (!error) {
                        NSArray *grantedPermissions = session.permissions;
                        if (grantedPermissions && [grantedPermissions containsAllObjectsFromArray:facebookReadPermissions]) {
                            NSLog(@"Request for read permissions succeded.");
                        } else {
                            NSLog(@"Read permissions were not all granted by user %@.", [PFUser currentUser].username);
                        }
                        if (completionBlock) {
                            completionBlock(YES, nil);
                        }
                    } else {
                        NSLog(@"Requesting Facebook read permissions failed with error : %@.", error);
                        if (completionBlock) {
                            completionBlock(NO, error);
                        }
                    }
                }];
            }
        } else {
            NSLog(@"Refreshing Facebook permissions failed with error : %@.", error);
            if (completionBlock) {
                completionBlock(NO, error);
            }
        }
    }];
}

@end


@implementation NSArray (Additions)

- (BOOL)containsAllObjectsFromArray:(NSArray *)array
{
    return !array || [[NSSet setWithArray:array] isSubsetOfSet:[NSSet setWithArray:self]];
}

@end

//
//  FBRequestConnection+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBSDKGraphRequest.h"
#import <PromiseKit/Promise.h>

@interface FBSDKGraphRequest (PromiseKit)

+ (PMKPromise *)requestMyCurrentPermissions;
+ (PMKPromise *)startForMe;

@end

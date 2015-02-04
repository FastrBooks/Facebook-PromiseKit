//
//  FBRequestConnection+PromiseKit.h
//  Facebook-PromiseKit
//
//  Created by Kirils Sivokozs on 30/01/2015.
//  Copyright (c) 2015 Kirils Sivokozs. All rights reserved.
//

#import "FBRequestConnection.h"
#import <PromiseKit/Promise.h>

@interface FBRequestConnection (PromiseKit)

+ (PMKPromise *)requestMyCurrentPermissions;
+ (PMKPromise *)startForMe;

@end

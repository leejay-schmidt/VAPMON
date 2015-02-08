//
//  Doctor.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-08.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "Doctor.h"

@implementation Doctor


@synthesize code;

static Doctor *instance = nil;

+(Doctor *)getInstance {
    @synchronized(self) {
        if(instance == nil) {
            instance = [Doctor new];
        }
    }
    return instance;
}


@end
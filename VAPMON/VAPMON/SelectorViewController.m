//
//  SelectorViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "SelectorViewController.h"

@interface SelectorViewController ()

@end

@implementation SelectorViewController
@synthesize xmitButton;
@synthesize viewButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    doctor = [Doctor getInstance];
    NSLog(@"Doctor set: code=%@", doctor.code);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

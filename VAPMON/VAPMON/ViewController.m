//
//  ViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize docCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    doctor = [Doctor getInstance];
    [docCode addTarget:self action:@selector(docCodeChanged) forControlEvents:UIControlEventEditingChanged];
    [docCode becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)docCodeChanged {
    if(docCode.text.length == 4) {
        doctor.code = docCode.text;
        [self performSegueWithIdentifier:@"Next" sender:self];
    }
}

@end

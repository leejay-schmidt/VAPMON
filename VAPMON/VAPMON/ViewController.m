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

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

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
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Doctor"
                                                                inManagedObjectContext:context];
        [object setValue:@"John Doe" forKey:@"doctorName"];
        [object setValue:doctor.code forKey:@"doctorCode"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Patient"
                                               inManagedObjectContext:context];
        [object setValue:@"Jane Doe" forKey:@"patientName"];
        [object setValue:@"1234" forKey:@"doctorCode"];
        [object setValue:@"ae5493" forKey:@"patientNumber"];
        if (![context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Patient"
                                               inManagedObjectContext:context];
        [object setValue:@"Jimmy Doe" forKey:@"patientName"];
        [object setValue:@"4321" forKey:@"doctorCode"];
        [object setValue:@"ae5493" forKey:@"patientNumber"];
        if (![context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }

        [self performSegueWithIdentifier:@"Next" sender:self];
    }
}

@end

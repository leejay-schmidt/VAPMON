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
        NSString *csv = @"doctorName,doctorCode\nJohn Doe,1234\nJane Doxall,4534";
        CSVParse *parser = [[CSVParse alloc] init];
        NSMutableArray *data = [parser parseCSV:csv withSeparator:@","];
        NSLog(@"%@", data);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *object = nil;
        NSError *error;
        for (NSUInteger i = 0; i < data.count; ++i) {
            object = [NSEntityDescription insertNewObjectForEntityForName:@"Doctor"
                                                                    inManagedObjectContext:context];
            
            NSDictionary *curDoc = [data objectAtIndex: i];
            [object setValue:[curDoc valueForKey:@"doctorName"] forKey:@"doctorName"];
            [object setValue:[curDoc valueForKey:@"doctorCode"] forKey:@"doctorCode"];
            if (![context save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
        }
        csv = @"patientName|doctorCode|patientNumber\nJimmy Doe|4534|ae5786\nJane Doxall|1234|ae5493";
        data = [parser parseCSV:csv withSeparator:@"|"];
        NSLog(@"%@", data);
        for (NSUInteger i = 0; i < data.count; ++i) {
            object = [NSEntityDescription insertNewObjectForEntityForName:@"Patient"
                                                   inManagedObjectContext:context];
            
            NSDictionary *curPatient = [data objectAtIndex: i];
            [object setValue:[curPatient valueForKey:@"patientName"] forKey:@"patientName"];
            [object setValue:[curPatient valueForKey:@"doctorCode"] forKey:@"doctorCode"];
            [object setValue:[curPatient valueForKey:@"patientNumber"] forKey:@"patientNumber"];
            if (![context save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
        }
             
        [self performSegueWithIdentifier:@"Next" sender:self];
    }
}

@end

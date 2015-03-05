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
        csv = @"patientName|doctorCode|patientNumber\nJimmy Doe|1234|07889879\nJane Doxall|1234|3048de16\n\
        John Parsons|1234|e7232376";
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
        csv = @"doctorCode,patientNumber,date,flowRateValue,pressureValue\n\
        1234,3048de16,2015-02-24,5,1.3\n\
        1234,3048de16,2015-02-25,5,1.3\n\
        1234,07889879,2015-02-25,5,1.3\n\
        1234,07889879,2015-02-25,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,07889879,2015-02-26,5,1.3\n\
        1234,3048de16,2015-03-01,5,1.3\n\
        1234,3048de16,2015-03-01,5,1.3\n\
        1234,3048de16,2015-03-01,5,3\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,3.7898912163441487,2.5337436289322595\n\
        1234,3048de16,2015-03-01,3.7898912163441487,2.5337436289322595\n\
        1234,3048de16,2015-03-01,3.7898912163441487,2.5337436289322595\n\
        1234,3048de16,2015-03-01,3,2\n\
        1234,3048de16,2015-03-01,3,2\n\
        1234,3048de16,2015-03-01,3,2\n\
        1234,3048de16,2015-03-01,9,3\n\
        1234,3048de16,2015-03-01,9,3\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,0,4\n\
        1234,3048de16,2015-03-01,0,1\n\
        1234,3048de16,2015-03-01,8,4\n\
        1234,3048de16,2015-03-01,4,3\n\
        1234,3048de16,2015-03-01,8,1\n\
        1234,3048de16,2015-03-01,5,2\n\
        1234,a7889879,2015-03-01,7,1\n\
        1234,a7889879,2015-03-01,8,1\n\
        1234,07889879,2015-03-02,8,3\n\
        1234,e7232376,2015-03-03,7,1";
        
        data = [parser parseCSV:csv withSeparator:@","];
        NSLog(@"%@", data);
        for (NSUInteger i = 0; i < data.count; ++i) {
            object = [NSEntityDescription insertNewObjectForEntityForName:@"DataPoint"
                                                   inManagedObjectContext:context];
            
            NSDictionary *curDP = [data objectAtIndex: i];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [object setValue:[curDP valueForKey:@"patientNumber"] forKey:@"patientNumber"];
            [object setValue:[curDP valueForKey:@"doctorCode"] forKey:@"doctorCode"];
            [object setValue:[formatter dateFromString:[curDP valueForKey:@"date"]] forKey:@"date"];
            [object setValue:[numFormatter numberFromString:[curDP valueForKey:@"flowRateValue"]] forKey:@"flowRateValue"];
            [object setValue:[numFormatter numberFromString:[curDP valueForKey:@"pressureValue"]] forKey:@"pressureValue"];
            if (![context save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
        }
             
        [self performSegueWithIdentifier:@"Next" sender:self];
    }
}

@end

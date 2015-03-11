
//
//  DataViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-03-01.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController
@synthesize dataForPlot;
@synthesize mainNav;
@synthesize back;
@synthesize patientObject;
@synthesize graph;

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.dataForPlot count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot
    field:(NSUInteger)fieldEnum
    recordIndex:(NSUInteger)idx {
    NSDictionary *val = [self.dataForPlot objectAtIndex:idx];
    
    if(fieldEnum == CPTScatterPlotFieldX)
        return [NSNumber numberWithInteger:(NSInteger)idx];
    else
        return [val valueForKey:@"pressureValue"];
}

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
    self.mainNav.title = [patientObject valueForKey:@"patientName"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    //NSLog(@"Set Name, now running fetch request");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataPoint"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(doctorCode like %@) AND (patientNumber like %@)",
                              doctor.code, [patientObject valueForKey:@"patientNumber"]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                 ascending:YES];
    self.dataForPlot = [[[managedObjectContext executeFetchRequest:fetchRequest error:nil]
                         sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    NSLog(@"%@", self.dataForPlot);
    
    //[self.patientTable reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end
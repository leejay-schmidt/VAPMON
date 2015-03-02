
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
@synthesize patientName;

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
    self.mainNav.title = patientName;
    //NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Patient"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doctorCode like %@", doctor.code];
    //[fetchRequest setPredicate:predicate];
    //self.patientArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
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
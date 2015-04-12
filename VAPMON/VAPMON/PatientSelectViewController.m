//
//  DeviceViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "PatientSelectViewController.h"

@interface PatientSelectorViewController ()

@end

@implementation PatientSelectorViewController
@synthesize patientArray;
@synthesize back;
@synthesize patientTable;
@synthesize overlayView;
@synthesize activityView;

/**
 * Function to enable loading state
 * written by Leejay
 */
- (void)stateIsLoading
{
    if(![self.overlayView isDescendantOfView:self.view])
    {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.4;
        [self.view addSubview:self.overlayView];
        self.activityView=[[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.center=self.view.center;
        [self.activityView startAnimating];
        [self.overlayView addSubview:self.activityView];
    }
}

/**
 * Function to disable loading state
 * written by Leejay
 */
- (void)stateIsLoaded
{
    if([self.overlayView isDescendantOfView:self.view])
    {
        [self.activityView removeFromSuperview];
        [self.overlayView removeFromSuperview];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

/**
 * Executed when the view controller loads
 * Please refer to the Apple documentation for more information
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stateIsLoading];
    doctor = [Doctor getInstance];
    //Fetch the patients from Core Data
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Patient"];
    fetchRequest.includesSubentities = NO;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doctorCode==%@", doctor.code];
    [fetchRequest setPredicate:predicate];
    self.patientArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    //Load it all up in the table view
    [self.patientTable reloadData];
    [self stateIsLoaded];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)deviceTable
 numberOfRowsInSection:(NSInteger)section{
    return [patientArray count];
}

- (UITableViewCell *)tableView:(UITableView *)patientTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.patientTable dequeueReusableCellWithIdentifier:@"PatientCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PatientCell"];
    }
    NSManagedObject *object = [patientArray objectAtIndex:indexPath.row];
    NSLog(@"%@", [object valueForKey:@"doctorCode"]);
    cell.textLabel.text = [object valueForKey:@"patientName"];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToPatient"]) {
        NSIndexPath *indexPath = [self.patientTable indexPathForSelectedRow];
        DataViewController *destViewController = segue.destinationViewController;
        NSDictionary *patient = [patientArray objectAtIndex:indexPath.row]; 
        destViewController.patientObject = patient;
    }
}
@end
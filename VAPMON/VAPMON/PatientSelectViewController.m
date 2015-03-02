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
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Patient"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doctorCode like %@", doctor.code];
    [fetchRequest setPredicate:predicate];
    self.patientArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.patientTable reloadData];
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
        destViewController.patientName = [patient valueForKey:@"patientName"];
    }
}
@end
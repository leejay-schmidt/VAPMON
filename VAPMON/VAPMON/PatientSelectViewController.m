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

- (void)viewDidLoad {
    [super viewDidLoad];
    patientArray = [[NSMutableArray alloc] initWithObjects:@"Patient1", @"Patient2", @"Patient3", @"Patient4", @"Patient5", @"Patient6", nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)deviceTable
 numberOfRowsInSection:(NSInteger)section{
    return [patientArray count];
}

- (UITableViewCell *)tableView:(UITableView *)deviceTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.patientTable dequeueReusableCellWithIdentifier:@"PatientCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PatientCell"];
    }
    
    cell.textLabel.text = [patientArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end
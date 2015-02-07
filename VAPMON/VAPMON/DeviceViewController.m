//
//  ViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "DeviceViewController.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController
@synthesize deviceTable;
@synthesize back;
@synthesize deviceArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    deviceArray = [[NSMutableArray alloc] initWithObjects:@"Device1", @"Device2", @"Device3", @"Device4", @"Device5", @"Device6", nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)deviceTable
    numberOfRowsInSection:(NSInteger)section{
    return [deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)deviceTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.deviceTable dequeueReusableCellWithIdentifier:@"DeviceCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceCell"];
    }
    
    cell.textLabel.text = [deviceArray objectAtIndex:indexPath.row];
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

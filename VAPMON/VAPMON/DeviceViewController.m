//
//  DeviceViewController.m
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
@synthesize btleManager;
@synthesize back;
@synthesize deviceArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceArray = [[NSMutableArray alloc] init];
    self.btleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)manager
{
    switch (manager.state)
    {
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"State: Unsupported");
        } break;
            
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"State: Unauthorized");
        } break;
            
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"State: Powered Off");
        } break;
            
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"State: Powered On");
            [self.btleManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
        } break;
            
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"State: Unknown");
        } break;
            
        default:
        {
        }
            
    }
}

- (void)centralManager:(CBCentralManager*)btleManager didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if(![deviceName isEqual:@""]) {
        NSLog(@"Found device: %@", peripheral.name);
        [self.deviceArray addObject:peripheral];
    }
    [self.deviceTable reloadData];
    
}

- (NSInteger)tableView:(UITableView *)deviceTable
    numberOfRowsInSection:(NSInteger)section{
    return [deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)deviceTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CBPeripheral *btleDevice = [self.deviceArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.deviceTable dequeueReusableCellWithIdentifier:@"DeviceCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceCell"];
    }
    
    cell.textLabel.text = btleDevice.name;
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

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
@synthesize rcvdData;
@synthesize selectedPeripheral;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stateIsLoading];
    self.deviceArray = [[NSMutableArray alloc] init];
    self.btleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.rcvdData = [[NSMutableData alloc] init];
    
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
            NSLog(@"Scanning started");
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
        if(![self.deviceArray containsObject:peripheral]) {
            NSLog(@"Found device: %@", peripheral.name);
            [self.deviceArray addObject:peripheral];
            [self.deviceTable reloadData];
        }
    }
    [self stateIsLoaded];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    
    [self.btleManager stopScan];
    NSLog(@"Scanning stopped");
    [self.rcvdData setLength:0];
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"Discovered Characteristic");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
        NSLog(@"Discovered Service");
    }
    // Discover other characteristics
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        //[_textview setText:[[NSString alloc] initWithData:self.rcvdData encoding:NSUTF8StringEncoding]];
        
        
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        [self.btleManager cancelPeripheralConnection:peripheral];
    }
    
    [self.rcvdData appendData:characteristic.value];
}

- (NSInteger)tableView:(UITableView *)deviceTable numberOfRowsInSection:(NSInteger)section{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPeripheral = [self.deviceArray objectAtIndex:indexPath.row];
    NSLog(@"Connecting to peripheral %@", self.selectedPeripheral.name);
    [self.btleManager connectPeripheral:self.selectedPeripheral options:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end

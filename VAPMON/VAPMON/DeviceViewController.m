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
 * Core Data goodness
 */
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

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

/**
 * Apple things for initiating when the view controller loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    //put into a loading state
    [self stateIsLoading];
    //device array for listing possible device choices
    self.deviceArray = [[NSMutableArray alloc] init];
    //turn on the Core Bluetooth manager
    self.btleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //string for the received CSV from Bluetooth
    self.rcvdData = [[NSMutableString alloc] init];
    doctor = [Doctor getInstance];
    
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 * Handles state changes in the Bluetooth
 * Please refer to iOS SDK documentation for more information
 */
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
            //start scan once the central manager is available
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

/**
 * Handles when an available BTLE device is detected
 * Please refer to iOS SDK for more information
 */
- (void)centralManager:(CBCentralManager*)btleManager didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    //Grab the device name from the advertised name
    NSString *deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if(![deviceName isEqual:@""]) {
        if(![self.deviceArray containsObject:peripheral]) {
            //Log the device detected, add it to the table as a possible selectable device
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

/**
 * Handles when the peripheral is connected to
 * Please refer to iOS SDK documentation for more information
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    
    //Stop the manager scan
    [self.btleManager stopScan];
    NSLog(@"Scanning stopped");
    
    peripheral.delegate = self;
    //find the services available, to ensure that the desired service is available
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

/**
 * Handles the discovery of the possible characteristics for the device with the desired service
 * Please refer to the iOS SDK documentation for more information
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Characteristic Error: NO CHARACTERISTICS FOUND!");
        return;
    }
    
    //verify that the right characteristic is found
    //if it is, prepare for data transfer
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //NSString *docCodeStr = [NSString stringWithFormat:@"%@\n", doctor.code];
            //NSData *docCodeToSend = [docCodeStr dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"Sending Doctor Code: %@", doctor.code);
            //CBMutableCharacteristic *newCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristic.UUID
            //                                            properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
            //[peripheral writeValue:docCodeToSend forCharacteristic:newCharacteristic type:CBCharacteristicWriteWithResponse];
            [self stateIsLoading];
            NSLog(@"Discovered Characteristic");
        }
    }
}

/**
 * Handles the service(s) being discovered
 * Please refer to the iOS SDK documentation for more information
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        return;
    }
    //Find the characteristics for that service
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"Discovered Service");
    }
    // Discover other characteristics
}

/**
 * Handles if a value is writen to the device with the characteristic
 * Please refer to the iOS SDK documentation for more information
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error) {
        NSLog(@"Error writing to characteristic");
    }
    else {
        NSLog(@"Successfully wrote to characteristic");
    }
}

/**
 * Handles when a value is sent from the connected Bluetooth LE peripheral
 * Please refer to the iOS SDK documentation for more information
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
        return;
    }
    NSLog(@"GOT DATA from %@", characteristic.UUID);
    //Get the string that was sent on the characteristic
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    NSLog(@"%@", stringFromData);
    //check for EOF
    //if the EOF is hit, then wrap this shi...stuff up
    if ([stringFromData containsString:@"DONELIKEDINNER"]) {
        
        //[_textview setText:[[NSString alloc] initWithData:self.rcvdData encoding:NSUTF8StringEncoding]];
        NSLog(@"HIT EOF");
        //turn off notification
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        //close the peripheral connection
        [self.btleManager cancelPeripheralConnection:peripheral];
        
        //parse the CSV string into core data
        //create the CSV string and the CSVParse instance
        CSVParse *parser = [[CSVParse alloc] init];
        NSString *csv = [NSString stringWithFormat:@"%@", self.rcvdData];
        //parse the CSV into a mutable array
        NSMutableArray *data = [parser parseCSV:csv withSeparator:@","];
        NSManagedObjectContext *context = [self managedObjectContext];
        //create a new Core Data managed object
        NSManagedObject *object = nil;
        NSLog(@"%@", data);
        //for each object
        for (NSUInteger i = 0; i < data.count; ++i) {
            //enter the new data point entity into the table
            object = [NSEntityDescription insertNewObjectForEntityForName:@"DataPoint"
                                                   inManagedObjectContext:context];
            //save up the object
            NSDictionary *curDP = [data objectAtIndex: i];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            //load the object into Core Data (push values into proper keys) for persistence
            [object setValue:[curDP valueForKey:@"patientNumber"] forKey:@"patientNumber"];
            [object setValue:[curDP valueForKey:@"doctorCode"] forKey:@"doctorCode"];
            [object setValue:[formatter dateFromString:[curDP valueForKey:@"date"]] forKey:@"date"];
            [object setValue:[numFormatter numberFromString:[curDP valueForKey:@"flowRateValue"]] forKey:@"flowRateValue"];
            [object setValue:[numFormatter numberFromString:[curDP valueForKey:@"pressureValue"]] forKey:@"pressureValue"];
            NSLog(@"Saving new data point");
            if (![context save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
        }
        [self stateIsLoaded];
        //exit the loading state, display success message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"Data transmission successful"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //go back to the selector view controller
        [self performSegueWithIdentifier:@"Back" sender:self];
        

    }
    else {
        //append incoming data to string if not EOF
        [self.rcvdData appendString:stringFromData];
    }
}

/**
 * Tableview row number handler
 * Please refer to iOS SDK documentation for more information
 */
- (NSInteger)tableView:(UITableView *)deviceTable numberOfRowsInSection:(NSInteger)section{
    return [deviceArray count];
}


/**
 * Return the style and peripheral array in the device table
 * Please review iOS SDK documentation for more information on this method call
 */
- (UITableViewCell *)tableView:(UITableView *)deviceTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Instantiate a new peripheral for the selected device
    CBPeripheral *btleDevice = [self.deviceArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.deviceTable dequeueReusableCellWithIdentifier:@"DeviceCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceCell"];
    }
    //return the name of the peripheral too
    cell.textLabel.text = btleDevice.name;
    return cell;
}
/**
 * Trigger the peripheral connection in case of selecting that peripheral from the device tableview
 * Please review iOS SDK documentation for more information on this method call
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPeripheral = [self.deviceArray objectAtIndex:indexPath.row];
    NSLog(@"Connecting to peripheral %@", self.selectedPeripheral.name);
    NSString *message = @"Please press okay, and then select \"Transmit Mode\" on the monitoring device.\
                          \nData transmission can take a few minutes, so please be patient.";
    //Display the instruction message
    UIAlertView *instructionAlert = [[UIAlertView alloc] initWithTitle:@"Transfer Data"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    //Connect to the peripheral corresponding to that row, start listening
    [self.btleManager connectPeripheral:self.selectedPeripheral options:nil];
    [instructionAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end

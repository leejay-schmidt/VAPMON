//
//  DeviceViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "SERVICES.h"
#import "Doctor.h"
#import "CSVParse.h"
#import <CoreData/CoreData.h>


@interface DeviceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate> {
    Doctor *doctor;
}

@property IBOutlet UIBarButtonItem *back;
@property (nonatomic, strong) IBOutlet UITableView *deviceTable;
@property (nonatomic, strong) CBCentralManager *btleManager;
@property (nonatomic, strong) CBPeripheral *selectedPeripheral;
@property (nonatomic, strong) NSMutableString *rcvdData;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end


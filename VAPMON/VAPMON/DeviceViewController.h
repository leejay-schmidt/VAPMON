//
//  ViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UIBarButtonItem *back;
@property (nonatomic, strong) IBOutlet UITableView *deviceTable;

@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end


//
//  DataViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-03-01.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#ifndef VAPMON_DataViewController_h
#define VAPMON_DataViewController_h


#endif

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import "CorePlot-CocoaTouch.h"
#import "Doctor.h"

//@interface DataViewController : UIViewController <CPTPlotDataSource, CPTAxisDelegate> {
    //CPTXYGraph *graph;
@interface DataViewController : UIViewController {
    NSMutableArray *dataForPlot;
    Doctor *doctor;
}

@property IBOutlet UIBarButtonItem *back;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForPlot;
@property (nonatomic, strong) NSString *patientName;
@property (nonatomic, strong) IBOutlet UINavigationItem *mainNav;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end
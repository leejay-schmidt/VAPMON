//
//  SelectorViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doctor.h"

@interface SelectorViewController : UIViewController <UITextFieldDelegate> {
    Doctor *doctor;
}

@property (nonatomic, strong) IBOutlet UIButton *xmitButton;
@property (nonatomic, strong) IBOutlet UIButton *viewButton;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end


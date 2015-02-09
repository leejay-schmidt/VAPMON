//
//  ViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doctor.h"
#import "CSVParse.h"

@interface ViewController : UIViewController <UITextFieldDelegate> {
    Doctor *doctor;
}

@property (nonatomic, strong) IBOutlet UITextField *docCode;


@end


//
//  ViewController.h
//  objcFESSJSONv1.0
//
//  Created by macbook on 2015/03/08.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController
{
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UITextField *addressFld;
- (IBAction)saveBtn:(id)sender;
- (IBAction)pushReturn:(id)sender;
- (IBAction)singleTapped:(id)sender;

@end

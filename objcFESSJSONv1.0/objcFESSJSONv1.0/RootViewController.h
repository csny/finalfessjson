//
//  RootViewController.h
//  objcFESSJSONv1.0
//
//  Created by macbook on 2015/03/08.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RootViewController : UITableViewController

// property *items,appDelegateは手入力、ストーリーボードとのひもづけなし
@property NSArray *items;
@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITextField *searchFld;
- (IBAction)pushReturn:(id)sender;
- (IBAction)singleTapped:(id)sender;

@end

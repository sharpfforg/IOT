//
//  LCtrlTableViewController.h
//  IOTDemo1
//
//  Created by linfeng on 14-9-25.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCtrlTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *swLight;
@property (weak, nonatomic) IBOutlet UITextField *tfGenericData;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@end

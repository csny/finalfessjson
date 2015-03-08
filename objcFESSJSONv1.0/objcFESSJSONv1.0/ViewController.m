//
//  ViewController.m
//  objcFESSJSONv1.0
//
//  Created by macbook on 2015/03/08.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // viewが読み込まれたら、テキストフィールドにservernameを表示
    appDelegate = [[UIApplication sharedApplication] delegate];
    _addressFld.text = [NSString stringWithFormat:@"%@", appDelegate.servername];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ボタンが押されたらsevernameをテキストフィールドの文字で上書き
- (IBAction)saveBtn:(id)sender {
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.servername = [NSString stringWithFormat:@"%@", _addressFld.text];
}
// キーボード閉じる動作まとめ
// テキストフィールドのReturn押下でキーボードを閉じる
- (IBAction)pushReturn:(id)sender {
}
// キーボード外のシングルタップで閉じる
- (IBAction)singleTapped:(id)sender {
    [self.view endEditing:YES];
}
@end

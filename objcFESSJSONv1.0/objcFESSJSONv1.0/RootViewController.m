//
//  RootViewController.m
//  objcFESSJSONv1.0
//
//  Created by macbook on 2015/03/08.
//  Copyright (c) 2015年 macbook. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
// property*itemsは手入力、ストーリーボードとのひもづけなし
@property NSArray *items;
@end

@implementation RootViewController
// itemsへのsynthesize
@synthesize items;

- (void)viewDidLoad {
    [super viewDidLoad];
    // 空の配列を用意
    self.items = [NSArray array];
    // 更新機能の呼び出し
    [self refleshControlSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// viewが読み込まれたら
// TableViewControllerのviewDidLoadは起動時のみ、viewDidAppearはBackボタンでも毎回読み込まれる
- (void)viewDidAppear:(BOOL)animated
{
    appDelegate = [[UIApplication sharedApplication] delegate];
}

// セル数を返す(tableview必須メソッド)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"cell数:%ld",[items count]);
    return [items count];
    //NSLog(@"numberOfSectionsInTableView called");
}
// セルへの値入力(tableview必須メソッド)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 代表セルのID定義、ストーリーボードと合わせる
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // 代表セルがない場合の設定、たぶん自動で作る感じ
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // indexPath.rowの値をインデックスに、1グループずつJSON情報をitemに格納
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    // セルにタイトルとサブタイトルを表示
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text=[item objectForKey:@"url"];
    
    return cell;
    //NSLog(@"cellForRowAtIndexPath called");
}

// 下に引っ張ると更新する機能の準備
- (void)refleshControlSetting
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(onRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

// Alert表示
// [self showAlert:@"text"];で呼ぶ
- (void)showAlert:(NSString*)text
{
    // UIAlertControllerクラスの有無でiOS判定
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS 8の処理
        // UIAlertControllerを使ってアラートを表示
        UIAlertController *alert = nil;
        alert = [UIAlertController alertControllerWithTitle:@"Request Failed"
                                                    message:text
                                             preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        // iOS 7の処理
        // UIAlertViewを使ってアラートを表示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed"
                                                        message:text
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

// jsonをパースして配列格納
- (void)jsonParse:(NSData*)json
{
    // JSONをパース(NSDictionary-objectForKey)
    NSDictionary *temp_array = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    // NSDictionaryにセットされた値からまずresponseを取り出してtemp_arrayに再セット
    temp_array = [temp_array objectForKey:@"response"];
    // アプリデータの配列をプロパティに保持
    self.items = [temp_array objectForKey:@"result"];
    
    // TableView をリロード、ストーリーボードと名前を合わせる
    [self.tableView reloadData];
    NSLog(@"JsonParse called");
}
// 検索文字置換
-(NSString *)checkWords
{
    // ASCIIコード以外が含まれるかチェック
    NSString *words, *words1;
    NSCharacterSet *stringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:_searchFld.text];
    NSCharacterSet *asciiWithoutSpaceCharacterSet = [NSCharacterSet characterSetWithRange:NSMakeRange(0x21, 0x5e)];
    if ([asciiWithoutSpaceCharacterSet isSupersetOfSet:stringCharacterSet]) {
        // 英数字のみ
        words = _searchFld.text;
    } else {
        // 英数字以外の文字がある(空白の可能性もある)
        // 前後の空白を削除
        words1 = [_searchFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // 間の空白を+に置換
        words = [words1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    return [NSString stringWithFormat:@"%@", words];
}

// 通信処理
- (void)urlSession
{
    // 参考URL
    // http://dev.classmethod.jp/references/ios7-nsurlsession-2/
    // NSURLSession の作成
    NSURLSession *session = [NSURLSession sharedSession];
    
    // URL準備
    [self checkWords];
    // ttp://サーバアドレス/fess/json?query=検索語となるように生成
    NSString *temp_url = [NSString stringWithFormat:@"http://%@/fess/json?query=%@",appDelegate.servername, [self checkWords]];
    NSURL *url = [NSURL URLWithString:temp_url];
    
    // Requestの条件設定、キャッシュを使い、タイムアウトは7秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:7.0];
    
    // NSURLSessionDownloadTask の作成
    // responseはHTTPステータスコードが、
    // errorは、エラーコードや理由が入って帰ってくる。中身見た方が早い。
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *json, NSURLResponse *response, NSError *error) {
                                            if (json==nil || (error)) {
                                                // 通信が異常終了したときの処理
                                                //NSLog(@"request failed.");
                                                //NSLog(@"ERROR:%@",error);
                                                //NSLog(@"HTTPstatus:%@",response);
                                                // アラートを出して処理中断
                                                [self showAlert:@"Check network environment"];
                                                return;
                                            }
                                            // 通信が正に常終了したときの処理
                                            [self jsonParse:json];
                                        }];
    
    // 通信resume開始
    [task resume];
    NSLog(@"TaskResume called");
}

// 更新時に実行
- (void)onRefresh:(UIRefreshControl *)refreshControl
{
    [refreshControl beginRefreshing];
    // ここの間に更新のロジックを書く
    [self urlSession];
    [refreshControl endRefreshing];
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

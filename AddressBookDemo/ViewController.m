//
//  ViewController.m
//  AddressBookDemo
//
//  Created by colourlife on 15/4/2.
//  Copyright (c) 2015年 wuchao. All rights reserved.
//

#import "ViewController.h"
#import "BookAddressViewController.h"

@interface ViewController ()<BookAddressViewDelegate>
{
    UILabel *_label;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100, 100, 100, 40)];
    [button setTitle:@"通讯录" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button addTarget:self action:@selector(selectBookAddress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    _label = [[UILabel alloc] initWithFrame:CGRectMake(50, 260, 220, 40)];
    [_label setTextColor:[UIColor blackColor]];
    [self.view addSubview:_label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectBookAddress {
    BookAddressViewController *bookVC = [[BookAddressViewController alloc] init];
    bookVC.delegate                    =  self;

    [self presentViewController:bookVC animated:YES completion:nil];
}

- (void)passValue:(NSString *)phoneNum KeyName:(NSString *)keyName{
    // 返回所选中的联系人名称和号码
    [_label setText:[NSString stringWithFormat:@"%@：%@",keyName,phoneNum]];
    [_label sizeToFit];
}

@end

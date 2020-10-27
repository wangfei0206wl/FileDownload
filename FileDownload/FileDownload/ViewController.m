//
//  ViewController.m
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import "ViewController.h"
#import "FileUploadVC.h"
#import "FileDownloadVC.h"
#import "XPFileDownloadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnDownload = [self buttonWithTitle:@"下载" color:nil font:nil action:@selector(onClickDownload:)];
    [self.view addSubview:btnDownload];
    
    UIButton *btnUpload = [self buttonWithTitle:@"上传" color:nil font:nil action:@selector(onClickUpload:)];
    [self.view addSubview:btnUpload];
    
    UIButton *btnRemoveDownload = [self buttonWithTitle:@"清空下载" color:nil font:nil action:@selector(onClickClearDownload:)];
    [self.view addSubview:btnRemoveDownload];
    
    [btnDownload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-60);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    [btnUpload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(btnDownload.mas_bottom).offset(20);
        make.size.equalTo(btnDownload);
    }];
    [btnRemoveDownload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(btnUpload.mas_bottom).offset(20);
        make.size.equalTo(btnUpload);
    }];
}

#pragma mark - action

- (void)onClickDownload:(id)sender {
    FileDownloadVC *vc = [[FileDownloadVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)onClickUpload:(id)sender {
    FileUploadVC *vc = [[FileUploadVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)onClickClearDownload:(id)sender {
    [[XPFileDownloadManager shared] removeAllFileCaches];
}

- (UIButton *)buttonWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(color?color:[UIColor blackColor]) forState:UIControlStateNormal];
    button.titleLabel.font = font?font:[UIFont systemFontOfSize:16];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 1;
    
    return button;
}

@end

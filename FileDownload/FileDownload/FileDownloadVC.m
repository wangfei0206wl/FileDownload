//
//  FileDownloadVC.m
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import "FileDownloadVC.h"
#import "XPFileTotalSizeHelper.h"
#import "XPFileDownloadManager.h"

@interface FileDownloadVC ()

@property (nonatomic, strong) UIButton *btnStartAll;
@property (nonatomic, strong) UIButton *btnStopAll;
@property (nonatomic, strong) NSMutableArray *progressViews;
@property (nonatomic, strong) NSMutableArray *progressLabels;

@property (nonatomic, strong) NSArray *downloadInfos;

@end

@implementation FileDownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"下载测试";
    self.progressViews = [NSMutableArray array];
    self.progressLabels = [NSMutableArray array];
    self.downloadInfos = [self downloadFiles];
    
    [self createViews];
    [self asyncFileSize];
}

#pragma mark - action

- (void)onClickStartAll:(id)sender {
    
}

- (void)onClickStopAll:(id)sender {
    
}

- (void)onClickItem:(id)sender {
    UIButton *button = (UIButton *)sender;
    int index = (int)button.tag - 2000;
    
    if (index >= 0 && index < self.downloadInfos.count) {
        NSDictionary *dicInfo = self.downloadInfos[index];
        NSString *url = dicInfo[@"url"];
        XPFileDownloadModel *model = [[XPFileDownloadManager shared] isExistDownloadFileCache:url];
        
        button.selected = !model.bDownloading;
        
        if (model.bDownloading) {
            // 下载中，则停止下载
            [[XPFileDownloadManager shared] cancelDownloadWithUrl:url];
        } else {
            // 开始下载
            __weak typeof(self) weakSelf = self;
            [[XPFileDownloadManager shared] downloadFileWithUrl:url destFilePath:nil progress:^(long long cacheFileSize, long long totalFileSize) {
                [weakSelf handleDownloadProgress:cacheFileSize totalFileSize:totalFileSize index:index];
            } finish:^(NSError *error, NSString *filePath) {
                button.selected = NO;
                [weakSelf handleDownloadFinish:error filePath:filePath index:index];
            }];
        }
    }
}

#pragma mark - private

- (NSArray *)downloadFiles {
    return @[
        @{@"name": @"微信mac版", @"url": @"https://dldir1.qq.com/weixin/mac/WeChatMac.dmg"},
        @{@"name": @"微信windows版", @"url": @"https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe"},
        @{@"name": @"文件下载上传", @"url": @"https://github.com/wangfei0206wl/FileDownload/archive/main.zip"},
    ];
}

- (void)asyncFileSize {
    for (int index = 0; index < self.downloadInfos.count; index++) {
        NSDictionary *dicInfo = self.downloadInfos[index];
        __weak typeof(self) weakSelf = self;
        [[XPFileTotalSizeHelper alloc] asyncFileSizeWithUrl:dicInfo[@"url"] finish:^(long long totalSize, BOOL bSuccess) {
            [weakSelf handleAsyncFileSizeFinish:totalSize url:dicInfo[@"url"] index:index];
        }];
    }
}

- (void)handleAsyncFileSizeFinish:(long long)totalSize url:(NSString *)url index:(int)index {
    XPFileDownloadModel *model = [[XPFileDownloadManager shared] isExistDownloadFileCache:url];
    model.totalFileSize = totalSize;
    
    [self handleDownloadProgress:model.cacheFileSize totalFileSize:model.totalFileSize index:index];
}

- (void)createViews {
    self.btnStartAll = [self buttonWithTitle:@"全部开始" color:nil font:nil action:@selector(onClickStartAll:)];
    [self.view addSubview:self.btnStartAll];
    
    self.btnStopAll = [self buttonWithTitle:@"全部停止" color:nil font:nil action:@selector(onClickStopAll:)];
    [self.view addSubview:self.btnStopAll];
    
    [self.btnStartAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view).offset(-60);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    [self.btnStopAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnStartAll);
        make.centerX.equalTo(self.view).offset(60);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    
    [self createDownloadViews];
}

- (void)createDownloadViews {
    UIView *upView = self.btnStartAll;
    
    for (int index = 0; index < self.downloadInfos.count; index++) {
        NSDictionary *dicInfo = self.downloadInfos[index];
        upView = [self downloadItemView:dicInfo upView:upView index:index];
    }
}

- (UIView *)downloadItemView:(NSDictionary *)dicInfo upView:(UIView *)upView index:(int)index {
    UIView *view = [[UIView alloc] init];
    [self.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(upView.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(60);
    }];
    
    NSString *url = dicInfo[@"url"];
    XPFileDownloadModel *model = [[XPFileDownloadManager shared] isExistDownloadFileCache:url];

    // 文件名
    UILabel *nameLabel = [self labelWithTextFont:nil textColor:[UIColor blackColor] text:dicInfo[@"name"]];
    [view addSubview:nameLabel];
    
    // 进度条
    CGFloat progress = (model.totalFileSize > 0)?(model.cacheFileSize * 1.0 / model.totalFileSize):0;
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.progress = progress;
    [view addSubview:progressView];
    [self.progressViews addObject:progressView];
    
    // 百分比
    UILabel *progressLabel = [self labelWithTextFont:[UIFont systemFontOfSize:14] textColor:[UIColor lightGrayColor] text:[NSString stringWithFormat:@"%2d%%", (int)(progress * 100)]];
    [view addSubview:progressLabel];
    [self.progressLabels addObject:progressLabel];
    
    // 按钮
    UIButton *button = [self buttonWithTitle:(model.cacheFileSize > 0)?@"继续":@"下载" color:nil font:nil action:@selector(onClickItem:)];
    [button setTitle:@"暂停" forState:UIControlStateSelected];
    button.tag = (2000 + index);
    [view addSubview:button];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.bottom.equalTo(view).offset(-10);
        make.width.mas_equalTo(100);
    }];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(120);
        make.right.equalTo(view).offset(-120);
        make.bottom.equalTo(view).offset(-10);
        make.height.mas_equalTo(10);
    }];
    [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(10);
        make.centerX.equalTo(progressView);
    }];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.right.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    
    return view;
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

- (UILabel *)labelWithTextFont:(UIFont *)font textColor:(UIColor *)color text:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    
    label.font = font?font:[UIFont systemFontOfSize:14];
    label.textColor = color?color:[UIColor lightGrayColor];
    label.text = text;
    
    return label;
}

- (void)handleDownloadProgress:(long long)cacheFileSize totalFileSize:(long long)totalFileSize index:(int)index {
    if (index >= 0 && index < self.progressViews.count && index < self.progressLabels.count && totalFileSize > 0) {
        CGFloat progress = cacheFileSize * 1.0 / totalFileSize;
        UIProgressView *progressView = self.progressViews[index];
        UILabel *progressLabel = self.progressLabels[index];
        
        progressView.progress = progress;
        progressLabel.text = [NSString stringWithFormat:@"%2d%% ( %@/%@ )", (int)(progress * 100), [self fileSizeString:cacheFileSize], [self fileSizeString:totalFileSize]];
    }
}

- (void)handleDownloadFinish:(NSError *)error filePath:(NSString *)filePath index:(int)index {
    if (!error && index >= 0 && index < self.progressViews.count && index < self.progressLabels.count) {
        UIProgressView *progressView = self.progressViews[index];
        UILabel *progressLabel = self.progressLabels[index];
        
        progressView.progress = 1.0;
        progressLabel.text = @"下载完成";
    }
}

- (NSString *)fileSizeString:(long long)fileSize {
    NSString *string = nil;
    
    if (fileSize > 1024 * 1024 * 1024) {
        CGFloat size = fileSize * 1.0 / (1024 * 1024 * 1024);
        string = [NSString stringWithFormat:@"%.2fG", size];
    } else if (fileSize > 1024 * 1024) {
        CGFloat size = fileSize * 1.0 / (1024 * 1024);
        string = [NSString stringWithFormat:@"%.2fM", size];
    } else if (fileSize > 1024) {
        CGFloat size = fileSize * 1.0 / 1024;
        string = [NSString stringWithFormat:@"%.2fK", size];
    } else {
        string = [NSString stringWithFormat:@"%lldByte", fileSize];
    }
    
    return string;
}

@end

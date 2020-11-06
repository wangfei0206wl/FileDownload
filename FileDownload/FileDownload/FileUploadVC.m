//
//  FileUploadVC.m
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import "FileUploadVC.h"
#import "XPFileUploadManager.h"

@interface FileUploadVC ()

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation FileUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"上传测试";
    
    [self createView];
}

#pragma mark - action

- (void)onClickStart:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate {

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.95);
    NSString *fileName = [NSString stringWithFormat:@"%lld.jpg", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    
    __weak typeof(self) weakSelf = self;
    [[XPFileUploadManager shared] uploadFileWithData:imgData fileName:fileName progress:^(double fractionCompleted) {
        weakSelf.progressView.progress = fractionCompleted;
    } finish:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)createView {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:self.progressView];
    
    UIButton *button = [self buttonWithTitle:@"选择图片" color:nil font:nil action:@selector(onClickStart:)];
    [self.view addSubview:button];

    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-20);
        make.left.equalTo(self.view).offset(120);
        make.right.equalTo(self.view).offset(-120);
        make.height.mas_equalTo(10);
    }];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.progressView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
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

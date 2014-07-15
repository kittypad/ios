//
//  MyMessageEditViewController.m
//  Twatch
//
//  Created by yugong on 14-6-7.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyMessageEditViewController.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DataManager.h"
#import <SBJson.h>
#import "AFHTTPRequestOperationManager.h"
#import "NetDatamanager.h"
#import <AFNetworking.h>

#define ORIGINAL_MAX_WIDTH 640.0f

@interface MyMessageEditViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
{
    UIImage* photoimage;
    UITextField* nickname;  //昵称
    UITextField* age;   //年龄
    UITextField* hobby; //爱好
    UITextField* email;   //邮箱
    UITextField* declaration;   //宣言
    UIButton* boyBtn;
    UIButton* girlBtn;
    UIButton* editBtn;
    UIImage* radioselect;
    UIImage* radio;
    NSString* sex;
    UIView* editSexView;
    UILabel* sexLabel;
    BOOL currentEdit;
    int ieditCount;
    NSString* imageName;
    
    NSURLConnection* updateConnection;
}

@property (nonatomic, strong) UIImageView *portraitImageView;

@end

@implementation MyMessageEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserInformation:) name:@"sendUserInformation" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    editBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, IS_IOS7?25:5, 30, 30)];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
    
    ieditCount = 0;
    
    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(130, IS_IOS7?64:44, 60, 60)];
    
    if ([self.myMessageDic objectForKey:@"Avatar"]==nil||[[self.myMessageDic objectForKey:@"Avatar"] isEqualToString:@""])
    {
        NSURL *portraitUrl = [NSURL URLWithString:@"http://photo.l99.com/bigger/31/1363231021567_5zu910.jpg"];
        UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
        [photo setImage:protraitImg];
        
    }
    else
    {
        [photo setImage:photoimage];
    }
    
    [photo.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
    [photo.layer setMasksToBounds:NO];
    [photo setContentMode:UIViewContentModeScaleAspectFill];
    [photo setClipsToBounds:YES];
    photo.layer.shadowColor = [UIColor blackColor].CGColor;
    photo.layer.shadowOffset = CGSizeMake(4, 4);
    photo.layer.shadowOpacity = 0.5;
    photo.layer.shadowRadius = 2.0;
    photo.layer.cornerRadius= 30;
    photo.layer.borderColor = [[UIColor blackColor] CGColor];
    photo.layer.borderWidth = 2.0f;
    photo.userInteractionEnabled = YES;
    photo.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
    [photo addGestureRecognizer:portraitTap];
    self.portraitImageView = photo;
    [self.view addSubview:self.portraitImageView];
    
    UITableView *mymessageview = [[UITableView alloc] initWithFrame:CGRectMake(0, IS_IOS7?124:104, 320, 300) style:UITableViewStylePlain];
    mymessageview.delegate = self;
    mymessageview.dataSource = self;
    mymessageview.rowHeight = 40;
    mymessageview.scrollEnabled = NO;
    mymessageview.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    [self.view addSubview:mymessageview];
    
    UIButton* exitLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, IS_IOS7?434:414, 260, 30)];
    [exitLoginBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
    [exitLoginBtn setBackgroundColor:[UIColor redColor]];
    [exitLoginBtn setTitle:@"退出" forState:UIControlStateNormal];
    [exitLoginBtn addTarget:self action:@selector(exitLoginClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitLoginBtn];
    
    radioselect = [UIImage imageNamed:@"单选-选中"];
    radio = [UIImage imageNamed:@"单选"];
    
    currentEdit = NO;
    

}

-(void)setUserInformation:(NSNotification*) notification
{
    self.myMessageDic = notification.object;
    imageName = [self.myMessageDic objectForKey:@"Avatar"];
    photoimage = [UIImage imageWithData:[self.myMessageDic objectForKey:@"avatarData"]];
}

-(void)dismissKeyboard {
//    NSArray *subviews = [self.view subviews];
//    for (id objInput in subviews) {
//        if ([objInput isKindOfClass:[UITextField class]]) {
//            UITextField *theTextField = objInput;
//            if ([objInput isFirstResponder]) {
//                [theTextField resignFirstResponder];
//            }
//        }
//    }
     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void)exitLoginClicked
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"gobacktologin" object:nil];
    
    //获取跳转的viewcontroller，跳转到某一个级目录
    NSArray *ctrlArray = self.navigationController.viewControllers;
    [self.navigationController popToViewController:[ctrlArray objectAtIndex:0] animated:YES];
}

-(void)SelectGirl
{
    [boyBtn setBackgroundImage:radio forState:UIControlStateNormal];
    [girlBtn setBackgroundImage:radioselect forState:UIControlStateNormal];
    sex = @"1";
    sexLabel.text = @"女";
    
}

-(void)SelectBoy
{
    [girlBtn setBackgroundImage:radio forState:UIControlStateNormal];
    [boyBtn setBackgroundImage:radioselect forState:UIControlStateNormal];
    sex = @"0";
    sexLabel.text = @"男";
}

-(void)editClicked
{
    if (currentEdit)
    {
        if (ieditCount>0) {
            ieditCount++;
            
            [self.myMessageDic setValue:imageName forKey:@"Avatar"];
            [self.myMessageDic setValue:nickname.text forKey:@"Nickname"];
            [self.myMessageDic setValue:hobby.text forKey:@"Hobbies"];
            [self.myMessageDic setValue:email.text forKey:@"Email"];
            [self.myMessageDic setValue:declaration.text forKey:@"Signature"];
            [self.myMessageDic setValue:age.text forKey:@"Age"];
            [self.myMessageDic setValue:sex forKey:@"Gender"];
            
            [[NetDatamanager sharedManager] editMyMessage:self.myMessageDic success:^(id response, NSString* str){
                
            } failure:^(NSError* error){
            }];
        }
        
        [editBtn setTitle:nil forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [self isEdit:NO];
        currentEdit = NO;
    }
    else
    {
        ieditCount++;
        
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [editBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self isEdit:YES];
        currentEdit = YES;
    }
    
}

-(void)loginToMyCenter:(NSNotification*) notification
{
    self.myMessageDic = notification.object;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"DetialCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
    }
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            sexLabel =  [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            
            [cell addSubview:sexLabel];
            cell.textLabel.text = @"账号";
            editSexView = [[UIView alloc] initWithFrame:CGRectMake(120, 0, 200, 40)];
            editSexView.backgroundColor = [UIColor clearColor];
            [cell addSubview:editSexView];
            //单选按钮，选女
            girlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [girlBtn setFrame:CGRectMake(110,  cell.textLabel.frame.origin.y+5, 30, 30)];
            [girlBtn addTarget:self action:@selector(SelectGirl) forControlEvents:UIControlEventTouchUpInside];
            [editSexView addSubview:girlBtn];
            //单选按钮，选男
            boyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [boyBtn setFrame:CGRectMake(0, 5, 30, 30)];
            [boyBtn addTarget:self action:@selector(SelectBoy) forControlEvents:UIControlEventTouchUpInside];
            [editSexView addSubview:boyBtn];
            
            NSString* strsex = [self.myMessageDic objectForKey:@"Gender"];;
            if ([strsex isEqualToString:@"M"]||[strsex isEqualToString:@"O"])
            {
                [girlBtn setBackgroundImage:radio forState:UIControlStateNormal];
                [boyBtn setBackgroundImage:radioselect forState:UIControlStateNormal];
                sexLabel.text = @"男";
            }
            else
            {
                [boyBtn setBackgroundImage:radio forState:UIControlStateNormal];
                [girlBtn setBackgroundImage:radioselect forState:UIControlStateNormal];
                sexLabel.text = @"女";
            }
            
            //女
            UILabel *lblgirl = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 60, 40)];
            lblgirl.textColor = [UIColor colorWithRed:136.0/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
            lblgirl.text = @"女";
            [editSexView addSubview:lblgirl];
            //男
            UILabel *lblboy = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 60, 40)];
            lblboy.textColor = [UIColor colorWithRed:136.0/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
            lblboy.text = @"男";
            [editSexView addSubview:lblboy];
            cell.textLabel.text = @"性别";
            [editSexView setHidden:YES];
            break;
        }
        case 1:
        {
            nickname = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            nickname.enabled = NO;
            NSString* strNickName = [self.myMessageDic objectForKey:@"Nickname"];
            if (strNickName==nil || [strNickName isEqualToString:@""]) {
                nickname.placeholder = @"您还没有昵称";
            }
            else
            {
                nickname.text = strNickName;
            }
            [cell addSubview:nickname];
            cell.textLabel.text = @"昵称";
            break;
        }
        case 2:
        {
            age = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            age.enabled = NO;
            NSInteger iage = [[self.myMessageDic objectForKey:@"Age"] integerValue];
            age.text = [NSString stringWithFormat:@"%d",iage];
            age.keyboardType = UIKeyboardTypeNumberPad;
            [cell addSubview:age];
            cell.textLabel.text = @"年龄";
            break;
        }
        case 3:
        {
            hobby = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 200, 40)];
            NSString* strhobby = [self.myMessageDic objectForKey:@"Hobbies"];
            if ([strhobby isEqualToString:@""] || strhobby==nil) {
                hobby.placeholder = @"您还没有爱好";
            }
            else
            {
                hobby.text = strhobby;
            }
            hobby.enabled = NO;
            [cell addSubview:hobby];
            cell.textLabel.text = @"爱好";
            break;
        }
        case 4:
        {
            UILabel* userNum = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            userNum.text = [self.myMessageDic objectForKey:@"userName"];
            [cell addSubview:userNum];
            cell.textLabel.text = @"账号";
            cell.editing = NO;
            break;
        }
        case 5:
        {
            email = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            email.enabled = NO;
            NSString* stremail = [self.myMessageDic objectForKey:@"Email"];
            if ([stremail isEqualToString:@""] || stremail==nil) {
                email.placeholder =@"您还没有邮箱";
            }
            else
            {
                email.text = stremail;
            }
            email.keyboardType = UIKeyboardTypeEmailAddress;
            [cell addSubview:email];
            cell.textLabel.text = @"邮箱";
            break;
        }
        case 6:
        {
            declaration = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 260, 40)];
            declaration.enabled = NO;
            NSString* strDeclaration = [self.myMessageDic objectForKey:@"Signature"];
            if ([strDeclaration isEqualToString:@""] || strDeclaration==nil) {
                declaration.placeholder =@"您还没有宣言";
            }
            else
            {
                declaration.text = strDeclaration;
            }
            [cell addSubview:declaration];
            cell.textLabel.text = @"宣言";
            break;
        }
        default:
            break;
    }
    
    //处理虚拟键盘
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(dismissKeyboard)];
    [cell addGestureRecognizer:tap];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)isEdit:(BOOL)edit
{
    if (edit)
    {
        [sexLabel setHidden:YES];
        [editSexView setHidden:NO];
        nickname.enabled = YES;
        age.enabled = YES;
        hobby.enabled = YES;
        declaration.enabled = YES;
        email.enabled = YES;
    }
    else
    {
        [sexLabel setHidden:NO];
        [editSexView setHidden:YES];
        nickname.enabled = NO;
        age.enabled = NO;
        hobby.enabled = NO;
        declaration.enabled = NO;
        email.enabled = NO;
    }
}

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.portraitImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        //[self LoadPhoto:@"http://www.yugong-tech.com/up_avatar.php" photo:editedImage];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@.jpg",[self.myMessageDic objectForKey:@"userName"], str];
        [[NetDatamanager sharedManager] uploadPhoto:[self.myMessageDic objectForKey:@"userName"] iamge:editedImage filename:fileName success:^(id response){
            NSLog(@"response:%@", response);
        } failure:^(NSError* error){
        
        }];
        
        NSData* imageData = UIImageJPEGRepresentation(editedImage, 1);
        [self.myMessageDic setValue:fileName forKey:@"Avatar"];
        [self.myMessageDic setObject:imageData forKey:@"avatarData"];
        
        NSMutableDictionary* editdic = [[NSMutableDictionary alloc] initWithDictionary:self.myMessageDic];
        [editdic removeObjectForKey:@"avatarData"];
        
        [[NetDatamanager sharedManager] editMyMessage:editdic success:^(id response, NSString* str){
        
        } failure:^(NSError* error){
        }];

        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//        
//        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
//        [manager.requestSerializer setValue:@"Accept" forHTTPHeaderField:@"application/json"];
//        NSData* imageData = UIImageJPEGRepresentation(editedImage, 1);
//        [manager.requestSerializer setValue:[self.myMessageDic objectForKey:@"userName"] forHTTPHeaderField:@"userName"];
//        
//        [manager POST:@"http://www.yugong-tech.com/up_avatar.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            
//            [formData appendPartWithFileData:imageData
//                                        name:@"uploadedfile"
//                                    fileName:fileName mimeType:@"image/jpeg"];
//            
//            // etc.
//        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"Response: %@", responseObject);
//            NSLog(@"Response: %@", operation.response.allHeaderFields);
//            [self.myMessageDic setValue:fileName forKey:@"Avatar"];
//            [self.myMessageDic setObject:imageData forKey:@"avatarData"];
//            [self editMyMessage:HTTPBASE_URL para:self.myMessageDic];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

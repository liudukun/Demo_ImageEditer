//
//  DKViewController.m
//  Demo_ImagePicker
//
//  Created by ldk on 13-9-11.
//  Copyright (c) 2013年 DK. All rights reserved.
//

#import "DKViewController.h"
#import "DKRect.h"

@interface DKViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>
{
    
    CGPoint beganPoint;
    CGPoint endPoint;
    BOOL isLockGesture;
    BOOL imageViewFlag;

    
}

@property (nonatomic,strong) UIImagePickerController * picker;

@property (strong, nonatomic) UIImageView *editImageView;

@property (strong, nonatomic) UIImageView *cropImageView;

@property (strong, nonatomic) UIImage *tempImage;

@property (strong, nonatomic) DKRect * rect;

@property (strong, nonatomic) UIImageView * pasteImageView;

@property (strong, nonatomic) UIScrollView * editScrollView;

@property (strong, nonatomic) UIScrollView * bgScrollView;

@property (strong,nonatomic) UIRotationGestureRecognizer * rotationEditGestureRecognizer;

@property (strong, nonatomic) UIPanGestureRecognizer * panEditGestureRecognizer;

@property (strong,nonatomic) UIRotationGestureRecognizer * rotationPasteGestureRecognizer;

@property (strong, nonatomic) UIPanGestureRecognizer * panPasteGestureRecognizer;

@property (strong, nonatomic) UIImageView *bgImageView;


- (IBAction)cropImage:(id)sender;

- (IBAction)openImage:(id)sender;

- (IBAction)addBgImage:(id)sender;

- (IBAction)pressedPasteImage:(id)sender;

- (IBAction)selectRectButtonPressed:(id)sender;

@end

@implementation DKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //初始化picker
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.allowsEditing = YES;
    self.picker.delegate = self;
    isLockGesture = NO;

    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(LABEL_X, LABEL_Y, LABEL_WIDTH, LABEL_HEIGHT)];
    label.font = [UIFont systemFontOfSize:LABEL_FONT];
    label.text = LABEL_TEXT;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];

    self.editScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(EDIT_SCROLLVIEW_X, EDIT_SCROLLVIEW_Y, EDIT_SCROLLVIEW_WIDTH, EDIT_SCROLLVIEW_HEIGHT)];
    self.editScrollView.backgroundColor = [UIColor whiteColor];
    self.editScrollView.pagingEnabled = NO;
    self.editScrollView.bounces = NO;
    self.editScrollView.bouncesZoom = NO;
    self.editScrollView.showsHorizontalScrollIndicator = NO;
    self.editScrollView.showsVerticalScrollIndicator = NO;
    self.editScrollView.maximumZoomScale = EDIT_SCROLLVIEW_MAX_ZOOM_SCALE;
    self.editScrollView.minimumZoomScale = EDIT_SCROLLVIEW_MIN_ZOOM_SCALE;
    [self.view addSubview:self.editScrollView];
    self.editScrollView.delegate = self;
    
    self.bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(BG_SCROLLVIEW_X, BG_SCROLLVIEW_Y, BG_SCROLLVIEW_WIDTH, BG_SCROLLVIEW_HEIGHT)];
    self.bgScrollView.delegate = self;
    self.bgScrollView.backgroundColor = [UIColor whiteColor];
    self.bgScrollView.pagingEnabled = NO;
    self.bgScrollView.bounces = NO;
    self.bgScrollView.bouncesZoom = NO;
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    self.bgScrollView.minimumZoomScale = BG_SCROLLVIEW_MIN_ZOOM_SCALE;
    self.bgScrollView.contentSize = self.bgImageView.frame.size;
    self.editScrollView.maximumZoomScale = BG_SCROLLVIEW_MAX_ZOOM_SCALE;
    
    self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, BG_SCROLLVIEW_WIDTH, BG_SCROLLVIEW_HEIGHT)];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.bgScrollView addSubview:self.bgImageView];
    [self.view addSubview:self.bgScrollView];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//imagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.tempImage = info[UIImagePickerControllerEditedImage];
    if (imageViewFlag) {
        [self initlizeEditImageView];
        
    }else{
        self.bgImageView.image = self.tempImage;
    }
}

//intilize  editImageView
- (void)initlizeEditImageView{
    self.editImageView = [[UIImageView alloc]initWithImage:self.tempImage];
    self.editImageView.contentMode = UIViewContentModeRedraw;
    self.editImageView.userInteractionEnabled = YES;
    
    self.rotationEditGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateEditImageView:)];
    [self.editImageView addGestureRecognizer:self.rotationEditGestureRecognizer];
    self.panEditGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveEditImageView:)];
    [self.editImageView addGestureRecognizer:self.panEditGestureRecognizer];
    
    [self.editScrollView addSubview:self.editImageView];
    self.editScrollView.contentSize = CGSizeMake(self.tempImage.size.width, self.tempImage.size.height);
    
}



//editView旋转
- (void)rotateEditImageView:(UIRotationGestureRecognizer *) rotationGestureRecognizer{
    CGAffineTransform transform = CGAffineTransformRotate(self.editImageView.transform, rotationGestureRecognizer.rotation);
    self.editImageView.transform = transform;
    rotationGestureRecognizer.rotation = 0.0;
    
}

//移动edit
- (void)moveEditImageView:(UIPanGestureRecognizer *)panGestureRecognizer{
    static CGPoint originalCenter;
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        originalCenter = self.editImageView.center;
    } else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [panGestureRecognizer translationInView:self.editImageView];
        CGPoint center = self.editImageView.center;
        center.x = originalCenter.x + translation.x;
        center.y = originalCenter.y + translation.y;
        self.editImageView.center = center;
    }
}

//pasteView旋转
- (void)rotatePasteImageView:(UIRotationGestureRecognizer *) rotationGestureRecognizer{
    CGAffineTransform transform = CGAffineTransformRotate(self.pasteImageView.transform, rotationGestureRecognizer.rotation);
    self.pasteImageView.transform = transform;
    rotationGestureRecognizer.rotation = 0.0;
}

//移动paste
- (void)movePasteImageView:(UIPanGestureRecognizer *)panGestureRecognizer{
    static CGPoint originalCenter;
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        originalCenter = self.pasteImageView.center;
    } else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [panGestureRecognizer translationInView:self.pasteImageView];
        CGPoint center = self.pasteImageView.center;
        center.x = originalCenter.x + translation.x;
        center.y = originalCenter.y + translation.y;
        self.pasteImageView.center = center;
    }
}

//选择矩形框
- (void)selectRect:(UIPanGestureRecognizer*)panGestureRecognizer{
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        beganPoint = [panGestureRecognizer locationInView:self.editScrollView];
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged ){
        endPoint = [panGestureRecognizer locationInView:self.editScrollView];
        if (endPoint.x >= beganPoint.x && endPoint.y >= beganPoint.y) {
            if (self.rect == NULL) {
                self.rect = [[DKRect alloc]initWithFrame:CGRectMake(beganPoint.x, beganPoint.y, fabsf(beganPoint.x - endPoint.x), fabsf(beganPoint.y - endPoint.y))];
                [self.editScrollView addSubview:self.rect];
            }else {
                [self.rect removeFromSuperview];
                self.rect = [[DKRect alloc]initWithFrame:CGRectMake(beganPoint.x, beganPoint.y, fabsf(beganPoint.x - endPoint.x), fabsf(beganPoint.y - endPoint.y))];
                [self.editScrollView addSubview:self.rect];
            }
        }
     
    }
}


- (UIImage *)cropImageWithRect:(CGRect)rectRect view:(UIView *)theView{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(rectRect.size);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rectRect);
    UIImage * img = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    return img;
}



//切图
- (IBAction)cropImage:(id)sender {
    
    UIImage *cropImage =  [self cropImageWithRect:self.rect.frame view:self.editScrollView];
    
    self.editImageView.transform = self.rect.transform;
    self.editImageView.frame = CGRectMake(0, 0, cropImage.size.width, cropImage.size.height);
    self.editImageView.image = cropImage;
    [self.rect removeFromSuperview];
    
}

//paste
- (IBAction)pressedPasteImage:(id)sender {
    self.bgScrollView.contentSize = self.pasteImageView.frame.size;

    self.pasteImageView = [[UIImageView alloc]initWithImage:self.editImageView.image];
    self.pasteImageView.userInteractionEnabled = YES;

    self.panPasteGestureRecognizer = [[UIPanGestureRecognizer alloc ]initWithTarget:self action:@selector(movePasteImageView:)];
    [self.pasteImageView addGestureRecognizer:self.panPasteGestureRecognizer];
    
    self.rotationPasteGestureRecognizer = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotatePasteImageView:)];
    [self.pasteImageView addGestureRecognizer:self.rotationPasteGestureRecognizer];
    
    [self.bgScrollView addSubview:self.pasteImageView];

}

//切换编辑模式
- (IBAction)selectRectButtonPressed:(id)sender {    
    UIButton * button = sender;
    self.editScrollView.scrollEnabled = NO;
    if (isLockGesture) {
        [self.panEditGestureRecognizer removeTarget:self action:@selector(selectRect:)];
        [self.panEditGestureRecognizer addTarget:self action:@selector(moveEditImageView:)];
        [button setTitle:@"编辑模式1" forState:UIControlStateNormal];
        isLockGesture = NO;
    }else{
        [self.panEditGestureRecognizer removeTarget:self action:@selector(moveEditImageView:)];
        [self.panEditGestureRecognizer addTarget:self action:@selector(selectRect:)];
        [button setTitle:@"编辑模式2" forState:UIControlStateNormal];
        isLockGesture = YES;
    }
}

#pragma UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([scrollView isEqual: self.bgScrollView]) {
        return self.pasteImageView;
    }
    return self.editImageView;
    
}


- (IBAction)openImage:(id)sender {
    imageViewFlag = YES;
    [self presentViewController:self.picker animated:YES completion:nil];
    
}

- (IBAction)addBgImage:(id)sender {
    imageViewFlag = NO;
    [self presentViewController:self.picker animated:YES completion:nil];
    
}



@end

//
//  JooxJoinViewController.m
//  Jooxbot
//
//  Created by Andrew Barba on 6/3/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import "JooxJoinViewController.h"
#import "JXRequest.h"

@interface JooxJoinViewController ()
@property (weak, nonatomic) IBOutlet UITextField *jooxIDField;
@property (weak, nonatomic) IBOutlet UIView *jooxIDView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation JooxJoinViewController
@synthesize jooxIDField = _jooxIDField;
@synthesize jooxIDView = _jooxIDView;
@synthesize topBarView = _topBarView;
@synthesize cameraView = _cameraView;
@synthesize loading = _loading;
@synthesize delegate = _delegate;
@synthesize detailLabel = _detailLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.jooxIDField.delegate = self;
    self.jooxIDField.text = @"";
    [self.jooxIDField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame;
        
        frame = self.topBarView.frame;
        frame.origin.x = 0;
        self.topBarView.frame = frame;
        
        frame = self.cameraView.frame;
        frame.origin.x = self.view.bounds.size.width - self.cameraView.frame.size.width;
        self.cameraView.frame = frame;
        
        self.detailLabel.layer.opacity = 1;
    }];
}

-(void)initStyles
{
    CGRect frame;
    
    frame = self.topBarView.frame;
    frame.origin.x = -80;
    self.topBarView.frame = frame;
    
    frame = self.cameraView.frame;
    frame.origin.x = self.view.bounds.size.width + 20;
    self.cameraView.frame = frame;
    
    self.detailLabel.layer.opacity = 0;
    
    self.jooxIDView.layer.shadowRadius = 2;
    self.jooxIDView.layer.shadowOpacity = 0.8;
    self.jooxIDView.layer.shadowOffset = CGSizeMake(1, 1);
    self.jooxIDView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.jooxIDView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.jooxIDView.bounds].CGPath;
    
    self.topBarView.layer.shadowRadius = 2;
    self.topBarView.layer.shadowOpacity = 0.8;
    self.topBarView.layer.shadowOffset = CGSizeMake(-4, 1);
    self.topBarView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBarView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBarView.bounds].CGPath;
    
    self.cameraView.layer.shadowRadius = 2;
    self.cameraView.layer.shadowOpacity = 0.8;
    self.cameraView.layer.shadowOffset = CGSizeMake(4, 1);
    self.cameraView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cameraView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.cameraView.bounds].CGPath;
}

- (IBAction)scan:(id)sender 
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.showsCameraControls = NO;
    reader.showsHelpOnFail = NO;
    reader.showsZBarControls = NO;
    reader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);
    reader.cameraOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner.png"]];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeBarcodeView)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [reader.view addGestureRecognizer:swipe];
    
    [reader.scanner setSymbology: ZBAR_I25
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
}

-(void)closeBarcodeView
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.jooxIDField becomeFirstResponder];
    }];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    for(ZBarSymbol *symbol in results) {
        self.jooxIDField.text = symbol.data;
        break;
    }
    
    [reader dismissViewControllerAnimated:YES completion:nil];
    [self.jooxIDField becomeFirstResponder];
}

- (IBAction)back:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)dismissView:(BOOL)success
//{
//    //[self.jooxIDField resignFirstResponder];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.loading stopAnimating];
//        [UIView animateWithDuration:0.25 animations:^{
//            
//            CGRect frame = self.topBarView.frame;
//            frame.origin.x = -80;
//            self.topBarView.frame = frame;
//            
//            frame = self.cameraView.frame;
//            frame.origin.x = self.view.bounds.size.width+20;
//            self.cameraView.frame = frame;
//            
//            self.detailLabel.layer.opacity = 0;
//        } completion:^(BOOL done){
//            //[self dismissViewControllerAnimated:YES completion:nil];
//            [self.delegate userJoinedJooxList:success];
//        }];
//    });
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.jooxIDField.text isEqualToString:@""]) {
        [self join:self.jooxIDField.text];
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return textField.text.length < 4 || [string isEqualToString:@""];
}

-(void)join:(NSString *)jooxID
{
    [self.loading startAnimating];
    [JXRequest joinPartyWithJooxID:jooxID onCompletion:^(NSUInteger partyID){
        if (partyID) {
            [JXRequest fetchParty:partyID onCompletion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loading stopAnimating];
                [Joox alert:@"This does not appear to be a valid party code. Please check the code and your network connection and try again."
                  withTitle:@"Failed to Join"];
            });
        }
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end

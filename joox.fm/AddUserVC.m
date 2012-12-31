//
//  AddUserVC.m
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "AddUserVC.h"
#import "JXFMAppDelegate+CoreData.h"
#import "FacebookUsersCell.h"
#import "User+Get.h"

@interface AddUserVC ()
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) AddUserCollectionVC *usersVC;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;
@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) NSMutableArray *allFriends;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@end

@implementation AddUserVC
@synthesize loading;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.searchField.delegate = self;
    self.accountStore = [JXFMAppDelegate appDelegate].accountStore;
    self.facebookAccount = [JXFMAppDelegate appDelegate].facebookAccount;
    [self.searchField addTarget:self action:@selector(searchFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self getFriends];
}

-(void)initStyles
{
    self.searchView.layer.shadowRadius = 5;
    self.searchView.layer.shadowOpacity = 0.8;
    self.searchView.layer.shadowOffset = CGSizeMake(0, -1);
    self.searchView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.searchView.bounds].CGPath;
    self.searchField.layer.opacity = 0;
    self.loading.layer.opacity = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.closeButton.transform = CGAffineTransformMakeRotation(degreesToRadians(45));
        self.searchField.layer.opacity = 1;
        self.loading.layer.opacity = 1;
    }];
}

-(void)didSelectUser:(User *)user sender:(FacebookUsersCell *)cell
{
    [JXRequest inviteUser:user toPlaylist:[self.list.identifier integerValue] onCompletion:^(NSUInteger success){
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.loadingView stopAnimating];
            if (success == JXRequestInviteSuccess) {
                NSLog(@"Successfully invtied User");
                cell.successImageView.hidden = NO;
            } else if (success == JXRequestInviteSuccessNoAccount) {
                [Joox alert:[NSString stringWithFormat:@"%@ does not have a joox.fm account! Tell your friend to sign up for joox.fm and their invite will automatically appear in their account as soon as they sign up.",user.fullName] withTitle:@"No joox.fm Account"];
            }
        });
    }];
}

-(void)searchFieldDidChange:(UITextField *)textField
{
    [self search];
}

-(void)search
{
    NSString *query = self.searchField.text;
    [self searchFacebook:query];
}

-(void)getFriends
{    
    [self.loading startAnimating];
    self.allFriends = [NSMutableArray array];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection,
                                                                  NSDictionary *result, NSError *error){
        [self initUsers:result[@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loading stopAnimating];
        });
    }];
}

-(void)initUsers:(NSArray *)users
{
    [JXFMAppDelegate storeFacebookFriends:users];
    [self.usersVC fetchFriends];
}

-(void)searchFacebook:(NSString *)query
{
    [self.usersVC searchFriends:query];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search];
    [self.searchField resignFirstResponder];
    return YES;
}

- (IBAction)dismissView:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.closeButton.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
        self.searchField.layer.opacity = 0;
    } completion:^(BOOL done){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Facebook Users Segue"]) {
        self.usersVC = segue.destinationViewController;
        self.usersVC.list = self.list;
        self.usersVC.delegate = self;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

@end

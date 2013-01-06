//
//  PeopleViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "PeopleViewController.h"

#import "PersonCollectionViewCell.h"
#import "PersonViewController.h"
#import "ConnectionManager.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"
#import "NSDictionary+JSONCategories.h"

NSString *kPersonCellId = @"personCellId";
NSString *size = @"600x600";
CGFloat cellPadding = 10.f;

@implementation PeopleViewController

NSInteger peopleCount;
@synthesize collectionView, peopleArray, dictionary, spinner, receivedData;

- (void) viewDidLoad
{
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor fourcabBackgroundColor];
    [collectionView registerClass:[PersonCollectionViewCell class] forCellWithReuseIdentifier:kPersonCellId];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    [self.view addSubview:spinner];
}

- (void)viewDidLayoutSubviews
{
    spinner.center = collectionView.center;
}

- (IBAction)cancelAction:(id)sender
{
    NSDictionary *dictionaryToPOST = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken] forKey:@"foursquareOauthToken"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/cancel/",fourcabAPIBaseURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *requestData = [dictionaryToPOST toJSON];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"connnected");
    } else {
        NSLog(@"not connected");
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void) processDictionary
{
    if (![dictionary objectForKey:@"waitingCount"]) {
        NSLog(@"didn't get relevant data back... this is probably a cancellation");
        return;
    }
    
    peopleCount = [[dictionary objectForKey:@"waitingCount"] integerValue];
    
    NSLog(@"waiting count = %@",[dictionary objectForKey:@"waitingCount"]);
    
    if (peopleCount > 0) {
        NSLog(@"people count > 0");
        NSArray *waitingArray = [dictionary objectForKey:@"waiting"];
        peopleArray = [NSMutableArray arrayWithArray:waitingArray];
        [collectionView reloadData];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(checkForRides:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void)checkForRides:(id)sender
{
    NSDictionary *dictionaryToPOST = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken] forKey:@"foursquareOauthToken"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/rides/",fourcabAPIBaseURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *requestData = [dictionaryToPOST toJSON];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"connnected");
    } else {
        NSLog(@"not connected");
    }
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"received a bit of data");
    if (!receivedData) receivedData = [NSMutableData data];
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"finished receiving data");
    NSError *myError = nil;
    dictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:&myError];
    receivedData = nil;
    if (myError) {
        NSLog(@"receivedData = %@",receivedData.description);
        NSLog(@"dictionary.description = %@",dictionary.description);
        NSLog(@"Error = %@", [myError userInfo].description);
    } else {
        [self processDictionary];
        //[collectionView reloadData];
    }

    NSLog(@"dictionary description = %@",dictionary.description);
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kShowPersonSegueId sender:self];
}

#pragma mark - <UICollectionViewDatasource>

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if (peopleCount > 0)
        [spinner stopAnimating];
    
    return [peopleArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    PersonCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kPersonCellId forIndexPath:indexPath];
    
    NSDictionary *personWaiting = (NSDictionary*)peopleArray[indexPath.row];
    NSString *prefix = [personWaiting objectForKey:@"photo_prefix"];
    NSString *suffix = [personWaiting objectForKey:@"photo_suffix"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",prefix,size,suffix];
    
    NSLog(@"urlString = %@",urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    ConnectionManager *manager = [[ConnectionManager alloc] initWithImageView:cell.imageView];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:manager];
    if (theConnection) {
        NSLog(@"Connected");
    } else {
        NSLog(@"Connection Failed");
    }
    
    return cell;
}

#pragma mark - <UICollectionViewFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat singleSide = (self.view.bounds.size.width - cellPadding - cellPadding - cellPadding) / 2;
    return CGSizeMake(singleSide, singleSide);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(cellPadding, cellPadding, cellPadding, cellPadding);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return cellPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return cellPadding;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog([[segue identifier] isEqualToString:kShowPersonSegueId] ? @"YES" : @"NO");
    
    if ([[segue identifier] isEqualToString:kShowPersonSegueId]) {
        NSIndexPath *selectedIndexPath = collectionView.indexPathsForSelectedItems[0];
        NSDictionary *personWaiting = (NSDictionary*)peopleArray[selectedIndexPath.row];
        
        PersonViewController *personViewController = (PersonViewController*)[segue destinationViewController];
        personViewController.name = [personWaiting objectForKey:@"name"];
        
        NSLog(@"name = %@",personViewController.name);
        
        PersonCollectionViewCell *cell = (PersonCollectionViewCell*)[collectionView cellForItemAtIndexPath:selectedIndexPath];
        
        NSLog(cell.imageView.image ? @"image YES" : @"image NO");
        
        [personViewController setImage:cell.imageView.image];
        [collectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
    }
}


@end

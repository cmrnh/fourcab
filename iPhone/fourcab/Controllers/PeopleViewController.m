//
//  PeopleViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "PeopleViewController.h"

#import "PersonCollectionViewCell.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"
#import "ConnectionManager.h"

NSString *kPersonCellId = @"personCellId";
NSString *size = @"290x290";
CGFloat cellPadding = 10.f;

@implementation PeopleViewController

NSInteger peopleCount;
NSString *name;
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

- (void) processData
{
    
    [self processDictionary];
}

- (void) processDictionary
{
    NSLog(@"processdictionary");
    peopleCount = [[dictionary objectForKey:@"waitingCount"] integerValue];
    
    NSLog(@"waiting count = %@",[dictionary objectForKey:@"waitingCount"]);
    
    if (peopleCount > 0) {
        NSLog(@"people count > 0");
        NSArray *waitingArray = [dictionary objectForKey:@"waiting"];
        peopleArray = [NSMutableArray arrayWithArray:waitingArray];
        [collectionView reloadData];
    }
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    NSLog(@"received a bit of data");
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    //[venueImageView setContentMode:UIViewContentModeScaleAspectFit];
    //venueImageView.image = [UIImage imageWithData:venueImageData];
    NSLog(@"finished receiving data");
    
    //NSError *myError = nil;
    //receivedDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&myError];
    //NSLog(@"res description = %@",receivedDictionary.description);
    
    //NSLog([NSJSONSerialization isValidJSONObject:receivedData] ? @"VALID" : @"NOT VALID");
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *alertString = [NSString stringWithFormat:@"Meet %@ outside by the door", name];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertString
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    [alert show];
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
    
    for (NSDictionary *personWaiting in peopleArray) {
        name = [personWaiting objectForKey:@"name"];
        NSString *prefix = [personWaiting objectForKey:@"photo_prefix"];
        NSString *suffix = [personWaiting objectForKey:@"photo_suffix"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",prefix,size,suffix];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

        ConnectionManager *manager = [[ConnectionManager alloc] initWithImageView:cell.imageView];
        
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:manager];
        if (theConnection) {
            NSLog(@"Connected");
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
        } else {
            NSLog(@"Connection Failed");
            // Inform the user that the connection failed.
        }

    }
    
    return cell;
}

#pragma mark - <UICollectionViewFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat singleSide = (self.view.bounds.size.width - cellPadding - cellPadding) / 2;
    singleSide = 140;
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
    
}


@end

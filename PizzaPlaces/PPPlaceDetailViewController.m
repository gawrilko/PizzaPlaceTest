//
//  PPPlaceDetailViewController.m
//  PizzaPlaces
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Olearis. All rights reserved.
//

#import "PPPlaceDetailViewController.h"
#import <UXRFourSquareNetworkingEngine.h>
#import <UXRFourSquarePhotoModel.h>
#import "PizzaPlace.h"
#import <UIImageView+AFNetworking.h>

@interface PPPlaceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *PlaceImage;
@property (weak, nonatomic) IBOutlet UILabel *randomTip;

@end

@implementation PPPlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = self.pizzaPlace.name;

	// Fetch a "Full" Restaurant
	[[UXRFourSquareNetworkingEngine sharedInstance] getRestaurantWithId: self.pizzaPlace.restaurantId
													withCompletionBlock: ^(UXRFourSquareRestaurantModel* restaurant) {

														if (restaurant.tips.count > 0)
														{
															self.randomTip.text = [restaurant.tips[0] text];
														}
													} failureBlock:^(NSError *error) {

													}];


	// Download a photo
	[[UXRFourSquareNetworkingEngine sharedInstance] getPhotosForRestaurantWithId: self.pizzaPlace.restaurantId
															 withCompletionBlock:^(NSArray *photos) {
																 UXRFourSquarePhotoModel *photoModel = (UXRFourSquarePhotoModel *)photos[0];

																 NSURL* fullPhotoURL = [photoModel fullPhotoURL];
																 [self.PlaceImage setImageWithURL: fullPhotoURL];

									} failureBlock:^(NSError *error) {
										// Error.
									}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

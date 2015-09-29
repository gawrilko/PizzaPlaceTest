//
//  ViewController.m
//  PizzaPlaces
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Olearis. All rights reserved.
//

#import "PPNearestPlacesViewController.h"
#import <UXRFourSquareNetworkingEngine.h>
#import "PPDatabaseManager.h"
#import "NSManagedObjectContext+PizzaPlace.h"
#import "PPPlaceDetailViewController.h"

@interface PPNearestPlacesViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSFetchedResultsController* pizzaFetchedController;
@property (weak, nonatomic) IBOutlet UITableView *nearPlacesList;


@end

@implementation PPNearestPlacesViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self startStandardUpdates];



	self.pizzaFetchedController = [[PPDatabaseManager sharedInstance] pizzaPlacesFetchResultController];
	self.pizzaFetchedController.delegate = self;



//	// Fetch a "Full" Restaurant

//	// Download a photo
//	[self.fourSquareEngine getPhotosForRestaurantWithId:@"4fc7c071e4b06e4ecff8e93d"
//									withCompletionBlock:^(NSArray *photos) {
//										UXRFourSquarePhotoModel *photoModel = (UXRFourSquarePhotoModel *)photos[0];
//										// Download the image to your image view
//										NSURL *fullPhotoURL = [photoModel fullPhotoURL];
//										// Use this URL to fetch the photo however you like to do that...
//									} failureBlock:^(NSError *error) {
//										// Error.
//									}];
//
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	 if ([segue.identifier isEqualToString: @"showDetails"])
	 {
		 PPPlaceDetailViewController* detailController = [segue destinationViewController];
		 detailController.pizzaPlace = self.pizzaFetchedController.fetchedObjects[[self.nearPlacesList indexPathForSelectedRow].row];
	 }
}




#pragma mark - Location Manager

- (void)startStandardUpdates {
	// Create the location manager if this object does not
	// already have one.
	if (nil == self.locationManager)
		self.locationManager = [[CLLocationManager alloc] init];

	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	if ([self.locationManager respondsToSelector: @selector(requestWhenInUseAuthorization)])
		[self.locationManager requestWhenInUseAuthorization];

	self.locationManager.distanceFilter = 500;

	[self.locationManager startUpdatingLocation];
}



- (void) locationManager: (CLLocationManager*) manager
	  didUpdateLocations: (NSArray*) locations{

	CLLocation* newLocation = [locations lastObject];
	[manager stopUpdatingLocation];

	NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

	// Get Nearby pizza restaurants.
	NSString* query = @"pizza";
	UXRFourSquareNetworkingEngine* fsEngine = [UXRFourSquareNetworkingEngine sharedInstance];
	[fsEngine exploreRestaurantsNearLatLong: newLocation.coordinate
								withQuery: query
						withCompletionBlock: ^(NSArray *restaurants) {
							NSLog(@"API returned %lu result", (unsigned long)restaurants.count);
							[[PPDatabaseManager sharedInstance] performBlockOnWorkerThread:^(NSManagedObjectContext *workerContext) {
											 for (UXRFourSquareRestaurantModel* restaurantModel in restaurants)
											 {
												 PizzaPlace* place = [workerContext pizzaPlaceWithId: restaurantModel.restaurantId];

												 if (!place)
												 {
													 PizzaPlace* place = [workerContext createPizzaPlace];
													 place.restaurantId = restaurantModel.restaurantId;
													 place.name = restaurantModel.name;
													 place.url = [restaurantModel.url absoluteString];
													 place.isOpen = @(restaurantModel.hours.isOpen);
													 place.phone = restaurantModel.contact.formattedPhone;
													 place.placeDescription = restaurantModel.description;
													 place.rating = restaurantModel.rating;
												 }
											 }
										 }];
									  } failureBlock:^(NSError *error) {
										  // Error
									  }];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.pizzaFetchedController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cellId = @"pizzaPlaceId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId forIndexPath: indexPath];

	PizzaPlace* pizzaPlace = (PizzaPlace*)self.pizzaFetchedController.fetchedObjects[indexPath.row];
//	NSLog(@"cell name: %@", pizzaPlace.name);
	[self configureCell: cell
		  forPizzaPlace: pizzaPlace];

	return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) configureCell: (UITableViewCell*) cell
		 forPizzaPlace: (PizzaPlace*) pizzaPlace
{
	cell.textLabel.text = pizzaPlace.name;
	cell.detailTextLabel.text = pizzaPlace.url;
	cell.detailTextLabel.textColor = [UIColor blueColor];
}

- (void) controller: (NSFetchedResultsController *) controller
	didChangeObject: (id) anObject
		atIndexPath: (NSIndexPath *) indexPath
	  forChangeType: (NSFetchedResultsChangeType) type newIndexPath: (NSIndexPath *) newIndexPath
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.nearPlacesList insertRowsAtIndexPaths: [NSArray arrayWithObject: newIndexPath]
									   withRowAnimation: UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[self.nearPlacesList deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
									   withRowAnimation: UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeUpdate:
		{
			[self configureCell:  [self.nearPlacesList cellForRowAtIndexPath: indexPath] forPizzaPlace: anObject];
		}
			break;

		case NSFetchedResultsChangeMove:
			[self.nearPlacesList deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
									   withRowAnimation: UITableViewRowAnimationFade];
			[self.nearPlacesList insertRowsAtIndexPaths: [NSArray arrayWithObject: newIndexPath]
									   withRowAnimation: UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.nearPlacesList endUpdates];
}

- (void)controllerWillChangeContent: (NSFetchedResultsController *) controller
{
	[self.nearPlacesList beginUpdates];

}

@end

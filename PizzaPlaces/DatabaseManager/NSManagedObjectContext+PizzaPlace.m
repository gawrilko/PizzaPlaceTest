//
//  NSManagedObjectContext+PizzaPlace.m
//  PizzaPlaces
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Olearis. All rights reserved.
//

#import "NSManagedObjectContext+PizzaPlace.h"

@implementation NSManagedObjectContext (PizzaPlace)

- (PizzaPlace*) createPizzaPlace
{
	PizzaPlace* newPizzaPlace = [NSEntityDescription insertNewObjectForEntityForName:@"PizzaPlace"
															  inManagedObjectContext: self];

	NSLog(@"pizza created");
	return newPizzaPlace;
}

- (PizzaPlace*) pizzaPlaceWithId: (NSString*) placeId
{
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"PizzaPlace"];
	fetchRequest.predicate = [NSPredicate predicateWithFormat: @"restaurantId == %@", placeId];

	NSError* error = nil;
	NSArray* fetchedObjects = [self executeFetchRequest: fetchRequest error: &error];
	if (error)
	{
		NSLog(@"Can't execute request: %@", error);
	}

	NSLog(@"id: %@ objects count: %lu", placeId, (unsigned long)fetchedObjects.count);

	return fetchedObjects.count > 0 ? [fetchedObjects lastObject] : nil;
}

@end

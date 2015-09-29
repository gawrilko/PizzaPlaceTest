//
//  NSManagedObjectContext+PizzaPlace.h
//  PizzaPlaces
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Olearis. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PizzaPlace.h"

@interface NSManagedObjectContext (PizzaPlace)

- (PizzaPlace*) createPizzaPlace;
- (PizzaPlace*) pizzaPlaceWithId: (NSString*) placeId;


@end

//
//  PizzaPlace+CoreDataProperties.h
//  
//
//  Created by Oleg Lavrentyev on 9/29/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PizzaPlace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PizzaPlace (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *placeDescription;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *isOpen;
@property (nullable, nonatomic, retain) NSString *restaurantId;
@property (nullable, nonatomic, retain) NSString *phone;

@end

NS_ASSUME_NONNULL_END

//
//  PPDatabaseManager.h
//  TestCoreData
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Oleg Lavrentyev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const PPSaveDBNotification;

@interface PPDatabaseManager : NSObject

+ (instancetype)sharedInstance;

- (void) performBlockOnWorkerThread:(void(^)(NSManagedObjectContext* workerContext))workBlock;
- (NSURL *)applicationDocumentsDirectory;

- (NSFetchedResultsController*) pizzaPlacesFetchResultController;

@end

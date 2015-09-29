//
//  PPDatabaseManager.m
//  TestCoreData
//
//  Created by Oleg Lavrentyev on 9/29/15.
//  Copyright © 2015 Oleg Lavrentyev. All rights reserved.
//

#import "PPDatabaseManager.h"

NSString * const PPSaveDBNotification = @"SaveDatabaseNotification";

@interface PPDatabaseManager ()
{
    NSManagedObjectContext* _privateWriterContext;
    NSManagedObjectContext* _managedObjectContext;
}
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation PPDatabaseManager

+ (instancetype)sharedInstance {
    static PPDatabaseManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PPDatabaseManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Core Data stack

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (instancetype) init {
    self = [super init];
    if (self)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator)
        {
            _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
            _privateWriterContext.persistentStoreCoordinator = coordinator;
            
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _managedObjectContext.parentContext = _privateWriterContext;
        }
    }
    
    return self;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PizzaPlaces" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PizzaPlaces.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Core Data Saving support

- (void) performBlockOnWorkerThread:(void(^)(NSManagedObjectContext* workerContext))workBlock
{
    NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    workerContext.parentContext = _managedObjectContext;
    
    [workerContext performBlock:^{
        workBlock(workerContext);
        
        // push to parent
        NSError *error;
        if (![workerContext save:&error])
        {
			NSLog(@"1%@", error.localizedDescription);
        }
        
        [_managedObjectContext performBlock:^{
            NSError *error;
            if (![_managedObjectContext save:&error])
            {
				NSLog(@"2%@", error.localizedDescription);
            }
            
            [_privateWriterContext performBlock:^{
                NSError *error;
                if (![_privateWriterContext save:&error])
                {
					NSLog(@"3%@", error.localizedDescription);
                }
				else
				{
					[[NSNotificationCenter defaultCenter] postNotificationName: PPSaveDBNotification
																		object: self];
				}
            }];
        }];
    }];
}

#pragma mark - Fetch controllers 

- (NSFetchedResultsController*) pizzaPlacesFetchResultController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"PizzaPlace" inManagedObjectContext: _managedObjectContext];
    [fetchRequest setEntity: entity];
    
    //TODO: add predicate
//    fetchRequest.predicate = notesPredicate;
    
    //TODO: add sort descriptors
	[fetchRequest setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES]]];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                                managedObjectContext: _managedObjectContext
                                                                                                  sectionNameKeyPath: nil
                                                                                                           cacheName: nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchedResultsController;
    
}


@end

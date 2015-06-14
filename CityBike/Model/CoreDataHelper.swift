//
//  CoreDataHelper.swift
//
//  Created by Tomasz Szulc on 22/09/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper: NSObject {
    
    /// Return main context. Created once.
    class var mainContext: NSManagedObjectContext {
        return CoreDataHelper.sharedInstance.mainContext
    }
    
    /// Return temporary context with `mainContext` as the parent. Everytime new is returned.
    class var temporaryContext: NSManagedObjectContext {
        return CoreDataHelper.sharedInstance.createTemporaryContext()
    }
    
    // Mark: Private section
    private class var sharedInstance: CoreDataHelper! {
        struct Static {
            static var instance = CoreDataHelper()
        }
        
        return Static.instance
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidSaveContext:"), name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func contextDidSaveContext(notification: NSNotification) {
//        println("contextDidSaveContext:")
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var model = NSManagedObjectModel(contentsOfURL: NSBundle.mainBundle().URLForResource("CityBike", withExtension: "momd")!)!
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let documentsDirectory = (NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as! [NSURL]).last!
        let storeURL = documentsDirectory.URLByAppendingPathComponent("CityBike.sqlite")
        
        var error: NSError? = nil
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
            
            /// Failed to initialize Core Data
            abort()
        }
        
        return coordinator
        }()
    
    private lazy var mainContext: NSManagedObjectContext! = {
        let coordinator = self.persistentStoreCoordinator
        let type = NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType
        var context = NSManagedObjectContext(concurrencyType: type)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    class func temporaryContextWithParent(parent: NSManagedObjectContext!) -> NSManagedObjectContext {
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = parent
        return context
    }
    
    private func createTemporaryContext() -> NSManagedObjectContext {
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        return context
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}
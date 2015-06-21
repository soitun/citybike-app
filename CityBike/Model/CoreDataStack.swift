//
//  CoreDataStack.swift
//
//  Created by Tomasz Szulc on 22/09/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import Foundation


public typealias CoreDataModelStoreType = String

public struct CoreDataModel {
    let name: String
    let bundle: NSBundle
    
    public init(name: String, bundle: NSBundle) {
        self.name = name
        self.bundle = bundle
    }
}

public class CoreDataStack: NSObject {
    
    private var model: CoreDataModel
    private var storeType: CoreDataModelStoreType
    private var concurrencyType: NSManagedObjectContextConcurrencyType
    
    public init(model: CoreDataModel, storeType: CoreDataModelStoreType, concurrencyType: NSManagedObjectContextConcurrencyType) {
        self.model = model
        self.storeType = storeType
        self.concurrencyType = concurrencyType
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidSaveContext:"), name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    public class func setSharedInstance(shared: CoreDataStack) {
        Static.instance = shared
    }
    
    public class func sharedInstance() -> CoreDataStack {
        return Static.instance
    }
    
    // Return main context.
    public lazy var mainContext: NSManagedObjectContext! = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
        }()
    
    // Return new temporary context
    public func createTemporaryContext(parent: NSManagedObjectContext!) -> NSManagedObjectContext {
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = parent
        return context
    }
    
    /// Creates context and set main context as parent
    public func createTemporaryContextFromMainContext() -> NSManagedObjectContext {
        return self.createTemporaryContext(self.mainContext)
    }
    
    private struct Static {
        static var instance: CoreDataStack!
    }
    
    
    /// Private
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let model = NSManagedObjectModel(contentsOfURL: self.model.bundle.URLForResource(self.model.name, withExtension: "momd")!)!
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let documentsDirectory = (NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as! [NSURL]).last!
        let storeURL = documentsDirectory.URLByAppendingPathComponent("\(self.model.name).sqlite")
        
        var error: NSError? = nil
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
            abort()
        }
        
        return coordinator
        }()

    private func saveContext(context: NSManagedObjectContext) {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func contextDidSaveContext(notification: NSNotification) {
//        println("contextDidSaveContext:")
    }
}

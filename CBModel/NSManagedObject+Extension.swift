//
//  NSManagedObject+Extension.swift
//  CityBike
//
//  Created by Tomasz Szulc on 17/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

public extension NSManagedObject {
    public class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = split(fullClassName) { $0 == "." }
        return last(nameComponents)!
    }
    
    public convenience init(context: NSManagedObjectContext) {
        let entity = self.dynamicType.entity(context)
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    private class func entity(context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)!
    }
}

public extension NSManagedObject {
    public class func fetchAll(context: NSManagedObjectContext) -> [NSManagedObject] {
        return self.fetch(self.fetchAllRequest(), context: context)
    }
    
    public class func fetchAllRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: self.entityName())
    }
    
    public class func fetchWithAttribute(key: String, value: AnyObject, context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])
        return self.fetch(request, context: context)
    }
    
    private class func fetch(request: NSFetchRequest, context: NSManagedObjectContext) -> [NSManagedObject] {
        return context.executeFetchRequest(request, error: nil) as? [NSManagedObject] ?? []
    }
}
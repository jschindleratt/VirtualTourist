//
//  DataController.swift
//  CaptivateSpace
//
//  Created by Joshua Schindler on 5/2/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    var backgroundContext:NSManagedObjectContext!
    
    //convenience property to access the context
    var viewContext:NSManagedObjectContext {
        return persistentContaner.viewContext
    }
    
    //create persistant container
    let persistentContaner:NSPersistentContainer
    init(modelName:String) {
        persistentContaner = NSPersistentContainer(name:modelName)
    }
    
    //load persistent store
    func load(completion: (() -> Void)? = nil) {
        persistentContaner.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContext()
            completion?()
        }
    }
    func configureContext() {
        backgroundContext = persistentContaner.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
}

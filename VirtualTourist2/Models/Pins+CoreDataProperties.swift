//
//  Pins+CoreDataProperties.swift
//  VirtualTourist2
//
//  Created by Joshua Schindler on 5/6/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//
//

import Foundation
import CoreData


extension Pins {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pins> {
        return NSFetchRequest<Pins>(entityName: "Pins")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension Pins {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photos)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photos)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

//
//  Photos+CoreDataProperties.swift
//  VirtualTourist2
//
//  Created by Joshua Schindler on 5/6/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pins: Pins?

}

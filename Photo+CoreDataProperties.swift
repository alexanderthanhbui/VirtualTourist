//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/26/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import Foundation
import CoreData 

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageID: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var pinData: Pin?

}

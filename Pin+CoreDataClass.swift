//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/26/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Pin: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        latitude = annotation.coordinate.latitude as Double
        longitude = annotation.coordinate.longitude as Double
        annotationTitle = annotation.title
    }
}

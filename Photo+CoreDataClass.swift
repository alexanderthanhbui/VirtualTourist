//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/26/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        imageID = dictionary["id"] as? String
        imagePath = dictionary["url_m"] as? String
        imageData = dictionary["imageData"] as? Data as NSData?
    }
}

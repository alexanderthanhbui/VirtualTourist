//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/17/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import Foundation

extension Client {
    
    // MARK: - Constants
    
    struct Constants {
        
        // MARK: Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
            static let SearchBBoxHalfWidth = 1.0
            static let SearchBBoxHalfHeight = 1.0
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
            
            static let imageSize = "_m"

        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let GalleryID = "gallery_id"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
            static let PerPage = "per_page"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "02fc91ae9eb51c98dc236fc62eed5edd"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
            static let GalleryID = "5704-72157622566655097"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
            static let UsePerPage = "21"
        }
        
        // MARK: Flickr Response Keys
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
        
        // MARK: JSON Response Keys
        struct JSONResponseKeys {
            static let annotationID = "annotationID"
            static let annotationTitle = "annotationTitle"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let page = "page"
            static let perPage = "perPage"
            
            static let imageData = "imageData"
            static let imageTitle = "imageTitle"
            static let imagePath = "imagePath"
            static let imageID = "imageID"
            
        }
    }
}

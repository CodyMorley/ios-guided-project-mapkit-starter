//
//  Quake.swift
//  Quakes
//
//  Created by Cody Morley on 7/9/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation
import MapKit


class QuakeResults: Decodable {
    enum CodingKeys: String, CodingKey {
        case quakes = "features"
    }
    
    let quakes: [Quake]
}


class Quake: NSObject, Decodable {
    //MARK: - Types -
    enum CodingKeys: String, CodingKey {
        case properties
        case geometry
        
        enum PropertiesKeys: String, CodingKey {
            case magnitude = "mag"
            case place
            case time
        }
        
        enum GeometryKeys: String, CodingKey {
            case coordinates
        }
    }
    
    
    //MARK: - Properties -
    let magnitude: Double
    let place: String
    let time: Date
    let latitude: Double
    let longitude: Double
    
    
    //MARK: - Inits -
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let propertiesContainer = try container.nestedContainer(keyedBy: CodingKeys.PropertiesKeys.self, forKey: .properties)
        let geometryContainer = try container.nestedContainer(keyedBy: CodingKeys.GeometryKeys.self, forKey: .geometry)
        var coordinatesContainer = try geometryContainer.nestedUnkeyedContainer(forKey: .coordinates)
        
        magnitude = try propertiesContainer.decodeIfPresent(Double.self, forKey: .magnitude) ?? 0.0
        place = try propertiesContainer.decode(String.self, forKey: .place)
        time = try propertiesContainer.decode(Date.self, forKey: .time)
        longitude = try coordinatesContainer.decode(Double.self)
        latitude = try coordinatesContainer.decode(Double.self)
        
        super.init()
    }
}


///conforming to this protocol allows MapKit to know where to place a pin in the map for our quake
extension Quake: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return place
    }
    
    var subtitle: String? {
        return "Magnitude: \(magnitude)"
    }
}



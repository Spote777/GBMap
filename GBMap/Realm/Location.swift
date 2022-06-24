//
//  Location.swift
//  GBMap
//
//  Created by Павел Заруцков on 18.06.2022.
//

import Foundation
import RealmSwift

class Location: Object {
    @Persisted(primaryKey: true) var _number: Int
    @Persisted var latitude: Double
    @Persisted var longitude: Double 
}

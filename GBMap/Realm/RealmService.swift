//
//  RealmService.swift
//  GBMap
//
//  Created by Павел Заруцков on 18.06.2022.
//

import Foundation
import RealmSwift
import CoreLocation

final class RealmService {
    
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    static var shared: RealmService = {
        let instance = RealmService()
        
        return instance
    }()
    
    private init() {}
    
    func saveList(_ list: [Object]) {
        do {
            let realm = try Realm(configuration: configuration)
            realm.beginWrite()
            realm.add(list, update: .all)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func saveObject(_ object: Object) {
        do {
            let realm = try Realm(configuration: configuration)
            realm.beginWrite()
            realm.add(object, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func loadListOfLocation() -> Array<Location> {
        do {
            let realm = try Realm(configuration: configuration)
            return Array(realm.objects(Location.self))
        } catch {
            print(error)
            return Array<Location>()
        }
    }
    
    func deleteAllLocations() {
        do {
            let realm = try Realm(configuration: configuration)
            realm.beginWrite()
            let locations = realm.objects(Location.self)
            realm.delete(locations)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}

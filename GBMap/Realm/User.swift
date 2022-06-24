//
//  User.swift
//  GBMap
//
//  Created by Павел Заруцков on 18.06.2022.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var _login: String
    @Persisted var password: String
}


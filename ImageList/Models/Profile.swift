//
//  UserProfile.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let loginName: String
    let bio: String
    
    var fullName: String { "\(firstName) \(lastName)" }
}

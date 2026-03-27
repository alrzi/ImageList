//
//  ProfileModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import Foundation
import UIKit.UIImage

struct ProfileModel: Equatable {
    let name: String
    let email: String
    let greeting: String
    let totalLikes: Int
    let image: UIImage?
    
    init(
        name: String,
        email: String,
        greeting: String,
        totalLikes: Int,
        imageData: Data? = nil
    ) {
        self.name = name
        self.email = email
        self.greeting = greeting
        self.totalLikes = totalLikes
                
        if let data = imageData {
            self.image = UIImage(data: data)
        }
        else {
            self.image = nil
        }
    }
    
    init(
        name: String,
        email: String,
        greeting: String,
        totalLikes: Int,
        image: UIImage?
    ) {
        self.name = name
        self.email = email
        self.greeting = greeting
        self.totalLikes = totalLikes
        self.image = image
    }
}

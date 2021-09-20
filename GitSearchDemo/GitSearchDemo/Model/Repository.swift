//
//  Repository.swift
//  GitSearchDemo
//
//  Created by Sergei Morozov on 19.09.21.
//

import Foundation

struct Repository : Decodable {
    
    let name: String
    let full_name: String
    let html_url: URL
    let description : String?
    let owner : Owner?
}

struct Owner : Decodable {
    let login : String
    let avatar_url : URL?
}

//
//  dataStructure.swift
//  NewBrightonMurals
//
//  Created by Moldovan, Eusebiu on 09/12/2022.
//

import Foundation


//default data structure created to the spec given in the pdf file for the assignment

struct muralStructure: Decodable{
    let id: String
    let title: String?
    let artist: String?
    let info: String?
    let thumbnail: String?
    let lat: String
    let lon: String
    let enabled: String?
    let lastModified: String?
    let images: [images]
}

struct images: Decodable{
    let id: String
    let filename: String
}

struct muralsCollection: Decodable{
    var newbrighton_murals: [muralStructure]
}

//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by mac on 21/01/23.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IDVideoElement?
}

struct IDVideoElement: Codable {
    let kind: String?
    let videoId: String?
}

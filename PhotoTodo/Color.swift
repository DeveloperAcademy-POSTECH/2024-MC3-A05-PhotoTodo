//
//  Color.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 2/2/25.
//

import SwiftUI

enum FolderColorName: String {
    case blue
    case green
    case yellow
    case red
    case sky
    case purple
}

let customFolderColorDict: [FolderColorName: Color] = [
    .blue: Color("folder_color/blue"),
    .green: Color("folder_color/green"),
    .yellow: Color("folder_color/yellow"),
    .red: Color("folder_color/red"),
    .sky: Color("folder_color/sky"),
    .purple: Color("folder_color/purple"),
    ]
    

extension Color {
    static func folderColor(forName color: FolderColorName) -> Color {
        if let folderColor = customFolderColorDict[color] {
            return folderColor
        } else {
            return Color.gray
        }
    }
}

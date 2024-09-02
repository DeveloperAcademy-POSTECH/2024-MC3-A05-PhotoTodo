//
//  PhotoTodoProvider.swift
//  PhotoTodoWidget-extensionExtension
//
//  Created by Lyosha's MacBook   on 8/30/24.
//
// 1.
import WidgetKit

// 2.
struct PhotoTodoProvider: TimelineProvider {

    private let placeholderEntry = PhotoTodoEntry(
        date: Date()
    )
    
    func placeholder(in context: Context) -> PhotoTodoEntry {
        return placeholderEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PhotoTodoEntry) -> ()) {
        completion(placeholderEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PhotoTodoEntry>) -> Void) {
        let currentDate = Date()
        var entries: [PhotoTodoEntry] = []
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
        }
    
}

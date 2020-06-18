//
//  EventNotifier.swift
//  Swindler
//
//  Created by André Terron on 6/17/20.
//  Copyright © 2020 Tyler Mandry. All rights reserved.
//

import Foundation


public typealias EventHandler = (EventType) -> Void


public protocol EventNotifier : AnyObject {
    func on<Event: EventType>(_ handler: @escaping (Event) -> Void) -> Void
    func notify<Event: EventType>(_ event: Event) -> Void
}

/// Original Simple pubsub.
public class SimpleEventNotifier : EventNotifier {
    private var eventHandlers: [String: [EventHandler]] = [:]

    public func on<Event: EventType>(_ handler: @escaping (Event) -> Void) {
        let notification = Event.typeName
        if eventHandlers[notification] == nil {
            eventHandlers[notification] = []
        }
        // Wrap in a casting closure to preserve type information that gets erased in the
        // dictionary.
        eventHandlers[notification]!.append({ handler($0 as! Event) })
    }

    public func notify<Event: EventType>(_ event: Event) {
        assert(Thread.current.isMainThread)
        if let handlers = eventHandlers[Event.typeName] {
            for handler in handlers {
                handler(event)
            }
        }
    }
}

//
//  main.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/27/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//


commandRegistry().main(arguments: Process.arguments, defaultVerb: "help") { (error) -> () in
    switch error {
    case .SubtaskError(let message):
        print("Sorry, error occurred")
        print("Error: \(message)")
    case .SomeNSError(let err):
        print("Error: ", err)
    default:
        print("Unknown Error")
    }
}
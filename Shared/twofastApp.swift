//
//  twofastApp.swift
//  Shared
//
//  Created by Noah Rubin on 7/7/20.
//

import SwiftUI
import CoreData
import OneTimePassword

@main
struct twofastApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // You should add your own error handling code here.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // The context couldn't be saved.
                // You should add your own error handling here.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension Account: Identifiable {
    var token: Token {
        get {
            return Token(url: otpauth!)!
        }
    }
    
    var accentColor: Color {
        get {
            let rgb = accentColorString?.split(separator: " ").map { Double.init($0)! }

            if let rgb = rgb, rgb.count >= 3 {
                return Color(red: rgb[0], green: rgb[1], blue: rgb[2])
            }

            return Color.black;
        }
    }
}

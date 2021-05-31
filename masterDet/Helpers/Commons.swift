//
//  Category+CoreDataClass.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit
import CoreData

protocol ItemActionDelegate: class {
    func itemAdded(title: String)
    func itemEdited(title: String)
}

class Utilities {
    
    static var alert: UIAlertController!
    static let dateFormatter = DateFormatter()
    
    typealias actionHandler = ()  -> Void
    typealias saveFunctionType = (_ viewController: UIViewController) -> Void
    typealias resetToDefaultsFunctionType = () -> Void
    
    private static let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    
    // Get an instance of core data to access the entities
    static func getDBContext() -> NSManagedObjectContext  {
        return container.viewContext
    }
    
    // Save into the Entity
    static func saveDBContext()  {
        if Utilities.getDBContext().hasChanges {
            do {
                try Utilities.getDBContext().save()
            } catch {
                fatalError("Unresolved error while saving the context \(error)")
            }
        }
    }
    
    // Fetch the instance of core data using entityName
    static func fetchFromDBContext<Entity>(entityName: String, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> [Entity] where Entity: NSManagedObject {
        let request: NSFetchRequest<Entity> = NSFetchRequest<Entity>(entityName: entityName)
        
        if let selectedPredicate = predicate {
            request.predicate = selectedPredicate
        }
        
        if let selectedSortDescriptor = sortDescriptor {
            request.sortDescriptors = [selectedSortDescriptor]
        }
        
        do {
            // Fetch and return
            let results = try Utilities.getDBContext().fetch(request)
            return results
        } catch {
            fatalError("Unresolved error while loading the context \(error)")
        }
    }
    
    // Confirmation Alert
    static func showConfirmationAlert (title: String, message: String, yesAction: @escaping actionHandler = {() in}, noAction: @escaping actionHandler = {() in}, caller: UIViewController) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
            noAction()
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            yesAction()
        }))
        caller.present(alert, animated: true, completion: nil)
    }
    
    // Information Alert
    static func showInformationAlert (title: String, message: String, caller: UIViewController) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        caller.present(alert, animated: true, completion: nil)
    }
    
    //
//    static func getDaysDifference(between firstDate: Date, and secondDate: Date) -> Float {
//        let calendar = Calendar.current
//
//        let date1 = calendar.startOfDay(for: firstDate)
//        let date2 = calendar.startOfDay(for: secondDate)
//
//        return Float(calendar.dateComponents([.day], from: date1, to: date2).day!) - 1
//    }
    
    static func getColorFor(value: Float) -> UIColor {
        if value >= 0 && value <= 25 {
            return .systemRed
        } else if value > 25 && value <= 50 {
            return .systemOrange
        } else if value > 50 && value <= 75 {
            return .systemGreen
        } else {
            return .systemBlue
        }
    }
    
    static func getFormattedDateString(for date: Date, format: String) -> String {
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // Category cell color
    static func chooseColor(_ name: String) -> UIColor{
        switch name{
        case "Red":
            return UIColor(red:1, green:0, blue:0, alpha:1.0).lighter(by: 50)!
        case "Blue":
            return UIColor(red:0, green:0, blue:1, alpha:1.0).lighter(by: 50)!
        case "Green":
            return UIColor(red:0, green:1, blue:0, alpha:1.0).lighter(by: 50)!
        case "Cyan":
            return UIColor(red:0, green:1, blue:1, alpha:1.0).lighter(by: 50)!
        case "Yellow":
            return UIColor(red:1, green:1, blue:0, alpha:1.0).lighter(by: 50)!
        case "Purple":
            return UIColor(red:1, green:0, blue:1, alpha:1.0).lighter(by: 50)!
        default:
            return UIColor.white
        }
    }
}

// Extension to adjust the color
extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

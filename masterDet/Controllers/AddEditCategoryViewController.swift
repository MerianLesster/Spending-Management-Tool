//
//  AddEditCategoryViewController.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit

class AddEditCategotyViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var addNotesTextField: UITextField!
    @IBOutlet weak var colorSegmentControl: UISegmentedControl!

    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var categoryPlaceholder: Category?
    var isEditView:Bool?
    var categories:[Category]?
    var categoryTable:UITableView?
    weak var delegate: ItemActionDelegate?

    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    let colorsArray = ["Red","Green","Blue","Yellow", "Cyan","Purple"]

    override func viewDidDisappear(_ animated: Bool) {
        isEditView=false
        categoryPlaceholder=nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if (isEditView!) {
            if let category = categoryPlaceholder {
                nameTextField.text = category.name
                budgetTextField.text = "\(category.budget)"
                addNotesTextField.text = category.note
                colorSegmentControl.selectedSegmentIndex = colorsArray.firstIndex(of: category.color ?? "Red") ?? 0
            }
        }
        nameTextField.becomeFirstResponder()
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true);
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        // Check whether the budget amount input contains numbers
        var containsNumber : Bool = false
        let budgetAmount = budgetTextField.text
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = budgetAmount!.rangeOfCharacter(from: decimalCharacters)
        if decimalRange != nil {
            containsNumber = true
        }
        
        // Category name emplty validation
        if nameTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Name of the Category can't be empty", caller: self)
        }
        // Budget amount empty validation
        else if budgetTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Budget can't be empty", caller: self)
        }
        // Budget amount input type validation
        else if containsNumber == false {
            Utilities.showInformationAlert(title: "Error", message: "Enter a valid budget amount", caller: self)
        }
        else {
            var newCategory:Category
            if(self.isEditView ?? false){
                newCategory = self.categoryPlaceholder!
            }else{
                newCategory = Category(context: self.context)
                cancelButtonPressed("new")
            }
            newCategory.name = nameTextField.text!
            newCategory.budget = (budgetTextField.text! as NSString).floatValue
            newCategory.note = addNotesTextField.text!
            
            // Set the selected color from the segmented control
            var colorName : String = "Blue"
            if colorSegmentControl.selectedSegmentIndex == 0  {
                colorName = "Red"
            } else if colorSegmentControl.selectedSegmentIndex == 1  {
                colorName = "Green"
            }
            else if colorSegmentControl.selectedSegmentIndex == 2  {
                colorName = "Blue"
            }
            else if colorSegmentControl.selectedSegmentIndex == 3  {
                colorName = "Yellow"
            }
            else if colorSegmentControl.selectedSegmentIndex == 4  {
                colorName = "Cyan"
            }
            else if colorSegmentControl.selectedSegmentIndex == 5  {
                colorName = "Purple"
            }
            newCategory.categoryId = UUID().uuidString
            newCategory.color = colorName
            newCategory.clickCount = 0
            //var test : UINavigationController =

            do {
                // Save and reload the table
                try self.context.save()
                categoryTable?.reloadData()
                cancelButtonPressed("working")

            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // Cancel button action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

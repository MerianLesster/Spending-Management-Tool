//
//  AddEditExpenseViewController.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class AddEditExpenseViewController: UIViewController, EKEventEditViewDelegate  {

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }

    let eventStore = EKEventStore()
    var time = Date()

    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var expenseDate: UIDatePicker!
    @IBOutlet weak var selectedOccurance: UISegmentedControl!

    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    var expenses:[Expense]?
    var category:Category?
    var expenseTable:UITableView?
    var isEditView:Bool? = false
    var expensePlaceholder:Expense?

    weak var delegate: ItemActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        addToCalendarToggle.isOn = false

        if (isEditView!) {
            if let expense = expensePlaceholder {
                        expenseNameTextField.text = expense.title
                expenseAmountTextField.text = "\(expense.amount)"
                notesTextField.text = expense.notes
                addToCalendarToggle.isOn = expense.reminderflag
                expenseDate.date = expense.date!
                selectedOccurance.selectedSegmentIndex =  Int(expense.occurence)


                    }
        }
        // Do any additional setup after loading the view.
        expenseNameTextField.becomeFirstResponder()
    }

    func clearField(){
        self.expenseNameTextField.text = ""
        self.expenseAmountTextField.text = ""
        self.notesTextField.text = ""
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        
        // Check whether the expense amount input contains numbers
        var containsNumber : Bool = false
        let budgetAmount = expenseAmountTextField.text
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = budgetAmount!.rangeOfCharacter(from: decimalCharacters)
        if decimalRange != nil {
            containsNumber = true
        }
        
        // Expense name emplty validation
        if expenseNameTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense name can't be empty", caller: self)
        }
        // Expense amount emplty validation
        else if expenseAmountTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense amount can't be empty", caller: self)
        }
        // Expense amount input type validation
        else if containsNumber == false {
            Utilities.showInformationAlert(title: "Error", message: "Enter a valid expense amount", caller: self)
        }
        else {
            var newExpense = Expense(context: self.context)
            if(self.isEditView ?? false){
                newExpense = self.expensePlaceholder!

            }else{
                newExpense = Expense(context: self.context)
                cancelExpense("cancel")

            }

            newExpense.title = expenseNameTextField.text!
            newExpense.amount = (expenseAmountTextField.text! as NSString).floatValue
            newExpense.date = expenseDate.date
            newExpense.occurence = Int64(selectedOccurance.selectedSegmentIndex)
            newExpense.notes = notesTextField.text!
            newExpense.reminderflag = addToCalendarToggle.isOn

            category?.addToExpenses(newExpense)

            if addToCalendarToggle.isOn{
                eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                    DispatchQueue.main.async {
                        if (granted) && (error == nil) {
                            let event = EKEvent(eventStore: self.eventStore)
                            event.title = self.expenseNameTextField.text
                            event.startDate = self.expenseDate.date
                            event.notes = self.notesTextField.text
                            event.endDate = self.expenseDate.date
                            event.calendar = self.eventStore.defaultCalendarForNewEvents

                            let selectedOccurenceValue = self.selectedOccurance.titleForSegment(at: self.selectedOccurance.selectedSegmentIndex)
                            var rule: EKRecurrenceFrequency? = nil
                            switch selectedOccurenceValue! {
                            case "One Off":
                                rule = nil
                            case "Daily":
                                rule = .daily
                            case "Weekly":
                                rule = .weekly
                            case "Monthly":
                                rule = .monthly
                            default:
                                rule = nil
                            }

                            if rule != nil {
                                let recurrenceRule = EKRecurrenceRule(recurrenceWith: rule!, interval: 1, end: nil)
                                event.addRecurrenceRule(recurrenceRule)
                            }

                            do {
                                try self.eventStore.save(event, span: .thisEvent)
                            } catch let error as NSError {
                                fatalError("Failed to save event with error : \(error)")
                            }
                        }else{
                            fatalError("Failed to save event with error : \(String(describing: error)) or access not granted")
                        }
                    }
                })
            }

            do {
                try self.context.save()
                dismiss(animated: true)
                expenseTable?.reloadData()

            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    @IBAction func cancelExpense(_ sender: Any) {
        dismiss(animated: true)
    }

    func getExpense() {
        let e = (category?.expenses?.allObjects) as! [Expense]
        e.forEach{exp in print(exp.amount)}
    }
}

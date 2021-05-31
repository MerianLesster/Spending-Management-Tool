//
//  DetailViewController.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit

class ExpenseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var budgetAmountLabel: UILabel!
    @IBOutlet weak var spentAmountLabel: UILabel!
    @IBOutlet weak var remainAmountLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var orangeLabel: UILabel!
    @IBOutlet weak var purpleLabel: UILabel!
    @IBOutlet weak var cyanLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var addExpenseBtn: UIBarButtonItem!
    @IBOutlet weak var pieChartViewContainer: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryNoteLabel: UILabel!
    
    var expenseItem:Category?
    var isEditView:Bool? = false
    var expensePlaceholder:Expense?
    var addEditExpenseController: AddEditExpenseViewController? = nil
    let pieChartView = PieChartView()
    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default values on the expense view
        categoryNameLabel.text = "\(expenseItem?.name ?? "Add / Select Category")"
        categoryNoteLabel.text = "\(expenseItem?.note ?? "No notes added")"
        budgetAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
        spentAmountLabel.text = "£ 0.0"
        remainAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"

        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        addcounter()

        expenseTableView.tableFooterView = UIView()

        let padding: CGFloat = 20
        
        // Set the pie chart height
        let height = (pieChartViewContainer.frame.height - padding * 3)
        pieChartView.frame = CGRect(
            x: 0, y: padding, width: pieChartViewContainer.frame.size.width, height: height
        )

        // Set the pie chart colors
        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.121568627, blue: 0.28627451, alpha: 1.0), name: "Red",        value: 0),
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.541176471, blue: 0.0, alpha: 1.0), name: "Orange",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.478431373, green: 0.423529412, blue: 1.0, alpha: 1.0), name: "Purple",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.0, green: 0.870588235, blue: 1.0, alpha: 1.0), name: "Light Blue", value: 0),
            LabelledSegment(color: UIColor(red: 0.0, green: 1, blue: 0, alpha: 1.0) , name: "Green", value: 0)
        ]

        pieChartView.segmentLabelFont = .systemFont(ofSize: 10)
        
        // Add pie chart to the container
        pieChartViewContainer.addSubview(pieChartView)

        if (expenseItem === nil){
            addExpenseBtn.isEnabled = false
        }
    }

    // Pass data to AddEditExpenseViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendCategory" {
            let controller = segue.destination as! AddEditExpenseViewController
            controller.category = self.expenseItem
            controller.expenseTable = self.expenseTableView
            controller.isEditView = self.isEditView
            controller.expensePlaceholder = self.expensePlaceholder
            addEditExpenseController = controller
        }
    }

//    override func viewDidAppear(_ animated: Bool) {
//        //        pieChartView.animateChart()
//    }
    

    // update pie chart
    func populatePyChart(exps : [Expense], spentAmount : Float){
        resetPieChart()
        let expsR = exps.sorted(by: {$0.amount > $1.amount})
        var other:Float = 0
        var labeltags: [String] = ["None", "None", "None","None","None"]

        // Loop and set the title
        for (index, element) in expsR.enumerated() {
            if(index < 4){
                pieChartView.segments[index].value = CGFloat(element.amount/spentAmount*100)
                labeltags[index] = element.title!
            }else{
                other += element.amount
            }
        }

        // Pie chart setting the 'other' segment
        if other > 0  {
            pieChartView.segments[4].value = CGFloat(other/spentAmount*100)
            labeltags[4] = "Other"
        }

        // Set the lable values to outlets
        redLabel.text = labeltags[0]
        orangeLabel.text = labeltags[1]
        purpleLabel.text = labeltags[2]
        cyanLabel.text = labeltags[3]
        greenLabel.text = labeltags[4]
    }

    func addcounter(){
        self.expenseItem?.setValue(self.expenseItem!.clickCount + 1, forKey: "clickCount")
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exps = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
            if exps.count == 0 {
                self.expenseTableView.setEmptyMessage("No expenses added for this category!")
                categoryNameLabel.text = "\(expenseItem?.name ?? "Add / Select Category")"
                categoryNoteLabel.text = "\(expenseItem?.note ?? "No notes added")"
                budgetAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
                spentAmountLabel.text = "£ 0.0"
                remainAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
                resetPieChart()
            } else {
                resetPieChart()
                self.expenseTableView.restore()
            }
            return exps.count
        }
        return 0
    }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
//        swipeRefreshLayout.setColorSchemeColors(Color.BLUE, Color.YELLOW, Color.BLUE);
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }

    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]

        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            self.expensePlaceholder = expenseList![indexPath.row]

            self.performSegue(withIdentifier: "sendCategory", sender: expenseList![indexPath.row])
            self.isEditView = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }

    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]


        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete expense", yesAction: {
                () in
                print("deleted",expenseList![indexPath.row])
                
                do {
                    let removingExpense = expenseList![indexPath.row]
                    self.expenseItem?.removeFromExpenses(removingExpense)
                    let context = self.context

                    try context.save()
                    self.expenseTableView.reloadData()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenseTableView.dequeueReusableCell(withIdentifier: "expenseCell") as! ExpenseTableViewCell
        if let e = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
            let datapoint = e[indexPath.row]
            cell.titleLbl.text = datapoint.title
            cell.amountLbl.text = "\(datapoint.amount)"
            cell.noteLbl.text = datapoint.notes

            var totalSpent:Float = 0
            for exp in e {
                totalSpent += exp.amount
            }
            
            switch datapoint.occurence {
                        case 0:
                            cell.occurenceLbl.text = "One Off"
                        case 1:
                            cell.occurenceLbl.text = "Daily"
                        case 2:
                            cell.occurenceLbl.text = "Weekly"
                        case 3:
                            cell.occurenceLbl.text = "Monthly"
                        default:
                            cell.occurenceLbl.text = "One Off"
                        }


                        if datapoint.reminderflag {
                            cell.reminderSetLbl.text = "On"
                        } else {
                            cell.reminderSetLbl.text = "Off"
                        }
            
            spentAmountLabel.text = "£ \(round(Double(totalSpent) * 100)/100.0)"
            remainAmountLabel.text = "£ \(round((expenseItem!.budget - totalSpent) * 100)/100.0)"
            // Progress bar (Expense amount / Expense category budget)
            cell.customProgressBar.progress = CGFloat(e[indexPath.row].amount/expenseItem!.budget)
            populatePyChart(exps :e, spentAmount : totalSpent)
        }
        return cell
    }

    func resetPieChart(){
        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.121568627, blue: 0.28627451, alpha: 1.0), name: "Red",        value: 0),
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.541176471, blue: 0.0, alpha: 1.0), name: "Orange",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.478431373, green: 0.423529412, blue: 1.0, alpha: 1.0), name: "Purple",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.0, green: 0.870588235, blue: 1.0, alpha: 1.0), name: "Light Blue", value: 0),
            LabelledSegment(color: UIColor(red: 0.0, green: 1, blue: 0, alpha: 1.0) , name: "Green", value: 0)
            ]
            
            redLabel.text = "None"
            orangeLabel.text =  "None"
            purpleLabel.text = "None"
            cyanLabel.text =  "None"
            greenLabel.text = "None"
            
            
            
        
    }
}

//
//  TripComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse
import Eureka

class TripComposerViewController: FormViewController, UITextFieldDelegate {


    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var tripToEdit : PFObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveBarButton.isEnabled = false
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
            
        }
        
        
        
        initializeForm()
        
        if let _ = tripToEdit {
            let owner = tripToEdit!["createdBy"] as? PFUser
            let current = PFUser.current()
            
            if let owner = owner, let current = current, owner["facebookId"] as! String == current["facebookId"] as! String {
                self.title = "Edit Trip"
                let row = self.form.rowBy(tag: "Trip Title") as! TextRow
                row.cell.textField.becomeFirstResponder()
            }else{
                self.title = "Trip Settings"
                let row = self.form.rowBy(tag: "Trip Title") as! TextRow
                row.cell.isUserInteractionEnabled = false

                let tripStartDateRow = self.form.rowBy(tag: "START DATE") as! DateInlineRow
                tripStartDateRow.cell.isUserInteractionEnabled = false
                let tripEndDateRow = self.form.rowBy(tag: "END DATE") as! DateInlineRow
                tripEndDateRow.cell.isUserInteractionEnabled = false
                saveBarButton.isEnabled = false
                saveBarButton.tintColor = UIColor.clear
                cancelBarButton.title = "Close"
            }
        }else{
            let row = self.form.rowBy(tag: "Trip Title") as! TextRow
            row.cell.textField.becomeFirstResponder()
        }
        
        
       
        
    }
    

    
    
    func initializeForm() {
        
        form
            +++ Section(header: "TRIP TITLE", footer: "")
                
                <<< TextRow("Trip Title") {
                    $0.add(rule: RuleRequired())
                    if let tripToEdit = tripToEdit {
                        $0.value = tripToEdit["title"] as? String
                    }
                    
                    $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if (cell.textField.text?.characters.count)! > 0 && row.isValid {
                        self.saveBarButton.isEnabled = true
                    }
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "REQUIRED"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }

            
            +++ Section(header: "TRIP DATES", footer: "")
                
                <<< DateInlineRow("START DATE") {
                    $0.title = $0.tag
                    $0.add(rule: RuleRequired())
                    
                    if let tripToEdit = tripToEdit {
                        $0.value = tripToEdit["startDate"] as? Date
                    }else{
                        $0.value = Date().addingTimeInterval(60*60*24)
                    }
                    
                    
                    }
                    .onChange { [weak self] row in
                        let endRow: DateInlineRow! = self?.form.rowBy(tag: "END DATE")
                        if row.value?.compare(endRow.value!) == .orderedDescending {
                            endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                            endRow.cell!.backgroundColor = .white
                            endRow.updateCell()
                        }
                    }
                    .onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate() { cell, row in
                            cell.datePicker.datePickerMode = .date
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                }
                
                <<< DateInlineRow("END DATE"){
                    $0.title = $0.tag
                    $0.add(rule: RuleRequired())
                    
                    if let tripToEdit = tripToEdit {
                        $0.value = tripToEdit["endDate"] as? Date
                    }else{
                        $0.value = Date().addingTimeInterval(60*60*24)
                    }
                    
                    }
                    .onChange { [weak self] row in
                        let startRow: DateInlineRow! = self?.form.rowBy(tag: "START DATE")
                        if row.value?.compare(startRow.value!) == .orderedAscending {
                            row.cell!.backgroundColor = .red
                        }
                        else{
                            row.cell!.backgroundColor = .white
                        }
                        row.updateCell()
                    }
                    .onExpandInlineRow { cell, row, inlineRow in
                        inlineRow.cellUpdate { cell, dateRow in
                            cell.datePicker.datePickerMode = .date
                        }
                        let color = cell.detailTextLabel?.textColor
                        row.onCollapseInlineRow { cell, _, _ in
                            cell.detailTextLabel?.textColor = color
                        }
                        cell.detailTextLabel?.textColor = cell.tintColor
                }
    }
    
    @IBAction func saveTrip(_ sender: Any) {
        
        
        let tripTitleRow = self.form.rowBy(tag: "Trip Title") as! TextRow
        let tripStartDateRow = self.form.rowBy(tag: "START DATE") as! DateInlineRow
        let tripEndDateRow = self.form.rowBy(tag: "END DATE") as! DateInlineRow
        
        if let tripToEdit = tripToEdit {
            
            tripToEdit["updatedAt"] = Date()
            tripToEdit["startDate"] = tripStartDateRow.value
            tripToEdit["endDate"] = tripEndDateRow.value
            tripToEdit["title"] = tripTitleRow.cell.textField.text
            
//            let users = trip.relation(forKey: "users")
//            users.add(PFUser.current()!)
            
            tripToEdit.saveEventually { (success, error) in
                if success {
                    print("trip saved")
                }
            }
            
            
        }else{
            let trip = PFObject(className:"Trip")
            trip["createAt"] = Date()
            trip["updatedAt"] = Date()
            trip["startDate"] = tripStartDateRow.value
            trip["endDate"] = tripEndDateRow.value
            trip["title"] = tripTitleRow.cell.textField.text
            trip["createdBy"] = PFUser.current()
            
            let users = trip.relation(forKey: "users")
            users.add(PFUser.current()!)
            
            trip.saveEventually { (success, error) in
                if success {
                    print("trip saved")
                }
            }
        }
        
        
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

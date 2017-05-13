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
    var shouldAllowAddFriends : Bool = false
    var friends : [String : PFObject] = [:]
    var unsubscribe : ButtonRow?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            cancelBarButton.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            cancelBarButton.title = String.Fontawesome.Cancel
            saveBarButton.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            saveBarButton.title = String.Fontawesome.Save
        }
        
        
        
        saveBarButton.isEnabled = false
        
        
        
        tableView.isEditing = false
        
        if tripToEdit == nil {
            shouldAllowAddFriends = true
        }else{
            let owner = tripToEdit!["createdBy"] as? PFUser
            let current = PFUser.current()
            if let owner = owner, let current = current, owner["facebookId"] as! String == current["facebookId"] as! String {
                shouldAllowAddFriends = true
            }else{
                shouldAllowAddFriends = false
            }
            
        }
        
        initializeForm()
        
        if let _ = tripToEdit {
            let owner = tripToEdit!["createdBy"] as? PFUser
            let current = PFUser.current()
            
            if let owner = owner, let current = current, owner["facebookId"] as! String == current["facebookId"] as! String {
                self.title = "Edit Trip"
            }else{
                self.title = "Trip Settings"
                let row = self.form.rowBy(tag: "Trip Title") as! TextRow
                row.cell.isUserInteractionEnabled = false
                
                let sRow = self.form.rowBy(tag: "START DATE") as! DateInlineRow
                sRow.cell.isUserInteractionEnabled = false
                
                let eRow = self.form.rowBy(tag: "END DATE") as! DateInlineRow
                eRow.cell.isUserInteractionEnabled = false
                
                // self.tableView.isUserInteractionEnabled = false
                
                
                
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
            +++
            
            buildTitleSection()
            
            +++
            
            buildDatesSection()
            
            +++
            
            buildCreatedBySection()
            
            +++
            
            buildUsersSection()
            
            +++
            
            buildActionButtonSection()
        
    }
    
    
    
    func buildTitleSection() -> Section {
        
        let section = Section(header: "Trip Title", footer: "")
            
            <<< TextRow("Trip Title") {
                $0.add(rule: RuleRequired())
                if let tripToEdit = tripToEdit {
                    $0.value = tripToEdit["title"] as? String
                }
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.tintColor = UIColor.FlatColor.Blue.MainText
                
                
                $0.cell.textLabel!.font = UIFont.Buttons.ProfilePageButton
                $0.cell.textLabel!.textColor = UIColor.FlatColor.Blue.MainText
                $0.cell.textField.font = UIFont.Buttons.ProfilePageButton
                $0.cell.textField.textColor = UIColor.FlatColor.Blue.MainText
                $0.cell.textField?.font = UIFont.Subheadings.TripComposeUserTitleText
                
                
                $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if (cell.textField.text?.characters.count)! > 0 {
                        self.saveBarButton.isEnabled = true
                    }else{
                        self.saveBarButton.isEnabled = false
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
                                $0.cell.contentView.backgroundColor = UIColor.FlatColor.Green.Subtext
                                $0.cell.textLabel?.font = UIFont.Subheadings.Validation
                                $0.cell.textLabel?.textAlignment = .right
                                }.cellUpdate({ (cell, row) in
                                    cell.textLabel?.textColor = UIColor.FlatColor.White.Background
                                })
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
        
        return section
        
    }
    
    func buildDatesSection() -> Section {
        
        let section = Section(header: "TRIP DATES", footer: "")
            
            <<< DateInlineRow("START DATE") {
                $0.title = $0.tag
                $0.add(rule: RuleRequired())
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                
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
                        cell.datePicker.backgroundColor = UIColor.FlatColor.White.Background
                        
                        
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }
            
            <<< DateInlineRow("END DATE"){
                $0.title = $0.tag
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                $0.cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                
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
                        cell.datePicker.backgroundColor = UIColor.FlatColor.White.Background
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
        }
        
        return section
    }
    
    
    
    
    func buildUsersSection() -> Section {
        tableView.isEditing = false
        
        let section = MultivaluedSection(multivaluedOptions: .Delete, header: "friends in trip") {
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = { CGFloat.leastNormalMagnitude }
            $0.tag = "userSection"
            
        }
        
        if let tripToEdit = tripToEdit {
            // create a relation based on the authors key
            let relation = tripToEdit.relation(forKey: "users")
            
            // generate a query based on that relation
            let query = relation.query()
            
            
            query.findObjectsInBackground(block: { (users, error) in
                
                if users != nil {
                    for user in users! {
                        
                        let fbID = user["facebookId"] as! String
                        if fbID != PFUser.current()!["facebookId"] as! String {
                            
                            self.friends[user["facebookId"] as! String] = user as? PFUser
                            
                            
                            section <<< LabelRow("\(user["facebookId"]!)") {
                                $0.title = user["name"] as? String
                                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                                if self.shouldAllowAddFriends {
                                    $0.cell.isUserInteractionEnabled = true
                                }else{
                                    $0.cell.isUserInteractionEnabled = false
                                }
                                
                                }.cellUpdate({ (cell, row) in
                                    // cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                                })
                        }
                    }
                }
            })
        }
        
        return section
        
    }
    
    
    func buildCreatedBySection() -> Section {
        let section = Section(header: "created by", footer: "")
        
        let owner : PFUser?
        
        if let tripToEdit = tripToEdit {
            owner = tripToEdit["createdBy"] as? PFUser
        }else{
            owner = PFUser.current()
        }
        
        section <<< LabelRow() {
            $0.title = owner!["name"] as? String
            $0.cell.backgroundColor = UIColor.FlatColor.White.Background
            $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
            $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
            
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                cell.alpha = 1.0
            })
        
        
        return section
        
    }
    
    func buildActionButtonSection() -> Section {
        let section = Section("") {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = { CGFloat.leastNormalMagnitude }
        }
        
        
        if shouldAllowAddFriends {
            section <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Add Friends"
                row.cell.backgroundColor = UIColor.FlatColor.White.Background
                row.cell.tintColor = UIColor.FlatColor.Green.Subtext
                row.cell.textLabel?.font = UIFont.Buttons.ProfilePageButton
                }
                .onCellSelection({ (cell, row) in
                    self.performSegue(withIdentifier: "AddFriendsSegue", sender: self)
                })
        }else{
            
            if let tripToEdit = tripToEdit {
                // create a relation based on the authors key
                let relation = tripToEdit.relation(forKey: "users")
                
                
                section <<< ButtonRow("Unsubscribe") { (row: ButtonRow) in
                    row.title = "Unsubscribe"
                    row.cell.isUserInteractionEnabled = true
                    row.cell.backgroundColor = UIColor.FlatColor.White.Background
                    row.cell.tintColor = UIColor.FlatColor.Green.Subtext
                    row.cell.textLabel?.font = UIFont.Buttons.ProfilePageButton
                    }
                    .onCellSelection({ (cell, row) in
                        
                        relation.remove(PFUser.current()!)
                        
                        tripToEdit.saveInBackground(block: { (success, error) in
                            if success {
                                self.dismiss(animated: true)
                            }else{
                                print("Error Unsubscribing \(error!.localizedDescription)")
                            }
                        })
                    })
            }
        }
        
        return section
        
    }
    
    
    @IBAction func saveTrip(_ sender: Any) {
        
        
        let tripTitleRow = self.form.rowBy(tag: "Trip Title") as! TextRow
        let tripStartDateRow = self.form.rowBy(tag: "START DATE") as! DateInlineRow
        let tripEndDateRow = self.form.rowBy(tag: "END DATE") as! DateInlineRow
        let userSection = self.form.sectionBy(tag: "userSection") as! MultivaluedSection
        
        
        
        
        if let tripToEdit = tripToEdit {
            
            tripToEdit["startDate"] = tripStartDateRow.value
            tripToEdit["endDate"] = tripEndDateRow.value
            tripToEdit["title"] = tripTitleRow.cell.textField.text
            
            
            let users = tripToEdit.relation(forKey: "users")
            
            var tagArray : [String] = []
            
            for row in userSection.enumerated() {
                if let tag = row.element.tag  {
                    tagArray.append(tag)
                }
            }
            
            for (fbId, friend) in friends {
                if tagArray.index(of: fbId) == nil {
                    users.remove(friend)
                }else{
                    users.add(friend)
                }
            }
            
            tripToEdit.saveEventually { (success, error) in
                if success {
                    print("trip saved")
                }
            }
            
            
        }else{
            let trip = PFObject(className:"Trip")
            trip["startDate"] = tripStartDateRow.value
            trip["endDate"] = tripEndDateRow.value
            trip["title"] = tripTitleRow.cell.textField.text
            trip["createdBy"] = PFUser.current()
            
            
            let users = trip.relation(forKey: "users")
            
            var tagArray : [String] = []
            
            for row in userSection.enumerated() {
                if let tag = row.element.tag  {
                    tagArray.append(tag)
                }
            }
            
            for (fbId, friend) in friends {
                if tagArray.index(of: fbId) == nil {
                    users.remove(friend)
                }else{
                    users.add(friend)
                }
            }
            
            users.add(PFUser.current()!)
            
            trip.saveInBackground { (success, error) in
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFriendsSegue" {
            let desination = segue.destination as! UINavigationController
            
            let addFriendsVC = desination.viewControllers[0] as! AddFriendsViewController
            addFriendsVC.delegate = self
            
            
            let userSection = self.form.sectionBy(tag: "userSection") as! MultivaluedSection
            
            var tagArray : [Any] = []
            
            for row in userSection.enumerated() {
                if let tag = row.element.tag  {
                    tagArray.append(tag as Any)
                }
            }
            
            
            
            addFriendsVC.alreadyAddedArray = tagArray
            
            
            
            
            
        }
    }
    
}

extension TripComposerViewController : AddFriendsDelegate {
    func add(friendsToAdd: [PFObject]) {
        
        var userSection = self.form.sectionBy(tag: "userSection") as! MultivaluedSection
        
        var tagArray : [String] = []
        
        for row in userSection.enumerated() {
            if let tag = row.element.tag  {
                tagArray.append(tag)
            }
        }
        
        for friend in friendsToAdd {
            
            if (self.friends.index(forKey: friend["facebookId"] as! String) == nil || tagArray.index(of: friend["facebookId"] as! String) == nil) {
                
                self.friends[friend["facebookId"] as! String] = friend as? PFUser
                
                
                let row = LabelRow("\(friend["facebookId"]!)") {
                    $0.title = friend["name"] as? String
                    $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                    $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                    if self.shouldAllowAddFriends {
                        $0.cell.isUserInteractionEnabled = true
                    }else{
                        $0.cell.isUserInteractionEnabled = false
                    }
                    
                    }.cellUpdate({ (cell, row) in
                        // cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                    })
                
                userSection.insert(row, at: 0)
                
            }
        }
    }
}


//
//  TripComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

class TripComposerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelChanges(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveChanges(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

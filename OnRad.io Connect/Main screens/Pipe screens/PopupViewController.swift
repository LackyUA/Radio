//
//  PopupViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/16/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var dialogView: DialogView! {
        didSet {
            dialogView.layer.cornerRadius = 15.0
            dialogView.layer.masksToBounds = true
            
            for checkbox in dialogView.collectionOfCheckboxes {
                checkbox.layer.cornerRadius = checkbox.frame.height / 2
                checkbox.layer.masksToBounds = true
                checkbox.layer.borderColor = UIColor.black.cgColor
                checkbox.layer.borderWidth = 0.5
            }
            
            for button in dialogView.collectionOfVariables {
                button.contentHorizontalAlignment = .left
            }
            
            dialogView.saveButton.layer.cornerRadius = dialogView.saveButton.frame.height / 2
            dialogView.saveButton.layer.masksToBounds = true
            saveButtonUserInteration(isEnabled: false, color: .lightGray)
            
            dialogView.directPipeCallBack = {
                self.checkboxBackground(tag: 0)
                // TODO: - Add function for direct pipe accept
            }
            dialogView.askEachTimeCallBack = {
                self.checkboxBackground(tag: 1)
                // TODO: - Add function for ask each time accept
            }
            dialogView.saveButtonCallBack = {
                self.dismiss(animated: true, completion: {
                    // TODO: - Add function for saving choosed type of acception
                    print("WOw")
                })
            }
        }
    }
    
    // MARK: - Helpers
    private func checkboxBackground(tag: Int?) {
        for checkbox in dialogView.collectionOfCheckboxes {
            checkbox.backgroundColor = .white
            if checkbox.tag == tag {
                checkbox.backgroundColor = .black
            }
        }
        saveButtonUserInteration(isEnabled: true, color: #colorLiteral(red: 1, green: 0.4573812485, blue: 0, alpha: 1))
    }
    private func saveButtonUserInteration(isEnabled: Bool, color: UIColor) {
        self.dialogView.saveButton.isUserInteractionEnabled = isEnabled
        self.dialogView.saveButton.backgroundColor = color
    }

}

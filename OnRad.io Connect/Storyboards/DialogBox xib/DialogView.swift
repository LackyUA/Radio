//
//  DialogView.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/5/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class DialogView: UIView {

    // MARK: - Properties
    private let xibFileName = "DialogBox"
    var directPipeCallBack: (() -> Void)?
    var askEachTimeCallBack: (() -> Void)?
    var saveButtonCallBack: (() -> Void)?
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet var collectionOfCheckboxes: [UIView]!
    @IBOutlet var collectionOfVariables: [UIButton]!
    
    // MARK: - Actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            directPipeCallBack?()
        case 1:
            askEachTimeCallBack?()
        case 2:
            saveButtonCallBack?()
        default:
            break
        }
    }
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    func commonInit() {
        Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)
        contentView.fixInView(self)
    }

}

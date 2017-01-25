//
//  EditTableViewCell.swift
//  ModaListPro
//
//  Created by Jim Hessin on 12/5/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import UIKit

class EditTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!

    var updateText: (String) -> Void = {_ in}

    func updateText(_ block: @escaping (String) -> Void){
        updateText = block
    }

    var newItem: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }

    // MARK: - Text Field

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return !newItem
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
            !text.isEmpty else {
            return true
        }

        updateText(text.trimmingCharacters(in: .whitespaces))

        if newItem{
            textField.becomeFirstResponder()
            return false
        }

        return true
    }
}

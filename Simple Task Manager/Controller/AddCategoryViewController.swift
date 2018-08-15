//
//  AddCategoryViewController.swift
//  Simple Task Manager
//
//  Created by apple on 8/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import CoreData
import KMPopUp

class AddCategoryViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var categoryColorTextField: UITextField!
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    
    var selectedColorIndex = 0
    var selectedColorName:String!
    
    //category colors array
    var colorsArray:[String] = ["Red","Green","Blue"]
    
    //Category colors PickerView
    let colorsPickerView : UIPickerView = {
        let pick = UIPickerView()
        pick.backgroundColor = UIColor.clear
        return pick
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorsPickerView.delegate = self
        colorsPickerView.dataSource = self
        CreateColorsPicker()
    }
    
    
    //To Create Colors PickerView
    func CreateColorsPicker() {
        colorsPickerView.backgroundColor = UIColor.clear
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed_color))
        toolBar.setItems([doneButton], animated: true)
        self.colorsPickerView.reloadAllComponents()
        categoryColorTextField.inputAccessoryView = toolBar
        categoryColorTextField.inputView = colorsPickerView
    }
    
    //Categories Color Picker Done Buton
    @objc func donePressed_color() {
        
        self.categoryColorTextField.endEditing(true)
        categoryColorTextField.text = " \(colorsArray[selectedColorIndex])"
        
        if selectedColorIndex == 0 {
            selectedColorName = "red"
            categoryColorTextField.textColor = UIColor.red
        }else if selectedColorIndex == 1 {
            selectedColorName = "green"
            categoryColorTextField.textColor = UIColor.green
        }else if selectedColorIndex == 2 {
            selectedColorName = "blue"
            categoryColorTextField.textColor = UIColor.blue
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorsArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedColorIndex = row
    }
    
    // Action after clicking add category button - input required in both TextFields
    @IBAction func addCategoryBtnClicked(_ sender: Any) {
        if categoryNameTextField.text?.isEmpty != true && categoryColorTextField.text?.isEmpty != true {
            saveCategory()
        }else{
            KMPoUp.ShowMessageWithDuration(controller: self, message: "Please fill all data.", image: #imageLiteral(resourceName: "warning_img"), duration: 1.5)
        }
    }

    //Save Category Details (Color & Name) in Core Data (CategoryEntity)
    func saveCategory(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(categoryNameTextField.text, forKey: "name")
        newUser.setValue(selectedColorName, forKey: "color")
        do {
            //data added successfully to Core Data
            try context.save()
            KMPoUp.ShowMessageWithDuration(controller: self, message: "Category added successfully.", image: #imageLiteral(resourceName: "like_img"), duration: 1.5)
            categoryNameTextField.text = ""
            categoryColorTextField.text = ""
            selectedColorIndex = 0
        } catch {
            // failed case
            print("Failed saving")
        }
    }
}

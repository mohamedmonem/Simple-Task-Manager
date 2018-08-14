//
//  AddNewTaskViewController.swift
//  Simple Task Manager
//
//  Created by apple on 8/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import CoreData
import KMPopUp

class AddNewTaskViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {

    var namesArray:[String]!
    var colorsArray:[String]!
    var categoryList = [Category]()
    var selectedCategoryIndex = 0
    var selectedCategoryColor:String!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    let categoriesPickerView : UIPickerView = {
        let pick = UIPickerView()
        pick.backgroundColor = UIColor.clear
        return pick
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriesPickerView.delegate = self
        categoriesPickerView.dataSource = self
        getSavedCategories()
        CreatDatePicker()
        CreateCategoryPicker()
    }
    
    func CreatDatePicker() {
        let date = Date()
        let calendar = Calendar.current
        var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        minDateComponent.day = calendar.component(.day, from: date)
        minDateComponent.month = calendar.component(.month, from: date)
        minDateComponent.year = calendar.component(.year, from: date)
        
        let minDate = calendar.date(from: minDateComponent)
        var maxDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        maxDateComponent.day = 01
        maxDateComponent.month = 01
        maxDateComponent.year = 2030
        
        let maxDate = calendar.date(from: maxDateComponent)
        self.datePicker.minimumDate = minDate! as Date
        self.datePicker.maximumDate =  maxDate! as Date
        datePicker.datePickerMode = .date
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed_date))
        toolBar.setItems([doneButton], animated: true)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
    @objc func donePressed_date() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateTextField.text = " \(dateFormatter.string(from: datePicker.date))"
        view.endEditing(true)
    }

    func getSavedCategories(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryEntity")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let name = data.value(forKey: "name") as! String
                let color = data.value(forKey: "color") as! String
                categoryList.append(Category(name: name, color: color))
            }
        } catch {
            print("Failed")
        }
    }
    
    func CreateCategoryPicker() {
        
        if categoryList.count > 0{
        categoriesPickerView.backgroundColor = UIColor.clear
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed_category))
        toolBar.setItems([doneButton], animated: true)
        self.categoriesPickerView.reloadAllComponents()
        categoryTextField.inputAccessoryView = toolBar
        categoryTextField.inputView = categoriesPickerView
        }else{
        categoryTextField.isEnabled = false
        categoryTextField.placeholder = "No Categories - Add From Settings"
        }
    }
    
    @objc func donePressed_category() {
        self.categoryTextField.endEditing(true)
        categoryTextField.text = " \(categoryList[selectedCategoryIndex].name!)"
        if categoryList[selectedCategoryIndex].color == "red" {
            selectedCategoryColor = "red"
            categoryTextField.textColor = UIColor.red
        }else if categoryList[selectedCategoryIndex].color == "green" {
            selectedCategoryColor = "green"
            categoryTextField.textColor = UIColor.green
        }else if categoryList[selectedCategoryIndex].color == "blue" {
            selectedCategoryColor = "blue"
            categoryTextField.textColor = UIColor.blue
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryIndex = row
    }
    
    @IBAction func addTaskBtnClicked(_ sender: Any) {
        if titleTextField.text?.isEmpty != true && categoryTextField.text?.isEmpty != true && dateTextField.text?.isEmpty != true {
            saveTask()
        }else{
        KMPoUp.ShowMessageWithDuration(controller: self, message: "Please fill all data.", image: #imageLiteral(resourceName: "warning_img"), duration: 1.5)
        }
    }
    
    func saveTask(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CurrentTasksEntity", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        newTask.setValue(titleTextField.text!, forKey: "title")
        newTask.setValue(dateTextField.text!, forKey: "date")
        newTask.setValue(categoryTextField.text, forKey: "categoryName")
        newTask.setValue(selectedCategoryColor, forKey: "categoryColor")
        do {
            try context.save()
            KMPoUp.ShowMessageWithDuration(controller: self, message: "Task added successfully.", image: #imageLiteral(resourceName: "like_img"), duration: 1.5)
            titleTextField.text = ""
            dateTextField.text = ""
            categoryTextField.text = ""
            selectedCategoryIndex = 0
            selectedCategoryColor = ""
        } catch {
            print("Failed saving")
        }
    }
}

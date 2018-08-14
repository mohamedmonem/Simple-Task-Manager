//
//  HomeViewController.swift
//  Simple Task Manager
//
//  Created by apple on 8/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import CoreData
import KMPopUp

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tasksList = [Task]()
    
    var taskState:String = "current"

    var deletedItemIndex:Int!
    
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var tasksSegment: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTasks()
    }
    
    @IBAction func tasksSegmentValueChanged(_ sender: Any) {
        
        if tasksSegment.selectedSegmentIndex == 0 {
         taskState = "current"
         getTasks()
        }else{
         taskState = "finished"
         getTasks()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasksList.count < 1{
         tasksTableView.isHidden = true
         return 0
        }else{
         tasksTableView.isHidden = false
         return tasksList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tasksCell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath) as! TasksTableViewCell
        tasksCell.selectionStyle = .none
        tasksCell.cellTitle.text = tasksList[indexPath.row].title!
        tasksCell.cellTime.text = tasksList[indexPath.row].date!
        var cellColor = tasksList[indexPath.row].categoryColor!
        
        if cellColor == "red"{
        tasksCell.cellView.layer.backgroundColor = UIColor.red.cgColor
        }else if cellColor == "green"{
        tasksCell.cellView.layer.backgroundColor = UIColor.green.cgColor
        }else if cellColor == "blue"{
        tasksCell.cellView.layer.backgroundColor = UIColor.blue.cgColor
        }
        return tasksCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            deletedItemIndex = indexPath.row
            tasksTableView.reloadData()
            finishTask()
        }
        
    }
    
    @IBAction func newTaskBtnClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskViewController")as! AddNewTaskViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func settingsBtnClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")as! SettingsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getTasks(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentTasksEntity")
        
        if taskState == "current"{
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentTasksEntity")
        }else{
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "FinishedTasksEntity")
        }
        
        request.returnsObjectsAsFaults = false
        
        do {
            tasksList.removeAll()
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if result.count > 0 {
                let title = data.value(forKey: "title") as! String
                let date = data.value(forKey: "date") as! String
                let categoryName = data.value(forKey: "categoryName") as! String
                let categoryColor = data.value(forKey: "categoryColor") as! String
                
                tasksList.append(Task(categoryName: categoryName, categoryColor: categoryColor, date: date, title: title))
            }
            }
            
            tasksTableView.reloadData()
        } catch {
            
            print("Failed")
        }
    }
    
    func finishTask(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentTasksEntity")
        
        if taskState == "current"{
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentTasksEntity")
        }else{
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "FinishedTasksEntity")
        }
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                
                moveToCompletedTasks()
                
                context.delete(result[deletedItemIndex] as! NSManagedObject)
            }
            do {
                try context.save()
            } catch {
            }
            
            tasksTableView.reloadData()
            
        } catch {
            
            print("Failed")
        }
    }
    
    
    func moveToCompletedTasks(){
        
        if taskState == "current"{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "FinishedTasksEntity", in: context)
        let completedTask = NSManagedObject(entity: entity!, insertInto: context)
        
        completedTask.setValue(tasksList[deletedItemIndex].title!, forKey: "title")
        completedTask.setValue(tasksList[deletedItemIndex].date!, forKey: "date")
        completedTask.setValue(tasksList[deletedItemIndex].categoryName!, forKey: "categoryName")
        completedTask.setValue(tasksList[deletedItemIndex].categoryColor!, forKey: "categoryColor")
        
        
        
        do {
            try context.save()
            KMPoUp.ShowMessageWithDuration(controller: self, message: "Task moved to finished list.", image: #imageLiteral(resourceName: "like_img"), duration: 1.5)
            tasksList.remove(at: deletedItemIndex)
        } catch {
            print("Failed saving")
        }
        
        }else{
        // Already Completed Task
        tasksList.remove(at: deletedItemIndex)
        }
        
    }
    
    
}

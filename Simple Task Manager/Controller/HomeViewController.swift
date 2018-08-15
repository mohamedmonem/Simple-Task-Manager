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
    
    //Segment between "Current Tasks" & "Finished Tasks" -> calling same function but "taskState" flag separate the actions using if statements
    @IBAction func tasksSegmentValueChanged(_ sender: Any) {
        if tasksSegment.selectedSegmentIndex == 0 {
         taskState = "current"
        }else{
         taskState = "finished"
        }
        getTasks()
    }

    // if tasks list is empty hide tableview else show tableview and return count of tasks
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasksList.count < 1{
         tasksTableView.isHidden = true
         return 0
        }else{
         tasksTableView.isHidden = false
         return tasksList.count
        }
    }
    
    //Set Task (Title & Time) and set background color of task cell depends on it's category color
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
    
    //action after delete Cell
    //set deleted cell index in variable to have access on the task in upcoming functions for delete,insert or both
    //Calling finishTas() function
    
    //Case: Current Tasks -> delete the task from "CurrentTasksEntity" and Insert it into "FinishedTasksEntity"
    //Case: Finished Tasks -> delete the task from "FinishedTasksEntity"
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deletedItemIndex = indexPath.row
            tasksTableView.reloadData()
            finishTask()
        }
        
    }
    
    //Action after New Task BarButton Clicked - > Open "AddNewTaskViewController"
    //Navigation Type "Push" for using back in the next Activity
    @IBAction func newTaskBtnClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskViewController")as! AddNewTaskViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Action after Settings BarButton Clicked - > Open "SettingsViewController"
    //Navigation Type "Push" for using back in the next Activity
    @IBAction func settingsBtnClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")as! SettingsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //Get All Data Of Tasks from Core Data
    // From "CurrentTasksEntity" in case Current Tasks
    // From "FinishedTasksEntity" in case Finished Tasks
    //And append on tasksList
    //Reload TableView after getting tasks data
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
    
    //Function called after deleting task
    //"Current Tasks" -> Delete Task from "CurrentTasksEntity"
    //"Finished Tasks" -> Delete Task from "CurrentTasksEntity"
    //In Both Cases will call MoveToCompletedTasks() functio
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
    // In "Current Tasks" Case -> Will add deleted data from "CurrentTasksEntity" to "FinishedTasksEntity" and remove task from tasks List and finally reload tableView.
    
    // In "Finished Tasks" will just remove task from tasks List and reload tableView.
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
        tasksList.remove(at: deletedItemIndex)
        }
    }
}

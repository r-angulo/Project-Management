//
//  TasksTableViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/20/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import EventKit


class TasksTableViewController: UITableViewController {
    @IBOutlet weak var navTitle: UINavigationItem!
    
    private var tasksModel = TasksService.shared//load tasks model singleton
    let dateFormatter = DateFormatter()//create date formatter object
    let eventStore : EKEventStore = EKEventStore()//create an even store object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem //enable edit button
        
        tableView.reloadData()//when view loads reload data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()//reload data evertime this view appears
        
        //display how many uncomplete tasks there are
        self.navTitle.title = "\(tasksModel.uncompletedTasks().count) \(NSLocalizedString("uncompleted_tasks", comment: ""))"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//return 1 section available
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksModel.uncompletedTasks().count//return the number of uncomplete tasks there are
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a new cell instance
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! SingleTaskTableViewCell
        //initiate the cell with a task from the uncomplete tasks model
        let thisTask:Task = tasksModel.uncompletedTasks()[indexPath.row]
        cell.taskName.text = thisTask.projectName //set its text to the name of the project
        
        //set format for top part of data text ex May 6
        if let lang = Locale.autoupdatingCurrent.languageCode, lang == "es"{
            dateFormatter.locale = Locale(identifier: "es_419")
            dateFormatter.setLocalizedDateFormatFromTemplate("d MMM")
        }else{
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d")
        }
        
        let dateTextTop = dateFormatter.string(from: thisTask.startDate)
        
        //set format for bottom part of date text, ex 7:00 PM
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        let dateTextBottom = dateFormatter.string(from: thisTask.startDate)
        
        //update the date label with formatted date
        cell.dateDetail.text = "\(dateTextTop)\n\(dateTextBottom)"
        
        //if this project is past due date, mark the date text as red
        if thisTask.estimatedEndDate < Date() {
            cell.dateDetail.textColor = UIColor.red
        }else{//if this project is past due date, mark the date text otherwise, make it black
            cell.dateDetail.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 //return cell height as 75
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //this method delete the selected event from calendar and from the task model
        if editingStyle == .delete {
            //get the calendar id for this tasks
            let thisTaskCalID = tasksModel.getTasksCalendarID(inputTask:tasksModel.uncompletedTasks()[indexPath.row])
            if let thisTaskCalID = thisTaskCalID{//if a calendar was created for it
                eventStore.requestAccess(to: .event) { (success, err) in//attempt to request access from even store
                    if (success) && (err == nil) {//if access was granted
                        if let calendarEvent = self.eventStore.event(withIdentifier: thisTaskCalID){//get the even with this event id
                            do {
                                try self.eventStore.remove(calendarEvent, span: .thisEvent,commit: true)//then delete that event
                            } catch let error as NSError {//display any errors
                                print("Failed to delete event with error : \(error)")
                            }
                        }
                    }
                }
            }
            tasksModel.deleteProject(inputTask: tasksModel.uncompletedTasks()[indexPath.row])//delete this event from the tasks model
            tableView.deleteRows(at: [indexPath], with: .fade)//delete this cell in the table view
            //update how many uncomplete tasks there are
            self.navTitle.title = "\(tasksModel.uncompletedTasks().count) Uncompleted Task(s)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass selected task to the next view controller
        let uncompletedTaskVC = segue.destination as? UncompletedTaskViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            uncompletedTaskVC?.currentTask = tasksModel.uncompletedTasks()[indexPath.row]
        }
    }
}

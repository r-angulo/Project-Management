//
//  CompletedProjectsTableViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/22/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class CompletedProjectsTableViewController: UITableViewController {
    private var tasksModel = TasksService.shared
    let dateFormatter = DateFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set date format aased on language
        if let lang = Locale.autoupdatingCurrent.languageCode, lang == "es"{
            dateFormatter.locale = Locale(identifier: "es_419")
            dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        }else{
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
        }
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()//reload table vie cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        //return 1 section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of uncompleted task there are
        return tasksModel.completedTasks().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a cell for each uncompleted tasks, showing its name and date it ended
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedTaskCell", for: indexPath) as! CompletedTaskTableViewCell
        
        let thisTask = tasksModel.completedTasks()[indexPath.row]
        cell.completedTaskName.text = thisTask.projectName
        cell.completedDate.text = dateFormatter.string(from: thisTask.actualEndDate)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //make cell size 75
        return 75
     }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the selected task to the next view
        let completedTaskVC = segue.destination as? FinishedProjectViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            completedTaskVC?.currentTask = tasksModel.completedTasks()[indexPath.row]
        }
    }
    

}

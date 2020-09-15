//
//  TasksService.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/18/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import Foundation

class TasksService:NSObject{
    static let shared = TasksService()
    private var allTasks = [Task]()
    private var tasksFileLocation: URL!//DATA persistence url for device
    
    override init(){
        super.init()
        //get the path of the document directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //save a file called tasks.json
        tasksFileLocation = documentsDirectory.appendingPathComponent("tasks.json")
        
        if let fileLoc = tasksFileLocation {
            print(fileLoc) //print the location of the file
        }
        if FileManager.default.fileExists(atPath: tasksFileLocation.path){
            //if the file already exists load the tasks into this array
            load()
        }
    }
    
    func insertNewTask(newTask:Task){
        //insert a new tasks into the model and save it to the json file
        allTasks.append(newTask)
        save()
    }
    
    func numberOfTasks()->Int{
        //return number of tasks
        return allTasks.count
    }
    
    func taskAt(_ index:Int)->Task{
        //return the tasks at that certain index
        return allTasks[index]
    }
    
    func sortByDate(){
        //sort all the task by date
        allTasks.sort { (i, j) -> Bool in
            i.startDate < j.startDate
        }
    }
    
    func deleteProject(inputTask:Task){
        //delete this specific tasks by finding it and then removeing it
        //then update json file
        if let i = allTasks.firstIndex(where: { $0 == inputTask}) {
            allTasks.remove(at: i)
        }
        save()
    }
    
    func getTasksCalendarID(inputTask:Task)->String?{
        //get the calendar id of this object by first finding the tasks
        //then returning it if this tasks has a calendar id
        //else return nil
        if let i = allTasks.firstIndex(where: { $0 == inputTask}) {
            return allTasks[i].calendarID
        }else{
            return nil
        }
    }
    
    func uncompletedTasks()->[Task]{
        //return all the tasks that have not been completed as an array
        var returnArr = [Task]()
        for task in allTasks{
            if task.completed == false{
                returnArr.append(task)
            }
        }
        return returnArr
    }
    
    func completedTasks()->[Task]{
        //return all the tasks that have been completed as an array
        var returnArr = [Task]()
        for task in allTasks{
            if task.completed == true{
                returnArr.append(task)
            }
        }
        return returnArr
    }
    
    func completeProject(_ inputTask: inout Task,summary:String,completeDate:Date,imageURLs:[String]?){
        //find the object passed in
        //then update its summary and completion date
        //and if it has images stored in the firebase storage, update that too
        //update the json file
        if let i = allTasks.firstIndex(where: { $0 == inputTask}) {
            allTasks[i].completed = true
            allTasks[i].summary = summary
            allTasks[i].actualEndDate = completeDate
            allTasks[i].firIDs = imageURLs
        }
        save()
    }
    
    public func save(){
        //everytime a new task is saved, sort the tasks
        sortByDate()
        do{
            //update the json file with the allTasks array contents
            let encoder = JSONEncoder()
            let data = try encoder.encode(allTasks)
            let jsonString = String(data: data, encoding: .utf8)!
            try jsonString.write(to: tasksFileLocation, atomically: true, encoding: .utf8)
        } catch{
            print("err \(error)")
        }
    }
    
    private func load(){
        //load tasksfrom the json file into the allTaks array
        do {
            let data = try Data(contentsOf: tasksFileLocation)
            let decoder = JSONDecoder()
            allTasks = try decoder.decode([Task].self, from: data)
        } catch{
            print("err \(error)")
        }
    }
    
}

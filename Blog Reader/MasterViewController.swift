//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Wilmer sinchi on 1/16/19.
//  Copyright © 2019 Wilmer sinchi. All rights reserved.
//

import UIKit
import CoreData

//go to blooger website and use your google account to make the api key
//enable blogger api
// retreive a blog by a url
//https://www.googleapis.com/blogger/v3/blogs/2399953?key=AIzaSyBoKw1b3lZIvvMRdAHt_9YYvFbVUaYGYSs
//use your api key to make the url work
//when access to the website it will give you in the json format


//Retrieving a blog by its URL



// see if you can get the id number for a particular blog,  google blog spot in this case.
//https://www.googleapis.com/blogger/v3/blogs/byurl?url=https://googleblog.blogspot.com/index.html&key=AIzaSyD9l7_goluzyvxqOaMLGbjWvg-L7AsLums
// remmber to change the ? to & since you have two things going on.
//and copy the blogspot url in the the api website

// now we go back to the api url, and change the id with googleblogspout id number that you got from the last link
//https://www.googleapis.com/blogger/v3/blogs/10861780?key=AIzaSyBoKw1b3lZIvvMRdAHt_9YYvFbVUaYGYSs


//Retrieving posts from a blog
//https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyBoKw1b3lZIvvMRdAHt_9YYvFbVUaYGYSs






// when you use the masterViewController this is all is created for you along with the coredata modle and more.

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
// this was created for you
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyBoKw1b3lZIvvMRdAHt_9YYvFbVUaYGYSs")
        let task  = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
                
            } else {
                if let urlContent = data {
//                    print(urlContent)
                    do {
                        //It's not the friendliest response because we didn't encode it using UTF 8. so we use this code to encode it
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                        print(jsonResult)
                        
                        if let items = jsonResult["items"] as? NSArray {
                            let context = self.fetchedResultsController.managedObjectContext
                            let request =  NSFetchRequest<Event>(entityName: "Event")
                            do {
                                let results = try context.fetch(request)
                                
                                if results.count > 0 {
                                    for result in results {
                                        // this help delete duplikcate copies of...inside of the array when it reload, since it keep on adding to eachother , since its item has more array 
                                        context.delete(result)
                                        do {
                                            try context.save()
                                        } catch{ print("specidfic delete failed")
                                            
                                        }
                                        
                                    }
                                }
                            } catch {
                                print("delete failed")
                            }
                            
                            for item in items as [AnyObject] {
                                print(item)
                                
                                print(item["published"])
                                print(item["title"])
                                print(item["content"])
                                // when you look into the term, you can see it under  optional
                                
                                // next step is to save the data , so create an entity called event and make two attribute call title, timestamp
                                
//                                let context = self.fetchedResultsController.managedObjectContext
//                                OUR NEW OBJECT IN THEDATA BASE
                                let newEvent = Event(context: context)
                                
                                // If appropriate, configure the new managed object.
                                newEvent.timestamp = Date()
                                // where you save the poublished in the attrubute
                                newEvent.setValue(item["published"] as! String, forKey: "published")
                                newEvent.setValue(item["title"] as! String, forKey: "title")
                                newEvent.setValue(item["content"] as! String, forKey: "content")
                                // Save the context.
                                do {
                                    try context.save()
                                    //once it save we must uplaod it to the table view
                                    
                                } catch {
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            }
                            
                            DispatchQueue.main.async(execute:  {
                                self.tableView.reloadData()
                            })
                        }
                    } catch {
                        print("JSON PROCCESING FAILED")
                    }
                }
            }
            
        
        }
        
        // Do any additional setup after loading the view, typically from a nib.
      
        //we do not need this code
        
        /* navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        } */
        task.resume()
    }
/*
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    } */

    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        cell.textLabel!.text = event.value(forKey: "title") as? String// we can since the type of data is a string
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        //change the key to published, you can see the new result first 
        let sortDescriptor = NSSortDescriptor(key: "published", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}


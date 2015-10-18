//
//  TableViewController.swift
//  BoilerMake2015
//
//  Created by Julianna Stevenson on 10/16/15.
//  Copyright © 2015 BoilerMake2015. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import CoreLocation

class TableViewController: UITableViewController, WCSessionDelegate, CLLocationManagerDelegate {
    
    var contacts = [NSManagedObject]()
    let locationManager = CLLocationManager()
    var friends = [String]()
    var addDirection = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Contacts"
        
        
        //for watch
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("session is activated")
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        //for location
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lat = NSString(format: "%f", (manager.location?.coordinate.latitude)!)
        let long = NSString(format: "%f", (manager.location?.coordinate.longitude)!)
        
        var friendsString = "["
        for var i = 0; i < friends.count; i++ {
            friendsString += friends[i]
            if (i != friends.count-1){
                friendsString += ","
            }
        }
        friendsString += "]"
        
        let params: [String: AnyObject] = [ "number": "100", "friends": friendsString, "lat": lat, "long" : long ]
        
        
        sendRequest("http://www.friendsfind.me/api2", parameters: params) { (data, resp, err) -> Void in
            //print("data = \(data), resp = \(resp)")
            
            
            if let err = err {
                print("err = \(err)")
            }
            
            print("request done")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        addDirection = newHeading.magneticHeading
    }
    
    func sendRequest(url: String, parameters: [String: AnyObject], completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionTask {

        let parameterString = parameters.stringFromHttpParameters()
        let requestURL = NSURL(string:"\(url)?\(parameterString)")!
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler:completionHandler)
        task.resume()
        
        getRequest(requestURL)
        
        return task
    }
    
    func getRequest(url : NSURL) {
        
        do {
            print("in getRequest")
            let data = NSData(contentsOfURL: url)
            print("in data")
            print(data)
            if ((data) != nil) {
                let numString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(numString)
                let num = numString?.integerValue
                print(num)
                let calculatedValue = Int(((Double(num!)*22.5) + addDirection)/22.5)
                print(calculatedValue)
                sendMessage(calculatedValue)
            }
            else {
                print("got nil")
            }
        } catch {
            
        }
    }
    
    func sendMessage(degrees : Int){
        
        print("starting to send data")
        
        guard WCSession.defaultSession().reachable else { print("reachable failed")
            return }
        guard WCSession.defaultSession().paired else { print("paired failed")
            return }
        //guard WCSession.defaultSession().watchAppInstalled else { print("watchAppInstalled failed")
            //return }
        
        print("watch session reachable")
        
        let applicationData = ["image": degrees]
        
        WCSession.defaultSession().sendMessage(applicationData, replyHandler: { (_: [String : AnyObject]) -> Void in
            //Handle reply
            print("success")
            }) { (error: NSError) -> Void in
                print("error \(error)")
                //Handle error
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = applicationDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        
        if let results = fetchedResults {
            contacts = results
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = contacts[indexPath.row].valueForKey("name") as? String
        friends.append((contacts[indexPath.row].valueForKey("number") as? String)!)
        
        return cell
    }
    
    @IBAction func addContact(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Contact", message: "Please add a new contact.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveButton = UIAlertAction(title: "save", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            // Retrieve the text from text fields
            let nameTF = alert.textFields![0]
            let numTF = alert.textFields![1]
            let name = nameTF.text! as String
            let num = numTF.text! as String
            self.saveContact(name, number: num)
            self.tableView.reloadData()
        })
        
        let cancelButton = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
        })
        
        alert.addTextFieldWithConfigurationHandler({(textField:UITextField) -> Void in
            textField.placeholder = "Name"
        })
        
        alert.addTextFieldWithConfigurationHandler({(textField:UITextField) -> Void in
            textField.placeholder = "Cell Phone Number"
        })
        
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func saveContact(name: String, number: String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedContext)
        
        let contact = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        contact.setValue(name, forKey: "name")
        contact.setValue(number, forKey: "number")
        
        do {
            try managedContext.save()
            contacts.append(contact)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            // Delete the row from the data source
            
            let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = applicationDelegate.managedObjectContext
            
            managedContext.deleteObject(contacts[indexPath.row])
            
            try! managedContext.save()
            contacts.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
        }   
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

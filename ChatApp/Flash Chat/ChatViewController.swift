//
//  ViewController.swift
//  Chat-App
//
//  Created by Ali Mirabzadeh on 03/27/2019.
//  Copyright (c) 2019 AMZ Development. All rights reserved.
//

import UIKit
import Firebase // to use logout feature
import ChameleonFramework //for background color for cells
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    //variables here
    //create an array of Message type with nothing in it
    var messageArr : [Message] = [Message]()
    //IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    //load
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set myselfself as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        //Set myselfself as the delegate of the text field
        messageTextfield.delegate = self
        //Set the tapGesture, to find where the user tap, so we can use that when the user was done using the keyboar
        //hence the textFieldDidEndEditing() can be called
        //when the tableView gets tapped we call that method
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        //add this gesture
        messageTableView.addGestureRecognizer(tapGesture)
        //Registering MessageCell.xib file:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        //call this method to configure the body of cell message
        configureTableView()
        //after configuring retrive the messages if any exist on the DB
        retrieveMessages()
        //get rid of the horizontal lines on the messageViewTable
        messageTableView.separatorStyle = .none
    }
    ///////////////////////////////////////////
    // TableView DataSource Methods
    //cellForRowAtIndexPath:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //each cell in the able view would be the costum cell with the following identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArr[indexPath.row].messageBody
        cell.senderUsername.text = messageArr[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        //if the sender is the current user logged in
        if cell.senderUsername.text == Auth.auth().currentUser?.email as! String {
            //this is the message we sent
            cell.avatarImageView.backgroundColor = UIColor.flatRed()
            cell.avatarImageView.backgroundColor = UIColor.flatSkyBlue()
        }
            //if we didn't send the message
        else{

            cell.avatarImageView.backgroundColor = UIColor.flatGray()
            cell.avatarImageView.backgroundColor = UIColor.flatGreen()
        }
        return cell
    }
    //Declare numberOfRowsInSection:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    //tableViewTapped
    @objc func tableViewTapped() {
        //when done writing/editing
        //endEditing would call textFieldDidEndEditing()
        messageTextfield.endEditing(true)
    }
    //Declare configureTableView :
    func configureTableView(){
        //make the message body to have an automatic sizing depending on its text size
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    ///////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    //textFieldDidBeginEditing
    //when the user taps on the messageTextFiel the keyboard would come up so we need to change thehight of the messageCell when
    // cellBody gets tapped
    //this method would get called automatically by the OS
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //for animation
        UIView.animate(withDuration: 0.7, animations: {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        })
    }
    //textFieldDidEndEditing
    //this methid
    //this method doesn't get called automatically and we need to call it
    func textFieldDidEndEditing(_ textField: UITextField) {
        //for animation
        UIView.animate(withDuration: 0.7, animations: {
            //going back to normal hight
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    ///////////////////////////////////////////
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        //pressing send would also collapse the keyboard
        messageTextfield.endEditing(true)
        //after the send button got presse, it should get disabled so the user cannot press it again
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        //for messages to be saved in data base
        //would create "sub-database" to store messages
        let messageDataBase = Database.database().reference().child("Messages")
        // would save messages as dictinoray
        //the sender is the user who is logged in
        let messageInfo = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        //childByAutoId() would create a costume ID for the message
        //we set the key to the user message info
        messageDataBase.childByAutoId().setValue(messageInfo){
            //closure to check for errors
            (error, refrence) in
            if error != nil{
                print(error!)
            }else{
                print("Message has been saved in DB")
                //if the message got saved successfuly on DB, then re-enable the send button and the textField
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                //then set the textField to be empty for the next time
                self.messageTextfield.text = ""
            }
        }
    }
    //retrieveMessages method:
    func retrieveMessages(){
        //constant to retrieve messages from the DB of child "Messages"
        let messageDataBase = Database.database().reference().child("Messages")
        //whenever a new message gets added to the DB, this method would get called to retrieve that data and store in snapShot
        messageDataBase.observe(.childAdded) { (snapShot) in
            //since snapShot has Any datatype, we convert it to a Dictinary as we stored data in the DB as a Dictionary which has data of String and String
            let snapShotValue = snapShot.value as! Dictionary<String, String>
            let textField = snapShotValue["MessageBody"]!
            let sender = snapShotValue["Sender"]!
            //create a new Message object
            let messageFromDB = Message()
            messageFromDB.messageBody = textField
            messageFromDB.sender = sender
            //add the message object to the array
            self.messageArr.append(messageFromDB)
            //configure the table View after retrieving data
            self.configureTableView()
            //the reload the data
            self.messageTableView.reloadData()
        }
    }
    //logout button
    @IBAction func logOutPressed(_ sender: AnyObject) {
        //Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
            //go back to the root viewControler
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Error in Loging out!")
        }
    }
}

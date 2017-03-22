//
//  MainAlarmViewController.swift
//  Alarm-ios-swift
//
//  Created by longyutao on 15-2-28.
//  Copyright (c) 2015年 LongGames. All rights reserved.
//

import UIKit
import EZClockView

class MainAlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
  @IBOutlet weak var analogView: UIView!
  @IBOutlet weak var timeClockLabel: UILabel!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  
    var alarmDelegate: AlarmApplicationDelegate = AppDelegate()
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    let time = Time()
    var timer: Timer?
    var clock: EZClockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainAlarmViewController.updateTime), userInfo: nil, repeats: true)
      
        self.segmentedControl.selectedSegmentIndex = 0
      
        clock = EZClockView(frame: analogView.frame)

      
        

        // Customize face with border thickness and background color
        clock.faceBorderWidth = 3
        clock.faceBackgroundColor = UIColor(white: 0.9, alpha: 1)

        // Set the thickness of any needle
        clock.hoursThickness = 5

        // Set the length of any needle (1 means the needle is as long as the face radius)
        clock.minutesLength = 0.5

        // Offset is how far beyond the center the needle can go back.
        clock.secondsOffset = 5

        // You can customize several markings properties
        clock.markingBorderSpacing = 5
        clock.markingHourLength = 10
        clock.markingMinuteLength = 5
        clock.markingHourThickness = 3

        clock.markingMinuteColor = UIColor.darkGray
      

        self.view.addSubview(clock)
        clock.isHidden = true
      
              
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTime()
        alarmModel = Alarms()
        tableView.reloadData()
        //dynamically append the edit button
        if alarmModel.count != 0 {
            self.navigationItem.leftBarButtonItem = editButtonItem
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        }
        //unschedule all the notifications, faster than calling the cancelAllNotifications func
        UIApplication.shared.scheduledLocalNotifications = nil
        
        let cells = tableView.visibleCells
        if !cells.isEmpty {
            for i in 0..<cells.count {
                if alarmModel.alarms[i].enabled {
                    (cells[i].accessoryView as! UISwitch).setOn(true, animated: false)
                    cells[i].backgroundColor = UIColor.white
                    cells[i].textLabel?.alpha = 1.0
                    cells[i].detailTextLabel?.alpha = 1.0
                }
                else {
                    (cells[i].accessoryView as! UISwitch).setOn(false, animated: false)
                    cells[i].backgroundColor = UIColor.groupTableViewBackground
                    cells[i].textLabel?.alpha = 0.5
                    cells[i].detailTextLabel?.alpha = 0.5
                }
            }
        }
    }
  
    func updateTime(){
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "HH:mm:ss"
        timeClockLabel.text = formatter.string(from: time.clock as Date)
      
        let timeclock = formatter.string(from: time.clock as Date)
        let splittedTime = timeclock.components(separatedBy: ":")
        let hr = Int(splittedTime[0])
        let min = Int(splittedTime[1])
        let sec = Int(splittedTime[2])
      
        // Setup time
        clock.hours = hr!
        clock.minutes = min!
        clock.seconds = sec!
      
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if alarmModel.count == 0 {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        else {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        }
        return alarmModel.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            performSegue(withIdentifier: Id.editSegueIdentifier, sender: SegueInfo(curCellIndex: indexPath.row, isEditMode: true, label: alarmModel.alarms[indexPath.row].label, mediaLabel: alarmModel.alarms[indexPath.row].mediaLabel, mediaID: alarmModel.alarms[indexPath.row].mediaID, repeatWeekdays: alarmModel.alarms[indexPath.row].repeatWeekdays))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.alarmCellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Id.alarmCellIdentifier)
        }
        //cell text
        cell!.selectionStyle = .none
        cell!.tag = indexPath.row
        let alarm: Alarm = alarmModel.alarms[indexPath.row]
        let amAttr: [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 45.0)]
        let str = NSMutableAttributedString(string: alarm.formattedTime, attributes: amAttr)
        let timeAttr: [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 45.0)]
        str.addAttributes(timeAttr, range: NSMakeRange(0, str.length-2))
        cell!.textLabel?.attributedText = str
        cell!.detailTextLabel?.text = alarm.label
        //append switch button
        let sw = UISwitch(frame: CGRect())
        sw.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);
        
        //tag is used to indicate which row had been touched
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(MainAlarmViewController.switchTapped(_:)), for: UIControlEvents.touchUpInside)
        if alarm.enabled {
            sw.setOn(true, animated: false)
        }
        cell!.accessoryView = sw
        
        //delete empty seperator line
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        return cell!
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        alarmModel.alarms[index].enabled = sender.isOn
        if sender.isOn {
            print("switch on")
            sender.superview?.backgroundColor = UIColor.white
            alarmScheduler.setNotificationWithDate(alarmModel.alarms[index].date, onWeekdaysForNotify: alarmModel.alarms[index].repeatWeekdays, snooze: alarmModel.alarms[index].snoozeEnabled, soundName: alarmModel.alarms[index].mediaLabel, index: index)
            let cells = tableView.visibleCells
            if !cells.isEmpty {
                cells[index].textLabel?.alpha = 1.0
                cells[index].detailTextLabel?.alpha = 1.0
            }
        }
        else {
            print("switch off")
            sender.superview?.backgroundColor = UIColor.groupTableViewBackground
            let cells = tableView.visibleCells
            if !cells.isEmpty {
                cells[index].textLabel?.alpha = 0.5
                cells[index].detailTextLabel?.alpha = 0.5
            }
            alarmScheduler.reSchedule()
        }
    }

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            alarmModel.alarms.remove(at: index)
            alarmScheduler.reSchedule()
            let cells = tableView.visibleCells
            for cell in cells {
                let sw = cell.accessoryView as! UISwitch
                //adjust saved index when row deleted
                if sw.tag > index {
                    sw.tag -= 1
                }
            }
            if alarmModel.count == 0 {
                self.navigationItem.leftBarButtonItem = nil
            }
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }   
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let dist = segue.destination as! UINavigationController
        let addEditController = dist.topViewController as! AlarmAddEditViewController
        if segue.identifier == Id.addSegueIdentifier {
            addEditController.navigationItem.title = "Add Alarm"
            addEditController.segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, label: "Alarm", mediaLabel: "bell", mediaID: "", repeatWeekdays: [])
            addEditController.repeatText = "Never"
        }
        else if segue.identifier == Id.editSegueIdentifier {
            addEditController.navigationItem.title = "Edit Alarm"
            addEditController.segueInfo = sender as! SegueInfo
            addEditController.repeatText = "Never"
        }
    }
    
    @IBAction func unwindFromAddEditAlarmView(_ segue: UIStoryboardSegue) {
        isEditing = false
    }
  
    deinit {
      if let timer = self.timer {
          timer.invalidate()
      }
    }
  
  @IBAction func segmentedControl(_ sender: Any) {
  
    if(self.segmentedControl.selectedSegmentIndex == 1){
      print("analog selected")
      timeClockLabel.isHidden = true
      clock.isHidden = false

    } else {
      print("digital selected")
      timeClockLabel.isHidden = false
      clock.isHidden = true

    }
    
  }
  
  
  

}


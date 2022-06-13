//
//  ViewController.swift
//  Project21 - Local Notifications
//
//  Created by Vitali Vyucheiski on 5/11/22.
//

import UIKit
import UserNotifications
import CoreHaptics

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var customACTitle = ""
    var customACBody = ""
    
    let generator = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }

    @objc func registerLocal() {
        generator.prepare()
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        generator.notificationOccurred(.success)
    }

    @objc func scheduleLocal() {
        generator.prepare()
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

       let content = UNMutableNotificationContent()
       content.title = "Late wake up call"
       content.body = "The early bird catches the worm, but the second mouse gets the cheese."
       content.categoryIdentifier = "alarm"
       content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

       var dateComponents = DateComponents()
       dateComponents.hour = 10
       dateComponents.minute = 30
// let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)


        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
       center.add(request)
        
        generator.notificationOccurred(.success)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let remindLater = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: .authenticationRequired)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindLater], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        generator.prepare()
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                showDiferentInstanceOfUN(0)
                
                generator.notificationOccurred(.success)

            case "show":
                // the user tapped our "show more info…" button
                print("Show more information…")
                showDiferentInstanceOfUN(1)
                
                generator.notificationOccurred(.success)
                
            case "remindLater":
                print("RemindLater tapped")
                
                let content = UNMutableNotificationContent()
                content.title = "Late wake up call AGAIN"
                content.body = "The early bird catches the worm, but the second mouse gets the cheese, got it, you snow white!"
                content.categoryIdentifier = "alarm"
                content.userInfo = ["customData": "fizzbuzz"]
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (24 * 60 * 60), repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
                
                generator.notificationOccurred(.success)

            default:
                break
            }
            
            completionHandler()
            
        }
    }
    
    @objc func showDiferentInstanceOfUN(_ MessageNumber: Int) {
        let message = ["Default message", "Show more info was tapped"]
        
        let ac = UIAlertController(title: message[MessageNumber], message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}


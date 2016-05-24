//
//  BibleGramUtil.swift
//  biblegram
//
//  Created by Weien Wang on 1/14/15.
//  Copyright (c) 2015 BibleKingdom. All rights reserved.
//

import UIKit
import Parse

class BibleGramUtil: NSObject {
    
    class var sharedInstance:BibleGramUtil {
        struct Singleton {
            static let instance = BibleGramUtil()
        }
        return Singleton.instance
    }
    
    func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setupLocalNotifications() {
        if UIApplication.sharedApplication().scheduledLocalNotifications.count == 0 {
            var calendar = NSCalendar.autoupdatingCurrentCalendar()
            var components = NSDateComponents()
            components.day = 1
            components.month = 1
            components.year = 2015
            components.hour = 10
            components.minute = 0
            components.second = 0
            calendar.timeZone = NSTimeZone.localTimeZone()
            var fireDate = calendar.dateFromComponents(components)
            
            var notification = UILocalNotification()
            notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
            notification.fireDate = fireDate
            notification.timeZone = NSTimeZone.localTimeZone()
            notification.alertBody = "Share the verse of the day with a friend!"
            notification.alertAction = "View"
            notification.applicationIconBadgeNumber = 1;
            notification.soundName = UILocalNotificationDefaultSoundName
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func pullVerses() -> Array<Verse> {
        var bibleVersesQuery = PFQuery(className: "BibleVerses")
        bibleVersesQuery.limit = 700
        var returnedObjects = bibleVersesQuery.findObjects()
        
        var formattedVerses:[Verse] = []
        for item in returnedObjects {
            var verseCategory : String
            if let parseCategory : String = item["category"] as? String {
                verseCategory = parseCategory
            }
            else {
                verseCategory = Constants.GlobalConstants.categories.last! //anytime
            }
 
            var formattedVerse = Verse(verse: item["verse"] as String, reference: item["reference"] as String, day: item["day"] as String, category: verseCategory, verseObjectId: item.objectId)
            
            formattedVerses.append(formattedVerse)
        }
        
        return formattedVerses
    }

    func pullCardsForCategory(category:String) -> Array<Card> {
        var cardQuery = PFQuery(className: "GreetingCards")
        cardQuery.limit = 15
        if category == "Featured" {
            cardQuery.whereKey("featured", equalTo:"Y")
        }
        else {
            cardQuery.whereKey("category", equalTo: category)
        }
        var returnedObjects = cardQuery.findObjects()
        var formattedCards:[Card] = []
        for item in returnedObjects
        {
            var imageFile = item["cardImage"] as PFFile
            var image = UIImage(data: imageFile.getData())
            var formattedCard = Card(title: item["title"] as String, image: image!, category:item["category"] as String, cardObjectId: item.objectId)
            formattedCards.append(formattedCard)
        }
        return formattedCards
    }
    
    func uploadLiveGram(fromName:String, fromEmail:String, toName:String, toEmail:String, verseId:String, message:String, cardObjectId:String) -> Bool {
        var liveGram = PFObject(className:"LiveGram")
        liveGram.setObject(fromName, forKey: "fromName")
        liveGram.setObject(fromEmail, forKey: "fromEmail")
        liveGram.setObject(toName, forKey: "toName")
        liveGram.setObject(toEmail, forKey: "toEmail")
        liveGram.setObject(message, forKey: "message")
        liveGram["verseId"] = PFObject(withoutDataWithClassName: "BibleVerses", objectId: verseId)
        liveGram["cardObjectId"] = PFObject(withoutDataWithClassName: "GreetingCards", objectId: cardObjectId)

        var error : NSError?
        var successful = liveGram.save(&error);
        if (successful) {
            NSLog("Upload liveGram success. LiveGram is %@", liveGram.objectId)
            
            PFCloud.callFunction("email", withParameters: ["livegramid":liveGram.objectId, "fromname":fromName, "toname":toName, "fromemail":fromEmail, "toemail":toEmail], error: &error)
            
            if (error == nil) {
                return true
            }
            else {
                NSLog("Error sending email with PFCloud: %@", error!)
                return false
            }
        }
        else {
            NSLog("Upload liveGram failed. Error is %@", liveGram.objectId, error!)
            return false
        }
    }
    
    //deprecated
    func sendToMandrill(fromEmail:String, toEmail:String, fromName:String, toName:String, liveGramID:String) -> Bool {
        let key = "X-0DG-a6NAtbViv1GFsiow"
        let liveGramURL = "http://biblekingdom.com/grams/\(liveGramID)"
        let subject = "\(fromName) sent you a BibleGram"
        let content = "Hi \(toName), \\n\\n\(fromName) sent you a BibleGram, which can be viewed here: \(liveGramURL). \\nWe hope it is an encouragement! \\n\\nYours,\\nBibleGram"
        
        let postString = "{\"key\": \"X-0DG-a6NAtbViv1GFsiow\", \"raw_message\": \"From: \(fromEmail)\\nTo: \(toEmail)\\nSubject: \(subject)\\n\\n\(content)\"}";
        let postData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string:"https://mandrillapp.com/api/1.0/messages/send-raw.json")
        request.HTTPMethod = "POST"
        request.setValue(String(countElements(postString)), forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Length")
        request.HTTPBody = postData;
        
        NSLog("Post: %@", postString)
        var error : NSError?
        var response : NSURLResponse? = NSURLResponse()
        let postReply = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)!
        let postReplyString = NSString(bytes: postReply.bytes, length: postReply.length, encoding: NSASCIIStringEncoding)
        
        if (error == nil) {
            NSLog("Post successful, response: %@, replyString: %@", response!, postReplyString!)
            return true
        }
        else {
            NSLog("Post failed, error: %@", error!)
            return false
        }
    }
}
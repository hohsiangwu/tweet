//
//  Tweet.swift
//  tweet
//
//  Created by Ho-Hsiang Wu on 5/2/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: Int?

    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?

    var favorited: Bool?
    var retweeted: Bool?
    var favorite_count: Int?
    var retweet_count: Int?

    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int

        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String

        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)

        favorited = dictionary["favorited"] as? Bool
        retweeted = dictionary["retweeted"] as? Bool
        favorite_count = dictionary["favorite_count"] as? Int
        retweet_count = dictionary["retweet_count"] as? Int
    }

    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}

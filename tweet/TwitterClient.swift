//
//  TwitterClient.swift
//  tweet
//
//  Created by Ho-Hsiang Wu on 5/2/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

let twitterConsumerKey = "XXXX"
let twitterConsumerSecret = "XXXX"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {

    var loginCompletion: ((user: User?, error: NSError?) -> ())?

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }

    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            // println("home timeline: \(response)")
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(tweets: nil, error: error)
            // println("error getting home timeline")
        })
    }

    func updateStatuses(status: String, otherParams: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = [String: AnyObject]()
        params["status"] = status
        if let otherParams = otherParams {
            for (k, v) in otherParams {
                params[k as! String] = v
            }
        }

        POST("1.1/statuses/update.json", parameters: params, constructingBodyWithBlock: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            // println("\(response)")
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(tweet: nil, error: error)
        }
    }

    func retweetStatus(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, constructingBodyWithBlock: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }

    func favoriteStatus(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = ["id": id]

        POST("1.1/favorites/create.json", parameters: params, constructingBodyWithBlock: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }

    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion

        // Fetch request token & redirect to authorization page
        requestSerializer.removeAccessToken()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            // println("Got the request token")
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
        }) { (error: NSError!) -> Void in
            // println("Error getting the request token: \(error)")
            self.loginCompletion?(user: nil, error: error)
        }
    }

    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            println("Got the access token")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                // println("user: \(response)")
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                // println("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                // println("error getting current user")
                self.loginCompletion?(user: nil, error: error)
            })
        }) { (error: NSError!) -> Void in
            // println("Failed to receive access token")
            self.loginCompletion?(user: nil, error: error)
        }
    }
}

//
//  TweetsViewController.swift
//  tweet
//
//  Created by Ho-Hsiang Wu on 5/2/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets: [Tweet]?
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var tweetsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tweetsTableView.insertSubview(refreshControl, atIndex: 0)

        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self

        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 200

        loadingView.stopAnimating()

        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            if let tweets = tweets {
                self.tweets = tweets
                self.tweetsTableView.reloadData()
                // self.tweetsTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tweetsTableView.numberOfSections())), withRowAnimation: .None)
            } else {
                println("\(error)")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func onRefresh() {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            if let tweets = tweets {
                self.tweets = tweets
                self.tweetsTableView.reloadData()
            }
        })

        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let len = self.tweets!.count
        if len > 0 && indexPath.row == len - 1 {
            println("\(indexPath.row) \(len)")
            loadingView.startAnimating()
            var params = ["max_id": self.tweets![len - 1].id!, "count": 20]
            TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: { (tweets, error) -> () in
                if let tweets = tweets {
                    println("\(tweets.count)")
                    self.tweets! += tweets
                    self.tweetsTableView.reloadData()
                    // self.tweetsTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tweetsTableView.numberOfSections())), withRowAnimation: .None)
                    self.delay(1, closure: {
                        self.loadingView.stopAnimating()
                    })
                } else {
                    println("\(error)")
                }
            })
        }

        var cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetTableViewCell
        let tweet = tweets![indexPath.row]
        if let user = tweet.user {
            cell.userImageView.setImageWithURL(NSURL(string: user.profileImageURL!))
            cell.userNameLabel.text = user.name!
            cell.userHandleLabel.text = "@\(user.screenName!)"
        }
        cell.tweetLabel.text = tweet.text
        cell.createdAtLabel.text = tweet.createdAtString

        if tweet.retweeted! {
            cell.retweetButton.setImage(UIImage(named: "retweet_on.png"), forState: .Normal)
        }
        cell.retweetCountLabel.text = "\(tweet.retweet_count!)"
        
        if tweet.favorited! {
            cell.favoriteButton.setImage(UIImage(named: "favorite_on.png"), forState: .Normal)
        }
        cell.favoriteCountLabel.text = "\(tweet.favorite_count!)"
        
        return cell
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }

    @IBAction func onRetweet(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = tweetsTableView.indexPathForCell(cell)!
        var tweet = tweets![indexPath.row]

        TwitterClient.sharedInstance.retweetStatus(tweet.id!, completion: { (tweet, error) -> () in
            if tweet != nil {
                button.setImage(UIImage(named: "retweet_on.png"), forState: .Normal)
            }
        })
    }

    @IBAction func onFavorite(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = tweetsTableView.indexPathForCell(cell)!
        var tweet = tweets![indexPath.row]

        TwitterClient.sharedInstance.favoriteStatus(tweet.id!, completion: { (tweet, error) -> () in
            if tweet != nil {
                button.setImage(UIImage(named: "favorite_on.png"), forState: .Normal)
            }
        })

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if sender is UITableViewCell {
            let cell = sender as! UITableViewCell
            let indexPath = tweetsTableView.indexPathForCell(cell)!
            var tweet = tweets![indexPath.row]
            var tweetDetailsViewController = segue.destinationViewController as! TweetDetailsViewController
            tweetDetailsViewController.tweet = tweet
        } else if sender is UIButton {
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview as! UITableViewCell
            let indexPath = tweetsTableView.indexPathForCell(cell)!
            var tweet = tweets![indexPath.row]
            var updateTweetViewController = segue.destinationViewController as! UpdateTweetViewController
            updateTweetViewController.replyTweet = tweet
        }
    }
}

//
//  TweetDetailsViewController.swift
//  tweet
//
//  Created by Ho-Hsiang Wu on 5/3/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    var tweet: Tweet?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = tweet!.user {
            userImageView.setImageWithURL(NSURL(string: user.profileImageURL!))
            userNameLabel.text = user.name!
            userHandleLabel.text = "@\(user.screenName!)"
        }
        tweetLabel.text = tweet!.text
        if tweet!.retweeted! {
            retweetButton.setImage(UIImage(named: "retweet_on.png"), forState: .Normal)
        }
        retweetCountLabel.text = "\(tweet!.retweet_count!)"

        if tweet!.favorited! {
            favoriteButton.setImage(UIImage(named: "favorite_on.png"), forState: .Normal)
        }
        favoriteCountLabel.text = "\(tweet!.favorite_count!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onReply(sender: AnyObject) {
    }

    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweetStatus(tweet!.id!, completion: { (tweet, error) -> () in
            if tweet != nil {
                self.retweetButton.setImage(UIImage(named: "retweet_on.png"), forState: .Normal)
                self.retweetCountLabel.text = "\(tweet!.retweet_count!)"
            }
        })
    }

    @IBAction func onFavorite(sender: AnyObject) {
        TwitterClient.sharedInstance.favoriteStatus(tweet!.id!, completion: { (tweet, error) -> () in
            if tweet != nil {
                self.favoriteButton.setImage(UIImage(named: "favorite_on.png"), forState: .Normal)
                self.favoriteCountLabel.text = "\(tweet!.favorite_count!)"
            }
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var updateTweetViewController = segue.destinationViewController as! UpdateTweetViewController
        updateTweetViewController.replyTweet = tweet
    }
}

//
//  UpdateTweetViewController.swift
//  tweet
//
//  Created by Ho-Hsiang Wu on 5/3/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class UpdateTweetViewController: UIViewController, UITextViewDelegate {

    var replyTweet: Tweet?

    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var tweetWordCountLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userImageView.setImageWithURL(NSURL(string: User.currentUser!.profileImageURL!))
        userNameLabel.text = User.currentUser!.name!
        userHandleLabel.text = "@\(User.currentUser!.screenName!)"

        tweetTextView.delegate = self

        if replyTweet != nil {
            tweetButton.title = "Reply"
        }
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewDidChange(textView: UITextView) {
        let tweet = textView.text
        let tweetLength = count(tweet)
        tweetWordCountLabel.text = "\(140 - tweetLength)"
        if tweetLength > 140 {
            textView.text = tweet.substringToIndex(advance(tweet.startIndex, 140))
        }
    }

    @IBAction func onUpdateTweet(sender: AnyObject) {
        var params = [String: AnyObject]()
        if replyTweet != nil {
            params["in_reply_to_status_id"] = replyTweet!.id
        }

        TwitterClient.sharedInstance.updateStatuses(tweetTextView.text, otherParams: params, completion: { (tweet, error) -> () in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Siji Rachel Tom on 9/14/17.
//  Copyright © 2017 Siji Rachel Tom. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {
    
    var backdropURL : URL?
    var movieDescriptionStr : String!
    var movieTitleStr : String!

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var movieDetailsScrollView: UIScrollView!
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieDetailsScrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        movieTitle.text = movieTitleStr
        movieDescription.text = movieDescriptionStr
        if let backdropURL = backdropURL {
            backdropImageView.setImageWith(backdropURL)
        }
    }
    
    override func viewWillLayoutSubviews() {
        movieDescription.sizeToFit()
        movieTitle.sizeToFit()
        
        let padding : CGFloat = 8.0 * 5
        var size = movieDetailsScrollView.frame.size
        size.height = movieTitle.frame.size.height + movieDescription.frame.size.height + padding
        movieDetailsScrollView.contentSize = size
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

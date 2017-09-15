//
//  NowPlayingTableViewCell.swift
//  Flicks
//
//  Created by Siji Rachel Tom on 9/14/17.
//  Copyright © 2017 Siji Rachel Tom. All rights reserved.
//

import UIKit

class NowPlayingTableViewCell: UITableViewCell {

    @IBOutlet weak var nowPlayingMovieImageView: UIImageView!
    
    @IBOutlet weak var nowPlayingMovieDescription: UILabel!
    
    @IBOutlet weak var nowPlayingMovieTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

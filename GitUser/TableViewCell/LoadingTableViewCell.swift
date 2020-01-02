//
//  LoadingTableViewCell.swift
//  GitUser
//
//  Created by Antoni on 02/01/20.
//  Copyright © 2020 aiwiguna. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func startLoading(){
        activityIndicator.startAnimating()
    }
    
}

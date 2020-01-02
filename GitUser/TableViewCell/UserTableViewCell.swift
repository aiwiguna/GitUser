//
//  UserTableViewCell.swift
//  GitUser
//
//  Created by Antoni on 02/01/20.
//  Copyright © 2020 aiwiguna. All rights reserved.
//

import UIKit
import SDWebImage

protocol FaveDelegate {
    func faveChanged(isFave:Bool,indexPath:IndexPath)
}

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var adminStatusLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var indexPath : IndexPath?
    var delegate : FaveDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(user:User,indexPath:IndexPath){
        adminStatusLabel.text = "\(user.siteAdmin ?? false)"
        accountTypeLabel.text = user.type ?? ""
        urlLabel.text = user.url ?? ""
        loginLabel.text = user.login ?? ""
        avatarImageView.sd_setImage(with: URL(string: user.avatarURL ?? ""))
        faveButton.isSelected = user.isFave
        self.indexPath = indexPath
    }
    
    @IBAction func faveButtonTapped(_ sender:UIButton){
        faveButton.isSelected = !faveButton.isSelected
        if let index = indexPath{
            delegate?.faveChanged(isFave: faveButton.isSelected, indexPath: index)
            
        }
    }

}

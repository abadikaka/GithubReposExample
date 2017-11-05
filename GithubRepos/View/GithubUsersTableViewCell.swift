//
//  GithubUsersTableViewCell.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import UIKit
import AlamofireImage

/**
 * @discussion Class for the git list table view cell
 */
class GithubUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var githubUrlLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var siteAdminLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var avatarImageViewCustom: CustomImageView!
    
    // image identifier name
    let blankProfileImageName = "BlankProfile"

    // home controller reference set to weak avoid retain cycle
    weak var homeController: GithubUsersTableViewController!
    
    // detect index patch current cell
    var cellIndexPath: Int!
    
    var user: User? {
        didSet{
            if let _user = user {
                favoriteButton.isHidden = false
                loginLabel.text = _user.login
                accountTypeLabel.text = "Account Type: " + _user.accountType
                githubUrlLabel.text = "Git URL: " + _user.githubUrl
                siteAdminLabel.text = "Admin Status: " + _user.siteAdminStatus
                setupFilledUserView()
                setupProfileImage(imageUrl: _user.avatar)
            }else{
                favoriteButton.isHidden = true
                loginLabel.text = "a" // if set to empty would break some line on the label , weird
                accountTypeLabel.text = "a"
                githubUrlLabel.text = "a"
                siteAdminLabel.text = "a"
                avatarImageView.image = UIImage(named: blankProfileImageName)
                //avatarImageViewCustom.image = UIImage(named: blankProfileImageName)
                setupUnfilledUserView()
            }
        }
    }
    
    /**
     * @discussion function for automatically setup label color and background
     * @param array of labels that will be modified
     * @param textColor which is the label text color
     * @param backgroundColor which is the label background color
     */
    private func setupLabel(labels: [UILabel], textColor: UIColor, backgroundColor: UIColor){
        for label in labels {
            label.textColor = textColor
            label.backgroundColor = backgroundColor
        }
    }
    
    /**
     * @discussion function for setup view when user not nil
     */
    private func setupFilledUserView(){
        setupLabel(labels: [loginLabel, accountTypeLabel, githubUrlLabel, siteAdminLabel], textColor: .black, backgroundColor: .clear)
    }
    
    /**
     * @discussion function for setup view when user nil
     */
    private func setupUnfilledUserView(){
        setupLabel(labels: [loginLabel, accountTypeLabel, githubUrlLabel, siteAdminLabel], textColor: .clear, backgroundColor: .lightGray)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    /**
     * @discussion function for setup profile image
     * @param imageUrl which is string name of the image url
     */
    private func setupProfileImage(imageUrl: String) {
        //avatarImageViewCustom.loadImageUsingUrlString(imageUrl)
        let url = URL(string: imageUrl)!
        avatarImageView.af_setImage(withURL: url)
    }
    
    /**
     * @discussion function for handle the fav button when clicked
     */
    @IBAction func handleFavouriteButton(_ sender: Any) {
        guard let user = user else {
            return
        }
        
        if user.markedAsFavorite {
            homeController.viewModel.deleteCurentIndexToFavourite(indexPath: cellIndexPath)
            homeController.githubTableView.reloadData()
        }else{
            homeController.viewModel.addCurentIndexToFavourite(indexPath: cellIndexPath)
            homeController.githubTableView.reloadData()
        }
    }
}

//
//  GithubUsersTableViewController.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * @discussion Root class of Github Users List Table View
 */
class GithubUsersTableViewController: UITableViewController {

    @IBOutlet var githubTableView: UITableView!
    
    // refresh control -- lazy loading to avoid unwrapping variables
    lazy var refreshControls = UIRefreshControl()
    
    // cell identifier
    let githubCellIdentifier = "githubCellId"
    let githubDetailSegue = "githubDetailSegue"
    
    // all image name
    let favouriteImageName = "Favourite"
    let unfavouriteImageName = "Unfavourite"
    
    // all neccesarry properties
    //var githubUsers: Variable<GithubUsers?> = Variable(nil)
    var githubUsers: GithubUsers?
    
    //var savedFavouriteChannelIds: [Int] = []
    var savedFavouriteChannelIds: Variable<[Int]> = Variable([]) // using RxSwift
    
    // viewModel of current view
    var viewModel = GithubViewModel()
    var disposeBag = DisposeBag()
    
    // all string substitution
    let pullToRefreshString = "Pull To Refresh"
    
    // some checker
    var isFetching: Bool = false
    var errorResponse: Bool = false
    var currentPage: Int = 0
    
    // errorType variable to check current error
    var errorType: NetworkError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        populateGithubFavourites()
        manualRefresh()
        //populateGithubUsers()
        //setupViewModel()
    }
    
    /**
     * @discussion function for setup view model
     */
    private func setupViewModel(){
        //viewModel.delegate = self
    }
    
    /**
     * @discussion function for setup table view UI
     */
    private func setupTableView(){
        githubTableView.estimatedRowHeight = 150
        githubTableView.rowHeight = UITableViewAutomaticDimension
        githubTableView.allowsSelection = false
        refreshControls.attributedTitle = NSAttributedString(string: pullToRefreshString)
        refreshControls.addTarget(self, action: #selector(refresh), for: .valueChanged)
        githubTableView.refreshControl = refreshControls
    }
    
    /**
     * @discussion function for handling refresh control
     */
    @objc private func refresh(sender:AnyObject) {
        NotificationBarManager.successCalledOnce = false
        Config.Parameters.getUserPaginationNumber = 0
        currentPage = 0
        errorResponse = false
        populateGithubUsers()
    }
    
    /**
     * @discussion function for calling the refresh function manually
     */
    private func manualRefresh() {
        if let refreshControl = self.githubTableView.refreshControl {
            self.githubTableView.setContentOffset(CGPoint(x: 0, y:  -refreshControl.frame.size.height - self.topLayoutGuide.length), animated: true)
            self.githubTableView.refreshControl?.beginRefreshing()
            self.githubTableView.refreshControl?.sendActions(for: .valueChanged)
        }
    }
    
    /**
     * @discussion function for populate the github users from db (UserDefault)
     */
    private func populateGithubFavourites() {
        let observableGithubIds = viewModel.favouriteChannelIds.asObservable()
        observableGithubIds.bind(to: savedFavouriteChannelIds).disposed(by: disposeBag)
    }
    
    /**
     * @discussion function for populate the github users from API
     */
    private func populateGithubUsers() {
        if !isFetching {
            
            //
            // this one is with RxSwift but something went wrong move to old way !
            //
            
            /*isFetching = true
            viewModel.fetchGithubList()
            let observableGithubUsers = viewModel.githubList.asObservable()
            observableGithubUsers.bind(to: githubUsers).disposed(by: disposeBag)
            observableGithubUsers.bind { [unowned self] (response) in
                if response != nil {
                    print("Called this one", response!.users.count)
                    self.githubTableView.reloadData()
                    self.githubTableView.allowsSelection = true
                    self.isFetching = false
                }
                self.githubTableView.refreshControl!.endRefreshing()
                }.disposed(by: disposeBag
             )*/
            
            isFetching = true
            viewModel.fetchGithubListOldWay(completion: { [unowned self] response in
                if let response = response {
                    self.githubUsers = response
                    self.githubTableView.backgroundColor = .white
                    self.githubTableView.separatorStyle = .singleLine
                    self.githubTableView.allowsSelection = true
                    self.isFetching = false
                    self.errorResponse = false
                    self.githubTableView.reloadData()
                    if !NotificationBarManager.successCalledOnce {
                        NotificationBarManager.sharedInstance.showNotifBarSuccess()
                        NotificationBarManager.successCalledOnce = true
                    }
                    self.githubTableView.refreshControl!.endRefreshing()
                }else{
                    self.errorResponse = true
                    self.isFetching = false
                    self.githubTableView.reloadData()
                    self.githubTableView.backgroundColor = .lightGray
                    self.githubTableView.separatorStyle = .none
                    NotificationBarManager.sharedInstance.showNotifBarError(errorType: .noInternet)
                    self.githubTableView.refreshControl!.endRefreshing()
                }
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return githubUsers.value != nil ? githubUsers.value!.users.count > 0 ? githubUsers.value!.users.count+5 : 5 : 5
        return githubUsers != nil ? githubUsers!.users.count > 0 ? githubUsers!.users.count + 2 : 5 : self.errorResponse ? 1 : 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: githubCellIdentifier, for: indexPath) as! GithubUsersTableViewCell
        
        guard let githubUser = githubUsers else {
            cell.user = nil
            cell.cellIndexPath = 0
            cell.layoutIfNeeded()
            return cell
        }
        
        // to detect blank cell whenever view start fetching next pagination
        if indexPath.row > githubUser.users.count-1 {
            cell.user = nil
            cell.cellIndexPath = indexPath.item
            cell.layoutIfNeeded()
            return cell
        }
        
        cell.homeController = self
        cell.user = githubUser.users[indexPath.item]
        cell.cellIndexPath = indexPath.item
        cell.favoriteButton.setImage(UIImage(named:(githubUser.users[indexPath.item].markedAsFavorite ?  favouriteImageName: unfavouriteImageName)), for:.normal)
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row >= githubUsers!.users.count {
            return nil
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= githubUsers!.users.count {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let githubUser = githubUsers else {
            return
        }
        if errorResponse { // avoid infinite call when reach bottom - should be resetted using bottom refresh control
            return
        }
        let lastElement = githubUser.users.count - 1
        if !isFetching && indexPath.row == lastElement - 5 {
            currentPage += 1
            Config.Parameters.getUserPaginationNumber += 30
            populateGithubUsers()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == githubDetailSegue {
            let vc = segue.destination as! GithubDetailViewController
            if let indexPath =  githubTableView.indexPathForSelectedRow {
                if indexPath.row < githubUsers!.users.count {
                    let githubUser = githubUsers!.users[indexPath.row].githubUrl
                    vc.webViewLink = githubUser
                }
            }
        }
    }

}

// MARK: Conform to GithubViewModelDelegate protocol
/*extension GithubUsersTableViewController: GithubViewModelDelegate {
    
    func errorDidChange(error: NetworkError?) {
        self.errorType = error
    }
}
 */

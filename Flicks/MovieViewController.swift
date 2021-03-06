//
//  MovieViewController.swift
//  Flicks
//
//  Created by Siji Rachel Tom on 9/14/17.
//  Copyright © 2017 Siji Rachel Tom. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var nowPlayingTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var nowPlayingMoviesDict: [NSDictionary] = []
    var filteredMoviesDict: [NSDictionary] = []
    
    var refreshControl : UIRefreshControl!
    var initialLoad : Bool! = true
    var networkErrorView : UILabel!
    var isNowPlayingVC : Bool! = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowPlayingTableView.backgroundColor = UIColor(red: 250.0/255, green: 180.0/255, blue: 46.0/255, alpha: 0.7)
        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 250.0/255, green: 180.0/255, blue: 46.0/255, alpha: 0.7)
        
        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
        searchBar.delegate = self
        
        // Initialize network error UI
        networkErrorView = UILabel(frame: self.nowPlayingTableView.frame)
        networkErrorView.frame.origin.y += self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        networkErrorView.frame.size.height = 40
        networkErrorView.backgroundColor = UIColor.darkGray
        networkErrorView.alpha = 0.95
        networkErrorView.text = "Network Error!"
        networkErrorView.textColor = UIColor.white
        networkErrorView.textAlignment = NSTextAlignment.center
        networkErrorView.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.view.addSubview(networkErrorView)
        networkErrorView.isHidden = true
        
        fetchMovies()
        
        // Initialize a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        nowPlayingTableView.insertSubview(refreshControl, at: 0)
    }
    
    func fetchMovies() {
        let successCompletionBlock: ([NSDictionary]) -> Void = {[weak self] nowPlayingMoviesList in
            
            self?.networkErrorView.isHidden = true
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: (self?.nowPlayingTableView)!, animated: true)
            }
            
            self?.nowPlayingMoviesDict = nowPlayingMoviesList
            self?.filteredMoviesDict = nowPlayingMoviesList
            
            self?.nowPlayingTableView.reloadData()
            // Tell the refreshControl to stop spinning
            self?.refreshControl.endRefreshing()
        }
        
        let errorCompletionBlock: (Error?) -> Void = {[weak self] error in
            if let error = error {
                self?.networkErrorView.isHidden = false
                self?.refreshControl.endRefreshing()
                print(error)
            } else {
                print("Error is nil, but error closure was called?")
            }
        }
        
        // Display HUD right before the request is made, but only for the initial load. This doesn't have to be shown
        // when refreshing the data
        if initialLoad {
            MBProgressHUD.showAdded(to: nowPlayingTableView, animated: true)
            initialLoad = false
        }
        fetchMovies(successCallBack: successCompletionBlock, errorCallBack: errorCompletionBlock)
    }
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        // Clear the search bar
        searchBar.text = nil
        fetchMovies()
    }
    
    // MARK:- Search Bar methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMoviesDict = searchText.isEmpty ? nowPlayingMoviesDict : nowPlayingMoviesDict.filter({ (movieDict : NSDictionary) -> Bool in
            let movieName = movieDict["title"] as! String
            return movieName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        nowPlayingTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    // MARK:- Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMoviesDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = filteredMoviesDict[indexPath.row]
        let movieTitle = movie["title"] as! String
        let movieDescription = movie["overview"] as! String
        
        let cell = nowPlayingTableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell") as! MovieTableViewCell
        cell.nowPlayingMovieTitle.text = movieTitle
        cell.nowPlayingMovieDescription.text = movieDescription
        cell.contentView.backgroundColor = UIColor(red: 250.0/255, green: 180.0/255, blue: 46.0/255, alpha: 0.7)
        
        // movie icon
        if let movieIconURL = movie["poster_path"] as? String {
            let movieBaseUrl = "http://image.tmdb.org/t/p/w500" as String
            let movieUrl = URL(string: movieBaseUrl + movieIconURL)!
            cell.nowPlayingMovieImageView.setImageWith(movieUrl, placeholderImage: UIImage.init(named: "movieIcon"))
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.nowPlayingMovieImageView.image = nil
        }
        
        return cell
    }
    
    // MARK: - Movie API methods
    
    func fetchMovies(successCallBack: @escaping ([NSDictionary]) -> (), errorCallBack: ((Error?) -> ())?) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed" // From the assignment URL
        
        let url : URL!
        if isNowPlayingVC {
            url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        } else {
            url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")!
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorCallBack?(error)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                let movieResults = dataDictionary["results"] as! [NSDictionary]
                successCallBack(movieResults)
            }
        }
        task.resume()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()        
        
        let movieDetailVC = segue.destination as! MovieDetailViewController
        let indexPath = nowPlayingTableView.indexPath(for: sender as! MovieTableViewCell)!
        let movie = filteredMoviesDict[indexPath.row]
        
        let movieDescription = movie["overview"] as! String
        let movieTitle = movie["title"] as! String
        
        movieDetailVC.movieDescriptionStr = movieDescription
        movieDetailVC.movieTitleStr = movieTitle
        
        if let movieBackgroundURL = movie["poster_path"] as? String {
            let movieBaseUrl = "http://image.tmdb.org/t/p/w500" as String
            let movieUrl = URL(string: movieBaseUrl + movieBackgroundURL)!
            movieDetailVC.backdropURL = movieUrl
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            movieDetailVC.backdropURL = nil
        }
    }
}

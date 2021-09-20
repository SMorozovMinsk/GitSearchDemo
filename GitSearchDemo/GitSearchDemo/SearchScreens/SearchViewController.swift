//
//  SearchViewController.swift
//  GitSearchDemo
//
//  Created by Sergei Morozov on 19.09.21.
//

import UIKit
import SafariServices
// yes, I can divide this by extention, but I think that it's more better. You can opent this file and see all delegates and others
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak private var gitRepositorySearch: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak var activeIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak private var totalSearchResultsLabel: UILabel!
    
    private var searchedRepository = [Repository]()
    private var searching = false
    private var pageNumber : Int = 1
    
    //MARK: - intit VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopActivityIndicator()
        totalSearchResultsLabel.text = ""
        tableView.register(UINib(nibName: "DetailedSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailedSearchTableViewCell")
        gitRepositorySearch.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Table View delegates and Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedRepository.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameCellOnly", for: indexPath)
            cell.textLabel?.text = searchedRepository[indexPath.row].full_name
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedSearchTableViewCell", for: indexPath) as? DetailedSearchTableViewCell else {
                fatalError()
            }
            if indexPath.row > (pageNumber * 100 - 20 ){
                pageNumber = pageNumber + 1
                fetchRepositorySearchResults(searchString: gitRepositorySearch.text ?? "",pageNum: pageNumber)
            }
            cell.setDetiledRepositoryCell(repository: searchedRepository[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url =  searchedRepository[indexPath.row].html_url
        if UIApplication.shared.canOpenURL(url as URL) {
            searchBarSearchButtonClicked(gitRepositorySearch)
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchBarCancelButtonClicked(searchBar)
        } else {
            
            startActivityIndicator()
            fetchRepositorySearchResults(searchString: searchText)
        }
        searching = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stopActivityIndicator()
        searching = false
        searchBar.text = ""
        totalSearchResultsLabel.text = ""
        pageNumber = 1
        searchBar.endEditing(true)
        searchedRepository.removeAll()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        pageNumber = 1
        searchBar.endEditing(true)
        guard let searchText = searchBar.text else {return}
        if searchText != "" {
            fetchRepositorySearchResults(searchString: searchText)
        }
        tableView.setContentOffset(.zero, animated:true)
    }
    
    // MARK: - Get Search Results form GitHub
    private func fetchRepositorySearchResults(searchString: String, searchCount : Int = 100, pageNum : Int = 1) {
        GitHubService.shared.getSearchRepositories(searchString: searchString, searchCount: searchCount, pageNum: pageNum) { [weak self] (data, status, error) in
            self?.stopActivityIndicator()
            guard let data = data,
                  status == 200,
                  error == nil else {
                return
                
            }
            let totalCount =  data["total_count"] as? Int
            
            if let dataDict = data["items"],
               let data = try? JSONSerialization.data(withJSONObject: dataDict),
               let searchedRepository = try? JSONDecoder().decode([Repository].self, from: data) {
                DispatchQueue.main.async {
                    if totalCount != nil {
                        self?.totalSearchResultsLabel.text = String(format: "Total: %i", totalCount!)
                    }
                    if pageNum != 1 {
                        for repo in searchedRepository {
                            self?.searchedRepository.append(repo)
                        }
                        self?.appendTableView(numberOfItems: searchCount)
                    } else {
                        self?.searchedRepository = searchedRepository
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - add rows to table view without reloading
    
    func appendTableView(numberOfItems count: Int){
        
        let firstIndex = searchedRepository.count - count
        let lastIndex = searchedRepository.count - 1
        
        var indexPaths = [IndexPath]()
        for index in firstIndex...lastIndex {
            let indexPath = IndexPath(item: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        UIView.performWithoutAnimation {
            tableView.performBatchUpdates({ () -> Void in
                tableView.insertRows(at: indexPaths, with: .none)
                
            }, completion: { (finished) -> Void in
                
            })
        }
    }
    
    //MARK:- activity indicator
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activeIndicatorView.isHidden = false
            self.activeIndicatorView.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activeIndicatorView.isHidden = true
            self.activeIndicatorView.stopAnimating()
        }
    }
}



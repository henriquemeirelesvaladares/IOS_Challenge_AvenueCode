/*
* Copyright (c) 2017 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
  // MARK: - Properties
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  
  let searchController = UISearchController(searchResultsController: nil)
    
  var detailViewController: DetailViewController? = nil
  var locations: [Location] = []
  
  
  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.accessibilityIdentifier = "TableVC_Table"
    
    if let splitViewController = splitViewController {
      let controllers = splitViewController.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    // Setup the Search Controller
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search On Google Maps"
    navigationItem.searchController = searchController
    definesPresentationContext = true
    searchController.becomeFirstResponder()
    searchController.searchBar.delegate = self
    searchController.searchBar.accessibilityIdentifier = "SearchBar"
    

    
    // Setup the search footer
    //A view do footer da searchBar será o botão "display all results" para redirecionar para pagina seguinte
    let eventoToqueFooterResultados = UITapGestureRecognizer(target: self, action:  #selector (self.displayAllLocations (_:)))
    searchFooter.addGestureRecognizer(eventoToqueFooterResultados)
    
    tableView.tableFooterView = searchFooter
  }
  
    override func viewDidAppear(_ animated: Bool) {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    // or for Swift 4
    @objc func displayAllLocations(_ sender:UITapGestureRecognizer){
        print("teste aperta footer")
        
        //print ("count objects = \(filteredCandies.count)")
        if(locations.count == 0){
            return
        }
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        nextViewController.viewTitle.title = "All Results"
        //passa como parametro o array de localizacoes buscados nesta tela.
        nextViewController.locations = self.locations
        nextViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        nextViewController.navigationItem.leftItemsSupplementBackButton = true
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        print("cancel button pushed")
        searchBar.isLoading = false
    }
    
  
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //do something
        searchBar.resignFirstResponder() //hide keyboard
        if fetchResults() {
            searchBar.isLoading = true
            print("faca a busca")
            makeGetCall(stringToFetch: searchController.searchBar.text!)
        }
        //print("teste return button pushed")
    }
    
    func printRequestErrorOnFooter(stringError: String)
    {
        searchController.searchBar.isLoading = false
        searchFooter.setResultMessage(stringResult: stringError)
    }
    
    func makeGetCall(stringToFetch: String) {
        // Set up the URL request
        
       
        
        let todoEndpoint: String = "http://maps.googleapis.com/maps/api/geocode/json?address=\(stringToFetch)&sensor=false"
     
        var escapedString = todoEndpoint.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        guard let url = URL(string: escapedString!) else {
            print("Error: cannot create URL")
            self.printRequestErrorOnFooter(stringError: "Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                self.printRequestErrorOnFooter(stringError: "error calling GET on /todos/1")
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.printRequestErrorOnFooter(stringError: "Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        self.printRequestErrorOnFooter(stringError: "error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                //print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let status = todo["status"] as? String else {
                    print("Could not get todo title from JSON")
                    self.printRequestErrorOnFooter(stringError: "Could not get todo title from JSON")
                    return
                }
                print("response status: " + status)
                
                let results = todo["results"] as? [[String: Any]]
                
                //reinstancia o array que contem os resultados da busca.
                self.locations.removeAll()
                
                for result in results! {
                        if let geometry = result["geometry"] as? [String:Any] {
                            if let locationCoordinates = geometry["location"] as? [String:Any] {
                                if let latitude = locationCoordinates["lat"] as? Double {
                                    if let longitude = locationCoordinates["lng"] as? Double {
                                        
                                        let formatted_address = result["formatted_address"] as! String
                                        
                                        
                                        self.locations.append(Location(name:formatted_address, latitude:latitude, longitude:longitude))
                                        
                                    }
                                }
                            }
                        }
                }
                //resultados buscados com sucesso da requisicao asincrona !
                print(self.locations)
                DispatchQueue.main.async {
                    //pára o indicador de atividades
                    self.searchController.searchBar.isLoading = false
                    self.tableView.reloadData()
                }
                
                
            } catch  {
                print("error trying to convert data to JSON")
                self.printRequestErrorOnFooter(stringError: "error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func fetchResults() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
  
  override func viewWillAppear(_ animated: Bool) {
    if splitViewController!.isCollapsed {
      if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
    }
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table View
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fetchResults() {
        if(locations.count == 1){
            //se existe apenas um resultado, nao mostra o footer
            searchFooter.setNotFiltering()
        }else if(locations.count >= 1){
            //se há mais de um resultado de busca, mostra display all on map.
            searchFooter.setResultMessage(stringResult: "Display All on Map")
        }else if(locations.count == 0){
            searchFooter.setResultMessage(stringResult: "No items match your query")
        }
        return locations.count
    }
    //se nao existe nenhum resultado no filtro, mostra que nenhum resultado foi encontrado.
    searchFooter.setNotFiltering()
    return locations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel!.text = locations[indexPath.row].name
    return cell
  }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let locationName = locations[indexPath.row].name
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.locations = [locations[indexPath.row]]
        controller.viewTitle.title = locationName
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
}


extension UISearchBar {
    
    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }
    
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}



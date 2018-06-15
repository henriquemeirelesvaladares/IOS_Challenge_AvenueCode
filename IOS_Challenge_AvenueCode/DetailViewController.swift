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
import MapKit
import GoogleMaps
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var addRemoveButton: UIButton!
    @IBOutlet weak var viewTitle: UINavigationItem!
    
    //array que conterá os parametros passados pela tela anterior
    var locations: [Location] = []
    var singleLocation:Location? = nil
    
    var locationsCoreData: [NSManagedObject] = []
    var locationAlreadyExists = false
    
    override func loadView() {
        //Para displayAll, a funcionalidade de adicionar/deletar placemarker nao se aplica
        if(locations.count > 1){
            self.addRemoveButton.setTitle("", for: UIControlState.normal)
        }
        if(locations.count == 1){
            singleLocation = locations[0]
        }
        
        loadCoreDataLocations()
        
        //calcula o ponto medio dos pontos para centralizacao dos pontos, se há apenas um ponto, a camera é centralizada nele.
        let midPoint = calculateMidCoordinatePoint()
        
        let camera = GMSCameraPosition.camera(withLatitude: midPoint.latitude, longitude: midPoint.longitude, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        var markerList = [GMSMarker]()
        
        // Cria um placemarker para cada objeto passado por parametro na tela anterior
        for location in locations{
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = location.name
            marker.snippet = "( \(location.latitude) \(location.longitude))"
            marker.map = mapView
            markerList.append(marker)
        }
        //fit map to markers
        var bounds = GMSCoordinateBounds()
        for marker in markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        mapView.animate(with: update)
   }
    
   func calculateMidCoordinatePoint() -> CLLocationCoordinate2D
   {
    if locations.count == 1{
        return CLLocationCoordinate2D(latitude: locations[0].latitude, longitude: locations[0].longitude)
    }else{
        var latitudes = [Double]()
        var longitudes = [Double]()
        for location in locations{
            latitudes.append(location.latitude)
            longitudes.append(location.longitude)
        }
        let minLat = latitudes.min()
        let maxLat = latitudes.max()
        let minLon = longitudes.min()
        let maxLon = longitudes.max()
        return CLLocationCoordinate2D(latitude: (minLat!+maxLat!)/2, longitude: (minLon!+maxLon!)/2 )
    }
  }

  func loadCoreDataLocations(){
    //1 busca a instancia de appDelegate
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    //busca o contexto de persistencia do coreData
    let managedContext = appDelegate.persistentContainer.viewContext
    
    //2 busca todos registros da entidade LocationCoreData
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocationCoreData")
    
    //3
    do {
        locationsCoreData = try managedContext.fetch(fetchRequest)
        
        //adiciona os dados ja existentes do coreData ao vetor de localizacoes
        for item in locationsCoreData{
            print(item.value(forKey: "name") as! String)
                self.locationAlreadyExists = false
                for location in locations{
                    if(location.name == item.value(forKey: "name") as! String){
                        self.locationAlreadyExists = true
                    }
                }
            
                if(!self.locationAlreadyExists){
                    self.locations.append(Location(name: item.value(forKey: "name") as! String, latitude: item.value(forKey: "latitude") as! Double, longitude: item.value(forKey: "longitude") as! Double))
                }
        }
        //verifica se a localizacao passada por parametro na tela anterior ja está adicionada no coreData
        if(singleLocation != nil){
            var locationExists = false
            for item in locationsCoreData{
                if(item.value(forKey: "name") as! String == singleLocation?.name){
                    locationExists = true
                }
            }
            //se a localizacao ja esta no coreData, poe disponivel o botao delete
            if(locationExists){
                self.addRemoveButton.setTitle("Delete", for: UIControlState.normal)
            }
            
        }
        
       
    } catch let error as NSError {
        printCoreDataMessage(stringTitle: "Error", stringError: "Could not load core data locations")
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
    @IBAction func persistPlacerMarker(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1 busca o contexto coreData
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2 busca a entidade Location
        let locationEntity = NSEntityDescription.entity(forEntityName: "LocationCoreData", in: managedContext)!
        //cria uma instancia do objeto coreData a se armazenar
        let location = NSManagedObject(entity: locationEntity, insertInto: managedContext)
        
        
        
        
        // 3 adiciona os atributos a classe persistente
        location.setValue(self.singleLocation?.name, forKeyPath: "name")
        location.setValue(self.singleLocation?.longitude, forKeyPath: "longitude")
        location.setValue(self.singleLocation?.latitude, forKeyPath: "latitude")
       
        
        if(self.addRemoveButton.currentTitle == "Save"){
            // 4 salva a entidade no contexto
            do {
                try
                    managedContext.save()
                    locationsCoreData.append(location)
                    printCoreDataMessage(stringTitle: "Success", stringError: "Location succesfully saved")
                    //deleta o botao que adiciona o placemarker, para nao permitir o usuario salvar o mesmo objeto.
                    self.addRemoveButton.setTitle("Delete", for: UIControlState.normal)
            } catch let error as NSError {
                printCoreDataMessage(stringTitle: "Error", stringError: "Could not save. \(error), \(error.userInfo)")
            }
        }else if(self.addRemoveButton.currentTitle == "Delete"){
            
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete item?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //execute some code when this option is selected
                
                // Initialize Fetch Request
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCoreData")
                // Configure Fetch Request
                fetchRequest.includesPropertyValues = false
                do {
                    let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                    for item in items {
                        if(self.singleLocation?.name == item.value(forKey: "name") as! String){
                            managedContext.delete(item)
                        }
                    }
                    // Save Changes
                    try managedContext.save()
                    self.printCoreDataMessage(stringTitle: "Success", stringError: "Location succesfully deleted")
                    //deleta o botao que adiciona o placemarker, para nao permitir o usuario salvar o mesmo objeto.
                    self.addRemoveButton.setTitle("Save", for: UIControlState.normal)
                } catch let error as NSError{
                    self.printCoreDataMessage(stringTitle: "Error", stringError: "Could not save. \(error), \(error.userInfo)")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                //execute some code when this option is selected
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func printCoreDataMessage(stringTitle: String, stringError: String){
        let alert = UIAlertController(title: stringTitle, message: stringError, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
}


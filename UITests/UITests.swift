//
//  UITests.swift
//  UITests
//
//  Created by Henrique Valadares on 13/06/18.
//  Copyright © 2018 Henrique Valadares. All rights reserved.
//

import XCTest


class UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let app = XCUIApplication()
    
    func testCancelButtonTapped() {
        //teste se o botao "Cancel" esta funcionando
        app.buttons["Cancel"].tap()
    }
    
    func testTextFieldSubmit() {
        //analisa se a searchBar responde ao evento de clicar no botão "busca" do teclado,
        //se a interface nao responde corretamente, nao é possivel realizar a chamada de web service
        app.otherElements["SearchBar"].responds(to: Selector(("searchBarSearchButtonClicked")))
    }
    
    
    func testSaveLocation() {
        //Este teste, testa componentes da primeira e segunda tela
        
        //Analisa se é possivel inserir texto no input text que busca localizacao por nome
        let searchBar = app.otherElements["SearchBar"]
        searchBar.tap()
        //1 - primeiro clica no inputText da searchBar
        //espera um momento até que o teclado apareca na tela
        sleep(5)
        //digita Belo Horizonte no campo de texto
        searchBar.typeText("Belo Horizonte")
        
        //faz a busca e chama o web service
        app.buttons["Buscar"].tap()
        //aguardo um momento até que se obtenha os resultados e se popule a tableView
        sleep(2)
        
        //A busca Belo Horizonte, sempre retornará apenas um resultado, portanto clica nesta
        //celula para levar o fluxo de navegacao para pagina seguinte.
        let tableView = app.tables.containing(.table, identifier: "TableVC_Table")
        let firstCell = tableView.cells.element(boundBy: 0)
        
        firstCell.tap()
        //2 - Esta etapa do teste pertence a segunda tela(mapa)
        //A primeira vez que este teste executar, passará, pois Belo Horizonte ainda nao estará salvo no coreData, na segunda vez falhará pois o nome do botao será Delete
        app.buttons["Save"].tap()
    }
    
   
    

}

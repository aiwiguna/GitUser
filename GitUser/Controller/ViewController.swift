//
//  ViewController.swift
//  GitUser
//
//  Created by Antoni on 02/01/20.
//  Copyright © 2020 aiwiguna. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class ViewController: UIViewController {
    
    enum State{
        case empty
        case normal
        case error
    }

    @IBOutlet weak var tableView: UITableView!
    
    var users:[User] = []
    var faves:[Favorite] = []
    var isCanLoadMore = false
    var currentState = State.empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadFave()
        loadUser(userNumber:0)
    }
    
    func loadUser(userNumber:Int){
        isCanLoadMore = false
        ConnectionManager.getUsers(userNumber: userNumber) { (users, error) in
            if let errorValue = error{
                self.currentState = .error
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: errorValue.localizedDescription)
                    self.tableView.reloadData()
                }
            }else if let usersValue = users{
                self.currentState = .normal
                if(userNumber == 0){
                    self.users.removeAll()
                }
                self.users.append(contentsOf: usersValue)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.isCanLoadMore = true
                }
            }
        }
    }
    
    func showAlert(title:String, message:String){
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            vc.dismiss(animated: true, completion: nil)
        }))
        present(vc, animated: true, completion: nil)
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingTableViewCell")
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentState == .error{
            return users.count
        }else if currentState == .empty{
            return 1
        }else{
            return users.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentState == .empty{
            let empty = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            return empty
        }else if indexPath.row >= users.count{
            let footer = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell") as! LoadingTableViewCell
            footer.startLoading()
            return footer
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
            var user = users[indexPath.row]
            if faves.isExist(where: {$0.id == user.id ?? 0}){
                user.isFave = true
            }
            cell.setupCell(user: user,indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == users.count && isCanLoadMore{
            if let user = users.last{
                loadUser(userNumber: user.id ?? 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < users.count {
            let user = users[indexPath.row]
            if let url = URL(string: user.htmlURL ?? "") {
                let vc = SFSafariViewController(url: url)
                vc.delegate = self
                present(vc, animated: true)
            }
        }
    }
}

extension ViewController: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: FaveDelegate{
    func faveChanged(isFave: Bool, indexPath: IndexPath) {
        users[indexPath.row].isFave = isFave
        if isFave{
            saveFave(id: users[indexPath.row].id ?? 0)
        }else{
            deleteFave(id: users[indexPath.row].id ?? 0)
        }
        tableView.reloadData()
    }
}

//Core data handle
extension ViewController{
    func loadFave(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest = Favorite.fetchRequest()
        do{
            faves = try context.fetch(fetchRequest)
        }catch{
            print("Failed load favorite")
        }
    }
    
    func saveFave(id:Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fave = Favorite(context: context)
        fave.id = Int64(id)
        do{
            try context.save()
            faves.append(fave)
        }catch{
            print("Failed save favorite")
        }
    }
    func deleteFave(id:Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let deletes = faves.all(where: {$0.id == id})
        for del in deletes{
            context.delete(del)
        }
        do{
            try context.save()
        }catch{
            print("Failed delete favorite")
        }
        loadFave()
    }
}


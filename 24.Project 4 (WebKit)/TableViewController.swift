//
//  TableViewController.swift
//  24.Project 4 (WebKit)
//
//  Created by Валентин Картошкин on 03.05.2025.
//

import UIKit

class TableViewController: UITableViewController {
    
    //список разрешенных вебсайтов, по которым пользователь может переходить в нашем приложении
    var websites = ListWebsites.websites
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose website"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "website")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = ViewController()
        vc.websites = websites
        vc.selectedWebsite = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

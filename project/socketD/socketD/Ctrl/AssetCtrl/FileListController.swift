//
//  FileListController.swift
//  socketD
//
//  Created by Jz D on 2020/5/7.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

import AVFoundation

class FileListController: UITableViewController {
    
    let cellID = "cellID"
    var files = [URL]()
    var folders = [URL]()

    
    private lazy var refresh: UIRefreshControl = {
        let c = UIRefreshControl()
        c.addTarget(self, action: #selector(self.pullToRefresh), for: UIControl.Event.valueChanged)
        return c
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "媒体库"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        tableView.refreshControl = refresh
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    
    @objc
    func pullToRefresh(){
        refreshData()
        refresh.endRefreshing()
    }
    
    
    
    func refreshData(){
        files.removeAll()
        folders.removeAll()
        if let src = URL(string: URL.dir){
            do {
                let properties: [URLResourceKey] = [ URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
                let paths = try FileManager.default.contentsOfDirectory(at: src, includingPropertiesForKeys: properties, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles])
                for url in paths{
                    let isDirectory = (try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
                    let musicExtern = ["mp3", "m4a", "txt"]
                    if isDirectory{
                        folders.append(url)
                    }
                    else if musicExtern.contains(url.pathExtension){
                        files.append(url)
                    }
                }
                tableView.reloadData()
            } catch let error{
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return folders.count
        case 1:
            return files.count
        default:
            return 0
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            
            let attribute = [NSAttributedString.Key.foregroundColor: UIColor.green, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28)]
            
            let source = "\(indexPath.row)  ->  \(folders[indexPath.row].lastPathComponent)"
            let attrString = NSAttributedString(string: source, attributes: attribute)
            cell.textLabel?.attributedText = attrString
            return cell
        default:
            //  1
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            
            let attribute = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
            let source = "\(indexPath.row)  ->  \(files[indexPath.row].lastPathComponent)"
            let attrString = NSAttributedString(string: source, attributes: attribute)
            cell.textLabel?.attributedText = attrString
            return cell
        }
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let itemListCtrl = FileSubListCtrl()
            itemListCtrl.url = folders[indexPath.row]
            navigationController?.pushViewController(itemListCtrl, animated: true)
            

        case 1:
        
            let url = files[indexPath.row]
            guard url.absoluteString.contains("txt") == false else {
                //reading
                do {
                    let text = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
                    print(text)
                }catch { print(error) }
                return
            }
            navigationController?.pushViewController(PlayerController(music: url), animated: true)
        default:
            ()
        }
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 1:
            let url = files[indexPath.row]
            let contextItem = UIContextualAction(style: .destructive, title: "删文件") {  (contextualAction, view, boolValue) in
                do {
                    if FileManager.default.fileExists(atPath: url.path){
                        try FileManager.default.removeItem(atPath: url.path)
                    }
                    self.refreshData()
                } catch {
                    print(error)
                }
            }

            return UISwipeActionsConfiguration(actions: [contextItem])
        default:
            return nil
        }
        
        
        
    }
    
    /*
     
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
}

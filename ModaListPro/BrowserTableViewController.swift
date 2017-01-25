//
//  BrowserTableViewController.swift
//  ModaListPro
//
//  Created by Jim Hessin on 12/4/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import UIKit

class BrowserTableViewController: UITableViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var modeButton: UIBarButtonItem!

    var data = Browser()

    func reloadData(){
        if !availableModes.contains(currentMode) {
            currentMode = availableModes[0]
        }

        backButton.isEnabled = !(data.dir == .Root)
        modeButton.isEnabled = availableModes.count > 1

        tableView.reloadData()
    }

    enum Mode : String{
        case
        Checklist = "Checklist",
        Edit = "Edit",
        Browse = "Browse+"
    }

    var availableModes : [Mode]{
        get{
            var baseModes = [Mode.Browse]
            switch data.dir {
            case .AdminItems, .PrivateItems:
                baseModes.append(contentsOf: [Mode.Checklist, Mode.Edit])
            case .ReadOnlyItems:
                baseModes.append(.Checklist)
            case .AdminLists, .PrivateLists:
                baseModes.append(.Edit)
            default:
                return baseModes
            }

            return baseModes
        }
    }

    var currentMode: Mode = .Browse{
        didSet{
            if currentMode == .Edit{
                setEditing(true, animated: true)
            } else{
                setEditing(false, animated: true)
            }

            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count(forSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch currentMode {
        case .Browse:
            if let item = data.data(forIndexPath: indexPath){
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)

                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = data.dir.rawValue

                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditTableViewCell

                cell.newItem = true
                cell.textField.text = nil
                switch data.dir {
                case .AdminItems, .PrivateItems:
                    cell.textField.placeholder = "New Item..."
                    cell.updateText {
                        name in
                        self.data.viewStack.peek?.append(item: Item(name: name, key: "", checked: false, list: self.data.list!.key, group: self.data.group?.key))
                        cell.textField.text = nil
                    }
                case .PrivateLists, .AdminLists:
                    cell.textField.placeholder = "New List..."
                    cell.updateText {
                        name in
                        self.data.viewStack.peek?.append(item: List(name: name, key: "", group: self.data.group?.key))
                        cell.textField.text = nil
                    }
                case .Groups:
                    cell.textField.placeholder = "New Group..."
                    cell.updateText {
                        name in
                        self.data.viewStack.peek?.append(item: Group(name: name))
                        cell.textField.text = nil
                    }
                default:
                    // This should never execute
                    print("Error: New Item field in main menu")
                    return cell
                }

                return cell
            }
        case .Checklist:
            let item: Item = data.data(forIndexPath: indexPath) as! Item
            if item.checked{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckedCell", for: indexPath)

                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = data.dir.rawValue

                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)

                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = data.dir.rawValue

                return cell
            }
        case .Edit:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditTableViewCell
            switch data.dir {
            case .AdminItems, .PrivateItems:
                let item = data.data(forIndexPath: indexPath) as! Item

                cell.textField.text = item.name
                cell.updateText {
                    name in
                    self.data.viewStack.peek?.update(at: indexPath.row, with: item.name(name))
                }
            case .AdminLists, .PrivateLists:
                let list = data.data(forIndexPath: indexPath) as! List

                cell.textField.text = list.name
                cell.updateText {
                    name in
                    self.data.viewStack.peek?.update(at: indexPath.row, with: list.name(name))
                }
            case .Groups:
                let group = data.data(forIndexPath: indexPath) as! Group

                switch indexPath.section {
                case 0:
                    cell.textField.text = group.name
                    cell.updateText {
                        name in
                        self.data.viewStack.peek?.update(at: indexPath.row, with: group.name(name))
                    }
                default:
                    let viewCell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)

                    viewCell.textLabel?.text = group.name
                    viewCell.detailTextLabel?.text = data.dir.rawValue

                    return viewCell
                }
            default:
                return cell
            }

            return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Bar Buttons

    @IBAction func modePressed(_ sender: UIBarButtonItem) {
        if availableModes.count == 0{
            printMessage(title: "No Modes", message: "There are no modes available")
            return
        }

        let alert = UIAlertController(title: "Modes", message: nil, preferredStyle: .actionSheet)

        for mode in availableModes{
            let action = UIAlertAction(title: mode.rawValue, style: .default) {
                _ in
                self.currentMode = mode
            }
            alert.addAction(action)
        }

        present(alert, animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        data.back()
    }
}

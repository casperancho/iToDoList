//
//  ViewController.swift
//  iToDoList
//
//  Created by Артем Закиров on 15.11.2018.
//  Copyright © 2018 bmstu. All rights reserved.
//


import UIKit
import RealmSwift

class TasksList : Object {
    @objc dynamic var task = ""
    @objc dynamic var completed = false
}

class ViewController: UITableViewController {
    
    let realm = try! Realm()
    
    
    var itemsArray : Results<TasksList>!    // Массив для хранения записей
    var cellId = "Cell"     // Идентификатор ячейки
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Цвет заливки вью контроллера
        view.backgroundColor = .white
        
        // Цвет навигейшин бара
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 21/255,
                                                                   green: 101/255,
                                                                   blue: 192/255,
                                                                   alpha: 1)
        // Цвет текста для кнопки
        navigationController?.navigationBar.tintColor = .white
        
        // Добавляем кнопку "Добавить" в навигейшин бар
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addItem)) // Вызов метода для кнопки
        // Присваиваем ячейку для TableView с иднетифиактором "Cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        
        itemsArray = realm.objects(TasksList.self)
    }
    
    // Действие при нажатии на кнопку "Добавить"
    @objc func addItem(_ sender: AnyObject) {
       
                addAlertForNewItem()
    }
    
    func addAlertForNewItem() {
        
        // Создание алёрт контроллера
        let alert = UIAlertController(title: "Новая задача", message: "Пожалуйста заполните поле", preferredStyle: .alert)
        
        // Создание текстового поля
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая задача"
        }
        
        // Создание кнопки для сохранения новых значений
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { action in
            
            // Проверяем не является ли текстовое поле пустым
            guard let text = alertTextField.text, !text.isEmpty else {return}
            
            let task = TasksList()
            task.task = text
            
            try! self.realm.write {
                self.realm.add(task)
            }
            // Добавляем в массив новую задачу из текстового поля
//            self.itemsArray.append((alert.textFields?.first?.text)!)
            
            // Обновляем таблицу
            self.tableView.reloadData()
        }
        
        // Создаем кнопку для отмены ввода новой задачи
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alert.addAction(saveAction) // Присваиваем алёрту кнопку для сохранения результата
        alert.addAction(cancelAction) // Присваиваем алерут кнопку для отмены ввода новой задачи
        
        present(alert, animated: true, completion: nil) // Вызываем алёрт контроллер
    }
    
    //MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsArray.count != 0 {
            return itemsArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.task
        return cell
    }
    
    //MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editingRow = itemsArray[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { _,_ in
            try! self.realm.write {
                self.realm.delete(editingRow)
                tableView.reloadData()
            }
            
        }
        
        return [deleteAction]
    }
}


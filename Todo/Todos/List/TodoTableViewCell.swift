//
//  TodoTableViewCell.swift
//  PactTodo
//


import UIKit

protocol TodoTableViewCellDelegate: NSObjectProtocol {
    func todoCell(_ cell: TodoTableViewCell, didChangeCompletion completed: Bool)
}

class TodoTableViewCell: UITableViewCell {
    /* POI: Test outlets
     just to show why do we need to test outlets
     */
    @IBOutlet weak internal var notBoundControl: UIView!
    
    @IBOutlet weak internal var titleLabel: UILabel!
    @IBOutlet weak internal var descriptionLabel: UILabel!
    @IBOutlet weak internal var completedSwitch: UISwitch!
    @IBOutlet weak internal var priorityMarker: UIView!
    @IBAction func onChangeCompletion(_ sender: Any) {
        let s = sender as! UISwitch
        self.delegate?.todoCell(self, didChangeCompletion: s.isOn)
    }
    
    weak var delegate: TodoTableViewCellDelegate?
    private(set) var todoId: Int!
    
    func configure(id: Int,
                   title: String,
                   category: String,
                   priority: Int,
                   completed: Bool) {
        self.todoId = id
        self.titleLabel?.text = title
        self.descriptionLabel?.text = category
        self.completedSwitch?.setOn(completed, animated: true)
        switch priority {
        case 1:
            priorityMarker?.backgroundColor = .red
        case 2:
            priorityMarker?.backgroundColor = .orange
        case 3:
            priorityMarker?.backgroundColor = .green
        default:
            priorityMarker?.backgroundColor = .blue
        }
    }
    
}


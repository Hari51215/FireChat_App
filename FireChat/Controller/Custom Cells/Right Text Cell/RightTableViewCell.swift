//  RightTableViewCell.swift
//  Validation
//  Created by hari-pt5664 on 02/09/22.

import UIKit

//MARK: - Right Text Custom Cell Class

class RightTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var rightCellLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var bubbleStackView: UIStackView!
    static let cellNib = UINib(nibName: "RightTableViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(message: String, time: String) {
        self.rightCellLabel.text = message
        self.rightTimeLabel.text = time
        self.bubbleView.layer.cornerRadius = 5.0
    }
}

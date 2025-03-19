import UIKit

class TaskCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priorityView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(priorityView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dueDateLabel)
        
        NSLayoutConstraint.activate([
            priorityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priorityView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priorityView.widthAnchor.constraint(equalToConstant: 8),
            priorityView.heightAnchor.constraint(equalToConstant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: priorityView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dueDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dueDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dueDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        descriptionLabel.text = task.taskDescription
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dueDateLabel.text = formatter.string(from: dueDate)
        } else {
            dueDateLabel.text = "Tarih belirtilmedi"
        }
        
        // Priority color
        switch task.priority {
        case 0:
            priorityView.backgroundColor = .systemGray
        case 1:
            priorityView.backgroundColor = .systemYellow
        case 2:
            priorityView.backgroundColor = .systemRed
        default:
            priorityView.backgroundColor = .systemGray
        }
        
        // Completed task styling
        if task.isCompleted {
            titleLabel.textColor = .secondaryLabel
            titleLabel.attributedText = task.title?.strikethrough()
        } else {
            titleLabel.textColor = .label
            titleLabel.attributedText = nil
            titleLabel.text = task.title
        }
    }
}

extension String {
    func strikethrough() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.secondaryLabel
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
} 
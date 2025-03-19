import UIKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    func taskDetailViewController(_ controller: TaskDetailViewController, didSaveTask task: Task)
    func taskDetailViewControllerDidCancel(_ controller: TaskDetailViewController)
}

class TaskDetailViewController: UIViewController {
    weak var delegate: TaskDetailViewControllerDelegate?
    private let task: Task?
    private let coreDataManager = CoreDataManager.shared
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Görev başlığı"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let descriptionTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let prioritySegmentControl: UISegmentedControl = {
        let items = ["Düşük", "Orta", "Yüksek"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    init(task: Task?) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureWithTask()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(prioritySegmentControl)
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            prioritySegmentControl.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            prioritySegmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            prioritySegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            datePicker.topAnchor.constraint(equalTo: prioritySegmentControl.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        title = task == nil ? "Yeni Görev" : "Görevi Düzenle"
        
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureWithTask() {
        guard let task = task else { return }
        
        titleTextField.text = task.title
        descriptionTextView.text = task.taskDescription
        prioritySegmentControl.selectedSegmentIndex = Int(task.priority)
        
        if let dueDate = task.dueDate {
            datePicker.date = dueDate
        }
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.taskDetailViewControllerDidCancel(self)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Lütfen görev başlığını giriniz")
            return
        }
        
        if let task = task {
            // Update existing task
            task.title = title
            task.taskDescription = descriptionTextView.text
            task.priority = Int16(prioritySegmentControl.selectedSegmentIndex)
            task.dueDate = datePicker.date
            coreDataManager.updateTask(task)
            delegate?.taskDetailViewController(self, didSaveTask: task)
        } else {
            // Create new task
            let newTask = coreDataManager.createTask(
                title: title,
                description: descriptionTextView.text,
                dueDate: datePicker.date,
                priority: Int16(prioritySegmentControl.selectedSegmentIndex)
            )
            delegate?.taskDetailViewController(self, didSaveTask: newTask)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Hata",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
} 
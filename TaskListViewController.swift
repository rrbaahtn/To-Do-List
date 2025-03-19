import UIKit

class TaskListViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var tasks: [Task] = []
    private let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadTasks()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        title = "Yapılacaklar"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func loadTasks() {
        tasks = coreDataManager.fetchTasks()
        tableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        let taskVC = TaskDetailViewController(task: nil)
        taskVC.delegate = self
        let nav = UINavigationController(rootViewController: taskVC)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        let taskVC = TaskDetailViewController(task: task)
        taskVC.delegate = self
        let nav = UINavigationController(rootViewController: taskVC)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            self.coreDataManager.deleteTask(task)
            self.tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        let completeAction = UIContextualAction(style: .normal, title: "Tamamla") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            task.isCompleted.toggle()
            self.coreDataManager.updateTask(task)
            self.loadTasks()
            completion(true)
        }
        completeAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
}

// MARK: - TaskDetailViewControllerDelegate
extension TaskListViewController: TaskDetailViewControllerDelegate {
    func taskDetailViewController(_ controller: TaskDetailViewController, didSaveTask task: Task) {
        loadTasks()
        dismiss(animated: true)
    }
    
    func taskDetailViewControllerDidCancel(_ controller: TaskDetailViewController) {
        dismiss(animated: true)
    }
} 
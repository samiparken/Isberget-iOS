import Foundation
class TaskManager {
    let defaults = UserDefaults.standard
        
    func setTaskDone(_ id: Int){
        APIsetTaskDone(taskId: id); semaphore.wait()
    }
    
    func reportTask(_ id: Int, _ reasonId: Int, _ reasonText: String) {
        APIreportTask(taskId: id, reasonId: reasonId, reasonText: reasonText); semaphore.wait()
    }

    func refreshTasks() {
        let c = self.defaults.integer(forKey: K.UserDefaults.company_id)
        APIgetTasks(c); semaphore.wait()
    }
}

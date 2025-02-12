//
//  ContentView.swift
//  ListView
//
//  Created by 沖野匠吾 on 2025/02/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FirstView()
    }
}

struct FirstView: View {
    //"TasksDate"というキーで保存されたものを監視
    @AppStorage("TasksData") private var tasksData = Data()
    // タスクを入れておくための配列
    @State var tasksArray: [Task] = []
    //FirstView生成時に呼ばれる。
    init(){
        //tasksDateをデコードできたら、その値をtasksArrayに渡す
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            _tasksArray = State(initialValue: decodedTasks)
            print(tasksArray)
        }
    }
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: SecondView(tasksArray: $tasksArray).navigationTitle("Add Task")) {
                Text("Add New Task")
                    .font(.system(size: 20, weight: .bold))
                    .padding()
            }
            List {
                ForEach(tasksArray) { task in
                    Text(task.taskItem)
                }
                // リストの並び替え時の処理を設定
                .onMove(perform: { from, to in
                    replaceRow(from, to)
                    
                    
                    
                })
                .onDelete(perform: rowRemove)
            }
            .navigationTitle("Task List")
            // ナビゲーションバーに編集ボタンを追加
            .toolbar{
                EditButton()
                
            }
        }
        .padding()
    }
    
    // 並び替え処理と並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int) {
        tasksArray.move(fromOffsets: from, toOffset: to) // 配列内での並び替え
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray // エンコードできたらAppStorageに渡す(保存・更新)
        }
    }
    func rowRemove(at offsets: IndexSet) {
        tasksArray.remove(atOffsets: offsets)
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray
        }
    }
    struct SecondView: View {
        @Environment(\.dismiss) private var dismiss
        @State var task: String = ""
        
        @Binding var tasksArray: [Task]
        
        var body: some View {
            TextField("Enter your task", text: $task)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button {
                addTask(newTask: task)
                task = ""
                print(tasksArray)
            } label: {
                Text("Add")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding()
            
            Spacer()
            
            
        }
        func addTask(newTask: String) {
            if !newTask.isEmpty {
                let task = Task(taskItem: newTask)
                var array = tasksArray
                array.append(task)
                
                if let encodedData = try? JSONEncoder().encode(array) {
                    UserDefaults.standard.setValue(encodedData, forKey: "TasksData")
                    tasksArray = array
                    dismiss()
                }
            }
        }
    }
    
    #Preview("FirstView") {
        SecondView(tasksArray: FirstView().$tasksArray)
    }
}

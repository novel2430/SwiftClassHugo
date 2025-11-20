+++
date = '2025-11-20T18:28:14+08:00'
draft = true
title = 'Class07 - Alert, Sheet, FullScreenCover, Popover, ScrollView & GeometryReader'
tags = ['Alert', 'Sheet', 'FullScreenCover', 'Popover', 'ScrollView', 'GeometryReader']
isCJKLanguage = true
+++

## 技術覆蓋
- Alert
- Sheet
- FullScreenCover
- Popover
- ScrollView
- GeometryReader

## Alert
`Alert`用于向用户展示简短的警告、提示信息，并且支持**确认**或**取消**操作。
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State private var showDeleteAlert = false // 顯示與否
    
    var body: some View {
        Button("刪除項目") {
            showDeleteAlert = true
        }
        .alert("確定要刪除？", isPresented: $showDeleteAlert) {
            Button("取消") {}
            Button("刪除") {
                // 執行刪除
            }
        } message: { // 要顯示的內容
            Text("這個動作無法復原。")
        }
    }
}
```
### 2. role
```swift
import SwiftUI
struct ContentView: View {
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button("刪除項目") {
            showDeleteAlert = true
        }
        .alert("確定要刪除？", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) { // 重要是這個role, 可以發現刪除變成紅色了
                // 執行刪除
            }
        } message: {
            Text("這個動作無法復原。")
        }
    }
}
```
## Sheet
`Sheet`是从底部滑出的页面，常用于呈现表单、详细信息、编辑等内容。它适合展示**内容较多**、需要交互的页面。
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State private var showEditor = false // 顯示與否
    
    var body: some View {
        Button("编辑资料") { showEditor = true }
            .sheet(isPresented: $showEditor) {
                EditProfileView()
            }
    }
}
// 自定義View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss // 有點像關閉sheet，然後返回
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("昵称", text: .constant(""))
            }
            .navigationTitle("编辑资料")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() } // 關閉sheet
                }
            }
        }
    }
}
```
### 2. dismiss()
`dismiss()`是一個swiftUI提供給開發者的方便函數，概念就是關閉當前，然後返回主頁(上級)
```swift
import SwiftUI
struct ContentView: View {
    @State private var showEditor = false
    
    var body: some View {
        Button("编辑资料") { showEditor = true }
            .sheet(isPresented: $showEditor) {
                EditProfileView()
            }
    }
}
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss // 需要這樣聲明
    
    var body: some View {
        VStack{
            Text("Edit sth")
            Button("Back") {
                dismiss() // 直接使用dismiss()函數，我就不需要操作showEditor變量
            }
        }
    }
}
```
## FullScreenCover
`FullScreenCover`用于全屏覆盖，适用于需要占据**整个屏幕**的内容，如播放界面、欢迎界面等。
### 1. 使用格式
```swift
import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true // 注意，一開始就是true，所以會在啟動時就顯示
    var body: some View {
        Text("主页面")
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
    }
}
// 自定義歡迎介面View
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("欢迎使用本应用")
            Button("开始体验") {
                dismiss()
            }
        }
    }
}
```
## Popover
Popover 通常在 iPad 或 Mac 上使用，用来显示小的浮动视图。
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State private var showPopover = false
    var body: some View {
        Button("显示更多信息") { showPopover = true }
            .popover(isPresented: $showPopover) {
                Text("这是一个 Popover")
                    .padding()
                    .frame(width: 200)
            }
    }
}
```
## Coding Time - 學生列表
```swift
import SwiftUI

// MARK: - 学生数据模型
struct Student: Identifiable {
    let id = UUID()
    var name: String
    var age: String
    var className: String
}

struct ContentView: View {
    // 学生列表
    @State private var students: [Student] = [
        Student(name: "张三", age: "16", className: "高一(1)班"),
        Student(name: "李四", age: "17", className: "高二(3)班")
    ]
    
    // 控制“新增学生” sheet 是否显示
    @State private var showNewStudentSheet = false
    
    var body: some View {
        VStack {
            // 学生列表
            List(students) { student in
                Section(student.name) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("年龄")
                            .font(.headline)
                        Text("\(student.age)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("班级")
                            .font(.headline)
                        Text("\(student.className)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
                
            // 底部“添加新学生”按钮
            Button(action: {
                showNewStudentSheet = true
            }) {
                Text("添加新学生")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        // MARK: - 新增学生的 Sheet
        .sheet(isPresented: $showNewStudentSheet) {
            // 這裏開始寫代碼!
        }
    }
}
```
## ScrollView
`ScrollView`允许视图内容在一个轴向上可以滑动。当内容超出显示区域时，ScrollView 会自动启用滚动。
### 1. Vertical
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                ForEach(0..<50) { i in
                    Text("项目 \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
```
### 2. Horizontal
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(0..<50) { i in
                    Text("项目 \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
```
## GeometryReader
`GeometryReader`用于读取父视图的几何信息，并允许根据这些信息动态调整子视图的大小和位置
### 1. 示範代碼
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size // 父視圖的size
            ZStack {
                Color.orange.opacity(0.2)
                VStack(spacing: 8) {
                    Text("宽度：\(size.width)") // 寬度
                    Text("高度：\(size.height)") // 高度
                }
            }
        }
        .frame(height: 200)
        .border(Color.red)
    }
}
```
## ScrollView + GeometryReader : 跟随滚动缩放的卡片列表
```swift
import SwiftUI

struct ContentView: View {
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple
    ]
    var body: some View {
        // 外层使用垂直方向的 ScrollView
        ScrollView {
            // 用 VStack 把所有卡片垂直堆叠起来
            VStack(spacing: 24) {
                // 模拟 20 个卡片
                ForEach(0..<20) { index in
                    // 每一个卡片外面包一层 GeometryReader
                    // 用来「读取自己在滚动视图里的位置」
                    GeometryReader { geo in
                        // 从几何信息中取得当前卡片在名为 "scroll" 的坐标系里的 frame
                        let frame = geo.frame(in: .named("scroll"))
                        // 卡片当前中心点的 y 值
                        let cardCenterY = frame.midY
                        // 屏幕中心的大致 y 值
                        let screenCenterY = UIScreen.main.bounds.height / 2
                        // 计算卡片中心与屏幕中心的距离（绝对值）
                        let distance = abs(cardCenterY - screenCenterY)
                        // 距离越大，scale 越小，最小不小于 0.8
                        let _scale = max(0.8, 1.2 - distance / 600)
                        // scale 不大於1.05
                        let scale = min(_scale, 1.05)
                        // 距离越大，透明度越低，最小不低于 0.4
                        let opacity = max(0.4, 1.0 - distance / 400)
                        // 实际显示的卡片内容
                        ZStack(alignment: .leading) {
                            // 背景卡片
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colors[index % colors.count])
                            // 文字内容
                            VStack(alignment: .leading, spacing: 8) {
                                Text("第 \(index + 1) 个卡片")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("距离屏幕中心约 \(Int(distance)) pt")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                Text("往上 / 往下滚动，感受缩放变化")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                        }
                        // 根据距离调整缩放和透明度
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(.easeOut(duration: 0.2), value: scale)
                    }
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 32)
        }
        // 给 ScrollView 一个命名坐标空间，方便 GeometryReader 用 frame(in: .named("scroll")) 获取位置
        .coordinateSpace(name: "scroll")
    }
}
```

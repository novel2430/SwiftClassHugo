+++
date = '2025-10-24T13:24:07+08:00'
draft = false 
title = 'Class04 - List & Navigation'
tags = ['List', 'Navigation']
isCJKLanguage = true
+++

## 技術覆蓋
- List & ForEach
- NavigationLink
- NavigationStack 

## List & ForEach 
List的主要任務就是顯示列表內容  
比如說歌單，待辦清單等...
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        VStack {
            List {
                // 這邊放入你想列出的內容
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
                Text("Item 4")
            }
        }
    }
}
```
### 2. ForEach
在 SwiftUI 中，ForEach 是一个常用的视图生成器，用于在 SwiftUI 布局中动态创建多个视图  
它可以基于一个数据集合或一个范围来生成视图  
之前的代码可以修改为
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        VStack {
            List {
                ForEach(0...4, id: \.self) { index in
                    Text("Item \(index)")
                }
            }
        }
    }
}
```
可以發現ForEach本質跟C/C++中的for循環有點類似，可以輔助理解  
比如說C/C++從0~4的循環我們會寫`for(int i=0; i<=4; i++)`  
而如果使用SwiftUI的`ForEach`我們則會寫成:
```swift
ForEach(0...4, id: \.self) { i in
    // 一些View
        }
```
## Navigation 導航
導航在一個app是必備的功能，你們未來開發的app只要是多頁面，就一定需要導航的能力  
> 當然在實際生產環境，可能會出現你無法使用原生導航去跳轉的狀況
### 1. 使用格式
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        // 以下是主頁內容
        // 如果當前頁面會有主動跳轉到其他地方的操作
        // 就先用NavigationStack把它包起來
        NavigationStack {
            VStack {
                // 以下是跳轉按鈕，按下去發起跳轉
                NavigationLink {
                    // 跳轉的目的地
                    DetailView()
                } label: {
                    // 這個跳轉按鈕長什麼樣
                    Text("Go")
                }
                // 正常頁面內容
                Text("This is Main Page")
            }
            .navigationTitle("Home") // 頁面Title
        }
    }
}
// 以下是Detail頁面內容
struct DetailView: View {
    var body: some View {
        VStack {
            Text("This is Detail")
            Text("This is Detail")
            Text("This is Detail")
        }
        .navigationTitle("Detail") // 頁面Title
    }
}
```
## Coding Time
簡單來說，就是實現一個從Home頁面，往三個不同ColorView頁面跳轉的程序  
單個ColorView頁面很單純，就是將一種顏色充斥整個頁面  
每個跳轉的NavigationLink需要注意，他是純文本，但是該文本的顏色跟他要跳轉的ColorView要一樣
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // 這裏開始寫代碼
                    
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct ColorView: View {
    var bgColor: Color
    var body: some View {
        bgColor
            .navigationTitle("Color Page")
    }
}

struct ColorText: View {
    var fgColor: Color
    var text: String
    var body: some View {
        Text(text)
            .foregroundStyle(fgColor)
    }
}
```

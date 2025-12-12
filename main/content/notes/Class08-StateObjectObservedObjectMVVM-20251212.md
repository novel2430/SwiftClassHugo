+++
date = '2025-12-12T10:07:38+08:00'
draft = false 
title = 'Class08 - StateObject, ObservedObject, MVVM'
tags = ['StateObject', 'ObservedObject', 'MVVM', 'State', 'Binding' ]
isCJKLanguage = true
+++

## 技術覆蓋
- StateObject
- ObservedObject
- MVVM

## 狀態管理與資料中心
### 1. State的限制
在開始講 @StateObject 與 @ObservedObject 之前，我們先從每個人最熟悉的屬性開始 —— @State。  
所有人第一次寫 SwiftUI 都會寫出這種程式：
```swift
import SwiftUI

struct ContentView: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Add") {
                count += 1
            }
        }
    }
}
```
按下按鈕，畫面會更新，狀態也會記住。  
這一套機制讓 SwiftUI 顯得非常直覺。  
但 @State 能處理的東西非常有限，它只適合處理：  
- 一個頁面內的小數字
- 一個 toggle
- 一個字串
- UI 上的小小變化
也就是：
> @State = 用來管理「值」的本地小變數。

**那如果資料變大呢？**  

來想一個更真實的場景：
- 一個待辦清單
- 一個完整登入狀態
- 一個播放器資訊（正在播放的歌、進度、播放狀態）
- 一個購物車（包含商品清單、總金額）

這些東西有什麼共同特性？

> 它們不是**值**，而是**系統**。

也就是：
- 不是一個布林值，而是一堆資料
- 不只是顯示，而包含邏輯和行為
- 很多畫面都會需要用到同一份資料
- 一旦資料變動，許多 View 都要更新

這就是 App 變大的時候會遇到的第一個問題：**@State 不能管理一個完整的資料系統**  
錯誤代碼：
```swift
import SwiftUI
// 一個看起來很無害的小「資料系統」
class Counter {
    var value = 0
}
struct ContentView: View {
    @State private var counter = Counter()
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(counter.value)")
                .font(.largeTitle)
            
            Button("＋1") {
                counter.value += 1
                print("現在 counter.value =", counter.value)
            }
        }
        .padding()
    }
}
```
### 2. 資料中心 (Data Center)
你可以把它想像成：
> 資料中心 = 管理整段邏輯與資料的“大腦”

舉例：
- TodoList 的整組資料 + 新增/刪除的函式
- 播放器的資料 + 播放/暫停/跳曲的行為
- 使用者資訊 + 登入/登出的方法

這些都不適合放在 @State 裡，因為：
- 它們不是小變數，而是一整組系統狀態
- 它們需要「在畫面刷新時依然存在」
- 它們要被多個 View 同時讀寫
- 它們需要在值改變時「通知 SwiftUI 重繪」

這個資料中心通常會是一個 class，例如 ViewModel：
```swift
class TodoViewModel {
    var items = ["買牛奶", "寫報告"]
    func add(_ text: String) {
        items.append(text)
    }
}
```

## @StateObject / @ObservedObject
現在的問題是：
- 如何讓 SwiftUI 正確「看到」資料中心裡面的變化？
- 如何讓資料中心不會因為 View 重建而重新 new？
- 如何讓子 View 也能使用同一份資料中心？

這三個問題的答案，就是：

> @StateObject 與 @ObservedObject。

### 1. @StateObject：資料中心的建立者與擁有者
#### 1.1 StateObject 建立`唯一資料中心`
```swift
@StateObject var vm = CounterViewModel()
```
代表：
- 這個 ViewModel 的生命週期由這個 View 管
- SwiftUI 不會因為畫面 refresh 就 new 新的
- 這是整個頁面的「資料大腦」
#### 1.2 StateObject + ObservableObject = SwiftUI 才知道何時更新畫面
```swift
class CounterViewModel: ObservableObject {
    @Published var value = 0
}
```
@Published 這一條重要：  
當 value 改變時，SwiftUI 會收到通知，並自動刷新 UI。

這就是剛剛代碼**畫面永遠不更新**的根本原因：
- @State 追蹤不到 class 內部
- @StateObject + ObservableObject 才能做到資料綁定

所以我們更新一下剛剛的錯誤代碼
```swift
import SwiftUI
// 建立一個ViewModel
class CounterViewModel: ObservableObject {
    @Published var value = 0 // 記得要Published
}
struct ContentView: View {
    @StateObject var counter = CounterViewModel() // 建立StateObject
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(counter.value)")
                .font(.largeTitle)
            
            Button("＋1") {
                counter.value += 1
                print("現在 counter.value =", counter.value)
            }
        }
        .padding()
    }
}
```

### 2. @ObservedObject：資料中心的使用者（訂閱但不擁有）
#### 2.1 State <-> Bind, StateObject <-> ObservedObject
在 SwiftUI 的基礎教學裡，最先理解的一件事是：
> 父 View 擁有某個資料  
> 子 View 只是使用這個資料

也就是：
State (擁有) -> Binding (使用)  
ObservedObject 就是 Binding 的**物件版**。

| 單一值 (值類型) | 資料系統 / ViewModel |
| --- | --- |
| @State | @StateObject |
| @Binding | @ObservedObject |

#### 2.2 父子View示範
Step 1: 父 View 建立資料中心（StateObject）
```swift
struct ParentView: View {
    @StateObject var vm = CounterViewModel()

    var body: some View {
        ChildView(vm: vm)
    }
}
```
Step 2: 子 View 使用資料中心（ObservedObject）
```swift
struct ChildView: View {
    @ObservedObject var vm: CounterViewModel

    var body: some View {
        Text("Count: \(vm.value)")
        Button("Add") { vm.value += 1 }
    }
}
```
#### 2.3 為什麼 ObservedObject 不能拿來 new 一個 ViewModel？
> 因為和 Binding 一樣，它的角色是**使用者**，不是**擁有者**。

錯誤示範：
```swift
struct WrongView: View {
    @ObservedObject var vm = CounterViewModel()  // ❌
    var body: some View { ... }
}
```

就像你不會在 Binding 裡 new 一個值一樣，
> 你也不該在 ObservedObject 裡 new 一個 ViewModel。

### 3. Coding Time - Counter
```swift
import SwiftUI

class CounterViewModel: ObservableObject {
    // Write Here (what data we need?)
}

struct ContentView: View {
    // write here (U need a StateObject)
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Count: \(counter.value)")
                    .font(.largeTitle)
                
                Button("＋1") {
                    counter.value += 1
                    print("現在 counter.value =", counter.value)
                }
                
                NavigationLink("Go to Child") {
                    ChildView(vm: counter) // Navigate to ChildView
                }
            }
            .padding()
        }
    }
}

struct ChildView: View {
    // write here (U need a ObservedObject)
    var body: some View {
        VStack(spacing: 20) {
            Text("Child Count = \(vm.value)")
                .font(.title)
            
            Button("Child +1") {
                vm.value += 1
            }
        }
        .padding()
    }
}
```

## MVVM架構
M(Model) - V(View) - VM(ViewModel)  
用一句話講：
> View 負責長相和互動  
> ViewModel 負責資料與邏輯  
> Model 是資料的形狀  

如果要用之前的比喻：
- View = 螢幕
- ViewModel = 大腦
- Model = 記憶裡放的資料

SwiftUI 非常適合 MVVM，是因為 SwiftUI 的 body 是「純函數式 UI」。
也就是：
> 畫面應該只負責描述 UI，  
> 而不應該承擔邏輯。

讓我們用實際例子看一下差異。
### 1. 如果沒有 MVVM，會變成什麼樣子？
```swift
import SwiftUI
struct ContentView: View {
    @State private var items = ["牛奶", "咖啡"]
    var body: some View {
        VStack {
            List(items, id: \.self) { item in
                Text(item)
            }
            Button("加一項") {
                items.append("新商品")
            }
        }
    }
}
```
看起來沒問題，但這個畫面藏了兩個問題：
- 問題 1：邏輯塞在 View 裡，畫面變複雜就難維護  
    Button 裡面塞 append  
    List 裡面塞轉換邏輯  
    更多功能時，View.body 超級肥。
- 問題 2：同一份資料無法跨畫面共用  
    另開一個畫面，資料就不一致，因為沒有資料中心。

如果使用MVVM寫會如何呢？  

Model
```swift
struct Item: Identifiable {
    let id = UUID()
    let title: String
}
```
ViewModel
```swift
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = [
        Item(title: "牛奶"),
        Item(title: "咖啡")
    ]
    func addItem() {
        items.append(Item(title: "新商品"))
    }
}
```
View
```swift
struct ContentView: View {
    @StateObject var vm = ItemViewModel()
    var body: some View {
        VStack {
            List(vm.items) { item in
                Text(item.title)
            }
            Button("新增") {
                vm.addItem()
            }
        }
    }
}
```
### 2. MVVM 的核心價值
1.	View 不再擔心邏輯
    - View 只是「畫畫面」
    - 互動邏輯全部丟給 ViewModel
2.	資料中心變成唯一真相（Single Source of Truth）
    - 多個頁面共享資料很自然
    - 也讓 SwiftUI 的畫面刷新更可預期
3.	程式好維護、好測試、好擴充
    - 要加功能改 VM
    - 畫面不需要修改 body 結構
4.	這就是 Apple 官方最推薦的 SwiftUI 架構方式

### 3. Coding Time - 計分板 Scoreboard
> 做一個「計分板 Scoreboard」系統。  
> 你可以在父畫面按 +1 / -1，或在子畫面按 +1 / -1，  
> 結果要同步更新，因為它們共用同一個 ViewModel。

你應該會有三個文件，分別對應`Model`, `ViewModel`, 跟`View`
#### Score.swift (Model)
```swift
struct Score {
    var value: Int = 0
}
```
#### ScoreViewModel.swift (ViewModel)
```swift
import SwiftUI
class ScoreViewModel: ObservableObject {
    @Published var score = Score()
    // wirte here (addPoint func)
    // wirte here (minusPoint func)
}
```
#### ContentView.swift (View)
```swift
import SwiftUI
struct ContentView: View {
    // write here (U need a StateObject name "vm")
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Main Score: \(vm.score.value)")
                    .font(.largeTitle)
                HStack {
                    Button("+1") { vm.addPoint() }
                        .buttonStyle(.borderedProminent)
                    
                    Button("-1") { vm.minusPoint() }
                        .buttonStyle(.bordered)
                }
                NavigationLink("Go to Child Score View") {
                    ChildScoreView(vm: vm)
                }
                .padding(.top, 30)
            }
            .padding()
        }
    }
}
struct ChildScoreView: View {
    // write here (U need a ObservedObject name "vm")
    var body: some View {
        VStack(spacing: 20) {
            Text("Child Score: \(vm.score.value)")
                .font(.largeTitle)
            HStack {
                Button("+1") { 
                    vm.addPoint() 
                }
                .buttonStyle(.borderedProminent)
                Button("-1") { 
                    vm.minusPoint() 
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
```

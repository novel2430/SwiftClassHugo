+++
date = '2025-10-11T12:24:24+08:00'
draft = false 
title = 'Class02 - State, ParentChild(Binding), Toggle & TextField'
tags = ['State', 'Binding', 'Toggle', 'TextField']
isCJKLanguage = true
+++

## 技術覆蓋
- State
- Parent & Child (Binding)
- Toggle
- TextField

## @State
使用`@State`的主要目的是**存儲**數值，並且這個數值的變化會影響app畫面的更新  
比如說計數器所紀錄的**數**  
比如說音樂播放器的**進度條時間**  
在使用`@State`的時候需要注意下列:
- State变化自动触发视图更新
- 仅适用于值类型数据（String/Int/Bool等）
### 1. 使用格式
```swift
struct ContentView: View {
    // 聲明在body外面
    @State var stateValue = 0

    var body: some View {
        // 你的app畫面...
    }
}
```
### 2. 實戰案例 - 計數器
> 涉及: @State, Button

目標:  
畫面上有個按鈕，按鈕上會顯示當前被按下的次數，每次按下該數字都會增加
```swift
struct ContentView: View {
    @State var pressCount = 0

    var body: some View {
        Button {
            // 填入按鈕點擊後要執行的代碼
            pressCount = pressCount + 1
        } label: {
            Text("This is a Button: \(pressCount)")
                .padding()
                .foregroundColor(.white)
                .background(.orange)
                .cornerRadius(10)
        }
    }
}
```
### 3. Coding Time - 變種計數器
> 涉及: @State, Button, Text

目標:  
畫面上有個**2**個按鈕，分別是`按鈕A`跟`按鈕B`  
- 按下`按鈕A`的時候，`按鈕A`上面的數字增加1  
- 按下`按鈕B`的時候，`按鈕B`上面的數字**乘上**2
```swift
struct ContentView: View {
    // 這裡需要改
    var pressCountA = 0
    var pressCountB = 1

    var body: some View {
        VStack {
            HStack {
                Text("按鈕A")

                Button {
                    // 在此寫代碼
                } label: {
                    Text("Press Count: \(pressCountA)")
                        .padding()
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(10)
                }
            }
            HStack {
                Text("按鈕B")

                Button {
                    // 在此寫代碼
                } label: {
                    Text("Press Count: \(pressCountB)")
                        .padding()
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(10)
                }
            }
        }
    }
}
```
## Parent & Child (Binding)
在寫代碼的時候，`子視圖 Child View`可以幫助我們更快速的開發  
如何選擇哪些代碼集成為`子視圖 Child View`，最簡單的方式就是看看目前哪些**代碼重複**了
### 1. 實際案例
比如說剛剛實現的`變種計數器`，可以看到我們有兩個按鈕  
那現在我希望:
- 有第三個`按鈕C`，他跟按鈕A執行一樣的操作，按一次增加1
- 三個按鈕:`按鈕A`，`按鈕B`，`按鈕C`，他們的文字顏色變成`黃色 yellow`，背景顏色變成`紫色 purple`

你可能會直接這樣改
```swift
struct ContentView: View {
    @State var pressCountA = 0
    @State var pressCountB = 1
    // 增加一個State Value C
    @State var pressCountC = 0

    var body: some View {
        VStack {
            HStack {
                Text("按鈕A")

                Button {
                    pressCountA = pressCountA + 1
                } label: {
                    Text("Press Count: \(pressCountA)")
                        .padding()
                        .foregroundColor(.yellow) // 改文字顏色
                        .background(.purple) // 改背景顏色
                        .cornerRadius(10)
                }
            }
            HStack {
                Text("按鈕B")

                Button {
                    pressCountB = pressCountB * 2
                } label: {
                    Text("Press Count: \(pressCountB)")
                        .padding()
                        .foregroundColor(.yellow)
                        .background(.purple)
                        .cornerRadius(10)
                }
            }
            // 新按鈕C
            HStack {
                Text("按鈕C")

                Button {
                    pressCountC = pressCountC + 1
                } label: {
                    Text("Press Count: \(pressCountC)")
                        .padding()
                        .foregroundColor(.yellow)
                        .background(.purple)
                        .cornerRadius(10)
                }
            }
        }
    }
}
```
可以發現每個按鈕的`label`部分其實都差不多的，差別就是顯示的數字不同  
所以我們可以將label的代碼塊提取出來，寫成一個`子視圖 Child View`  
比如說:
```swift
struct LabelChildView: View {
    // @Binding : 這個值是由父視圖 Parent View的某個@State決定的
    @Binding var pressCount: Int
    var body: some View {
        Text("Press Count: \(pressCount)")
            .padding()
            .foregroundColor(.yellow)
            .background(.purple)
            .cornerRadius(10)
    }
}
```
將父子視圖進行結合就會得到:
```swift
import SwiftUI
struct ContentView: View {
    // 這裡需要改
    @State var pressCountA = 0
    @State var pressCountB = 1
    @State var pressCountC = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("按鈕A")
                
                Button {
                    pressCountA = pressCountA + 1
                } label: {
                    LabelChildView(pressCount: $pressCountA)
                }
            }
            HStack {
                Text("按鈕B")
                
                Button {
                    pressCountB = pressCountB * 2
                } label: {
                    LabelChildView(pressCount: $pressCountB)
                }
            }
            HStack {
                Text("按鈕C")
                
                Button {
                    pressCountC = pressCountC + 1
                } label: {
                    LabelChildView(pressCount: $pressCountC)
                }
            }
        }
    }
}

struct LabelChildView: View {
    @Binding var pressCount: Int
    var body: some View {
        Text("Press Count: \(pressCount)")
            .padding()
            .foregroundColor(.yellow)
            .background(.purple)
            .cornerRadius(10)
    }
}
```
## Toggle
就是開關，但記得他是子視圖
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    // Toggle 影響的@State
    @State var isOn = false
    
    var body: some View {
        VStack {
            Toggle(isOn: $isOn) {
                // 顯示的內容
                Text("Toggle")
            }
        }
    }
}
```
## TextField
文字輸入組件
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State var username = ""
    
    var body: some View {
        TextField("请输入用户名", text: $username)
            .padding()
    }
}
```
## Coding Time
```swift
import SwiftUI
struct ContentView: View {
    @State var username = ""
    @State var displayName = "?"
    
    @State var isOn = true
    
    var body: some View {
        VStack {
            HStack {
                TextField("Input Username ...", text: $username)
                    .padding()
                Button {
                    // 在此寫代碼
                } label: {
                    Text("Update")
                        .padding()
                        .foregroundColor(.yellow)
                        .background(.purple)
                        .cornerRadius(10)
                }
                Toggle(isOn: $isOn){}
            }
            if isOn {
                // 在此寫代碼
            }
            else {
                // 在此寫代碼
            }
        }
    }
}
```

+++
date = '2025-10-16T00:30:54+08:00'
draft = false 
title = 'Class03 - Stepper, Slider & Picker'
tags = ['Stepper', 'Slider', 'Picker', 'Color']
isCJKLanguage = true
+++

## 技術覆蓋
- Stepper
- Slider
- Picker

## Stepper
允许用户通过点击按钮来**增加或减少**一个值，适用于数量选择、分数调整等场景  
基本上感覺真的使用場景不多
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 0 // 會被改變的變量
    var body: some View {
        VStack {
            Stepper("数量: \(value)", // 這邊的字符串表示顯示的文字
                value: $value) // 需要被改變的@State變量放在這
        }
    }
}
```
### 2. 區間規範
在組件中進行加減法的時候，你可以限制他的**最大值**跟**最小值**  
#### 2.1 閉區間
以下區間是一個**閉區間**，何謂閉區間?  
可以看看以下例子:
- 閉區間0~5: 可用整形數字為`0`, `1`, `2`, `3`, `4`, `5`
- 寫成code的樣子的話為: `0 <= i <= 5`

在`Stepper`中的寫法:
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 0
    var body: some View {
        VStack {
            Stepper("数量: \(value)", 
                    value: $value,
                    in: 0...5 // 這裡來定義閉區間
            )
        }
    }
}
```
### 3. 步長(step)控制
步長的意思就是，組件中增加跟減少的**幅度**  
在`Stepper`的預設步長，就是每次執行，就會增加or減少`1`  
如果寫成code的樣子可以是`value += step`
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 0
    var body: some View {
        VStack {
            Stepper("数量: \(value)", 
                    value: $value,
                    in: 0...100,
                    step: 5 // step = 5, 所以每次增加或減少為5
            )
        }
    }
}
```
## Slider
允许用户通过**滑动选择器**在预定范围内选择一个值，非常适合用于调整音量、亮度等  
需要注意，`Slider`使用的@State變量，需要是`浮點數`
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 50.0 // 浮點數
    var body: some View {
        VStack {
            Slider(value: $value, // 會被滑動改變的@State變量
                in: 0...100 // 滑動的變量區間為0 <= i <= 100
            )
        }
    }
}
```
### 2. 步長(step)控制
`Slider`同樣可以使用`step`來控制增加or減少的幅度
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 50.0
    var body: some View {
        VStack {
            Slider(value: $value,
                   in: 0...100,
                   step: 3 // 每次增加3 or 減少3
            )
            Text("\(value)") // 顯示當前的value
        }
    }
}
```
### 3. tint設置
`tint`可以設置滑動條的**主色調**
```swift
import SwiftUI
struct ContentView: View {
    @State var value = 50.0
    var body: some View {
        VStack {
            Slider(value: $value,
                   in: 0...100
            )
            .tint(.red) // 設置為紅色
        }
    }
}
```
### 4. Coding Time - 背景換色器
#### 4.1 前置知識 (顏色)
在SwiftUI中，顏色表示為`Color`類  
比如說我們常用的`.red`, `.blue`這些都是`Color`，只是這些都是SwiftUI幫我們先定義好的，方便開發使用  
那如果我們今天想要定義一個自己的顏色，該如何?  
我們都知道，任何一個顏色都可以使用紅( R )，綠( G )，藍( B )，三原色來去定義，在SwiftUI中也是一樣的

![image](https://pica.zhimg.com/v2-77659c69d993774e260b1e968ccdbb62_1440w.jpg)

舉例來說，我們在代碼使用RGB定義一個顏色如下
```swift
import SwiftUI
var myColor = Color(red:1, green:1, blue:1) // 這樣是白色
```
可以看到我們使用`red`,`green`跟`blue`三個量來定義一個顏色`myColor`  
這三個變量對應的數值範圍如下:
- 紅色 red : 0 ~ 1
- 綠色 green : 0 ~ 1
- 藍色 blue : 0 ~ 1

所以如果我今天想要定義出一個**黃色**，我可以這麼寫
```swift
import SwiftUI
var myColor = Color(red:1, green:1, blue:0) // blue為0，red跟green為1
```
#### 4.2 題目本體
我們現在來實現一個**背景換色器**  
他的功能要求如下:
- 畫面上要有**三個**滑動組件，分別控制紅red，綠green，藍blue三個量值
- 當用戶滑動任意滑動組件，整個畫面的背景顏色會跟著變化
#### 4.3 Code
```swift
import SwiftUI
struct ContentView: View {
    @State var redValue = 1.0
    @State var greenValue = 1.0
    @State var blueValue = 1.0
    var body: some View {
        ZStack {
            Color(red: redValue, green: greenValue, blue: blueValue) // 使用ZStack把背景畫出來
            VStack {
                Text("Red Value: \(redValue)")
                    .background(.red)
                // 這裡填入控制紅色red的滑動條
                Text("Green Value: \(greenValue)")
                    .background(.green)
                // 這裡填入控制綠色green的滑動條
                Text("Blue Value: \(blueValue)")
                    .background(.blue)
                // 這裡填入控制藍色blue的滑動條
                
            }
        }
    }
}
```
![image](https://fussel.ygfrds.sbs/static/_gallery/albums/album01/501x891_1017-001-png.png)
## Picker
### 1. Color Picker
允许用户选择颜色，适用于图形设计、主题设置等  
> 注: 代碼要在swift playground運行，才會看到效果
```swift
import SwiftUI
struct ContentView: View {
    @State var selectedColor = Color.black // 顏色選擇的變量
    var body: some View {
        ColorPicker("选择颜色", selection: $selectedColor)
    }
}
```
### 2. Date Picker
用于选择日期和时间，适合于日历应用、事件计划等
> 注: 代碼要在swift playground運行，才會看到效果
```swift
import SwiftUI
struct ContentView: View {
    @State var selectedDate = Date() // 日期選擇的變量
    
    var body: some View {
        DatePicker("选择日期", selection: $selectedDate)
    }
}
```
#### 2.1 僅顯示日期
```swift
import SwiftUI
struct ContentView: View {
    @State var selectedDate = Date() // 日期選擇的變量
    
    var body: some View {
        DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
    }
}
```
#### 2.2 僅顯示時間
```swift
import SwiftUI
struct ContentView: View {
    @State var selectedDate = Date() // 日期選擇的變量
    
    var body: some View {
        DatePicker("选择时间", selection: $selectedDate, displayedComponents: .hourAndMinute)
    }
}
```
### Coding Time - 紀念日色彩徽章
> 注: 代碼要在swift playground運行，才會看到效果
```swift
import SwiftUI
struct ContentView: View {
    @State private var pickedDate = Date() // 日期選擇的變量
    @State private var pickedColor: Color = .mint // 顏色選擇的變量
    @State private var wiggle = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(radial(from: pickedColor))
                    .overlay(Circle().stroke(pickedColor.opacity(0.35), lineWidth: 6))
                    .shadow(color: pickedColor.opacity(0.35), radius: 18, x: 0, y: 8)
                    .scaleEffect(wiggle ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: wiggle)
                
                VStack(spacing: 6) {
                    Text(badgeTitle)
                        .font(.largeTitle.weight(.heavy))
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)
            .onAppear { wiggle = true }
            
            VStack(spacing: 14) {
                // 填入DatePicker
                
                HStack {
                    Text("Choose Color")
                    Spacer()
                    // 填入ColorPicker
                }
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            Spacer(minLength: 0)
        }
        .padding(24)
    }
    
    private var deltaDays: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: pickedDate)
        let today = cal.startOfDay(for: Date())
        return cal.dateComponents([.day], from: start, to: today).day ?? 0
    }
    private var badgeTitle: String {
        if deltaDays >= 0 { return "D+\(deltaDays)" }
        else { return "D-\(abs(deltaDays))" }
    }
    private var subtitle: String {
        if deltaDays >= 0 {
            return deltaDays == 0 ? "就是今天！" : "已經過了 \(deltaDays) 天"
        } else {
            return "還有 \(abs(deltaDays)) 天"
        }
    }
    private func radial(from color: Color) -> RadialGradient {
        RadialGradient(
            colors: [color, color.opacity(0.25), Color(.systemBackground)],
            center: .center,
            startRadius: 10, endRadius: 220
        )
    }
}
```
![image](https://fussel.ygfrds.sbs/static/_gallery/albums/album01/1061x772_1017-002-png.png)

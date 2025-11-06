+++
date = '2025-11-06T16:15:08+08:00'
draft = false 
title = 'Class06 - Form, Section, & TextEditor'
tags = ['Form', 'Section', 'TextEditor']
isCJKLanguage = true
+++

## 技術覆蓋
- Form & Section
- TextEditor

## Form
`Form`是一个用于**组织和布局控件的容器视图**。它会自动为其中的控件（比如按钮、开关、标签、列表等）应用平台特定的样式，帮助你创建表单界面  
简单来说，Form 就是一个**表单**容器，它会把相关的控件组合在一起，并且为这些控件提供符合平台设计的外观和行为。例如，在 iOS 上，表单控件会以**分组列表**的形式展示，而在 macOS 上，则是**垂直堆叠**的布局。
> 可以發現，`Form`跟`List`其實功能挺像的
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        Form {
            Text("Hello")
            Text("World")
            // Your Other View ...
        }
    }
}
```
## Section
`Section`通常是跟`Form`搭配使用，其主要目的就是在`Form`中將表單進行**分組**顯示
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        Form {
            Section("This is A Title") {
                Text("Hello")
                Text("World")
                // Your Other View ...
            }
        }
    }
}
```
### 2. Header
可以看到我們能直接將字符串傳入`Section`中，去將字符串作為標題顯示  
但如果我們今天希望我們的標題可以顯示比較**複雜**的東西，我們就需要使用`header`  
> 記住，`header`參數接受的是`View`
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        Form {
            Section(header: HStack {
                Text("This is Header")
                Image(systemName: "star.fill")
            }) {
                Text("Hello")
                Text("World")
                // Your Other View ...
            }
        }
    }
}
```
### 3. Footer 
`Section`還提供了頁腳，也就是`footer`給開發者使用，使用方式跟`header`類似
```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        Form {
            Section(footer: HStack {
                Text("This is Footer")
                Image(systemName: "car.fill")
            }) {
                Text("Hello")
                Text("World")
                // Your Other View ...
            }
        }
    }
}
```
### 4. Coding Time - 個人名片 Ver 2
```swift
import SwiftUI
struct ContentView: View {
    @State var username = ""
    @State var mail = ""
    @State var school = ""
    @State var food = ""
    @State var drink = ""
    @State var selectedColor = Color.blue
    @State var isPresented = false
    @State var bio = "Sth u want to say ..."

    var body: some View {
        VStack{
            Spacer(minLength: 50)
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150.0)
                .foregroundColor(.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 5))
            Form {
                Section(header: HStack {
                    Text("Personal Info")
                    Image(systemName: "star.fill")
                }) {
                    TextField("Name", text: $username)
                    TextField("E-Mail", text: $mail)
                    TextField("School", text: $school)
                    
                }

                // 這裏填空
                
                Button("Submit"){
                    isPresented.toggle()
                }
                .sheet(isPresented: $isPresented) {
                    SheetView(
                        bgColor: $selectedColor,
                        username: $username,
                        mail: $mail,
                        school: $school,
                        food: $food,
                        drink: $drink,
                        isPresented: $isPresented,
                        bio: $bio
                    )
                }
                
            }
        }
    }
}

struct SheetView: View {
    @Binding var bgColor: Color
    @Binding var username: String
    @Binding var mail: String
    @Binding var school: String
    @Binding var food: String
    @Binding var drink: String
    @Binding var isPresented: Bool
    @Binding var bio: String
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70.0, height: 70.0)
                .foregroundColor(bgColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
            Form {
                Section("My Name") {
                    Text("\(username)")
                }
                Section("E-Mail") {
                    Text("\(mail)")
                }
                Section("School") {
                    Text("\(school)")
                }
                Section("Food") {
                    Text("\(food)")
                }
                Section("Drink") {
                    Text("\(drink)")
                }
                Section("Bio") {
                    Text("\(bio)")
                }
            }
            Button("Close",
                   action: {
                isPresented.toggle()
            })
            Spacer(minLength: 30)
        }
    }
}
```
## TextEditor
`TextEditor`允许您在应用程序的用户界面中显示和编辑多行、可滚动的文本
### 1. 使用格式
```swift
import SwiftUI
struct ContentView: View {
    @State var fullText: String = "This is some editable text..."
    var body: some View {
        TextEditor(text: $fullText)
    }
}
```
### 2. 變換字體顏色
```swift
import SwiftUI
struct ContentView: View {
    @State var fullText: String = "This is some editable text..."
    var body: some View {
        TextEditor(text: $fullText)
            .foregroundStyle(.red) // <-- Here
    }
}
```
### 3. 行區間
```swift
import SwiftUI
struct ContentView: View {
    @State var fullText: String = "This is some editable text..."
    var body: some View {
        TextEditor(text: $fullText)
            .foregroundStyle(.red)
            .lineSpacing(10) // <-- Here
    }
}
```
### 4. Coding Time - 個人名片 Ver 3
在Ver 2的基礎上，加入一個個人介紹(Bio)的`TextEditor`
```swift
import SwiftUI
struct ContentView: View {
    @State var username = ""
    @State var mail = ""
    @State var school = ""
    @State var food = ""
    @State var drink = ""
    @State var selectedColor = Color.blue
    @State var isPresented = false
    @State var bio = "Sth u want to say ..."

    var body: some View {
        VStack{
            Spacer(minLength: 50)
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150.0)
                .foregroundColor(.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 5))
            Form {
                Section(header: HStack {
                    Text("Personal Info")
                    Image(systemName: "star.fill")
                }) {
                    TextField("Name", text: $username)
                    TextField("E-Mail", text: $mail)
                    TextField("School", text: $school)
                    
                }

                // 這裏是 Ver 2 的填空
                
                // Ver 3 是填入這裏
                
                Button("Submit"){
                    isPresented.toggle()
                }
                .sheet(isPresented: $isPresented) {
                    SheetView(
                        bgColor: $selectedColor,
                        username: $username,
                        mail: $mail,
                        school: $school,
                        food: $food,
                        drink: $drink,
                        isPresented: $isPresented,
                        bio: $bio
                    )
                }
                
            }
        }
    }
}

struct SheetView: View {
    @Binding var bgColor: Color
    @Binding var username: String
    @Binding var mail: String
    @Binding var school: String
    @Binding var food: String
    @Binding var drink: String
    @Binding var isPresented: Bool
    @Binding var bio: String
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70.0, height: 70.0)
                .foregroundColor(bgColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
            Form {
                Section("My Name") {
                    Text("\(username)")
                }
                Section("E-Mail") {
                    Text("\(mail)")
                }
                Section("School") {
                    Text("\(school)")
                }
                Section("Food") {
                    Text("\(food)")
                }
                Section("Drink") {
                    Text("\(drink)")
                }
                Section("Bio") {
                    Text("\(bio)")
                }
            }
            Button("Close",
                   action: {
                isPresented.toggle()
            })
            Spacer(minLength: 30)
        }
    }
}
```

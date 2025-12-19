+++
date = '2025-12-19T13:12:37+08:00'
draft = false 
title = 'Class09 - BargainGame'
tags = ['Project']
isCJKLanguage = true
+++
## Six Step
### Step 1 卖家输入一句话
- 你在输入框打字并点击“发送”
- 发生在：BargainGameView.swift，send() 被触发（按钮点击）
### Step 2 抽取数字 / 关键词（把自然语言变成“结构化信号”）
这一步仍然由 send() 串起来，但具体工作分散在几个文件里：
- 入口与组织：BargainGameView.swift

    send()：拿到输入 text 后，依次调用解析函数

- 抽取“报价数字”：Parsing.swift

    parseSellerAsk(_ text: String) -> Int?

    作用：从文本里抓一个数字（例如 1800）

    抓到了会在 BargainGameView.swift 的 send() 里更新：

    state.lastSellerAsk = a

- 识别“加值/让步”：Parsing.swift

    concessionScore(_ text: String) -> Int

    作用：识别“包邮/保修/赠品/已测试”等关键词，给一个 0～4 的加分

- 识别“态度强硬”：Parsing.swift

    attitudeScore(_ text: String) -> Int

    作用：识别“爱买不买/别浪费时间”等关键词，给一个 0～3 的扣分倾向
### Step 3 买家决策（决定下一步动作类型）
发生在：Planner.swift
> Planner.decide(state:sellerAsk:concession:attitude:) -> BuyerMove

- 输入：第 Step 2 的 state + ask/conc/att
- 输出：一个 BuyerMove，只会是四类之一：

1. .ask(...) 问问题
2. .counter(step: ...) 还价（注意：给的是 step，不是最终价）
3. .accept(...) 接受
4. .walkAway(...) 走人
### Step 4 更新状态（把动作落地成真实数值、回合推进、结束判定）
> 核心发生在：BargainGameView.swift, stepStateAndReply(move: BuyerMove)

它做的事情包括：

1. 硬截止（回合到上限就结束）

    在 BargainGameView.swift 的 stepStateAndReply(...) 开头判断：

    if state.round >= state.maxRounds { ... state.isDone = true ... }

2. 根据 BuyerMove 更新 state（SSOT）

    - .counter(step: ...)：

        计算：next = min(state.buyerMax, state.currentOffer + step)

        更新：state.currentOffer = next

    - .accept：

        state.isDone = true

        deal = state.lastSellerAsk ?? state.currentOffer

        state.dealPrice = deal

    - .walkAway：

        state.isDone = true

    - .ask：

        不改价格（只是问问题）

3. 回合推进

    if !state.isDone { state.round += 1 }

### Step 5 - 生成话术（把“动作 + 程序算好的数字”变成一句话）
> 发生在：Renderer.swift
- 开场话术：Renderer.opening(state:)
- 每轮回复：Renderer.respond(move:state:nextOffer:)

### Step 6 - 显示到聊天 UI（把话术变成气泡并滚动到底）
> 发生在：BargainGameView.swift

1. add(_ role:_ text:)：把消息追加进 messages

2. SwiftUI ForEach(messages) 自动刷新 UI

3. ScrollViewReader 的 .onChange(of: messages.count) 自动滚动到底部


## Code
### BargainGameView - Main View
```swift
import SwiftUI

// MARK: - Game View（SwiftUI）
struct BargainGameView: View {
    @State private var messages: [ChatMessage] = []
    @State private var input: String = ""
    @State private var state: NegotiationState = GameFactory.newGame()
    
    var body: some View {
        VStack(spacing: 12) {
            header
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { msg in
                            bubble(msg).id(msg.id)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)
                .onChange(of: messages.count) { _ in
                    if let last = messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            
            quickBar
            inputBar
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
        }
        .onAppear { resetGame() }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("卖家模式：把价格谈高")
                        .font(.headline)
                    Text("买家性格：\(state.persona.rawValue) ・ 回合 \(state.round)/\(state.maxRounds)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("新一局") { resetGame() }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            Text("商品：\(state.product.name) ・ 成本：\(state.product.cost) ・ 市场约：\(state.product.market) ・ 你的开价：\(state.listingPrice)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
    }
    
    private func bubble(_ msg: ChatMessage) -> some View {
        let isSeller = (msg.role == .seller)
        let isSystem = (msg.role == .system)
        
        return HStack {
            if isSeller { Spacer(minLength: 40) }
            
            VStack(alignment: isSeller ? .trailing : .leading, spacing: 4) {
                if isSystem {
                    Text(msg.text)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text(msg.role == .buyer ? "买家" : "你")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(msg.text)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(isSeller ? Color(uiColor: .systemBlue).opacity(0.15) : Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            
            if !isSeller { Spacer(minLength: 40) }
        }
    }
    
    private var quickBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                qb("报个价") { insert("我可以 \(state.listingPrice)。") }
                qb("包邮") { insert("我可以包邮。") }
                qb("保修") { insert("有保修／可提供购买凭证。") }
                qb("今天发") { insert("我今天就能发货。") }
                qb("强调成色") { insert("成色很好，功能都正常，也都测试过。") }
                qb("最后价") { insert("最后价：\(state.listingPrice)。") }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private func qb(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(uiColor: .tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .disabled(state.isDone)
    }
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(state.isDone ? "本局结束，点「新一局」再玩" : "输入你的回复（可包含价格数字）", text: $input, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(state.isDone)
            
            Button("发送") { send() }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(state.isDone ? Color(uiColor: .systemGray4) : Color(uiColor: .systemBlue))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(state.isDone)
        }
    }
    
    // MARK: - Game flow
    private func resetGame() {
        state = GameFactory.newGame()
        messages.removeAll()
        
        add(.system, "目标：把商品用更高的价格卖出去。买家会努力压价。")
        add(.system, "提示：回复里直接带数字就是你的还价（例如：1800）。你也可以用包邮/保修/成色等方式提高成交概率。")
        add(.buyer, Renderer.opening(state: state))
        
        state.lastSellerAsk = state.listingPrice
    }
    
    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        
        add(.seller, text)
        guard !state.isDone else { return }
        
        let ask = parseSellerAsk(text)
        let conc = concessionScore(text)
        let att = attitudeScore(text)
        
        if let a = ask { state.lastSellerAsk = a }
        
        let move = Planner.decide(state: state, sellerAsk: ask, concession: conc, attitude: att)
        stepStateAndReply(move: move)
    }
    
    private func stepStateAndReply(move: BuyerMove) {
        // 硬截止：到回合上限就结束
        if state.round >= state.maxRounds && !state.isDone {
            state.isDone = true
            add(.buyer, "我得现在决定了，我先不买了。")
            add(.system, "❌ 未成交。下次可以更快收敛，或多给一些加值条件。")
            return
        }
        
        switch move {
        case .ask:
            add(.buyer, Renderer.respond(move: move, state: state, nextOffer: nil))
            
        case .accept:
            state.isDone = true
            let deal = state.lastSellerAsk ?? state.currentOffer
            state.dealPrice = deal
            add(.buyer, Renderer.respond(move: move, state: state, nextOffer: nil))
            let profit = deal - state.product.cost
            add(.system, "✅ 成交价：\(deal) ・ 利润：\(profit)")
            
        case .walkAway:
            state.isDone = true
            add(.buyer, Renderer.respond(move: move, state: state, nextOffer: nil))
            add(.system, "❌ 未成交。你可以试着慢慢降价，或加上包邮/保修/赠品等条件。")
            
        case .counter(let step, _, _):
            let next = min(state.buyerMax, state.currentOffer + step)
            state.currentOffer = next
            add(.buyer, Renderer.respond(move: move, state: state, nextOffer: next))
        }
        
        if !state.isDone { state.round += 1 }
    }
    
    private func insert(_ s: String) { input = input.isEmpty ? s : (input + " " + s) }
    private func add(_ role: Role, _ text: String) { messages.append(.init(role: role, text: text)) }
}
```
### Models - 用一个 state 管一局
```swift
import Foundation

// MARK: - Domain Models
enum Role { case seller, buyer, system }

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
}

struct Product {
    let name: String
    let cost: Int
    let market: Int
}

enum Persona: String, CaseIterable {
    case stingy = "斤斤计较"
    case friendly = "好商量"
    case picky = "挑剔派"
}

struct NegotiationState {
    let product: Product
    let persona: Persona
    
    // SSOT：所有金额必须由程序掌控，模板不负责生成金额
    var listingPrice: Int
    var currentOffer: Int
    var buyerMax: Int
    var buyerIdeal: Int
    
    var round: Int = 1
    var maxRounds: Int = 8
    
    var lastSellerAsk: Int?
    var trust: Int = 50        // 0..100
    var impatience: Int = 0    // 回合数增加会变急
    
    var isDone: Bool = false
    var dealPrice: Int? = nil
}

// MARK: - Buyer Move（这里不直接放“价格文字”，价格由程序计算后再插入）
enum BuyerMove {
    case counter(step: Int, tone: Tone, tag: Tag?)
    case accept(tone: Tone)
    case walkAway(reason: WalkReason)
    case ask(QuestionKind)
}

enum Tone { case friendly, neutral, tough }
enum Tag { case mentionValue, mentionBudget, mentionAlternatives, lastOffer }
enum WalkReason { case tooExpensive, tooSlow, badAttitude }
enum QuestionKind { case condition, warranty, delivery, defects }

// MARK: - Utils
func clamp<T: Comparable>(_ x: T, _ a: T, _ b: T) -> T { min(b, max(a, x)) }
```
### Parsing - 从文本里读出信号
```swift
import Foundation

// MARK: - Parsing（简单但够用）
func parseSellerAsk(_ text: String) -> Int? {
    let cleaned = text.replacingOccurrences(of: ",", with: "")
    if let r = cleaned.range(of: #"(\d{2,7})"#, options: .regularExpression) {
        return Int(cleaned[r])
    }
    return nil
}

// 让步/加值关键词 -> 增加信任与愿意加价的程度
func concessionScore(_ text: String) -> Int {
    let t = text.lowercased()
    let good: [(String, Int)] = [
        ("包邮", 2), ("免邮", 2), ("免运", 2), ("含运", 2),
        ("保修", 2), ("保固", 2), ("发票", 1), ("凭证", 1),
        ("今天", 1), ("当天", 1), ("现货", 1),
        ("赠品", 1), ("加送", 1), ("配件", 1),
        ("全新", 1), ("九成新", 1), ("几乎全新", 1),
        ("已测试", 1), ("测试过", 1), ("功能正常", 1)
    ]
    var score = 0
    for (k, v) in good where t.contains(k.lowercased()) { score += v }
    if parseSellerAsk(text) != nil { score += 1 } // 有清楚报价加分
    return clamp(score, 0, 4)
}

// 语气差/强硬 -> 降低信任
func attitudeScore(_ text: String) -> Int {
    let t = text.lowercased()
    let bad: [String] = [
        "爱买不买", "别浪费时间", "不买拉倒", "随便", "最后一次", "别再问了", "别磨叽"
    ]
    var s = 0
    for k in bad where t.contains(k.lowercased()) { s += 1 }
    return clamp(s, 0, 3)
}
```
### Planner - 买家大脑 
Planner 是“买家大脑”，输入当前 state + 你这句话的信号（报价/加分/态度），输出一个动作：问问题/还价/接受/走人。
```swift
import Foundation

// MARK: - Planner（确定性 + 有界随机）
enum Planner {
    static func decide(state: NegotiationState, sellerAsk: Int?, concession: Int, attitude: Int) -> BuyerMove {
        var s = state
        
        let ask = sellerAsk ?? s.lastSellerAsk ?? s.listingPrice
        let roundsLeft = max(0, s.maxRounds - s.round)
        
        // 更新内部指标（确定性）
        let trustDelta = clamp(concession * 3 - attitude * 4, -12, 12)
        s.trust = clamp(s.trust + trustDelta, 0, 100)
        s.impatience = clamp(s.impatience + 8 + max(0, attitude) * 3, 0, 100)
        
        // 硬截止：最后几回合必须收敛
        let deadlineMode = roundsLeft <= 2
        
        // 如果卖家已经 <= 买家出价，倾向接受
        if ask <= s.currentOffer {
            return .accept(tone: tone(from: s))
        }
        
        // 在可接受范围内：接受概率取决于接近程度 + 信任 + 是否进入截止模式
        if ask <= s.buyerMax {
            let closeness = 1.0 - Double(max(0, ask - s.buyerIdeal)) / Double(max(1, s.buyerMax - s.buyerIdeal))
            var p = 0.18 + closeness * 0.55 + Double(s.trust) * 0.004
            if deadlineMode { p += 0.15 }
            p = min(0.92, max(0.05, p))
            
            if Double.random(in: 0...1) < p {
                return .accept(tone: tone(from: s))
            }
        }
        
        // 走人条件（有界、可解释）
        if ask > s.buyerMax + 250 && s.round >= 3 && s.trust < 35 {
            return .walkAway(reason: .tooExpensive)
        }
        if s.impatience >= 85 && s.round >= 5 {
            return .walkAway(reason: .tooSlow)
        }
        if attitude >= 2 && s.trust < 30 && s.round >= 3 {
            return .walkAway(reason: .badAttitude)
        }
        
        // 有时先追问细节，让体验更像“AI 会互动”
        if s.round <= 3 && Double.random(in: 0...1) < 0.28 {
            let q: QuestionKind = [.condition, .warranty, .delivery, .defects].randomElement()!
            return .ask(q)
        }
        
        // 还价：只计算“步进”，不直接产生最终价格（由程序计算）
        let base = max(40, (s.buyerMax - s.currentOffer) / 4)
        let personaBoost = personaStepBoost(s.persona)
        let trustBoost = s.trust / 10
        let impatienceBoost = s.impatience / 12
        let deadlineBoost = deadlineMode ? 40 : 0
        
        var step = base + personaBoost + trustBoost + impatienceBoost + deadlineBoost + concession * 10
        step = clamp(step, 30, 260)
        
        let t = tone(from: s)
        let tag = deadlineMode ? Tag.lastOffer : ([Tag.mentionBudget, .mentionValue, .mentionAlternatives].randomElement())
        return .counter(step: step, tone: t, tag: tag)
    }
    
    private static func tone(from s: NegotiationState) -> Tone {
        switch s.persona {
        case .friendly:
            return s.trust >= 55 ? .friendly : .neutral
        case .picky:
            return s.trust >= 65 ? .neutral : .tough
        case .stingy:
            return s.trust >= 70 ? .neutral : .tough
        }
    }
    
    private static func personaStepBoost(_ p: Persona) -> Int {
        switch p {
        case .friendly: return 10
        case .picky: return 0
        case .stingy: return -10
        }
    }
}
```
### Renderer - 模板嘴巴
Renderer 是“买家嘴巴”：根据动作生成一句话术，并把程序算出来的价格插进去。  
所以表现像 AI，但本质是模板多变体。
```swift
import Foundation

// MARK: - Renderer（只负责话术模板；价格由程序插入）
enum Renderer {
    static func opening(state: NegotiationState) -> String {
        let p = state.product.name
        let offer = state.currentOffer
        let persona = state.persona
        
        switch persona {
        case .friendly:
            return pick([
                "你好～我对「\(p)」有兴趣。不过你开价有点高，我先出 \(offer) 可以吗？",
                "嗨 😊 我挺喜欢这个「\(p)」。先从 \(offer) 开始谈行不行？"
            ])
        case .picky:
            return pick([
                "我在考虑「\(p)」。我先出 \(offer)。想问下成色/状态怎么样？",
                "有兴趣，但我需要一些细节。我的第一口价是 \(offer)。"
            ])
        case .stingy:
            return pick([
                "「\(p)」我出 \(offer)。先从这个价开始。",
                "\(offer)。你要就回价，不然我也在看预算。"
            ])
        }
    }
    
    static func respond(move: BuyerMove, state: NegotiationState, nextOffer: Int?) -> String {
        switch move {
        case .ask(let q):
            return question(q)
        case .accept(let tone):
            return acceptLine(tone, price: state.lastSellerAsk ?? nextOffer ?? state.currentOffer)
        case .walkAway(let reason):
            return walkLine(reason)
        case .counter(_, let tone, let tag):
            let offer = nextOffer ?? state.currentOffer
            return counterLine(tone: tone, tag: tag, offer: offer)
        }
    }
    
    private static func question(_ q: QuestionKind) -> String {
        switch q {
        case .condition:
            return pick(["整体状态怎么样？有没有划痕或使用问题？", "成色好吗？有没有明显瑕疵？"])
        case .warranty:
            return pick(["有保修或购买凭证吗？", "你有发票或保修信息吗？"])
        case .delivery:
            return pick(["今天能发货吗？有哪些配送方式？", "包邮吗？还是运费另算？"])
        case .defects:
            return pick(["有没有什么缺点需要提前说明？", "功能都正常吗？有没有暗病？"])
        }
    }
    
    private static func acceptLine(_ tone: Tone, price: Int) -> String {
        switch tone {
        case .friendly:
            return pick(["好吧，你说得有道理 🙂 那就 \(price) 成交！", "听起来合理，就 \(price) 吧。"])
        case .neutral:
            return pick(["可以，\(price) 成交。", "行，\(price)。"])
        case .tough:
            return pick(["行，\(price)。但就这样了。", "好，\(price)，最后价。"])
        }
    }
    
    private static func walkLine(_ r: WalkReason) -> String {
        switch r {
        case .tooExpensive:
            return pick(["这个价还是太高了，我先不买了。", "价差太大了，我就先撤。"])
        case .tooSlow:
            return pick(["谈太久了，我先不买。", "我得现在决定，我先放弃。"])
        case .badAttitude:
            return pick(["你这语气我不太舒服，我先走。", "先到这儿吧，我不想继续谈了。"])
        }
    }
    
    private static func counterLine(tone: Tone, tag: Tag?, offer: Int) -> String {
        let tagLine: String = {
            switch tag {
            case .mentionValue:
                return pick(["如果状态真的很好，我可以再加一点，不过", "我也重视品质，但"])
            case .mentionBudget:
                return pick(["我预算确实有限，所以", "从预算角度来说，"])
            case .mentionAlternatives:
                return pick(["我也看过其他类似的，所以", "我还有别的选择，所以"])
            case .lastOffer:
                return pick(["我最后一次出价：", "我的最终出价："])
            case .none:
                return ""
            }
        }()
        
        switch tone {
        case .friendly:
            return pick([
                "\(tagLine) \(offer) 可以吗？😊",
                "\(tagLine) 我可以到 \(offer)，这样能成交吗？"
            ])
        case .neutral:
            return pick([
                "\(tagLine) 我出 \(offer)。",
                "\(tagLine) \(offer)。"
            ])
        case .tough:
            return pick([
                "\(tagLine) \(offer)。要就成交，不然我就不买了。",
                "\(tagLine) \(offer)。这是我的底。"
            ])
        }
    }
    
    private static func pick(_ arr: [String]) -> String { arr.randomElement() ?? "" }
}
```
### GameFactory - 每局随机一点
用来生成商品、买家性格、开价、最高价、理想价，让每局不一样
```swift
import Foundation

// MARK: - Factory
enum GameFactory {
    static func newGame() -> NegotiationState {
        let products: [Product] = [
            .init(name: "二手 iPad（成色佳）", cost: 900, market: 1500),
            .init(name: "机械键盘", cost: 450, market: 900),
            .init(name: "耳机（带盒）", cost: 600, market: 1200),
            .init(name: "显卡（保修中）", cost: 2500, market: 3600),
            .init(name: "相机镜头", cost: 1800, market: 3000)
        ]
        
        let product = products.randomElement()!
        let persona = Persona.allCases.randomElement()!
        
        let listingPrice = Int(Double(product.market) * Double.random(in: 1.05...1.25))
        
        let buyerMaxPrice = Int(Double(product.market) * Double.random(in: persona == .stingy ? 0.75...0.95 : 0.85...1.05))
        let buyerIdealPrice = Int(Double(product.market) * Double.random(in: persona == .friendly ? 0.60...0.78 : 0.55...0.72))
        
        let openingOffer = Swift.max(product.cost + 50, buyerIdealPrice - Int.random(in: 0...80))
        let finalBuyerMax = Swift.max(openingOffer + 200, buyerMaxPrice)
        let finalBuyerIdeal = Swift.min(openingOffer, buyerIdealPrice)
        
        return NegotiationState(
            product: product,
            persona: persona,
            listingPrice: listingPrice,
            currentOffer: openingOffer,
            buyerMax: finalBuyerMax,
            buyerIdeal: finalBuyerIdeal,
            round: 1,
            maxRounds: 8,
            lastSellerAsk: listingPrice,
            trust: persona == .friendly ? 60 : 50,
            impatience: 0,
            isDone: false,
            dealPrice: nil
        )
    }
}
```

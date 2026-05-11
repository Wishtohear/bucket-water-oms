# Ralph 执行铁律 (Execution Iron Rules)

> **⚠️ 注意**: 这是 Ralph 开发流程的最高指令。所有 Agent 必须无条件遵守。每次行动前请自我检查。

## 1. 物理顺序优先 (Physical Order First)
- **规则**: 必须严格按照 `04-ralph-tasks.md` 和 `05-test-plan.md` 文件中的**行号物理顺序**执行任务。
- **禁止**: 严禁跳过当前未完成的条目去执行后面的任务（哪怕后面的看起来更容易）。
- **禁止**: 严禁跳过单元测试，进行后面的任务。
- **例外**: 只有当当前任务被明确标记为 `[-]` (Blocked) 并注明原因后，才允许跳过。

## 2. 测试即交付 (Test is Delivery)
- **规则**: 任何代码变更必须通过单元测试验证。
- **流程**: 编写代码 -> 编写/运行测试 -> 测试通过 -> 提交代码。
- **禁止**: **严禁跳过测试环节**。如果没有现有测试，必须编写新的测试用例。
- **验证**: 必须看到 `PASS` 或 `Success` 的终端输出，才能视为任务完成。

## 3. 状态真实性 (State Integrity)
- **规则**: `RALPH_STATE.md` 必须反映最真实的进度。修改任务、测试状态前，必须先修改 `04-ralph-tasks.md` 或 `05-test-plan.md`，再修改 `RALPH_STATE.md`。
- **强制**: 严格按照 `05-test-plan.md` 进行测试。每完成一个测试用例，**必须且必须先**修改 `05-test-plan.md` 中的状态（将 `[ ]` 改为 `[x]`），**然后**才能修改 `RALPH_STATE.md`。
- **强制**: 只能进行`04-ralph-tasks.md` 或 `05-test-plan.md`中的任务、测试，如果需要进行其他任务、测试，必须先写入这两个文件，再进行。
- **强制**: 每完成一个任务/测试，**必须**修改 `04-ralph-tasks.md` 或 `05-test-plan.md`，将对应的 `[ ]` 改为 `[x]`。
- **操作**: 每次更新状态前，必须**重新扫描**任务文件 (`04`/`05`)，统计实际的 `[x]` 数量。
- **禁止**: 禁止仅凭记忆更新状态。如果状态文件与任务文件不一致，必须强制修正状态文件。
- **禁止**: 严禁在未更新 `05-test-plan.md` 的情况下，直接修改`RALPH_STATE.md` 中的测试相关状态。

## 4. 单线程专注 (Single Thread Focus)
- **规则**: 每次只处理一个任务 ID (e.g., `T-AUTH-001`)。
- **禁止**: 禁止并发执行多个任务。
- **拒绝**: 如果用户在执行过程中插入无关话题，请礼貌拒绝并回归当前任务。

## 5. Flutter 移动端开发规范 (Flutter Mobile Development Rules)

> **⚠️ 重要**: 实现 Flutter 移动端页面时，必须严格参照原型文件的设计语言和视觉规范。

### 5.1 原型文件位置
- **原型目录**: `bucket-water-oms-admin-mobile/origin/`
- **设计语言来源**: 原型 HTML 文件使用的 Tailwind CSS 类和样式定义
- **必须先查看原型**: 在实现任何 Flutter 页面之前，必须先查看对应的原型文件

### 5.2 设计规范 (Design System)

#### 5.2.1 颜色系统 (Color Palette)
```
主色 (Primary):      #1890FF (蓝色)
成功色 (Success):     #52C41A (绿色)
警告色 (Warning):     #FAAD14 (橙色)
错误色 (Error):       #FF4D4F (红色)
紫色 (Purple):        #722ED1
背景色:               #F8FAFC, #F4F7F9

文字颜色:
- 主文字: #262626
- 次要文字: #8C8C8C
- 占位符: #BFBFBF
- 深灰: #333333

状态颜色:
- 在线状态: #52C41A (绿色)
- 离线状态: #BFBFBF (灰色)
```

#### 5.2.2 圆角规范 (Border Radius)
```
小圆角:    8px   (按钮、标签、小卡片)
中等圆角:  12px  (输入框、列表项)
大圆角:    16px  (卡片)
特大圆角:  20-24px (主要卡片、Banner)
容器圆角:  32px  (底部弹窗)
```

#### 5.2.3 阴影规范 (Shadows)
```
轻阴影:  0 2px 8px rgba(0,0,0,0.04)
中等阴影: 0 4px 12px rgba(0,0,0,0.08)
强阴影:  0 8px 24px rgba(0,0,0,0.12)
卡片阴影: shadow-sm (默认)
强调阴影: shadow-lg (重要卡片)
```

#### 5.2.4 字体规范 (Typography)
```
字体家族: PingFang SC, system-ui, sans-serif
标题:    16-20px, font-bold
正文:    14px, font-medium
辅助文字: 12px
小标签:   10-12px

行高: 1.4-1.6
```

### 5.3 布局规范 (Layout Rules)

#### 5.3.1 页面结构
```
┌─────────────────────────────────┐
│ 状态栏安全区 (SafeArea)          │ ← MediaQuery.of(context).padding.top
├─────────────────────────────────┤
│ 头部区域                          │ ← 固定/渐变背景
│ - Logo + 标题                    │
│ - Tab 导航                       │
├─────────────────────────────────┤
│                                  │
│ 内容区域                          │ ← Expanded / Flexible
│ - 搜索栏                        │
│ - 卡片列表                      │
│ - Banner轮播                    │
│                                  │
├─────────────────────────────────┤
│ 底部导航栏                        │ ← SafeArea + 固定高度
│ - 4-5个图标按钮                 │
└─────────────────────────────────┘
```

#### 5.3.2 间距规范 (Spacing)
```
页面边距: 16-24px
卡片内边距: 16-20px
元素间距: 8-16px
分组间距: 24-32px
底部安全区: 20-24px
```

#### 5.3.3 组件尺寸
```
图标大小: 20-24px
小按钮: 32-40px
大按钮: 48-56px
输入框高度: 40-48px
底部导航栏高度: 60-80px
头像: 32-48px
```

### 5.4 组件规范 (Component Rules)

#### 5.4.1 卡片组件 (Card)
```
圆角: 16-24px
内边距: 16-20px
阴影: shadow-sm
边框: 可选 border-gray-50
悬停: 可选 hover:shadow-md
```

#### 5.4.2 按钮组件 (Button)
```
主按钮: bg-blue-500, text-white, rounded-xl
次按钮: bg-gray-100, text-gray-600, rounded-xl
图标按钮: w-10 h-10, rounded-full
圆角: 8-12px
高度: 40-48px
内边距: 16-24px
```

#### 5.4.3 列表项 (List Item)
```
高度: 最小 56px
圆角: 12-16px
边框: 可选分隔线
悬停: 可选 active:bg-gray-50
```

#### 5.4.4 输入框 (Input)
```
高度: 40-48px
圆角: 12px (rounded-xl)
背景: bg-white
边框: focus:ring-blue-500
```

### 5.5 状态规范 (State Rules)

#### 5.5.1 状态徽章 (Status Badge)
```
进行中: bg-blue-100, text-blue-600
待处理: bg-orange-100, text-orange-600
已完成: bg-green-100, text-green-600
已取消: bg-gray-100, text-gray-600
错误:   bg-red-100, text-red-600
```

#### 5.5.2 统计卡片
```
背景: 渐变或纯色
数字: 大号加粗
单位: 小号辅助文字
对比: 小号百分比显示
```

### 5.6 交互规范 (Interaction Rules)

#### 5.6.1 手势
```
点击: active:scale-95 或 active:bg-gray-50
长按: 可选 contextMenu
滑动: ListView 或 PageView
下拉: RefreshIndicator
```

#### 5.6.2 动画
```
过渡: 200-300ms
缓动: ease-in-out
悬停: transform scale(1.02)
加载: Shimmer 或 CircularProgressIndicator
```

### 5.7 响应式规范 (Responsive Rules)

#### 5.7.1 安全区域
```
顶部: MediaQuery.of(context).padding.top
底部: MediaQuery.of(context).padding.bottom
刘海屏: 自动适配
```

#### 5.7.2 屏幕适配
```
手机端: 375px 设计稿
平板端: 768px+
异形屏: SafeArea 包裹所有内容
```

### 5.8 颜色映射表 (Color Mapping)

| 原型颜色 | Flutter AppColors |
|----------|-------------------|
| #1890FF | AppColors.primary |
| #52C41A | AppColors.success |
| #FAAD14 | AppColors.warning |
| #FF4D4F | AppColors.error |
| #722ED1 | AppColors.purple |
| #F8FAFC | AppColors.background |
| #F4F7F9 | AppColors.surfaceVariant |
| #262626 | AppColors.textPrimary |
| #8C8C8C | AppColors.textSecondary |
| #BFBFBF | AppColors.textTertiary |

### 5.9 圆角映射表 (Border Radius Mapping)

| 原型类名 | Flutter BorderRadius |
|----------|-------------------|
| rounded-lg | BorderRadius.circular(8) |
| rounded-xl | BorderRadius.circular(12) |
| rounded-2xl | BorderRadius.circular(16) |
| rounded-3xl | BorderRadius.circular(20) |
| rounded-full | BorderRadius.circular(9999) |

### 5.10 图标规范 (Icon Rules)

#### 5.10.1 图标库
- 使用 `iconify` 图标库风格
- 常用图标映射到 Flutter Material Icons 或 Cupertino Icons

#### 5.10.2 图标大小
```
小图标: 16-20px (Tab、文字内)
中图标: 20-24px (按钮、列表)
大图标: 32-40px (空状态、快速入口)
特大图标: 48-64px (Logo、Empty State)
```

### 5.11 实现检查清单 (Implementation Checklist)

实现每个 Flutter 页面时，必须检查：

- [ ] 查看并理解对应的原型文件
- [ ] 使用正确的颜色常量 (AppColors)
- [ ] 使用正确的圆角值 (AppTheme)
- [ ] 使用 SafeArea 包裹所有内容
- [ ] 使用正确的间距值
- [ ] 使用正确的阴影值
- [ ] 状态徽章颜色正确
- [ ] 底部导航栏正确实现
- [ ] 卡片样式与原型一致
- [ ] 按钮样式与原型一致
- [ ] 交互效果与原型一致 (active:scale, shadow等)

### 5.12 禁止事项 (Prohibited)

- ❌ 禁止使用硬编码的颜色值 (应使用 AppColors)
- ❌ 禁止使用不符合原型的圆角值
- ❌ 禁止跳过 SafeArea 包裹
- ❌ 禁止使用与原型不一致的布局结构
- ❌ 禁止忽略原型中的任何视觉元素
- ❌ 禁止使用未经授权的图标

---

## 6. 代码风格规范 (Code Style)

### 6.1 Dart 代码规范
- 使用 2 空格缩进
- 类名使用 PascalCase
- 方法名和变量名使用 camelCase
- 常量使用 SCREAMING_SNAKE_CASE
- 优先使用 `const` 构造函数
- 优先使用 `final` 声明不可变变量

### 6.2 Flutter 特定规范
- 使用 `Widget` 结尾命名自定义组件
- 使用 `StatelessWidget` 优先于 `StatefulWidget`
- 使用 `Consumer` 或 `context.watch` 管理状态
- 使用 `MediaQuery` 获取屏幕信息
- 使用 `SafeArea` 处理刘海屏

### 6.3 文件组织
```
lib/
├── main.dart
├── core/
│   ├── config/
│   ├── network/
│   ├── theme/
│   └── utils/
├── models/
├── services/
├── pages/
│   ├── login/
│   ├── owner/
│   ├── driver/
│   ├── warehouse/
│   └── admin/
└── shared/
    ├── widgets/
    └── components/
```

---

## 7. 文件修改记录规范

每次修改文件时，必须在文件头部或合适位置添加修改记录：

```dart
/// 修改记录 (YYYY-MM-DD)
/// - 功能描述 (issue #xxx)
/// - 详细修改内容
```

---

> **最后更新**: 2026-04-30
> **版本**: v2.0
> **添加内容**: Flutter 移动端开发规范 (第5章)

# Blowfish 主题功能说明

## 目录结构

```
blowfish/
├── layouts/         → HTML 模板（页面骨架，不需要修改）
├── assets/          → CSS/JS/图标/图片（视觉资源）
├── i18n/            → 多语言翻译文本
├── static/          → 静态文件
├── data/            → 主题数据（配色方案数据等）
├── archetypes/      → `hugo new` 文章模板
├── theme.toml       → 主题元信息
└── config/          → 主题默认配置（参考用，不直接生效）
```

## 一、layouts/ — 页面模板

所有模板均可通过 `config/_default/params.toml` 控制，无需修改模板文件。

### 首页布局（`layouts/partials/home/`）

| 文件 | 参数值 | 效果 |
|------|--------|------|
| `background.html` | `homepage.layout = "background"` | 全屏背景图 + 居中个人简介 |
| `profile.html` | `homepage.layout = "profile"` | 个人卡片（头像 + 简介） |
| `hero.html` | `homepage.layout = "hero"` | 大图标题 |
| `card.html` | `homepage.layout = "card"` | 卡片式列表 |
| `page.html` | `homepage.layout = "page"` | 纯页面内容 |
| `custom.html` | `homepage.layout = "custom"` | 完全自定义（需自己写模板） |

### 头部导航（`layouts/partials/header/`）

| 文件 | 参数值 | 效果 |
|------|--------|------|
| `basic.html` | `header.layout = "basic"` | 基础样式，随页面滚动 |
| `fixed.html` | `header.layout = "fixed"` | 固定悬浮 + 毛玻璃背景 |
| `fixed-fill.html` | `header.layout = "fixed-fill"` | 固定悬浮 + 背景填充 |
| `fixed-gradient.html` | `header.layout = "fixed-gradient"` | 固定悬浮 + 渐变背景 |
| `fixed-fill-blur.html` | `header.layout = "fixed-fill-blur"` | 固定悬浮 + 填充毛玻璃 |

### 文章列表模式（首页最近文章区域）

| 模板 | 参数组合 |
|------|----------|
| `recent-articles/list.html` | `homepage.cardView = false` 一行一篇，紧凑列表 |
| `recent-articles/cardview.html` | `cardView = true, cardViewScreenWidth = false` 2~3 列卡片 |
| `recent-articles/cardview-fullwidth.html` | `cardView = true, cardViewScreenWidth = true` 全宽多列卡片 |

### 短代码（`layouts/shortcodes/`）

可在 Markdown 文章中直接使用的增强组件：

| 短代码 | 用途 |
|--------|------|
| `github` / `gitlab` / `gitea` 等 | 嵌入仓库卡片 |
| `mermaid` | 流程图/时序图 |
| `chart` | 图表 |
| `katex` | 数学公式 |
| `icon` | 内联图标 |
| `youtubeLite` | 视频嵌入 |
| `carousel` | 图片轮播 |
| `timeline` | 时间线 |
| `gallery` | 图片画廊 |
| `typeit` | 打字机效果 |
| `tabs` | 标签页切换 |

### SEO 和社交（`layouts/partials/`）

| 文件 | 功能 |
|------|------|
| `head.html` | HTML head 标签：标题、描述、OG/Twitter 标签、CSS/JS 加载 |
| `schema.html` | 结构化数据（JSON-LD） |
| `sharing-links.html` | 文章分享按钮 |
| `sitemap.xml` | 站点地图 |

## 二、assets/ — 视觉资源

### 配色方案（`assets/css/schemes/`）

16 种内置配色，通过 `params.toml` 的 `colorScheme` 切换：

`blowfish` `ocean` `forest` `fire` `slate` `github` `neon` `noir` `terminal` `congo` `marvel` `princess` `one-light` `avocado` `bloody` `autumn`

### JS 功能（`assets/js/`）

| 文件 | 功能 |
|------|------|
| `appearance.js` | 亮/暗色模式切换 |
| `search.js` | 全文搜索 |
| `code.js` | 代码块复制按钮 |
| `scroll-to-top.js` | 返回顶部按钮 |
| `zen-mode.js` | 禅模式（专注阅读） |
| `rtl.js` | 从右到左文字支持 |

### 图标（`assets/icons/`）

内置 100+ SVG 图标，用于菜单、社交链接、UI 元素等。可通过 `partial "icon.html"` 调用。

## 三、config/_default/ — 主题参数参考

主题自带配置模板，展示了所有可配置项。实际生效的配置在站点 `config/_default/` 目录。

### 主要配置项类别

| 文件 | 控制内容 |
|------|----------|
| `hugo.toml` | `baseURL`、语言、分页、SEO、分类法 |
| `languages.xx.toml` | 网站标题、作者信息、Logo、社交链接 |
| `params.toml` | 主题行为：配色、布局、文章显示、页脚 |
| `markup.toml` | Markdown 渲染（高亮、目录层级） |
| `menus.xx.toml` | 顶部/底部导航菜单 |
| `module.toml` | Hugo Modules 配置 |

## 四、i18n/ — 多语言翻译

包含所有界面文字的翻译，如"阅读时间"、"上一篇"、"搜索"等。中文翻译文件为 `zh-cn.yaml`。

## 五、自定义覆盖规则

若要修改主题行为，**不要直接改 theme 文件**，而是在站点对应路径放置同名文件：

| 覆盖目标 | 站点路径 |
|----------|----------|
| 覆盖模板 | `layouts/` |
| 覆盖 CSS | `assets/css/custom.css` |
| 覆盖图标 | `assets/icons/xxx.svg` |
| 覆盖 JS | `assets/js/` |
| 覆盖翻译 | `i18n/` |

这样主题升级时不会丢失自定义内容。

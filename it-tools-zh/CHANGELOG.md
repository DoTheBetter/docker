# 更新日志
## 2026年1月1日 更新
镜像版本：dothebetter/it-tools-zh:20260101
1. 更新上游仓库commits版本c24f94c，release版本2025.12.7。
2. 新增工具（14个）
    - Amortization Calculator (分期付款计算器) ：金融类工具，用于计算分期付款
    - Trigonometric/Equation Curve Visualizer (三角函数/方程曲线可视化) ：数学类工具，可视化三角函数或方程曲线
    - SVG Previewer (SVG 预览器) ：图像类工具，预览 SVG 文件
    - Argon2 Hasher (Argon2 哈希器) ：加密类工具，生成 Argon2 哈希
    - GitIgnore Generator (GitIgnore 生成器) ：开发类工具，生成 .gitignore 文件
    - IP Subnets Lister (IP 子网列表器) ：网络类工具，列出 IP 子网信息
    - Shamir's Secret Sharing (Shamir 秘密共享) ：加密类工具，实现秘密共享算法
    - Short Urls Expander (短链接展开器) ：取证类工具，展开短链接
    - Markdown Lorem Ipsum Generator (Markdown Lorem Ipsum 生成器) ：Markdown 类工具，生成占位文本
    - CSS Units Converter (CSS 单位转换器) ：Web 类工具，转换 CSS 单位
    - CSS Gradient Generator (CSS 渐变生成器) ：Web 类工具，生成 CSS 渐变
    - PDF Compressor (PDF 压缩器) ：PDF 类工具，压缩 PDF 文件
    - Screen Command Cheatsheet (Screen 命令速查表) ：速查表类工具，Screen 命令备忘
    - Tmux Command Cheatsheet (Tmux 命令速查表) ：速查表类工具，Tmux 命令备忘
3. 有变动的工具（10个）
    - Docker Compose to Docker Run (Docker Compose 转 Docker Run) ：添加多行选项支持
    - Case Converter (大小写转换器) ：添加 title、sponge 和 swap case 转换模式
    - Git Semantic Commit Memo (Git 语义提交备忘录) ：增强版本功能
    - JSON Editor (JSON 编辑器) ：添加修复和 schema 验证功能
    - Docker Compose to Env File (Docker Compose 转 Env 文件) ：国际化改进
    - Url Parser (URL 解析器) ：为包含 xxx:// 的 URL 参数添加打开 URL 按钮
    - JSON Viewer (JSON 查看器) ：添加修复搜索关键词功能
    - JSON Linter (JSON 语法检查器) ：添加自动修复选项
    - Lorem Ipsum Generators (Lorem Ipsum 生成器) ：添加打印到 PDF 按钮
    - Unicode Search (Unicode 搜索) ：添加使用 Unicode 字符进行搜索的能力

## 2025年11月24日 更新
镜像版本：dothebetter/it-tools-zh:20251124
1. 更新上游仓库commits版本6af606b，release版本2025.10.19。
2. 自翻译部分新增模块页面。
3. 新增工具：（1个）
    - JSON to TOON & TOON to JSON (JSON 与 TOON 互转工具)：支持双向数据格式转换
4. 有变动的工具（4个）
    - Docker Compose to Docker Run (Docker Compose 转 Docker Run)：添加多行选项支持
    - JWT Generator (JWT 生成器)：支持粘贴现有 Token 编辑；新增密钥编码处理（Base64/Hex 数组/文本）
    - JWT Parser (JWT 解析器)：支持密钥编码格式（文本/Hex 数组/Base64）
    - CRC Calculator (CRC 校验计算器)：修复输入文本监视器逻辑错误



## 2025年11月21日 更新

镜像版本：dothebetter/it-tools-zh:20251121
1. 更新上游仓库commits版本c7d77e1，release版本2025.10.19。
2. 自翻译部分新增模块页面。
3. 新增工具：（9个）
    - Binary Calculator (二进制计算器)
    - EMV TLV Parser (EMV TLV 解析器)
    - ETH Transaction Decoder (以太坊交易解码器)
    - JSON Message Pack (JSON MessagePack)
    - File Splitter (文件分割器，支持 json, txt, xml)
    - Serial Terminal (串行终端)
    - Docker Compose to .env file (Docker Compose 转 .env 文件)
    - Keycode Info (键码信息)
    - I or L checker (I 或 L 检查器)
4. 有变动的工具（6个）
    - Many Units Converter (单位换算器)：添加了对其他单位转换的引用
    - JSON Linter (JSON 格式检查器)：添加了可复制的格式化 JSON 功能
    - Chmod Calculator (chmod 计算器)：添加了速查表功能
    - Image Formats Converter (图像格式转换器)：添加了 SVG 关键词支持
    - Base64 File Converter (Base64 文件转换器)：添加了粘贴图片功能
    - Data Storage Converter (数据存储转换器)：使 1.00 的精度为偶数
5. 移除的工具
    - Credit Card Generator (信用卡生成器)：因使用可能被滥用而移除(Nov 8, 2025)

## 2025年9月29日 更新
镜像版本：dothebetter/it-tools-zh:20250929
1. 更新上游仓库commits版本116ee92，release版本2025.08.31-13b8f041。
2. 自翻译新增模块页面。
3. 新增模块：
    1. 图像处理工具 (4个)
		- Image Color Inverter - 图像颜色反转工具
		- Favicon Generator - Favicon生成器
		- Image Comparer - 图像比较器
		- OCR Image - 图像OCR识别
     2. 网络和安全工具 (5个)
        - DNSBL Checker - DNS黑名单检查器
        - Wireguard Config Generator - Wireguard配置生成器
        - Dns Queries - DNS查询工具
        - My IP - IP地址查询
        - Port Numbers - 端口号查询
    3. 开发工具 (8个)
        - SQL Parameters Generator - SQL参数生成器
        - Env Variables Converter - 环境变量转换器
        - GPT Token Encoder/Decoder - GPT令牌编码器/解码器
        - Charset Detector/Decoder - 字符集检测器/解码器
        - Markdown to DOCX - Markdown转DOCX
        - Text Translator - 文本翻译器
        - Django Secret Key generator - Django密钥生成器
        - Sed Command Generator + Cheatsheet - Sed命令生成器和备忘单
    4. 数据转换工具 (6个)
        - JSON to Data - JSON转数据
        - TOML Linter - TOML语法检查器
        - XML Linter - XML语法检查器
        - Markdown Table Prettifier - Markdown表格美化器
        - Unicode to GSM7 - Unicode转GSM7编码
        - Properties Converter - 属性文件转换器
    5. 计算和转换工具 (9个)
        - Which Day Calculator - 日期计算器
        - Random Numbers Generator - 随机数生成器
        - Middle Endian Converter - 中间字节序转换器
        - zxcvbn Password Strength - 密码强度分析器
        - Mailto Generator - 邮件链接生成器
        - Social Link Sharer - 社交链接分享器
        - Resistor Data Calculator - 电阻数据计算器
        - RAID Reliability Calculator/MTTDL - RAID可靠性计算器
        - Font Comparer - 字体比较器


## 2025年8月7日 更新
镜像版本：dothebetter/it-tools-zh:20250807
1. 更新上游仓库commits版本11e2ac8，release版本2025.08.06-0325b117。

## 2025年7月30日 更新
镜像版本：dothebetter/it-tools-zh:20250730
1. 更新上游仓库commits版本6cbfa60，release版本2025.07.20-3ccbd853。
	- 新增工具：Swagger UI Tester、Compose to Quadlets、JSON Merger、JSON Flattener/Unflattener、Levenshtein Distance Calculator
2. 使用上游仓库的中文翻译，该翻译已非常完整。

## 2025年7月08日 更新
镜像版本：dothebetter/it-tools-zh:20250708
1. 更新上游仓库commits版本7527853。
	- 新增工具：Citation Generator、ANSI Escape Tester、Cli command editor、HTML Minifier、Json Query

## 2025年6月23日 更新
镜像版本：dothebetter/it-tools-zh:20250623
1. 更新上游仓库commits版本a12c43b。
	- 新增工具：图像水印

## 2025年6月16日 更新
镜像版本：dothebetter/it-tools-zh:20250616
1. 更新上游仓库commits版本5904fa7，release版本2025.06.15-20a26514。
2. 跟随上游添加Caddy安全标头。

## 2025年6月13日 更新
镜像版本：dothebetter/it-tools-zh:20250613
1. 更新上游仓库commits版本203f207。
2. 升级基础镜像alpine版本为3.22。

## 2025年6月10日 更新
镜像版本：dothebetter/it-tools-zh:20250610
1. 更新上游仓库commits版本8e9d921。

## 2025年6月2日 更新
镜像版本：dothebetter/it-tools-zh:20250603
1. 更新上游仓库commits版本b6a7a5a。

## 2025年6月2日 更新
镜像版本：dothebetter/it-tools-zh:20250602
1. 更新上游仓库commits版本8b7cdb4。
	- 新增bash、k8s、nginx、vim速查表和age加密工具、pdf文本提取器
2. 替换web服务器为Caddy。

## 2025年5月29日 更新
镜像版本：dothebetter/it-tools-zh:20250529
1. 更新上游仓库commits版本12b1c94。

## 2025年5月28日 更新
镜像版本：dothebetter/it-tools-zh:20250528
1. 使用 https://github.com/sharevb/it-tools 版本的it-tools初次构建。
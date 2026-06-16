# 統計期末專題

## Title History of AI Agent

**Transformer 的誕生與預訓練大戰（2017 - 2021）**

- **2017: Google 發表《Attention is All You Need》論文**
    - 提出了 **Transformer** 架構
    - [https://research.google/blog/transformer-a-novel-neural-network-architecture-for-language-understanding/](https://research.google/blog/transformer-a-novel-neural-network-architecture-for-language-understanding/)
- **2018**:
    - **GPT-1 (OpenAI)**
        - 證明了 ” 預訓練 (Pre-train) “後再進行 “ 微調 (Fine-tune) “ 的有效性。
        - [https://openai.com/index/language-unsupervised/](https://openai.com/index/language-unsupervised/)
    - **BERT (Google)**
        - 曾在自然語言理解（NLU）上成為 **SOTA**
        - Google 隨即將其應用於搜尋引擎。
        - [https://research.google/pubs/bert-pre-training-of-deep-bidirectional-transformers-for-language-understanding/](https://research.google/pubs/bert-pre-training-of-deep-bidirectional-transformers-for-language-understanding/)
- **2019: GPT-2 (OpenAI)**
    - 參數達到 15 億 (150B)。
    - OpenAI 最初以「太危險」為由拒絕開源，引發了科技界對 AI 倫理與行銷手段的熱烈討論。
    - [https://openai.com/index/better-language-models/](https://openai.com/index/better-language-models/)
- **2020:** **GPT-3 (OpenAI)**
    - 參數飆升至 **1750 億 (1.75T)**。
    - 展現了「少樣本學習（Few-shot learning）」的能力
    - 不需要微調 Finetuned 就能寫程式、寫詩，震驚科技業。
    - [https://arxiv.org/pdf/2005.14165](https://arxiv.org/pdf/2005.14165)
    - [https://openai.com/index/gpt-3-apps/](https://openai.com/index/gpt-3-apps/)
- **2022 年 1 月: InstructGPT (OpenAI):**
    - OpenAI 引入 **RLHF (人類回饋強化學習)**，讓模型學會「聽從指令」而非只是預測下一個字。

**生成式 AI 的爆發與平民化（2022 - 2023 初）**

- **2022 年 11 月 30 日: OpenAI 發布 ChatGPT**
    - 史上用戶增長最快的應用。它象徵著 AI 從工具變成了「協作夥伴」。
    - [https://openai.com/zh-Hant/index/chatgpt/](https://openai.com/zh-Hant/index/chatgpt/)
- **2023 年 1 月: 微軟投資 OpenAI**
    - 微軟宣佈向 OpenAI 投資百億美元，並將其整合進 Azure 和 Bing。Google 內部發布「紅色警報（Code Red）」。
    - **官方新聞稿：** Microsoft and OpenAI extend partnership.
    - [https://blogs.microsoft.com/blog/2023/01/23/microsoftandopenaiextendpartnership/](https://blogs.microsoft.com/blog/2023/01/23/microsoftandopenaiextendpartnership/)
- **2023 年 3 月 OpenAI 發布** **GPT-4**
    - 具備多模態能力（看圖說故事）與強大的邏輯推理，被視為接近 AGI（通用人工智慧）的里程碑。
    - [https://openai.com/zh-Hant/index/gpt-4-research/](https://openai.com/zh-Hant/index/gpt-4-research/)

**開源浪潮與 Agent 的萌芽 (2023 中 - 2023 底)**

- **2022 年 10 月 ReAct 框架的提出 (Agent 的起點)**
    - 由 Google Research 和普林斯頓大學提出的 **ReAct（Reason and Act）論文**，是 LLM Agent 最核心的運作邏輯起點。
    - 過去的 LLM 只能一問一答。ReAct 首次讓模型學會**「思考（Thought）→ 行動（Action）→ 觀察（Observation）」**的循環迴路。
    - [https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)
    - [https://research.google/blog/react-synergizing-reasoning-and-acting-in-language-models/](https://research.google/blog/react-synergizing-reasoning-and-acting-in-language-models/)
- **2023 年 2 月 Meta 發佈 Llama (65B LLM)，(開源模型的起點)**
    - 隨後由於模型權重外洩，引發了開源界的「Linux 時刻」，Meta 之後也將模型開源
    - 科技業開始出現大量本地化、私有化的輕量級模型。
    - [https://ai.meta.com/blog/large-language-model-llama-meta-ai/](https://ai.meta.com/blog/large-language-model-llama-meta-ai/)
- **2023 年 2 月 Anthropic 發佈 Claude**
    - 專門針對 Coding 優化的 LLM。
    - [https://www.anthropic.com/news/introducing-claude](https://www.anthropic.com/news/introducing-claude)
- **2023 年 3 月 Auto-GPT 與 BabyAGI 的爆紅**
    - 這是 **Agent（智慧體）** 概念的集體爆發。
    - 開發者發現可以讓 LLM 進行自我循環、規劃步驟並調用外部工具（如 Google 搜尋、執行代碼）。
    - [https://github.com/Significant-Gravitas/AutoGPT](https://github.com/Significant-Gravitas/AutoGPT)
- **2023 年 5: Function Calling (OpenAI)**
    - 官方正式支援 LLM 調用外部 API，這標誌著 LLM 從「大腦」轉化為「操作系統」。
    - [https://openai.com/index/function-calling-and-other-api-updates/](https://openai.com/index/function-calling-and-other-api-updates/)
- **2023 年 12 月: Google 發布 Gemini:**
    - [https://blog.google/innovation-and-ai/technology/ai/google-gemini-ai/#sundar-note](https://blog.google/innovation-and-ai/technology/ai/google-gemini-ai/#sundar-note)

**推理革命、Agentic Workflow (2024 年)**

- **2024.03: Devin (第一個 AI 工程師 Agent)**
    - **官方公告：** Introducing Devin, the first AI software engineer.
    - **連結：** [https://cognition.ai/blog/introducing-devin](https://cognition.ai/blog/introducing-devin)
- **2024.04: Llama 3 (早期開源巔峰)**
    - **官方公告：** Meta Llama 3: The most capable openly available LLM to date.
    - **連結：** [https://ai.meta.com/blog/meta-llama-3/](https://ai.meta.com/blog/meta-llama-3/)
- **2024.09: OpenAI o1 (推理模型)**
    - **官方公告：** Learning to Reason with LLMs (o1-preview).
    - **連結：** [https://openai.com/zh-Hant/index/learning-to-reason-with-llms/](https://openai.com/zh-Hant/index/learning-to-reason-with-llms/)
- **2024.10: Claude Computer Use (Agent 直接操控電腦)**
    - **官方公告：** Introducing computer use, a new Claude 3.5 Sonnet, and Claude 3.5 Haiku.
    - **連結：** [https://www.anthropic.com/news/3-5-models-and-computer-use](https://www.anthropic.com/news/3-5-models-and-computer-use)

**深度思考與中國開源模型崛起  (2024 - 2025)**

- **2024 年 12 月 - 2025 年 1 月：DeepSeek-V3 與 R1 的震撼**
    - **DeepSeek** 發佈 **DeepSeek-R1**。
    - R1 證明了透過「強化學習」能以極低成本達成超越 GPT-4 的推理能力。這導致矽谷算力焦慮緩解，投資重心從「燒錢買卡」轉向「算法效率」。
    - [https://github.com/deepseek-ai/DeepSeek-R1/blob/main/DeepSeek_R1.pdf](https://github.com/deepseek-ai/DeepSeek-R1/blob/main/DeepSeek_R1.pdf)
- **2025 年 7 月：Qwen 3.0 與矽谷的「去 OpenAI 化」**
    - 阿里巴巴發佈 **Qwen 3** 系列。
    - Qwen 3 在編碼與數學能力上全面超越 Llama 3。由於其 API 成本僅為 OpenAI 的 1/10，大量矽谷新創公司（如 Perplexity, Vercel）開始在後端大規模切換至 Qwen 模型。
    - [https://qwen.ai/blog?id=qwen3](https://qwen.ai/blog?id=qwen3)
- **2025.07.09: Grok 4 正式推出**
    - Elon Musk 宣佈跳過 3.5 直接發佈 Grok 4。該模型被稱為「全能代理人（Omni-Agent）」，原生整合了工具調用與長達 100 萬 token 的上下文。
    - 其 **Grok 4 Heavy** 版本採用了多 Agent 架構，內部會自動分配子任務給專門的微型模型處理。
    - [https://x.ai/news/grok-4](https://x.ai/news/grok-4)
- **2026 年 2 月: Qwen 3.5 發佈**
    - 第一個 **原生多模態代理模型 (Native Multimodal Agent)**，不再是透過外部插件看圖，而是將視覺與語言在預訓練階段深度融合，處理複雜 UI 操控的能力大幅提升。
    - [https://qwen.ai/blog?id=qwen3.5](https://qwen.ai/blog?id=qwen3.5)
- **2026 年 6月 Claude Fable 5 的誕生**
    - **Fable 5** 被業界定義為首個 **Mythos（神話）級模型**。
    - **技術定義：** 「Mythos」級模型具備超長程邏輯鏈（Reasoning Horizon 可達數月），並擁有「世界模擬」能力，能同時操控數萬個子 Agent 進行複雜專案。
    - **科技業衝擊：** 許多矽谷公司裁撤了中層管理職，轉而由一個 Fable 5 模型帶領無數個 Qwen 或 DeepSeek 子 Agent 運行整個產品線。
    - [https://www.anthropic.com/news/claude-fable-5-mythos-5](https://www.anthropic.com/news/claude-fable-5-mythos-5)

**Multi-Agent Framework 與協議標準化 (2025 - 2026 初)**

- **2024 年 11 月: Claude MCP (Model Context Protocol)**
    - Anthropic 推出的開源協議，它讓 AI 像插上 USB 一樣，無縫連結不同的資料來源（Google Drive, Slack, GitHub）能以統一格式與模型對接，讓「AI 跨軟體操作」成為可能。
    - [https://www.anthropic.com/news/model-context-protocol](https://www.anthropic.com/news/model-context-protocol)
- **2025 年 4 月 : Google A2A (Agent-to-Agent) 通訊協議**
    - Google 於 I/O 大會發表 **A2A 通訊協議**
    - Google 推出的標準，讓 Vertex AI 上的代理人可以互相發現、授權並協作。
    - 例如，你的「行程代理人」會自動找「預算代理人」核准機票費用。
    - [https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/)
- **2025 年 10 月 ： Anthorpic Agent Skills**
    - Anthropic 推出 **Agent Skills**（模組化技能包
    - 開發者可以像下載 App 一樣給 Agent 安裝「Skills」（例如：法律審核技能、Excel 深度分析技能）。
    - [https://anthropic.skilljar.com/introduction-to-agent-skills](https://anthropic.skilljar.com/introduction-to-agent-skills)
- **2026 年 2月： Nanobots (Nano-Agent)**
    - 開源社群推出輕量級的多 Agent Framework **Nanobots**
    - Nanobots 實現了在瀏覽器端本地運行微型多 Agent 系統。
    - [https://github.com/HKUDS/nanobot](https://github.com/HKUDS/nanobot)

**AI 原生生產力工具的全面革新 (2025-2026)**

- **2025 年 2-3 月：ClaudeCode 與 OpenCode**
    - Anthropic 發佈 **ClaudeCode**（AI 原生 IDE）；開源社群發起 **OpenCode** 專案。
    - 工程師不再寫代碼，而是透過「對話」引導 ClaudeCode 自動重構整個系統架構。軟體開發效率提升了 20 倍，引發了矽谷初級工程師的職位轉型。
    - [https://claude.com/blog/category/claude-code](https://claude.com/blog/category/claude-code)
    - [https://opencode.ai/zht](https://opencode.ai/zht)
- **2025 年 5 月：DeepWiki (自主知識庫)**
    - 由  Cognition AI 推出的 **DeepWiki** (發布 AI 工程師 DevinAI 的團隊）)。
    - DeepWiki 的核心功能是程式碼庫的自主知識化。它能將 GitHub 上的程式碼倉庫（Repo）自動轉化為可對話的維基百科式文檔，並生成架構圖，幫助開發者快速理解複雜的程式碼結構。
    - [https://cognition.ai/blog/deepwiki](https://cognition.ai/blog/deepwiki)
- **2026 年 3 月：Claude Cowork**
    - Anthropic 推出的協作平台。
    - 這是 Anthropic 邁向「Agentic AI」的重要產品。它不再只是聊天機器人，而是能直接在電腦上執行多步驟任務的 「虛擬員工」。它可以處理文件管理、瀏覽器操作、整理跨應用程式的數據，並支援自動化任務（Scheduled Tasks）。
    - [https://claude.com/product/cowork](https://claude.com/product/cowork)
- **2026 年 4 月：Claude Design**
    - Anthropic 推出的 UI/UX 設計產品。
    - 這是一個專門針對視覺與 UI/UX 工作流的產品。它讓用戶能透過與 Claude 的對話，直接生成精美的 UI 原型、投影片 (Slides)、登陸頁面 (Landing Pages) 以及各種視覺 Artifacts，並能無縫銜接到 Claude Code 進行工程實作。
    - [https://www.anthropic.com/news/claude-design-anthropic-labs](https://www.anthropic.com/news/claude-design-anthropic-labs)
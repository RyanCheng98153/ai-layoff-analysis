# 1. 安裝並載入必要的套件
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)
library(lubridate)

# 2. 讀取資料 (假設檔案名稱為 Cleaned_tech_layoffs.csv)
# 注意：請確保檔案路徑正確
df <- read.csv("./src/data/Cleaned_tech_layoffs.csv", stringsAsFactors = FALSE)

# 3. 資料清洗與轉換
df_clean <- df %>%
  # 轉換日期格式
  mutate(Date_layoffs = as.Date(Date_layoffs)) %>%
  # 提取年份與季度 (例如: "2023-Q1")
  mutate(Quarter = paste0(year(Date_layoffs), "-Q", quarter(Date_layoffs))) %>%
  # 過濾掉百分比為 NA 的資料 (若有的話)
  filter(!is.na(Percentage))

# 4. 按產業與季度計算平均裁員百分比
quarterly_industry_stats <- df_clean %>%
  group_by(Quarter, Industry) %>%
  summarise(
    avg_percentage = mean(Percentage, na.rm = TRUE),
    total_laid_off = sum(Laid_Off, na.rm = TRUE),
    company_count = n(),
    .groups = 'drop'
  ) %>%
  # 排序，讓時間軸正確
  arrange(Quarter)

# 5. 印出表格結果 (前 20 筆)
print("每季各產業裁員平均百分比統計：")
print(head(quarterly_industry_stats, 20))

# 6. 視覺化：產業裁員趨勢圖
# 由於產業眾多，我們先選取裁員次數最多的前幾大產業，圖表才不會太亂
top_industries <- df_clean %>%
  count(Industry, sort = TRUE) %>%
  top_n(8) %>%
  pull(Industry)

plot_data <- quarterly_industry_stats %>%
  filter(Industry %in% top_industries)

ggplot(plot_data, aes(x = Quarter, y = avg_percentage, group = Industry, color = Industry)) +
  geom_line(size = 1) +
  geom_point() +
  # 標註 AI 時代的關鍵轉折點：ChatGPT 發布 (2022-Q4)
  geom_vline(xintercept = "2022-Q4", linetype = "dashed", color = "red", alpha = 0.7) +
  annotate("text", x = "2022-Q4", y = 80, label = "ChatGPT Launch", color = "red", angle = 90, vjust = -0.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "AI 時代前後：各大產業每季平均裁員百分比趨勢",
    subtitle = "虛線標示 2022-Q4 ChatGPT 發表時點",
    x = "季度",
    y = "平均裁員百分比 (%)",
    color = "子產業"
  )

# 儲存圖表
ggsave("./output/industry_layoff_trends.png", width = 12, height = 8)
# ==========================================
# 1. 環境設定與套件載入
# ==========================================
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("stringdist")) install.packages("stringdist")
if (!require("ggpubr")) install.packages("ggpubr")

library(tidyverse)
library(stringdist)
library(ggpubr)

# 確保輸出目錄存在
if (!dir.exists("./output")) dir.create("./output")

# ==========================================
# 2. 定義輔助函數
# ==========================================

# A. 計算 95% 信賴區間的函數
calc_ci <- function(x) {
  x <- x[is.finite(x)] # 排除 NA 與 Inf
  if(length(x) < 2) {
    m <- ifelse(length(x) == 0, NA, mean(x))
    return(data.frame(mean = m, lower = m, upper = m))
  }
  se <- sd(x) / sqrt(length(x))
  mean_val <- mean(x)
  data.frame(mean = mean_val, lower = mean_val - 1.96 * se, upper = mean_val + 1.96 * se)
}

# B. 安全計算相關係數函數 (防止資料不足報錯)
calc_stats_safe <- function(sub_df) {
  sub_df <- sub_df %>% filter(!is.na(ai_mean), !is.na(layoff_mean))
  # 至少需要 3 個資料點且數值必須有變動 (sd > 0)
  if (nrow(sub_df) >= 3 && sd(sub_df$ai_mean) > 0 && sd(sub_df$layoff_mean) > 0) {
    p_test <- cor.test(sub_df$ai_mean, sub_df$layoff_mean, method = "pearson")
    s_cor  <- cor(sub_df$ai_mean, sub_df$layoff_mean, method = "spearman")
    return(data.frame(
      pearson_r = p_test$estimate,
      spearman_r = s_cor,
      p_val = p_test$p.value
    ))
  } else {
    return(data.frame(pearson_r = NA, spearman_r = NA, p_val = NA))
  }
}

# ==========================================
# 3. 資料讀取與清洗
# ==========================================
ai_data <- read.csv("./src/data/ai-adoption-fortune500-synthetic-dataset-2020-2025.csv")
layoff_data <- read.csv("./src/data/Cleaned_tech_layoffs.csv")

# A. AI 資料清洗
ai_clean <- ai_data %>%
  mutate(
    Uses_AI_Num = ifelse(Uses_AI == "Yes", 100, 0),
    Industry = str_trim(Industry)
  )

# B. 裁員資料清洗與產業名稱對齊 (Fuzzy Match 手動輔助)
layoff_clean <- layoff_data %>%
  filter(!is.na(Percentage)) %>%
  mutate(
    Industry = str_trim(Industry),
    # 根據你的觀察手動強制對齊
    Industry = case_when(
      Industry == "e-commerce" ~ "E-commerce",
      Industry == "Logistic" ~ "Logistics",
      TRUE ~ Industry
    )
  )

# ==========================================
# 4. 分析一：個別產業相關性 (N 宮格圖)
# ==========================================

# 聚合 AI 數據
ai_ind_stats <- ai_clean %>%
  group_by(Industry, Year) %>%
  summarise(res = list(calc_ci(Uses_AI_Num)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(ai_mean = mean, ai_low = lower, ai_up = upper)

# 聚合 Layoff 數據
layoff_ind_stats <- layoff_clean %>%
  group_by(Industry, Year) %>%
  summarise(res = list(calc_ci(Percentage)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(layoff_mean = mean, layoff_low = lower, layoff_up = upper)

# 合併
ind_combined <- inner_join(ai_ind_stats, layoff_ind_stats, by = c("Industry", "Year"))

# 計算統計標籤
ind_stats_labels <- ind_combined %>%
  group_by(Industry) %>%
  do(calc_stats_safe(.)) %>%
  ungroup() %>%
  mutate(label = ifelse(is.na(pearson_r), 
                        "Insufficient Data",
                        sprintf("Pearson r: %.2f\nSpearman r: %.2f\nP: %.3f", 
                                pearson_r, spearman_r, p_val)))

# 繪製 N 宮格圖
p1 <- ggplot(ind_combined %>% left_join(ind_stats_labels, by="Industry"), aes(x = Year)) +
  geom_ribbon(aes(ymin = ai_low, ymax = ai_up, fill = "AI Adoption CI"), alpha = 0.2) +
  geom_line(aes(y = ai_mean, color = "AI Adoption Mean"), size = 1) +
  geom_ribbon(aes(ymin = layoff_low, ymax = layoff_up, fill = "Layoff Rate CI"), alpha = 0.2) +
  geom_line(aes(y = layoff_mean, color = "Layoff Rate Mean"), size = 1) +
  facet_wrap(~Industry, scales = "free_y") +
  geom_text(aes(x = -Inf, y = Inf, label = label), 
            hjust = -0.05, vjust = 1.2, size = 2.8, inherit.aes = FALSE, check_overlap = TRUE) +
  scale_fill_manual(values = c("AI Adoption CI" = "#377eb8", "Layoff CI" = "#e41a1c")) +
  scale_color_manual(values = c("AI Adoption Mean" = "#377eb8", "Layoff Rate Mean" = "#e41a1c")) +
  labs(title = "AI Adoption vs. Layoff Rate by Industry (2020-2025)",
       subtitle = "Shaded areas represent 95% Confidence Intervals",
       y = "Percentage (%)", x = "Year") +
  theme_bw() +
  theme(legend.position = "bottom", strip.text = element_text(face="bold"))

print(p1)
ggsave("./output/Industry_Correlation_Analysis.png", p1, width = 15, height = 11, dpi = 300)

# ==========================================
# 5. 分析二：Real Data 每年平均趨勢 (整體相關性)
# ==========================================

# 過濾出 Real Data 並按年份平均
ai_real_overall <- ai_clean %>%
  filter(Company_Type == "Real") %>%
  group_by(Year) %>%
  summarise(res = list(calc_ci(Uses_AI_Num)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(ai_mean = mean, ai_low = lower, ai_up = upper)

# 裁員數據年度總平均
layoff_overall_stats <- layoff_clean %>%
  group_by(Year) %>%
  summarise(res = list(calc_ci(Percentage)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(layoff_mean = mean, layoff_low = lower, layoff_up = upper)

# 合併
overall_combined <- inner_join(ai_real_overall, layoff_overall_stats, by = "Year")

# 計算統計值
overall_p_cor <- cor.test(overall_combined$ai_mean, overall_combined$layoff_mean, method = "pearson")
overall_s_cor <- cor(overall_combined$ai_mean, overall_combined$layoff_mean, method = "spearman")

overall_stats_text <- sprintf(
  "Overall (Real Data Only):\nPearson R: %.2f (p=%.3f)\nSpearman R: %.2f",
  overall_p_cor$estimate, overall_p_cor$p.value, overall_s_cor
)

# 繪圖
p2 <- ggplot(overall_combined, aes(x = Year)) +
  geom_ribbon(aes(ymin = ai_low, ymax = ai_up, fill = "AI Adoption (Real) CI"), alpha = 0.2) +
  geom_line(aes(y = ai_mean, color = "AI Adoption (Real) Mean"), size = 1.5) +
  geom_point(aes(y = ai_mean, color = "AI Adoption (Real) Mean"), size = 3) +
  geom_ribbon(aes(ymin = layoff_low, ymax = layoff_up, fill = "Layoff Rate CI"), alpha = 0.2) +
  geom_line(aes(y = layoff_mean, color = "Layoff Rate Mean"), size = 1.5) +
  geom_point(aes(y = layoff_mean, color = "Layoff Rate Mean"), size = 3) +
  # 標註 ChatGPT 時間點
  geom_vline(xintercept = 2022.9, linetype = "dashed", color = "darkgreen") +
  annotate("text", x = 2022.7, y = max(overall_combined$ai_up, na.rm=T), 
           label = "ChatGPT Launch", color = "darkgreen", angle = 90, vjust = -0.5) +
  # 標註統計數值
  annotate("label", x = 2020.2, y = max(overall_combined$ai_up, na.rm=T), 
           label = overall_stats_text, hjust = 0, size = 4.5, fill = "white", alpha = 0.7) +
  scale_fill_manual(values = c("AI Adoption (Real) CI" = "#377eb8", "Layoff Rate CI" = "#e41a1c")) +
  scale_color_manual(values = c("AI Adoption (Real) Mean" = "#377eb8", "Layoff Rate Mean" = "#e41a1c")) +
  labs(title = "Global Trend: Real AI Adoption vs. Tech Layoffs",
       subtitle = "Aggregated from 120 verified real Fortune 500 records",
       y = "Percentage (%)", x = "Year") +
  theme_minimal() +
  theme(legend.position = "bottom", plot.title = element_text(size=16, face="bold"))

print(p2)
ggsave("./output/AI 採用 vs 裁員 by整體 real.png", p2, width = 10, height = 12, dpi = 300)

message("分析完成！圖檔已儲存於 ./output 資料夾。")
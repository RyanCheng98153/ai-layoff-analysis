# 載入必要的套件
library(tidyverse)
library(ggpubr)
library(gridExtra)
if (!require("stringdist")) install.packages("stringdist")
library(stringdist) # 用於模糊比對

# 0. 確保輸出目錄存在
if (!dir.exists("./output")) dir.create("./output")

# 1. 讀取資料
ai_data <- read.csv("./src/data/ai-adoption-fortune500-synthetic-dataset-2020-2025.csv")
layoff_data <- read.csv("./src/data/Cleaned_tech_layoffs.csv")

# 2. 資料清洗與標準化
# 標準化函數：轉小寫、去空格、去標點符號
clean_string <- function(x) {
  x %>% 
    str_to_lower() %>% 
    str_replace_all("[[:punct:]]", "") %>% 
    str_trim()
}

ai_clean <- ai_data %>%
  mutate(Uses_AI_Num = ifelse(Uses_AI == "Yes", 1, 0),
         Industry_Clean = clean_string(Industry))

layoff_clean <- layoff_data %>%
  filter(!is.na(Percentage)) %>%
  mutate(Industry_Clean = clean_string(Industry))

# 3. Fuzzy Matching 產業對齊
# 以 AI 資料的產業作為基準，去匹配 Layoff 的產業
ai_inds <- unique(ai_clean$Industry_Clean)
layoff_inds <- unique(layoff_clean$Industry_Clean)

# 建立映射表 (maxdist = 2 容許小誤差，如 Logistic vs Logistics)
matches <- stringdist::amatch(layoff_inds, ai_inds, maxDist = 2)
mapping_table <- data.frame(
  layoff_ind_clean = layoff_inds,
  ai_ind_clean = ai_inds[matches]
) %>% filter(!is.na(ai_ind_clean))

# 將對齊後的名稱帶回原始資料
# 我們統一使用 AI 資料集中的原始產業名稱作為顯示名稱
ind_display_name <- ai_clean %>% select(Industry, Industry_Clean) %>% distinct()

layoff_clean <- layoff_clean %>%
  inner_join(mapping_table, by = c("Industry_Clean" = "layoff_ind_clean")) %>%
  select(-Industry) %>%
  rename(Industry_Clean_Target = ai_ind_clean)

# 4. 定義計算信賴區間的函數
calc_ci <- function(x) {
  x <- x[is.finite(x)]
  if(length(x) < 2) return(data.frame(mean = mean(x, na.rm=T), lower = mean(x, na.rm=T), upper = mean(x, na.rm=T)))
  se <- sd(x) / sqrt(length(x))
  mean_val <- mean(x)
  data.frame(mean = mean_val, lower = mean_val - 1.96 * se, upper = mean_val + 1.96 * se)
}

# 5. 聚合資料
ai_stats <- ai_clean %>%
  group_by(Industry_Clean, Year) %>%
  summarise(res = list(calc_ci(Uses_AI_Num * 100)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(ai_mean = mean, ai_low = lower, ai_up = upper)

layoff_stats <- layoff_clean %>%
  group_by(Industry_Clean_Target, Year) %>%
  summarise(res = list(calc_ci(Percentage)), .groups = 'drop') %>%
  unnest(res) %>%
  rename(layoff_mean = mean, layoff_low = lower, layoff_up = upper)

# 6. 合併
combined_data <- inner_join(ai_stats, layoff_stats, 
                            by = c("Industry_Clean" = "Industry_Clean_Target", "Year")) %>%
  left_join(ind_display_name, by = "Industry_Clean")

# 7. 安全計算相關係數 (處理報錯核心)
calc_stats_safe <- function(df) {
  # 檢查是否有足夠的點且非數值全部相同（變異量不為0）
  if (nrow(df) >= 3 && sd(df$ai_mean) > 0 && sd(df$layoff_mean) > 0) {
    p_cor <- cor.test(df$ai_mean, df$layoff_mean, method = "pearson")
    s_cor <- cor(df$ai_mean, df$layoff_mean, method = "spearman")
    return(data.frame(
      pearson_r = p_cor$estimate,
      spearman_r = s_cor,
      p_val = p_cor$p.value
    ))
  } else {
    return(data.frame(pearson_r = NA, spearman_r = NA, p_val = NA))
  }
}

stats_labels <- combined_data %>%
  group_by(Industry) %>%
  do(calc_stats_safe(.)) %>%
  ungroup() %>%
  mutate(label = ifelse(is.na(pearson_r), 
                        "Insufficient data for correlation",
                        sprintf("Pearson: %.2f\nSpearman: %.2f\nP-value: %.3f", 
                                pearson_r, spearman_r, p_val)))

# 8. 繪圖
plot_df <- combined_data %>%
  left_join(stats_labels, by = "Industry")

final_combined_plot <- ggplot(plot_df, aes(x = Year)) +
  # AI Adoption 虛影與線
  geom_ribbon(aes(ymin = ai_low, ymax = ai_up, fill = "AI Adoption CI"), alpha = 0.2) +
  geom_line(aes(y = ai_mean, color = "AI Adoption Mean"), size = 1.2) +
  # Layoff 虛影與線
  geom_ribbon(aes(ymin = layoff_low, ymax = layoff_up, fill = "Layoff CI"), alpha = 0.2) +
  geom_line(aes(y = layoff_mean, color = "Layoff Rate Mean"), size = 1.2) +
  facet_wrap(~Industry, scales = "free_y") +
  # 統計數值標籤
  geom_text(data = stats_labels, aes(x = -Inf, y = Inf, label = label), 
            hjust = -0.1, vjust = 1.5, size = 3, inherit.aes = FALSE, check_overlap = TRUE) +
  scale_fill_manual(values = c("AI Adoption CI" = "#377eb8", "Layoff CI" = "#e41a1c")) +
  scale_color_manual(values = c("AI Adoption Mean" = "#377eb8", "Layoff Rate Mean" = "#e41a1c")) +
  labs(title = "AI Adoption vs. Layoff Rate by Industry (Fuzzy Matched)",
       subtitle = "Observed Trends with 95% Confidence Intervals",
       y = "Percentage (%)", x = "Year",
       color = "Metric", fill = "Confidence Interval") +
  theme_minimal() +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold", size = 10))

# 顯示與儲存
print(final_combined_plot)
ggsave("./output/AI 採用 vs 裁員 by產業.png", final_combined_plot, width = 14, height = 10, dpi = 300)
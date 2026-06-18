# 1. 環境設定與套件載入
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)
library(lubridate)

# 定義路徑
src_dir <- "./src/data/"
output_dir <- "./output/"
if (!dir.exists(output_dir)) dir.create(output_dir)

# 2. 讀取並清洗 AI 投資資料 (Entity: Total)
ai_invest_df <- read.csv(paste0(src_dir, "corporate-investment-in-artificial-intelligence-by-type.csv"), stringsAsFactors = FALSE) %>%
  filter(Entity == "Total", Year >= 2020 & Year <= 2025) %>%
  rename(AI_Investment = Global.corporate.investment.in.AI) %>%
  select(Year, AI_Investment)

# 3. 讀取並清洗 Layoff 資料
layoff_df <- read.csv(paste0(src_dir, "Cleaned_tech_layoffs.csv"), stringsAsFactors = FALSE) %>%
  filter(Year >= 2020 & Year <= 2025)

# 4. 計算產業年度指標 (Macro & Micro)
industry_year_stats <- layoff_df %>%
  group_by(Year, Industry) %>%
  summarise(
    Macro_Layoff_Rate = mean(Percentage, na.rm = TRUE),
    total_laid_off = sum(Laid_Off, na.rm = TRUE),
    total_size = sum(Company_Size_before_Layoffs, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(Micro_Layoff_Rate = (total_laid_off / total_size) * 100) %>%
  inner_join(ai_invest_df, by = "Year")

# 5. 建立核心統計函數：計算相關性並回傳格式化標籤
get_stat_labels <- function(df, target_var) {
  df %>%
    group_by(Industry) %>%
    filter(n() >= 3) %>%  # 至少需要3年數據做相關分析
    summarise(
      p_cor = cor(AI_Investment, get(target_var), method = "pearson"),
      p_val = cor.test(AI_Investment, get(target_var), method = "pearson")$p.value,
      s_cor = cor(AI_Investment, get(target_var), method = "spearman"),
      s_val = cor.test(AI_Investment, get(target_var), method = "spearman", exact=FALSE)$p.value,
      .groups = 'drop'
    ) %>%
    mutate(Stat_Label = paste0(
      Industry, "\n",
      "Pearson r: ", round(p_cor, 2), " (p=", round(p_val, 3), ")\n",
      "Spearman ρ: ", round(s_cor, 2), " (p=", round(s_val, 3), ")"
    ))
}

# 6. 生成 Macro 與 Micro 的標籤對照表
macro_labels <- get_stat_labels(industry_year_stats, "Macro_Layoff_Rate")
micro_labels <- get_stat_labels(industry_year_stats, "Micro_Layoff_Rate")

# 7. 準備繪圖資料 (選擇裁員次數最多的前 12 個產業)
top_industries <- layoff_df %>% count(Industry, sort = TRUE) %>% top_n(12) %>% pull(Industry)

# --- 繪製 Macro Layoff 圖表 ---
plot_macro <- industry_year_stats %>%
  filter(Industry %in% top_industries) %>%
  inner_join(select(macro_labels, Industry, Stat_Label), by = "Industry") %>%
  ggplot(aes(x = Year)) +
  # 正規化 AI 投資以便在同一張圖呈現趨勢
  geom_line(aes(y = AI_Investment / max(AI_Investment) * 50, color = "AI Investment (Scaled)"), linetype = "dashed", size = 0.8) +
  geom_line(aes(y = Macro_Layoff_Rate, color = "Macro Layoff Rate"), size = 1) +
  geom_point(aes(y = Macro_Layoff_Rate, color = "Macro Layoff Rate")) +
  facet_wrap(~Stat_Label, scales = "free_y") +
  theme_minimal(base_size = 10) +
  labs(title = "Macro Layoff Rate vs. AI Investment (2020-2025)",
       subtitle = "Subtitle includes Pearson (r) and Spearman (ρ) correlation with P-values",
       y = "Layoff % / AI Scaled", x = "Year", color = "Metric") +
  theme(strip.text = element_text(face = "bold", size = 9),
        legend.position = "bottom")

# --- 繪製 Micro Layoff 圖表 ---
plot_micro <- industry_year_stats %>%
  filter(Industry %in% top_industries) %>%
  inner_join(select(micro_labels, Industry, Stat_Label), by = "Industry") %>%
  ggplot(aes(x = Year)) +
  geom_line(aes(y = AI_Investment / max(AI_Investment) * 10, color = "AI Investment (Scaled)"), linetype = "dashed", size = 0.8) +
  geom_line(aes(y = Micro_Layoff_Rate, color = "Micro Layoff Rate"), size = 1) +
  geom_point(aes(y = Micro_Layoff_Rate, color = "Micro Layoff Rate")) +
  facet_wrap(~Stat_Label, scales = "free_y") +
  theme_minimal(base_size = 10) +
  labs(title = "Micro Layoff Rate vs. AI Investment (2020-2025)",
       subtitle = "Subtitle includes Pearson (r) and Spearman (ρ) correlation with P-values",
       y = "Layoff % / AI Scaled", x = "Year", color = "Metric") +
  theme(strip.text = element_text(face = "bold", size = 9),
        legend.position = "bottom")

# 8. 儲存與顯示結果
ggsave(paste0(output_dir, "產業 AI 投資 vs 產業公司平均裁員比 macro.png"), plot_macro, width = 14, height = 10)
ggsave(paste0(output_dir, "產業 AI 投資 vs 產業總平均裁員比 micro.png"), plot_micro, width = 14, height = 10)

# 印出文字版統計表格供參考
print("產業相關性統計摘要 (Macro):")
print(macro_labels %>% select(-Stat_Label))
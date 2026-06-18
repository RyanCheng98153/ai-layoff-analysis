# 1. 環境設定與套件載入
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggpubr")) install.packages("ggpubr") # 用於排版統計文字
library(tidyverse)
library(lubridate)
library(ggpubr)

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

# 4. 計算全行業年度總體指標 (Macro & Micro)
# 注意：這裡不再 group_by Industry
overall_annual_stats <- layoff_df %>%
  group_by(Year) %>%
  summarise(
    # 全行業 Macro: 所有公司裁員百分比的簡單平均
    Macro_Layoff_Overall = mean(Percentage, na.rm = TRUE),
    # 全行業 Micro: 所有公司裁員總人數 / 所有公司總規模
    total_laid_off = sum(Laid_Off, na.rm = TRUE),
    total_size = sum(Company_Size_before_Layoffs, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(Micro_Layoff_Overall = (total_laid_off / total_size) * 100) %>%
  inner_join(ai_invest_df, by = "Year")

# 5. 計算統計量 (Macro & Micro)
calc_overall_stats <- function(df, target_var) {
  p_test <- cor.test(df$AI_Investment, df[[target_var]], method = "pearson")
  s_test <- cor.test(df$AI_Investment, df[[target_var]], method = "spearman", exact = FALSE)
  
  return(list(
    pr = p_test$estimate, pp = p_test$p.value,
    sr = s_test$estimate, sp = s_test$p.value
  ))
}

macro_res <- calc_overall_stats(overall_annual_stats, "Macro_Layoff_Overall")
micro_res <- calc_overall_stats(overall_annual_stats, "Micro_Layoff_Overall")

# 6. 視覺化：全行業趨勢對照圖
# 定義一個雙 Y 軸繪圖函數
create_overall_plot <- function(df, target_var, res, title, color_theme) {
  # 為了讓 AI 投資與裁員比能在同圖呈現，進行正規化處理
  scale_factor <- max(df[[target_var]], na.rm=T) / max(df$AI_Investment)
  
  ggplot(df, aes(x = Year)) +
    # AI 投資區域圖 (背景)
    geom_area(aes(y = AI_Investment * scale_factor), fill = "grey90", alpha = 0.5) +
    # 裁員比例線
    geom_line(aes(y = get(target_var)), color = color_theme, size = 1.5) +
    geom_point(aes(y = get(target_var)), color = color_theme, size = 3) +
    theme_minimal(base_size = 12) +
    labs(
      title = title,
      subtitle = sprintf("Stats: [Pearson r:%.2f, p:%.3f] [Spearman ρ:%.2f, p:%.3f]", 
                         res$pr, res$pp, res$sr, res$sp),
      caption = "灰色區域: AI Annual Total Investment (Scaled)\nPr: Pearson, Sr: Spearman",
      y = "Layoff Rate (%)",
      x = "Year"
    ) +
    theme(plot.title = element_text(face="bold"),
          plot.subtitle = element_text(color="blue", face="italic"))
}

plot_macro_overall <- create_overall_plot(overall_annual_stats, "Macro_Layoff_Overall", 
                                          macro_res, "Overall Macro Layoff Rate vs. AI Investment", "darkred")

plot_micro_overall <- create_overall_plot(overall_annual_stats, "Micro_Layoff_Overall", 
                                          micro_res, "Overall Micro Layoff Rate vs. AI Investment", "darkblue")

# 7. 儲存結果
ggsave(paste0(output_dir, "AI 投資 vs 裁員 macro.png"), plot_macro_overall, width = 10, height = 6)
ggsave(paste0(output_dir, "AI 投資 vs 裁員 micro.png"), plot_micro_overall, width = 10, height = 6)

# 8. 印出數值結果
print("--- 全行業總體統計結果 ---")
cat(sprintf("Macro Layoff (平均比例): Pearson r=%.2f (p=%.3f), Spearman rho=%.2f (p=%.3f)\n", 
            macro_res$pr, macro_res$pp, macro_res$sr, macro_res$sp))
cat(sprintf("Micro Layoff (總數加權): Pearson r=%.2f (p=%.3f), Spearman rho=%.2f (p=%.3f)\n", 
            micro_res$pr, micro_res$pp, micro_res$sr, micro_res$sp))
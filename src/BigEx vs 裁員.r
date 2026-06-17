# 載入必要套件
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

# 1. 讀取資料
# 注意：根據你提供的 CSV 內容，處理編碼與欄位
financials <- read_csv("data/Fed/Big4_Tech_Financials_Quarterly_Est.csv", locale = locale(encoding = "UTF-8"))
layoffs <- read_csv("data/tech-layoffs-2020-2024/Cleaned_tech_layoffs.csv", locale = locale(encoding = "UTF-8"))

# 2. 處理裁員資料：將日期轉換為年度與季度
layoffs_clean <- layoffs %>%
  mutate(Date_layoffs = as.Date(Date_layoffs)) %>%
  mutate(
    Year = as.numeric(format(Date_layoffs, "%Y")),
    Month = as.numeric(format(Date_layoffs, "%m")),
    # 將月份轉換為季度，格式需與財務表一致 (Q1, Q2, Q3, Q4)
    Quarter_Ref = case_when(
      Month %in% 1:3 ~ "Q1 (1-3月)",
      Month %in% 4:6 ~ "Q2 (4-6月)",
      Month %in% 7:9 ~ "Q3 (7-9月)",
      Month %in% 10:12 ~ "Q4 (10-12月)"
    )
  ) %>%
  # 彙整每季的總裁員人數
  group_by(Year, Quarter_Ref) %>%
  summarise(Total_Laid_Off = sum(Laid_Off, na.rm = TRUE), .groups = 'drop')

# 3. 處理財務資料：彙整 Big 4 每一季的總資本支出 (CapEx)
# 因為裁員資料包含整個科技業，我們用 Big 4 的總 CapEx 代表整體 AI 投入趨勢
financials_agg <- financials %>%
  group_by(Year, Quarter) %>%
  summarise(Total_CapEx = sum(CapEx_B_USD, na.rm = TRUE), .groups = 'drop')

# 4. 合併兩份資料 (Inner Join)
# 只保留兩份資料都有的時間段
analysis_data <- financials_agg %>%
  inner_join(layoffs_clean, by = c("Year" = "Year", "Quarter" = "Quarter_Ref")) %>%
  arrange(Year, Quarter)

# 檢視合併後的資料
print("合併後的分析資料：")
print(head(analysis_data))
# 把 analysis_data 存到 CSV 以便後續分析或檢查
write_csv(analysis_data, "./output/BigEx vs 裁員.csv")

# 5. 進行相關性分析 (Spearman Correlation)
# 我們分析 Total_CapEx (AI 投入 proxy) 與 Total_Laid_Off (裁員) 的相關性
spearman_result <- cor.test(analysis_data$Total_CapEx, 
                            analysis_data$Total_Laid_Off, 
                            method = "spearman", 
                            exact = FALSE)

# 6. 輸出結果
cat("\n--- Spearman 相關性分析結果 ---\n")
cat("Spearman 相關係數 (rho):", spearman_result$estimate, "\n")
cat("P-value:", spearman_result$p.value, "\n")

# 7. 解釋結果
if(spearman_result$p.value < 0.05) {
  cat("結論：在 0.05 顯著水準下，兩者具有顯著相關性。\n")
} else {
  cat("結論：P-value > 0.05，統計上未達到顯著相關。\n")
}

# 8. 簡單視覺化
ggplot(analysis_data, aes(x = Total_CapEx, y = Total_Laid_Off)) +
  geom_point(aes(color = as.factor(Year)), size = 3) +
  geom_smooth(method = "lm", color = "red", se = FALSE, linetype = "dashed") +
  labs(title = "AI 投入 (Big 4 CapEx) 與科技業裁員人數相關性",
       subtitle = paste("Spearman rho:", round(spearman_result$estimate, 3), " P-value:", round(spearman_result$p.value, 4)),
       x = "Big 4 總資本支出 (十億美元)",
       y = "科技業總裁員人數",
       color = "年度") +
  theme_minimal()

# 儲存圖表
ggsave("output/BigEx vs 裁員.png", width = 10, height = 6)
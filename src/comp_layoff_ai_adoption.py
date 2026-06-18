import pandas as pd
from thefuzz import fuzz
from thefuzz import process

def fuzzy_matcher(list_a, list_b, threshold=85):
    """
    執行模糊匹配並回傳對照表
    list_a: 來源列表 (Layoff 資料)
    list_b: 目標列表 (AI 資料)
    """
    matches = []
    for item in list_a:
        # 找到最接近的匹配項，回傳 (名稱, 分數)
        match, score = process.extractOne(item, list_b, scorer=fuzz.token_sort_ratio)
        if score >= threshold:
            matches.append({'layoff_name': item, 'ai_adoption_name': match, 'similarity': score})
    return pd.DataFrame(matches)

# 1. 載入資料
# 假設檔案名稱如你所提供
ai_df = pd.read_csv('./src/data/ai-adoption-fortune500-synthetic-dataset-2020-2025.csv')
layoff_df = pd.read_csv('./src/data/Cleaned_tech_layoffs.csv')

# 2. 基本清洗 (去空格、統一格式)
ai_df['Company'] = ai_df['Company'].str.strip()
ai_df['Industry'] = ai_df['Industry'].str.strip()
layoff_df['Company'] = layoff_df['Company'].str.strip()
layoff_df['Industry'] = layoff_df['Industry'].str.strip()

# 標記 Real 資料 (根據 Company_Type 欄位)
real_ai_companies = ai_df[ai_df['Company_Type'] == 'Real']['Company'].unique()
real_ai_industries = ai_df[ai_df['Company_Type'] == 'Real']['Industry'].unique()

# --- 公司 (Company) 分析 ---
unique_layoff_companies = layoff_df['Company'].unique()
unique_ai_companies = ai_df['Company'].unique()

print("--- Company Statistics ---")
print(f"Unique Companies in Layoff Data: {len(unique_layoff_companies)}")
print(f"Unique Companies in AI Adoption Data: {len(unique_ai_companies)}")

# 執行模糊匹配 (門檻設為 85)
company_match_df = fuzzy_matcher(unique_layoff_companies, unique_ai_companies, threshold=85)

# 判斷是否為 Real 資料
company_match_df['is_real_data'] = company_match_df['ai_adoption_name'].isin(real_ai_companies)

# 輸出結果
company_match_df.to_csv('output/overlap_company.csv', index=False)
overlap_count = len(company_match_df)
real_overlap_count = company_match_df['is_real_data'].sum()

print(f"Overlap Company count (Fuzzy): {overlap_count}")
print(f"Overlap Company in 'Real Data': {real_overlap_count}")
print("Results saved to 'overlap_company.csv'\n")


# --- 產業 (Industry) 分析 ---
unique_layoff_industries = layoff_df['Industry'].dropna().unique()
unique_ai_industries = ai_df['Industry'].unique()

print("--- Industry Statistics ---")
print(f"Unique Industries in Layoff Data: {len(unique_layoff_industries)}")
print(f"Unique Industries in AI Adoption Data: {len(unique_ai_industries)}")

# 執行模糊匹配 (產業名稱通常較短，門檻可稍微調整或保持 85)
industry_match_df = fuzzy_matcher(unique_layoff_industries, unique_ai_industries, threshold=80)

# 判斷是否出現在 Real 資料中
industry_match_df['is_real_data'] = industry_match_df['ai_adoption_name'].isin(real_ai_industries)

# 輸出結果
industry_match_df.to_csv('output/overlap_industry.csv', index=False)
ind_overlap_count = len(industry_match_df)
ind_real_overlap_count = industry_match_df['is_real_data'].sum()

print(f"Overlap Industry count (Fuzzy): {ind_overlap_count}")
print(f"Overlap Industry in 'Real Data': {ind_real_overlap_count}")
print("Results saved to 'output/overlap_industry.csv'")
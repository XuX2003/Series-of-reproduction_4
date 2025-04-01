# 载入包和data
library(lavaan)   # 载入lavaan包
library(semPlot) # 绘图包
library(psych)  # 用于信度检验和因子分析等功能
library(readxl) # 用于读取excel数据

## （更改1）注意修改路径/表单/范围
total_data <- read_excel("D:/桌面/total_data.xlsx", 
                         sheet = "总数据", range = "L2:AL1833")
View(total_data)

## 1. 使用Cronbach'α对量表进行信度检验，并打印出每个潜变量的Cronbach'α
# （更改2）定义潜变量及其对应的指标
latent_vars <- list(
  ERA = c("ERA1", "ERA2", "ERA3"),
  SAA = c("SAA1", "SAA2", "SAA3"),
  RAP = c("RAP1", "RAP2", "RAP3"),
  ERC = c("ERC1", "ERC2", "ERC3"),
  EAA = c("EAA1", "EAA2", "EAA3"),
  EAC = c("EAC1", "EAC2", "EAC3"),
  MIP = c("MIP1", "MIP2", "MIP3"),
  SEP = c("SEP1", "SEP2", "SEP3"),
  IPP = c("IPP1", "IPP2", "IPP3")
)

# 循环计算每个潜变量的Cronbach'α
for (lv in names(latent_vars)) {
  items <- latent_vars[[lv]]
  alpha_result <- alpha(total_data[, items])
  cat("潜变量", lv, "的Cronbach'α值为：", alpha_result$total$raw_alpha, "\n")
}

## 2. 采用主成分方法提取公因子方差，抽取一定数量的因子，且通过最大方差法对因子成分矩阵进行旋转，并打印出所选因子的公因子方差提取值
# 合并所有指标
all_items <- unlist(latent_vars)
# 进行主成分分析并提取公因子方差
# （更改3）修改提取的公因子数目：nfactors  根据需要来设定，文中为8
pc_factor <- principal(total_data[, all_items], nfactors = 8, rotate = "varimax")  # 这里假设抽取3个因子，可根据实际调整
# 打印公因子方差提取值
cat("公因子方差提取值：\n", pc_factor$communality, "\n")

# 分析旋转后的因子成分矩阵，依据因子聚类情况以及测量题项的内容，剔除代表性和解释性较差的因子
# 这里需要人工查看因子成分矩阵进行分析和剔除，由于无法自动判断，所以只展示如何查看矩阵
print("旋转后的因子成分矩阵：")
print(pc_factor$loadings)


## 3.（更改4）定义观测模型+路径模型
model <- '
  ERA =~ ERA1 + ERA2 + ERA3
  SAA =~ SAA1 + SAA2 + SAA3
  RAP =~ RAP1 + RAP2 + RAP3
  ERC =~ ERC1 + ERC2 + ERC3
  EAA =~ EAA1 + EAA2 + EAA3
  EAC =~ EAC1 + EAC2 + EAC3
  MIP =~ MIP1 + MIP2 + MIP3
  SEP =~ SEP1 + SEP2 + SEP3
  IPP =~ IPP1 + IPP2 + IPP3
  
  ERA ~ SAA + RAP
  IPP ~ SEP + MIP
'
## 4.验证性因子分析
# （更改5） data = your file name
cfa_result <- cfa(model, data = total_data)

# 检查潜变量协方差矩阵是否正定（使用特征值方法）
cov_lv <- lavInspect(cfa_result, "cov.lv")
eigen_values <- eigen(cov_lv, symmetric = TRUE, only.values = TRUE)$values
if (any(eigen_values <= 1e-8)) {
  ERAt("警告：潜变量协方差矩阵非正定，请检查模型设定或数据。\n")
  ERAt("潜变量协方差矩阵的特征值：", eigen_values, "\n")
  ERAt("潜变量协方差矩阵：\n")
  print(cov_lv)
}

# 提取标准化因子载荷
param_est <- parameterEstimates(cfa_result, standardized = TRUE)
std_loadings <- param_est[param_est$op == "=~", c("lhs", "rhs", "std.all")]
cat("\n标准化因子载荷：\n")
print(std_loadings)

# 计算AVE和CR的改进方法
ave_cr_results <- data.frame()
for (lv in names(latent_vars)) {
  items <- latent_vars[[lv]]
  
  # 获取当前潜变量的因子载荷
  loadings <- std_loadings[std_loadings$lhs == lv, "std.all"]
  if (length(loadings) == 0) {
    cat("潜变量", lv, "未找到因子载荷，请检查模型设定\n")
    next
  }
  
  # 获取残差方差（使用标准化解）
  residuals <- sapply(items, function(item) {
    res <- param_est[param_est$op == "~~" & param_est$lhs == item & param_est$rhs == item, "std.all"]
    ifelse(length(res) > 0, res, NA)
  })
  
  if (any(is.na(residuals))) {
    cat("潜变量", lv, "的某些残差方差缺失，跳过计算\n")
    next
  }
  
  # 计算指标
  sum_loadings_sq <- sum(loadings^2)
  sum_residuals <- sum(residuals)
  
  AVE <- sum_loadings_sq / (sum_loadings_sq + sum_residuals)
  CR <- (sum(loadings))^2 / ((sum(loadings))^2 + sum_residuals)
  
  ave_cr_results <- rbind(ave_cr_results,
                          data.frame(Latent_Variable = lv,
                                     AVE = round(AVE, 3),
                                     CR = round(CR, 3)))
}

cat("\n平均方差抽取值（AVE）和组合信度（CR）：\n")
print(ave_cr_results)


## 5.结构方程模型检验
# （更改6） data = your file name
fit <- sem(model, data = total_data)

# 输出模型摘要，包含拟合度指标
summary(fit, fit.measures = TRUE, standard = TRUE)

# 检验模型效果，添加更多拟合度指标
fit_measures <- fitMeasures(fit, c("chisq", "df", "pvalue",
                                   "gfi", "agfi", "nfi", "ifi", "cfi",
                                   "rmr", "srmr", "rmsea"))
# 计算 chi-square/df
fit_measures["chi_square_df"] <- fit_measures["chisq"] / fit_measures["df"]
print(fit_measures)

# 获取参数估计结果
param_estimates <- parameterEstimates(fit, standardized = TRUE)

# 筛选出路径假设的部分
path_hypotheses <- param_estimates[param_estimates$op == "~", ]

# 创建假设检验表
hypothesis_table <- data.frame(
  "假设索引" = 1:nrow(path_hypotheses),
  "路径" = paste(path_hypotheses$lhs, path_hypotheses$op, path_hypotheses$rhs),
  "标准化路径系数" = path_hypotheses$std.all,
  "P值" = path_hypotheses$pvalue,
  "结论" = ifelse(path_hypotheses$pvalue < 0.05, "成立", "不成立")
)

print(hypothesis_table)

# 作图
semPaths(fit, # 上面跑出来的数据模型
         what = "std", # 图中边的格式，#"path"，"std"，"est "，"cons "
         layout = "tree2", # 图的格式， tree  circle  spring  tree2  circle2
         fade = T, # 褪色，按照相关度褪色
         residuals = F ,# 残差/方差要不要体现在图中，可T和F
         nCharNodes = 0)
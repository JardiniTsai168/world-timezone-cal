# 🚀 GitHub Pages 部署指令

**給 lihi-coder 的快速部署指令**  
**預計時間**: 5 分鐘

---

## 📋 部署前確認

**正確資訊**:
- **GitHub 帳號**: `JardiniTsai168`
- **Repository**: `JardiniTsai168/world-timezone-cal`
- **目標 URL**: `https://JardiniTsai168.github.io/world-timezone-cal/`
- **Token**: 使用環境變數或設定在 remote URL 中

---

## 🎯 Step-by-Step 部署指令

### Step 1: 進入專案目錄

```bash
cd /Users/tonytsai/.openclaw/workspace-world-timezone-cal/world_timezone_cal
```

---

### Step 2: 確認/設定 GitHub Remote

**檢查目前 remote**:
```bash
git remote -v
```

**如果不是 `JardiniTsai168`，修正**:
```bash
git remote remove origin
git remote add origin https://<YOUR_TOKEN>@github.com/JardiniTsai168/world-timezone-cal.git
```

---

### Step 3: Build Web 版本

```bash
/Users/tonytsai/.openclaw/workspace-world-timezone-cal/flutter_sdk/bin/flutter build web --release
```

**預期輸出**:
```
✓ Built build/web
```

---

### Step 4: Commit + Push

```bash
# 添加所有檔案
git add .

# Commit
git commit -m "Deploy to GitHub Pages - MVP v1.0.0"

# Push 到正確 repo
git push -u origin main
```

**預期輸出**:
```
Enumerating objects: ...
Counting objects: 100% ...
Writing objects: 100% ...
To https://github.com/JardiniTsai168/world-timezone-cal.git
 * [new branch]      main -> main
```

---

### Step 5: 確認 GitHub Actions Workflow

**確認 workflow 檔案存在**:
```bash
ls -la .github/workflows/deploy.yml
```

**如果不存在，建立**:
```bash
mkdir -p .github/workflows
# 然後從 docs/DEPLOYMENT-GUIDE.md 複製 workflow 內容
```

**Commit + Push workflow**:
```bash
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions workflow"
git push origin main
```

---

### Step 6: 啟用 GitHub Pages

**自動啟用（推薦）**:

```bash
gh api repos/JardiniTsai168/world-timezone-cal/pages \
  --method POST \
  -f source[branch]=main \
  -f source[path]=/ \
  -f build_type=workflow
```

> 如果已啟用過，更新為 workflow 模式：
> ```bash
> gh api repos/JardiniTsai168/world-timezone-cal/pages \
>   --method PUT \
>   -f source[branch]=main \
>   -f source[path]=/ \
>   -f build_type=workflow
> ```

**（或手動操作）** 如果 gh CLI 不可用，手動前往：
```
https://github.com/JardiniTsai168/world-timezone-cal/settings/pages
```

設定：
1. **Source**: Deploy from a branch
2. **Branch**: `main`
3. **Folder**: `/ (root)`
4. 按 **Save**

---

### Step 7: 等待部署完成

**查看部署狀態**:
```
https://github.com/JardiniTsai168/world-timezone-cal/actions
```

**預期流程**:
1. Workflow 開始執行（約 3-5 分鐘）
2. Build Web
3. Upload artifact
4. Deploy to GitHub Pages
5. 顯示綠色 ✓

**完成後會看到**:
```
Your site is live at https://JardiniTsai168.github.io/world-timezone-cal/
```

---

### Step 8: 測試線上版本

**打開瀏覽器，前往**:
```
https://JardiniTsai168.github.io/world-timezone-cal/
```

**測試清單**:
- [ ] App 頁面正常載入
- [ ] 3 個 Tab 可以切換
- [ ] 點擊城市 → 選擇日期時間
- [ ] 時區同步計算正常
- [ ] 新增城市正常
- [ ] Dark Mode 切換正常

---

## 🔧 問題排查

### 確認 remote 正確

```bash
git remote -v
# 應該顯示:
# origin	https://github.com/JardiniTsai168/world-timezone-cal.git (fetch)
# origin	https://github.com/JardiniTsai168/world-timezone-cal.git (push)
```

### 確認 GitHub Pages 狀態

```bash
curl -s https://api.github.com/repos/JardiniTsai168/world-timezone-cal/pages
```

### 查看 Actions 日誌

```
https://github.com/JardiniTsai168/world-timezone-cal/actions
```

點擊最新的 workflow run 查看詳細日誌

### 強制重新部署

```bash
# 清空並重新 build
rm -rf build/web
flutter clean
flutter build web --release

# 強制 push
git add build/
git commit -m "Force rebuild web"
git push -f origin main
```

---

## 📊 成功標誌

✅ **部署成功的標誌**:

1. GitHub Actions 顯示綠色 ✓
2. Pages URL 顯示 `https://JardiniTsai168.github.io/world-timezone-cal/`
3. 瀏覽器打開頁面正常
4. 所有功能正常運作

---

## 🎯 一行檢查指令

**快速檢查所有狀態**:

```bash
cd /Users/tonytsai/.openclaw/workspace-world-timezone-cal/world_timezone_cal && \
echo "=== Git Remote ===" && git remote -v && \
echo "=== Git Branch ===" && git branch && \
echo "=== Build Status ===" && ls -la build/web/index.html && \
echo "=== GitHub Pages ===" && curl -s https://api.github.com/repos/JardiniTsai168/world-timezone-cal/pages | jq -r '.html_url // "Not enabled yet"'
```

---

## 🔗 重要連結

| 資源 | 連結 |
|------|------|
| GitHub Repo | https://github.com/JardiniTsai168/world-timezone-cal |
| GitHub Actions | https://github.com/JardiniTsai168/world-timezone-cal/actions |
| GitHub Pages Settings | https://github.com/JardiniTsai168/world-timezone-cal/settings/pages |
| 目標測試 URL | https://JardiniTsai168.github.io/world-timezone-cal/ |

---

## 😎 快速總結

**執行順序**:
1. `cd` 進入專案
2. 確認 remote 是 `JardiniTsai168`
3. `flutter build web --release`
4. `git add . && git commit -m "Deploy" && git push`
5. 手動啟用 Pages Settings（瀏覽器打開）
6. 等 3-5 分鐘 → 完成！

**完成後在頻道回報測試連結！** 🚀

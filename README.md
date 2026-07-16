# 長城分會・例會排位系統

單一檔案網頁應用(index.html),無需安裝、無需 build,開啟即用。
資料(會員名單、上週分桌紀錄、儲存的座位表)儲存在瀏覽器 localStorage。
座位圖可一鍵下載成 PNG 圖檔;「儲存紀錄」頁籤可瀏覽或刪除歷次存檔的座位表。

## 部署方式

### 方式 A:Netlify Drop(最快,免 Git、免帳號設定)
1. 開啟 https://app.netlify.com/drop
2. 把整個資料夾(含 index.html)拖進去
3. 完成,立即取得網址

### 方式 B:GitHub Pages
```bash
git init
git add .
git commit -m "feat: 長城分會例會排位系統 v1"
git branch -M main
git remote add origin https://github.com/<你的帳號>/greatwall-seating.git
git push -u origin main
```
然後到 GitHub Repo → Settings → Pages → Branch 選 main / root → Save,
約 1 分鐘後網址為 https://<你的帳號>.github.io/greatwall-seating/

### 方式 C:Vercel
```bash
npm i -g vercel
vercel --prod
```

## 注意事項
- 資料存在「該台裝置的該瀏覽器」,換裝置或清除瀏覽資料會遺失,建議固定由一台裝置管理排位。
- 若需多人共用同一份資料,再升級後端(如 Supabase / Google Sheets)即可,介面不用改。

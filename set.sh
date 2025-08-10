#!/bin/bash

# 腳本說明：
# 這個腳本會自動為一個新的 Octra CLI 項目創建文件夾，
# 設置代理 IP，並安裝所有必要的依賴和客戶端程序。

echo "--- Octra CLI 項目設置嚮導 ---"
echo ""

# 1. 詢問項目名稱
read -p "請輸入項目名稱（將作為文件夾名）： " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "錯誤：項目名稱不能為空！"
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    read -p "警告：文件夾 '$PROJECT_NAME' 已存在。是否要覆蓋？(y/N) " OVERWRITE_CHOICE
    if [[ ! "$OVERWRITE_CHOICE" =~ ^[Yy]$ ]]; then
        echo "操作已取消。"
        exit 0
    fi
    echo "正在移除現有文件夾..."
    rm -rf "$PROJECT_NAME"
fi

mkdir -p "$PROJECT_NAME"
if [ $? -ne 0 ]; then
    echo "錯誤：創建文件夾 '$PROJECT_NAME' 失敗！"
    exit 1
fi
echo "已成功創建項目文件夾： $PROJECT_NAME/"

# 2. 進入項目文件夾
cd "$PROJECT_NAME" || { echo "錯誤：無法進入文件夾 '$PROJECT_NAME'。"; exit 1; }

# 3. 安裝 Python 依賴
echo ""
echo "--- 正在安裝 Python 依賴 ---"
sudo apt update
sudo apt install python3 python3-pip python3-venv git -y
echo "Python 依賴安裝完成。"

# 4. 克隆 Octra CLI 倉庫並安裝
echo ""
echo "--- 正在克隆並安裝 Octra CLI ---"
git clone https://github.com/octra-labs/octra_pre_client.git
cd octra_pre_client || { echo "錯誤：無法進入 octra_pre_client 文件夾。"; exit 1; }

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo "Octra CLI 安裝完成。"

# 5. 創建 run_cli.sh 腳本
# 這個腳本將負責啟動 CLI 並設置代理
RUN_CLI_SCRIPT="run_cli.sh"
cat << EOF > "$RUN_CLI_SCRIPT"
#!/bin/bash

# 確保虛擬環境已啟用
source venv/bin/activate

# 運行 Octra CLI 主程序
# 程序會自動載入同文件夾下的 wallet.json
python3 cli.py
EOF

chmod +x "$RUN_CLI_SCRIPT"
echo "已在 './octra_pre_client/' 中創建 'run_cli.sh' 啟動腳本。"

# 7. 提醒用戶配置錢包
echo ""
echo "--- 設置完成！ ---"
echo "下一步，請執行以下操作來配置你的錢包："
echo "1. 進入 Octra CLI 的目錄："
echo "   cd octra_pre_client/"
echo "2. 複製錢包模板文件："
echo "   cp wallet.json.example wallet.json"
echo "3. 使用 nano 編輯 wallet.json 文件，將 'private-key-here' 和 'octxxxxxxxx...' 替換為你的錢包信息："
echo "   nano wallet.json"
echo "4. 完成後，使用以下命令運行 Octra CLI："
echo "   ./run_cli.sh"
echo ""


# 查找行号
declare -i Bnum
declare -i Enum
Bnum=$(grep -n "var a int " ./aa/temp.txt | cut -d ":" -f 1)
Enum=$(grep -n "return a " ./aa/temp.txt | cut -d ":" -f 1)
echo "Bnum=$Bnum"
echo "Enum=$Enum"

#删除
for ((i=$Bnum+1; i<=$Bnum+2; i++))
do
echo "i=$i"
   sed -i '' "$i"d ./aa/temp.txt
done

# 追加
sed -i '' "$Bnum a\ 
\\	req.ParseForm() \\
\\  \\
\\	if len(req.Form) > 0 { \\
\\	protoReq.Nonce = req.Form.Get(\"nonce\") \\
\\	protoReq.Signature = req.Form.Get(\"signature\") \\
\\	protoReq.Timestamp = req.Form.Get(\"timestamp\") \\
\\	} \\
\\  \\
\\	buf, err := ioutil.ReadAll(req.Body) \\
\\	fmt.Println(\"body\", string(buf), \"err\", err) \\
\\	users := []*User{} \\
\\	err = json.Unmarshal([]byte(buf), &users) \\
\\	fmt.Println(\"json err\", err)  \\
\\	protoReq.Users = users \\
\\	if  err != nil { 
" ./aa/temp.txt

#调试执行过程
sh -x ./t.sh 

# 权限可执行
chmod 777 t.sh

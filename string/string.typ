
#import "../env.typ": *
= 字符串
== KMP
#explain[
  流水的 BF，学不会的 KMP
]

如果是统计字符串的情况下，RK 算法更易于理解

值的一提的是， 
/ next[i-1]: 表示的是 $S_0, S_1, dots, S_(i-1)$ 中最长前后缀的长度
/ i - next[i-1]: 表示$S_0, S_1, dots, S_(i-1)$ 中最小循环节


```cpp
void get_next(const std::string &pattern, int next[]){
  int j = 0;
  next[0] = -1;
  for(int i = 0; i < pattern.size(); i++){
    j = next[i];
    while(j != -1 && pattern[i] != pattern[j]) j = next[j];
    next[i+1] = j + 1;
  }
}

int match(const std::string& string, const std::string& pattern){
  int j = 0, ans = -1;
  for(int i = 0; i < string.size(); i++){
    while(j != -1 && string[i] != pattern[j]) j = next[j];
    if(++j == pattern.size()) return i - pattern.size() + 1;
  }
  return -1;
}
```

== RK

基与哈希+滑动窗口的子字符匹配算法，思路简单好写

#strike[然而压根不是真正的 Hash]

#alert[别人卡你 modd]

```cpp
const int magic = 31, modd = 1e9 + 7;
int RK(const std::string& string, const std::string& pattern){
  int target_hash = 0;
  for(auto &ch: pattern) {
    target_hash *= magic;
    target_hash += ch;
    target_hash %= modd;
  }
  
  int current_hash = 0;
  for(int i = 0; i < pattern.size(); i++){
    current_hash *= magic;
    current_hash += string[i];
    current_hash %= modd;
  }
  for(int i = 0; i + pattern.size() < string.size(); i++){
    if(current_hash == target_hash){
      return i;
    }
    current_hash *= magic;
    current_hash -= int(string[i] * std::pow(magic, pattern.size())) % modd;
    current_hash += string[i + pattern.size()];
  }
  return -1;
}
```

== Manacher

在 $O(n)$ 的时间中求最长回文串

先用 `#` 填充字符串，奇偶则不用分开讨论。使用 `r[i]` 来描述以 `i` 为中心的最大回文串的长度。

#explain[

]

```cpp
const int maxn = 1.1e7;
char str[maxn];
int r[maxn];
int manacher(const std::string& s){
  int mx = 0, id = 0, ans = 0, cnt = 0;
  str[cnt++] = '$';
  str[cnt++] = '#';
  for(int i = 0; i < s.size(); i++){
    str[cnt++] = s[i];
    str[cnt++] = '#';
  }
  str[cnt] = '@';
  
  for(int i = 1; i < cnt; i++){
    r[i] = mx > i ? std::min(r[2 * id - l], mx - 1) : 1;
    while(str[i + r[i]] == str[i - r[i]]) r[i]++;
    if(mx < i + r[i]) mx = i + r[i], id = i;
    ans = std::max(ans, r[i] - 1);
  }
  return ans;
}

```

== 扩展 KMP (Z 函数)
#explain[
  和 KMP 一点关系也没有，不知道谁起的名字
]

#todo[]

== Tries

#todo[]

== AC 自动机

#todo[]
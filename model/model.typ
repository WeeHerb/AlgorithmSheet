#import "../env.typ": *

== 单调栈

#explain[
  这下例题了 #link("https://codeforces.com/contest/1828/problem/D2")[CF1828D2]
]
一种常见的模型,常用于找出每个数左边离它最近的比它大/小的数

```cpp
std::vector<int> stack;
for(int i = 1; i <= n; i++){
  if(!stack.empty() && check(stack.back(), i))
    stack.pop_back();
  stack.push_back(i);
}
```
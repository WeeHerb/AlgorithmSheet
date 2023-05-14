#import "../env.typ" : *
= 动态规划

== 01 背包
有 $N$ 件物品和一个容量为 $V$ 的背包。放入第 $i$ 件物品耗费的费用是 $C_i$，得到的价值是 $W_i$。求解将哪些物品装入背包可使价值总和最大

$ F[i,v] = max{F[i-1, v], F[i-1, v - C_i] + W_i} $

```cpp
int F[maxn][maxv] = {0};

for(int i = 1; i <= N; i++){
  for(int v = C[i]; v <= V; v++){
    F[i][v] = std::max(F[i-1][v], F[i-1][v - C[i]] + W[i]);
  }
}
```

滚动数组优化

#alert[
  $v$ 是从 $V arrow C[i]$ 逆序循环
]
```cpp
int F[maxv] = {0};

for(int i = 1; i <= N; i++){
  for(int v = V; v >= C[i]; v--){
    F[v] = std::max(F[v], F[v - C[i]] + W[i]);
  }
}
```

时间复杂度 $O(N V sum(V/C_i))$

- 要求恰好装满背包，那么在初始化时除了 $F[0]$ 为 $0$，其它 $F[1..V]$  均设为 $- infinity$，这样就可以保证最终得到的 $F[V]$ 是一种恰好装满背包的最优解。
- 没有要求必须把背包装满，而是只希望价格尽量大，初始化时应该将 $F[0..V]$ 全部设为 $0$



== 完全背包

有 $N$ 种物品和一个容量为 $V$ 的背包，每种物品都有无限件可用。放入第 $i$ 种物品的费用是 $C_i$，价值是 $W_i$。
求将哪些物品装入背包，可使这些物品的耗费的费用总和不超过背包容量，且价值总和最大。

$ F[i,v] = max_(0 <= k C_i <= v) {F[i-1, v-k C_i] + k C_i} $

等价变形为
$ F[i,v] = max(F[i-1, v], F[i， v - C_i] + W_i) $

#alert[
  $v$ 是从 $C[i] arrow V$ 正序循环
]
```cpp
int f[maxn];

for (int i = 1; i <= N; i++)
  for (int j = v[i]; j <= V; j++)
      f[j] = std::max(f[j], f[j - v[i]] + w[i]);
```
== 多重背包

有 $N$ 种物品和一个容量为 $V$ 的背包。第 $i$ 种物品最多有 $M_i$ 件可用，每件耗费的空间是 $C_i$，价值是 $W_i$。
求将哪些物品装入背包可使这些物品的耗费的空间总和不超过背包容量，且价值总和最大。

基本的方程只需将完全背包问题的方程略微一改即可


$ F[i,v] = max_(0 <= k <= M_i) {F[i-1, v-k C_i] + k C_i} $

```cpp
int f[maxn];

for (int i = 1; i <= N; i++)
  for (int j = V; j >= v[i]; j--)
    for(int k = 1; k <= s[i] && k * v[i] <= j; k++)
      f[j] = std::max(f[j], f[j - k* v[i]] + k*w[i]);
std::cout << f[V];
```

=== 转化为 01

把第 $i$ 种物品拆成费用为 $C_i 2^k$、价值为 $W_i 2^k$ 的若干件物品，其中 $k$ 取遍满足 $C_i 2^k <= V$ 的非负整数。
不管最优策略选几件第 $i$ 种物品，其件数写成二进制后，总可以表示成若干个 $2^k$ 件物品的和。这样一来就把每种物品拆成 $O(log floor(V /C_i))$ 件物
品


```cpp
#include<bits/stdc++.h>
struct Item{
  int w,v;
};
const int maxn = 2000 + 17;

int F[maxn];

int main(){
  int N,V;
  std::cin >> N >> V;
  std::vector<Item> items;
  for(int i = 0; i < N; i++){
    int v,w,s;
    std::cin >> v >> w >> s;
    for(int k = 1; k <= s; k *= 2){
      s -= k;
      items.push_back({w*k, v*k});
    }
    if(s > 0) items.push_back({w * s,v * s});
  }


  for(const auto& i: items)
    for(int j = V; j >= i.v; j--)
      F[j] = std::max(F[j], F[j-i.v]+i.w);
    
  std::cout << F[V];

  return 0;
}
```

=== 可行性分析 $O(V N)$
#todo[]
== 混合背包
有的物品只可以取一次（01 背包），有的物品可以取无限次（完全背包），有的物品可以取的次数有一个上限（多重背包）

#rect(
  fill: luma(240),
  width: 100%,
  inset: 12pt)[
$"for" i arrow.l 1 "to" N \
quad "if" i in "ZeroOnePack"\
quad quad  "ZeroOnePack()"\
quad "else if" i in "ComplatePack"\
quad quad "ComplatePack()"\
quad "else if" i in "MultiplePack"\
quad quad "MultiplePack()"$]

== 二维费用
#todo[]
== 分组背包
#todo[]
== 依赖背包
#todo[]
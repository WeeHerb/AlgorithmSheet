#import "../env.typ" : *

= 图论
== 欧拉回路
== 拓扑排序
== LCA 树上倍增
#explain[
  有个人考场上现推 LCA 结果爆 0 了
]
```cpp
int st[maxn][21];
int parent[maxn];
int depth[maxn];
void dfs(int x, int fa){
  parent[x] = fa;
  depth[x] = depth[fa] + 1;
  for(int i = head[x]; i; i = e[i].next){
    const int v = e[i].to;
    if(v == fa) continue;
    dfs(v, x);
  }
}
void build_multiply(){
  for(int i = 1; i <= N; i++)
    st[i][0] = parent[i];
  for(int j = 1; j < 21; j++)
    for(int i = 1; i <= N; i++)
      st[i][j] = st[st[i][j-1]][j-1];
}

int LCA(int x,int y){
  if(depth[x] > depth[y]) std::swap(x, y);
  for(int j = 20; j >= 0; j--){
    if(depth[st[y][j]] >= depth[x]){
      y = st[y][j];
    }
  }
  if(x == y) return x;
  for(int j = 20; j >= 0; j--){
    if(st[x][j] != st[y][j]){
      x = st[x][j];
      y = st[y][j];
    }
  }
  return st[x][0];
}
```
== 最短路
#todo[]
=== 01 最短路
#todo[]
== 最小生成树
=== Prim
#todo[]
=== Kruskal
#todo[]
== 强联通分量
#todo[]
=== tarjan 缩点
#todo[]
= 二分图

二分图由两个集合组成，且两个集合内部没有边的图。

#figure(
  image("graph_bigraph.svg", width: 20%),
  caption: [
    二分图
  ]
)

/ 增广路(augmenting path):始于非匹配点且终于非匹配点的交错路
/ 交错路(alternating path): 始于非匹配点且由匹配边与非匹配边交错而成


== 匈牙利算法
```cpp
#include <algorithm>
#include <iostream>

const int N = 510, M = 100010;

int n, m, c;

struct Edge{
  int to, next;
}e[M];
int head[N], eid=0;

int match[N];
bool st[N];

void add(int a, int b) {
  e[++eid].to = b;
  e[eid].next = head[a];
  head[a] = eid;
}

bool find(int u) {
  for (int i = head[u]; i!= 0; i = e[i].next) {
    const int v = e[i].to;
    if (!st[v]) {
      st[v] = true;
      if (!match[v] || find(match[v])) {
        match[v] = u;
        return true;
      }
    }
  }
  return false;
}

int main() {
  std::cin >> n >> m >> c;
  while (c--) {
    int a, b;
    std::cin >> a >> b;
    add(a, b);
  }
  int res = 0;
  for (int i = 1; i <= n; i++) {
    std::fill(st, st + N, false);
    if (find(i)) res++;
  }
  std::cout << res;
  return 0;
}
```

== 网络流
#todo[]
=== EK
#todo[]
#import "../env.typ" : *

= 图论
== 欧拉回路
== 拓扑排序

正向拓扑,即寻找入度为0的点.

有需要可以反向建图

```cpp

int n;
const int maxn = 1e4 + 7;
std::vector<int> g[maxn];

int indeg[maxn];
int outdeg[maxn];

void clear(){
  for(int i  = 0; i < maxn; i++){
    g[i].clear();
  }
}
void add_edge(int u, int v){
  g[u].push_back(v);
  indeg[v]++;
  outdeg[u]++;
}

std::vector<int> topo_sorted;

void topo_dfs(int u){
  if(indeg[u] == 0){
    topo_sorted.push_back(u);
  }else return;
  for(auto v: g[u]){
    indeg[v]--;
    if(indeg[v] == 0){
      topo_dfs(v);
    }
  }
}

void topo_sort(){
  // 有哪些节点需要从这里改改
  for(int i = 0; i < n; i++){
    if(indeg[i] == 0){
      topo_dfs(i);
    }
  }
}
```

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
== 单源最短路
=== Dijkstra
```cpp
struct Edge{
  int next;
  int to, length;
} edges[maxm];
int head[maxn] = {0}, eid = 0;

int distance[maxn];
bool best_match[maxn];
void dijkstra(const int start){
  distance[start] = 0;
  std::fill_n(best_match, maxn, false);
  struct PairCmpImpl{
    bool operator () (const std::pair<int,int>& lhs,const std::pair<int,int>& rhs){
      return lhs.second > rhs.second; 
    }
  };
  std::priority_queue<std::pair<int, int>, std::vector<std::pair<int,int>>, PairCmpImpl> seq; // pair<point-id, length>
  seq.push(std::make_pair(start, 0));
  while(!seq.empty()){
    const std::pair<int, int> pt = seq.top();
    const int u = pt.first;
    seq.pop();
    if(best_match[u]) continue; // already handled! skip
    int u_dis = distance[u] = pt.second;
    best_match[u] = true;
    
    for(int node_id = head[u]; node_id != 0; node_id = edges[node_id].next){
      const Edge v = edges[node_id];
      if(best_match[v.to]) continue;
      seq.push(std::make_pair(v.to, u_dis + v.length));
    }
  }
}

```
=== Bellman-Ford

基于松弛操作且支持负权的单源最短路算法

时间复杂度 $O(N M)$

```cpp
const int maxn = 1e4 + 17;
const int maxm = 5 * 1e5 +17;
int n,m;
ll dis[maxn];
struct Edge{
  ll u,v,w;
} edges[maxm];

bool bellman_ford(const int start_point){
  std::fill_n(dis, maxn, INT32_MAX);
  dis[start_point] = 0;
  rep(i, 0, n){ // 进行 n-1 次松弛
    bool flag = false;
    rep(j, 0, m){ // 全图松弛
      if(dis[edges[j].v] > dis[edges[j].u] + edges[j].w){
        dis[edges[j].v] =  dis[edges[j].u] + edges[j].w;
        flag = true;
      }
    }
    if(!flag) return false;
  }
  rep(j, 0, m){ // 如果还能松弛, 证明存在负环
    if(dis[edges[j].v] > dis[edges[j].u] + edges[j].w){
      return true;      
    }
  }
  return false;
}

std::istream & operator >> (std::istream& is, Edge& rhs){
  return is >> rhs.u >> rhs.v >> rhs.w;
}
int s;
int main(){
  std::cin >> n >> m >> s;
  rep(i, 0, m){
    std::cin >> edges[i];    
  }
  bool f = bellman_ford(s);
  
  tout << "Circle :" << f << std::endl; // 有无负环
  rep(i, 1, n+1){
    std::cout << dis[i] << ' ';
  }
}
```

=== SPFA

Bellman-Ford 的队列优化

只有上一次被松弛的结点，所连接的边，才有可能引起下一次的松弛操作。

```cpp
const int maxn = 1e4 + 17;
const int maxm = 5 * 1e5 +17;
int n,m;

struct Edge{
  ll u,v,w;
  int next;
} edges[maxm];
int head[maxn], eid = 0;
void add_edge(int u ,int v, int w){
  eid++;
  edges[eid].u = u;
  edges[eid].v = v;
  edges[eid].w= w;
  edges[eid].next = head[u];
  head[u] = eid;
}

ll dis[maxn];
bool vis[maxn];
int in_queue_times[maxn]; //Í³¼ÆÈëÁÐµÄ´ÎÊý
bool spfa(const int point_start){
  std::queue<int> seq;
  std::fill_n(dis, maxn, INT32_MAX);
  std::fill_n(vis, maxn, false);
  std::fill_n(in_queue_times, maxn, 0);
  seq.push(point_start);
  vis[point_start] = 1;
  dis[point_start] = 0;
  in_queue_times[point_start] = 1;
  
  while(!seq.empty()){
    const int u = seq.front();
    seq.pop();
    vis[u] = false; // !!!!
    for(int node_id = head[u]; node_id != 0; node_id = edges[node_id].next){
      const int v = edges[node_id].v;
      if(dis[v] > dis[u] + edges[node_id].w){
        dis[v] = dis[u] + edges[node_id].w;
        if(!vis[v]){
          in_queue_times[v]++;
          if(in_queue_times[v] >= n){
            return true;
          }
          vis[v] = true;
          seq.push(v);
        }
      }
    }
  }
  return false;
}

int s;
int main(){
  std::cin >> n >> m >> s;
  rep(i, 0, m){
    int u,v,w;
    std::cin >> u >> v >> w;
    add_edge(u,v,w);    
  }
  
  spfa(s);
  
  rep(i, 1, n+1){
    std::cout << dis[i] << ' ';
  }
}
```


=== 01 最短路

基于双端 BFS

如果当前处理的点连接的边为0，那么将这个点移至队首，否则移入队尾，这样就可以保证队列的单调性。

当我们更新到的点边权为0时，那么这个点一定是到当前为止的最短路，所以可以直接将改点移至队首，如果这个点边权为1，那么这个点可能并不是到当前为止最短的，因此我们要将它移至队尾。

#explain[
在郊区有 $N$ 座通信基站，$P$条双向电缆，第 $i$ 条电缆连接基站 $A_i$ 和 $B_i$。

特别地，$1$ 号基站是通信公司的总站，$N$号基站位于一座农场中。

现在，农场主希望对通信线路进行升级，其中升级第 $i$ 条电缆需要花费 $L_i$。

农产主可以指定一条从 $1$ 号基站到 $N$ 号基站的路径，并指定路径上不超过 $K$ 条电缆，由电话公司免费提供升级服务。

农场主只需要支付在该路径上剩余的电缆中，升级价格最贵的那条电缆的花费即可。

求至少用多少钱可以完成升级。

题目来自 #link("https://www.acwing.com/problem/content/description/342/")[AcWing]
]
```cpp

#include <bits/stdc++.h>
using namespace std;
const int N = 1010;
const int M = 20010;
int n, m, tot, k;
int vis[N], h[N], e[M], vi[M], ne[M], dis[N], backup[N];
void add(int u, int v, int w){
  e[tot] = v, vi[tot] = w, ne[tot] = h[u], h[u] = tot++;
}

struct node{
  int now, d;
};
bool check(int x){
  memset(dis, 0x3f, sizeof dis);
  memset(vis, 0, sizeof vis);
  dis[1] = 0;
  deque<node> q;
  q.push_back(node{1, dis[1]});
  while(q.size()){
    node p = q.front();
    q.pop_front();
    int u = p.now;
    if (vis[u]) continue;
    vis[u] = 1;
    for (int i = h[u]; ~i; i = ne[i]){
      int v = e[i];
      int w = vi[i] > x ? 1 : 0; // 权是 1 是 0?
      if (dis[v] > dis[u] + w){
        dis[v] = dis[u] + w;
        if (!vis[v]){
          if (!w)
            q.push_front(node{v, dis[v]});
          else 
            q.push_back(node{v, dis[v]});
        }
      }
    }
  }
  if (dis[n] <= k) return true;
  else return false;
}

int main(){
  cin >> n >> m >> k;
  memset(h, -1, sizeof h);
  for (int i = 1; i <= m; i++) {
    int x, y, w;
    cin >> x >> y >> w;
    add(x, y, w), add(y, x, w);
  }
  
  int l = 0, r = 1e6+1;
  int mid;
  while(l <= r){
    mid = (l+r) >> 1;
    if (check(mid)) r = mid - 1;
    else l = mid + 1;
  }
  if (r == 1e6+1) cout << -1;
  else cout << l << endl;
}
```

== 多源最短路 Floyd

时间复杂度$O(N^3)$

```cpp
for (k = 1; k <= n; k++) {
  for (i = 1; i <= n; i++) {
    for (j = 1; j <= n; j++) {
      f[i][j] = min(f[i][j], f[i][k] + f[k][j]);
    }
  }
}
```

== 最长路
板子 SPFA
#explain[
肯定不能用dijkstra算法，这是因为，Dijkstra算法的大致思想是每次选择距离源点最近的结点加入，然后更新其它结点到源点
的距离，直到所有点都被加入为止。当每次选择最短的路改为每次选择最长路的时候，出现了一个问题，那就是不能保证现在加
入的结 点以后是否会被更新而使得到源点的距离变得更长，而这个点一旦被选中将不再会被更新。例如这次加入结点u，最长路
为10，下次有可能加入一个结点v，使得 u通过v到源点的距离大于10，但由于u在之前已经被加入到集合中，无法再更新，导致
结果是不正确的
]
#alert[一定不要用 Dijkstra]
== 最小生成树
=== Prim
#todo[]
=== Kruskal
#todo[]
== 强联通分量
#todo[]
=== tarjan 缩点
#todo[]
== 二分图

二分图由两个集合组成，且两个集合内部没有边的图。

#figure(
  image("graph_bigraph.svg", width: 20%),
  caption: [
    二分图
  ]
)

/ 增广路(augmenting path):始于非匹配点且终于非匹配点的交错路
/ 交错路(alternating path): 始于非匹配点且由匹配边与非匹配边交错而成


== 二分图最大匹配(匈牙利算法)
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
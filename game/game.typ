#import "../env.typ": *

= 博弈论
*公平组合游戏 (Impartial Game)* 的定义如下:
- 游戏有两个人参与，*二者轮流* 做出决策，双方均知道游戏的完整信息
- 任意一个游戏者在某一确定状态 *可以作出的决策集合只与当前的状态有关*，而与游戏者无关
- 游戏中的 *同一个状态不可能多次抵达*，游戏 *以玩家无法行动为结束*，且游戏一定会在 *有限步后以非平局结束*

*非公平组合游戏 (Partizan Game)* 与公平组合游戏的区别在于在非公平组合游戏中，*游戏者在某一确定状态可以做出的决策集合与游戏者有关*。大部分的棋类游戏都不是公平组合游戏，如国际象棋、中国象棋、围棋、五子棋等（因为双方都不能使用对方的棋子）。

*反常游戏 (Misère Game)* 按照传统的游戏规则进行游戏，但是其 *胜者为第一个无法行动的玩家*。

== 组合游戏分析法
对于组合游戏，一般先找到 P 状态(Previous Position， 当前玩家会输的状态) 和 N 状态(Next Positoin，当前玩家会赢的状态)。分析时，一般从结束状态往回推。

首先确定最终状态，然后反推前态
- 状态 S 是 N 状态 ，当且仅当 $exists S, f(S) arrow P$
- 状态 S 是 P 状态，当且仅当 $forall S, f(S) arrow N$


== Bash 游戏

有一堆石子， Alice 和 Bob 轮流取石子，每次最少取 $n$ 个，最多取 $k$ 个，如果轮到某个玩家无法取石子，则该玩家输

- $n$ 不能被$(k+1)$整除的的话，A赢
- $n$ 能被$(k+1)$整除的话，B赢

#alert[反常游戏需要将先后手PN状态反转]

== Nim 游戏(拈)

有一堆石子，第 $i$ 堆石子有 $x_i$ 个。Alice 和 Bob 轮流取石子，每次当前玩家可以从某堆石子中取出一个到多个石子（可以取完，但不能不取）。无法取石子的玩家输

$
"P" arrow.l.r.double x_1 plus.circle x_2 plus.circle dots plus.circle x_n = 0
$

$
"N" arrow.l.r.double x_1 plus.circle x_2 plus.circle dots plus.circle x_n != 0
$

== 反常 Nim 游戏

- 当 $ 1 <= i <= n, x_i = 1$，则 $n$ 为奇数数 P态，偶数是 N态。
- 当至少有一个 $x_i > 1 $ 时，和 Nim 游戏相同

== Sprague-Grundy 函数

定义有向无环图游戏 $G = (V, E)$ 的 SG 函数是一个结点集 $V$ 到非负整数 $ZZ >= 0$ 的映射 $g: V arrow.r ZZ >= 0$，满足

$
g(x) = "mex" {g(y) | y in F(x)}
$

在正常游戏下
- x 是 P 态当且仅当 $g(x) = 0$
- x 是 N 态当且仅当 $g(x) > 0$

求 SG 函数时，通常从终点出发，按照拓扑序逆序建立 SG 函数。

=== 确定顺序求 SG

```cpp
int k;
const int maxk = 100 + 17;
int S[maxk]; // 向前的转移状态

const int maxh =   1e4 + 7;
bool mex_vis[maxh]; // 仅用于求 mex
int SG[maxh];

int sg(int target){
  std::memset(SG, 0, sizeof(SG));
  for(int i = 1; i <= target; i++){
     std::memset(mex_vis, false, sizeof(mex_vis));
     

     // mex
     for(int j = 0; j < k; j++){
       if(i - S[j] >= 0){
         mex_vis[SG[i-S[j]]] = true;
       }
     }
     
     int mex = -1;
     for(int j = 0; j < k; j++){
       if(!mex_vis[j]){
         mex = j;
         break;
       }
     }

     SG[i] = mex;
  }
  return SG[target];
}
```

=== 从有向图游戏中求 SG

#explain[
  摘自题目: #link("https://acm.hdu.edu.cn/showproblem.php?pid=1524")[A Chess Game]
]

```cpp

int n;
const int maxn = 1e4 + 7;

//------ 图定义 ----------
// 应用反向建图,用于求 topo sort
std::vector<int> rev_g[maxn];
std::vector<int> g[maxn];

int rev_indeg[maxn];
int rev_outdeg[maxn];


void clear() {
  for (int i = 0; i < maxn; i++) {
    rev_g[i].clear();
    g[i].clear();
  }
  std::memset(rev_indeg, 0, sizeof(rev_indeg));
  std::memset(rev_outdeg, 0, sizeof(rev_outdeg));
}
void add_edge(int u, int v) {
  rev_g[v].push_back(u);
  g[u].push_back(v);

  rev_indeg[u]++;
  rev_outdeg[v]++;
}

//------ SG ----------

int SG[maxn];
bool mex_vis[maxn];  // 仅用于 SG 函数中求 mex

// 输入节点编号
// 输出 SG 函数中的点编号
int mex(int node) {
  std::memset(mex_vis, false, sizeof(mex_vis));
  for (auto v : g[node]) {  // 遍利能转移到的点
    mex_vis[SG[v]] = true;
  }
  for (int i = 0; i < maxn; i++) {
    if (!mex_vis[i]) return i;
  }
  return -1;
}

// 拓扑序
void topo_dfs(int u) {
  if (rev_indeg[u] == 0) {
    SG[u] = mex(u);
  } else
    return;

  for (auto v : rev_g[u]) {
    rev_indeg[v]--;
    if (rev_indeg[v] == 0) {
      topo_dfs(v);
    }
  }
}

// 求 SG 函数
void sg() {
  std::memset(SG, 0, sizeof(SG));
  for (int i = 0; i < n; i++) {
    if (rev_indeg[i] == 0) {
      // 无法行动的点 SG = 0
      // 故必须向下多 dfs 一次
      for (auto v : rev_g[i]) { 
        rev_indeg[v]--;
        if (rev_indeg[v] == 0) {
          topo_dfs(v);
        }
      }
    }
  }
}

```

== SG 定理: 组合游戏求和

#explain[
运用图游戏可以对求和进行描述。即给定 $n$ 个有向无环图$G_i(V_i, E_i)$,则图游戏的和$G(V,E)$满足
- $V= V_1 times V_2 times V_3 times dots times V_n$
- 结点 $x=(x_1, x_2, dots, x_n)$ 一步能到 $F(x) =  union.big^n_(i=1) {(x_1, x_2, dots, y_i, dots, x_n) | y_i in F_i(X_i)}$
]

每个游戏都有一个初始状态，每次当前玩家可以选择一个游戏，并按照游戏规则移动一次，如果轮到当前玩家时，所有的游戏都不能移动，则该玩家输（正常规则）。简单的游戏求和也能变的相当的困难。

#alert[
  游戏状态不能存在依赖关系
]

$G = G_1 + G_2 + dots + G_n$ 的 SG 函数为 $g(x)=g((x_1, x_2, dots, x_n)) = g_1(x_1) plus.circle g_2(x_2) plus.circle dots plus.circle g_n(x_n)$


#figure(
  image("sg_consective.svg", width: 50%),
  caption: [
    连续状态转移
  ]
)
若需要求大量 SG,且存在上图情况,不妨试试打表找规律
#explain[
  例如 #link("https://ac.nowcoder.com/acm/contest/34655/C")[Stone Game]
]


== 分裂游戏 (Take-and-Break Game)

例如 Lasker's Nim

n 堆石子中,每次玩家可以
- 从一堆中取走若干个石子
- 把一堆石子分成两个非空的堆
#import "../env.typ": *

= 区间操作结构

== 并查集

#explain[
  没想到吧，并查集也能用于区间操作

  用于区间操作时主要是将需要合并的元素进行合并，以此减少后续操作

  #strike[不过大多数时候路径压缩没法用]
]

```cpp
const int maxn = 1e8;
int parent[maxn], rank[maxn];
int find_root(int u) {
  while (parent[u] != 0) {
    u = parent[u];
  }
  return u;
}

void union_node(int u, int v) {
  int root_u = find_root(u);
  int root_v = find_root(v);
  if (root_v == root_u)
    return;
  // 压缩路径
  if (rank[root_u] > rank[root_v]) {
    parent[root_v] = root_u;
  } else if (rank[root_u] < rank[root_v]) {
    parent[root_u] = root_v;
  } else {
    parent[root_u] = root_v;
    rank[root_v]++;
  }
}

bool is_joint(int u, int v) { return find_root(u) == find_root(v); }
```

== ST 表

#explain[
  #link("https://www.luogu.com.cn/record/74628237")

  `table[i][j]` 表示从 $i$ 开始到 $i+2^j$ 范围中的最大值，构建 ST 表的递推公式为
  $
    f[i][j] = max(f[i][j-1], f[i + 2^(j-1)][j - 1])
  $
  查询公式
  $
    "RMQ"(i,j) = max(f["left"][k], f["right" - 2^k + 1][k]), quad k=ln("right"-"left"+1)
  $
]

$O(n)$ 在线 RMQ 


#alert[循环边界条件]

```cpp
const int maxn = 1e5 + 17;
int a[maxn];
int N, M;
int st[maxn][21];

void st_build(){
  for(int i = 1; i <= N; i++)
    st[i][0] = a[i];
  for(int j = 1; j < 21; j++)
    for(int i = 1; i + (1 << (j-1)) <= N; i++)
      st[i][j] = std::max(st[i][j-1], st[i + (1 << (j-1))][j-1]);
}
int st_query(int l, int r){
  int k = std::log2(r - l + 1);
  return std::max(st[l][k], st[r-(1<<k)+1][k]); 
}
```

== 树状数组

#explain[
  一种类似前缀和的结构

  其中 $"lowbit" = 2^k, quad "k 是一个数二进制中末尾 0 的个数"$。或者说 `lowbit` 表示一个数二进制最右边1所表示的值

  结构如下:
  #image("range_bits.png")
]

#alert[循环边界条件]

```cpp
const int maxn = 5e5;

#define lowbit(x) ((-x)&(x))

void add(int i, int value){
  for(; i <= maxn; i += lowbit(i))
    bits[i] += value
}

int prefix(int i){
  int sum = 0;
  for(; i > 0; i -= lowbit(i)){
    sum += bits[i];
  }
  return sum;
}
```

== 线段树
长是真的长,好用是真的好用
#alert[循环边界条件]

```cpp
const int maxn = 5e5 + 5, INF = 0x3f3f3f3f;
struct Node{
    int l, r;
    int maxv;
}tr[maxn * 4];

void pushup(int u){
    tr[u].maxv = std::max(tr[u << 1].maxv, tr[u * 2 + 1].maxv);
}

void build(int u, int l, int r){
    tr[u] = {l, r};
    if (l == r){
        tr[u].maxv = a[r];
        return;
    }
    int mid = (l + r) / 2;
    build(u * 2, l, mid), build(u * 2 + 1, mid + 1, r);
    pushup(u);
}

void modify(int u, int x){
    if (tr[u].l == tr[u].r){
        tr[u].maxv -= n;
        a[tr[u].r] -= n;
        return;
    }
    int mid = (tr[u].l + tr[u].r) / 2;
    if (x <= mid) modify(u << 1, x);
    else modify(u << 1 | 1, x);
    pushup(u);
}

int query(int u){
    if (k + tr[u].maxv < n - 1) return -1;
    if (tr[u].l == tr[u].r) return tr[u].r;
    if (k + tr[u * 2].maxv >= n - 1) return query(u * 2);
    return query(u* 2 + 1);
}
```

=== Lazy
#todo[]
== ZKW 线段树
重点突出一个简单好抄不好理解
#todo[]
=== Lazy
#todo[]
== treap
#todo[]
== Splay
#todo[]
== 主席树
#todo[]
== 珂朵莉树
*不适用于 ACM 赛制*
#explain[
  #table(
    columns: (1fr, 1fr),
    fill: luma(240),
    inset: 8pt,
    image("range_896C.png"),
    [
      *C. Willem, Chtholly and Seniorious*

      — Willem...

      — What's the matter?

      — It seems that there's something wrong with Seniorious...

      — I'll have a look...
    ]
  )

  该结构首次出现在 #link("https://codeforces.com/problemset/problem/896/C")[896C]。在具有区间赋值操作，区间统计操作，以及最好保证数据随机的情况下在时空复杂度上把线段树 *吊起来打*。#strike[也可以在走投无路时骗分]
]

珂朵莉树是一种优美的暴力，他的优美是建立在区间的合并操作上，即区间赋值，那么如果构造出一组数据使得其几乎不含区间赋值操作，那珂朵莉树就会被轻易的卡掉

所以珂朵莉树要求题目必须存在区间赋值操作，且数据有高度的随机性
#todo[]

== 单调栈

#todo[]
== 单调队列
#todo[]
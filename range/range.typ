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
#explain[
  来自 #link("https://codeforces.com/blog/entry/18051")[Efficient and easy segment trees]
]

推荐数组使用大小: $2n$

所有区间均指 $[l,r)$

=== 区间修改,单点查询

```cpp
void modify(int l, int r, int value) {
  for (l += n, r += n; l < r; l >>= 1, r >>= 1) {
    if (l&1) t[l++] += value;
    if (r&1) t[--r] += value;
  }
}

int query(int p) {
  int res = 0;
  for (p += n; p > 0; p >>= 1) res += t[p];
  return res;
}
```
更新所有元素:

```cpp
void push() {
  for (int i = 1; i < n; ++i) {
    t[i<<1] += t[i];
    t[i<<1|1] += t[i];
    t[i] = 0;
  }
}
```

=== 单点修改,区间查询

```cpp
void modify(int p, const S& value) {
  for (t[p += n] = value; p >>= 1; ) t[p] = combine(t[p<<1], t[p<<1|1]);
}

S query(int l, int r) {
  S resl, resr;
  for (l += n, r += n; l < r; l >>= 1, r >>= 1) {
    if (l&1) resl = combine(resl, t[l++]);
    if (r&1) resr = combine(t[--r], resr);
  }
  return combine(resl, resr);
}
```

=== 懒传播
```cpp
int h = sizeof(int) * 8 - __builtin_clz(n);
int d[N];  
```

区间增量,最大查值

```cpp
void apply(int p, int value) {
  t[p] += value;
  if (p < n) d[p] += value;
}

void build(int p) {
  while (p > 1) p >>= 1, t[p] = max(t[p<<1], t[p<<1|1]) + d[p];
}

void push(int p) {
  for (int s = h; s > 0; --s) {
    int i = p >> s;
    if (d[i] != 0) {
      apply(i<<1, d[i]);
      apply(i<<1|1, d[i]);
      d[i] = 0;
    }
  }
}

void inc(int l, int r, int value) {
  l += n, r += n;
  int l0 = l, r0 = r;
  for (; l < r; l >>= 1, r >>= 1) {
    if (l&1) apply(l++, value);
    if (r&1) apply(--r, value);
  }
  build(l0);
  build(r0 - 1);
}

int query(int l, int r) {
  l += n, r += n;
  push(l);
  push(r - 1);
  int res = -2e9;
  for (; l < r; l >>= 1, r >>= 1) {
    if (l&1) res = max(res, t[l++]);
    if (r&1) res = max(t[--r], res);
  }
  return res;
}
```

== 主席树
#todo[]
== 珂朵莉树(ODT)
*不适用于 ACM 赛制*
*极容易被卡*
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

  该结构首次出现在 #link("https://codeforces.com/problemset/problem/896/C")[CF896C] 的题解中。在具有区间赋值操作，区间统计操作，以及最好保证数据随机的情况下在时空复杂度上把线段树 *吊起来打*。#strike[也可以在走投无路时骗分]
]

珂朵莉树是一种优美的暴力，他的优美是建立在区间的合并操作上，即区间赋值，那么如果构造出一组数据使得其几乎不含区间赋值操作，那珂朵莉树就会被轻易的卡掉

所以珂朵莉树要求题目必须存在区间赋值操作，且数据有高度的随机性

```cpp
struct node {
    ll l, r;
    // mutable使得当整个结构体为const时，标为mutable的成员仍可变（因为可能有区间加等操作）
    mutable ll v;
    node(ll l, ll r, ll v) : l(l), r(r), v(v) {} 
    bool operator<(const node &o) const { 
      return l < o.l;
    }
};

std::set<node> tree;

std::set<node>::iterato split(ll pos){
    auto it = tree.lower_bound(node(pos, 0, 0)); // 寻找左端点大于等于pos的第一个节点
    if (it != tree.end() && it->l == pos) 
        return it; // 如果已经存在以pos为左端点的节点，直接返回
    it--; // 否则往前数一个节点
    ll l = it->l, r = it->r, v = it->v;
    tree.erase(it); // 删除该节点
    tree.insert(node(l, pos - 1, v)); // 插入<l,pos-1,v>和<pos,r,v>
    return tree.insert(node(pos, r, v)).first; // 返回以pos开头的那个节点的迭代器
                                               // insert默认返回值是一个pair，第一个成员是我们要的
}

// 区间赋值
void assign(ll l, ll r, ll v){
    auto end = split(r + 1), begin = split(l); // 顺序不能颠倒，否则可能RE
    tree.erase(begin, end); // 清除一系列节点
    tree.insert(node(l, r, v)); // 插入新的节点
}

// 区间加
void add(ll l, ll r, ll v){
    auto end = split(r + 1);
    for (auto it = split(l); it != end; it++)
        it->v += v;
}
// 区间 k 大值
ll kth(ll l, ll r, ll k){
    auto end = split(r + 1);
    vector<pair<ll, ll>> v; // 这个pair里存节点的值和区间长度
    for (auto it = split(l); it != end; it++)
        v.push_back(make_pair(it->v, it->r - it->l + 1));
    sort(v.begin(), v.end()); // 直接按节点的值的大小排下序
    for (int i = 0; i < v.size(); i++) // 然后挨个丢出来，直到丢出k个元素为止
    {
        k -= v[i].second;
        if (k <= 0)
            return v[i].first;
    }
}

// 区间 n 次方和
ll sum_of_pow(ll l, ll r, ll x, ll y){
    ll tot = 0;
    auto end = split(r + 1);
    for (auto it = split(l); it != end; it++)
        tot = (tot + qpow(it->v, x, y) * (it->r - it->l + 1)) % y; // qpow自己写一下
    return tot;
}
```
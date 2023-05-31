#import "../env.typ": *
= 数学(?)
#explain[
会做算我输
]
== 高精度

```cpp
// filename:    bigint_tiny.h
// author:      baobaobear
// create date: 2021-02-10
// This library is compatible with C++03
// https://github.com/Baobaobear/MiniBigInteger
#pragma once

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

struct BigIntTiny {
    int sign;
    std::vector<int> v;

    BigIntTiny() : sign(1) {}
    BigIntTiny(const std::string &s) { *this = s; }
    BigIntTiny(int v) {
        char buf[21];
        sprintf(buf, "%d", v);
        *this = buf;
    }
    void zip(int unzip) {
        if (unzip == 0) {
            for (int i = 0; i < (int)v.size(); i++)
                v[i] = get_pos(i * 4) + get_pos(i * 4 + 1) * 10 + get_pos(i * 4 + 2) * 100 + get_pos(i * 4 + 3) * 1000;
        } else
            for (int i = (v.resize(v.size() * 4), (int)v.size() - 1), a; i >= 0; i--)
                a = (i % 4 >= 2) ? v[i / 4] / 100 : v[i / 4] % 100, v[i] = (i & 1) ? a / 10 : a % 10;
        setsign(1, 1);
    }
    int get_pos(unsigned pos) const { return pos >= v.size() ? 0 : v[pos]; }
    BigIntTiny &setsign(int newsign, int rev) {
        for (int i = (int)v.size() - 1; i > 0 && v[i] == 0; i--)
            v.erase(v.begin() + i);
        sign = (v.size() == 0 || (v.size() == 1 && v[0] == 0)) ? 1 : (rev ? newsign * sign : newsign);
        return *this;
    }
    std::string to_str() const {
        BigIntTiny b = *this;
        std::string s;
        for (int i = (b.zip(1), 0); i < (int)b.v.size(); ++i)
            s += char(*(b.v.rbegin() + i) + '0');
        return (sign < 0 ? "-" : "") + (s.empty() ? std::string("0") : s);
    }
    bool absless(const BigIntTiny &b) const {
        if (v.size() != b.v.size()) return v.size() < b.v.size();
        for (int i = (int)v.size() - 1; i >= 0; i--)
            if (v[i] != b.v[i]) return v[i] < b.v[i];
        return false;
    }
    BigIntTiny operator-() const {
        BigIntTiny c = *this;
        c.sign = (v.size() > 1 || v[0]) ? -c.sign : 1;
        return c;
    }
    BigIntTiny &operator=(const std::string &s) {
        if (s[0] == '-')
            *this = s.substr(1);
        else {
            for (int i = (v.clear(), 0); i < (int)s.size(); ++i)
                v.push_back(*(s.rbegin() + i) - '0');
            zip(0);
        }
        return setsign(s[0] == '-' ? -1 : 1, sign = 1);
    }
    bool operator<(const BigIntTiny &b) const {
        return sign != b.sign ? sign < b.sign : (sign == 1 ? absless(b) : b.absless(*this));
    }
    bool operator==(const BigIntTiny &b) const { return v == b.v && sign == b.sign; }
    BigIntTiny &operator+=(const BigIntTiny &b) {
        if (sign != b.sign) return *this = (*this) - -b;
        v.resize(std::max(v.size(), b.v.size()) + 1);
        for (int i = 0, carry = 0; i < (int)b.v.size() || carry; i++) {
            carry += v[i] + b.get_pos(i);
            v[i] = carry % 10000, carry /= 10000;
        }
        return setsign(sign, 0);
    }
    BigIntTiny operator+(const BigIntTiny &b) const {
        BigIntTiny c = *this;
        return c += b;
    }
    void add_mul(const BigIntTiny &b, int mul) {
        v.resize(std::max(v.size(), b.v.size()) + 2);
        for (int i = 0, carry = 0; i < (int)b.v.size() || carry; i++) {
            carry += v[i] + b.get_pos(i) * mul;
            v[i] = carry % 10000, carry /= 10000;
        }
    }
    BigIntTiny operator-(const BigIntTiny &b) const {
        if (b.v.empty() || b.v.size() == 1 && b.v[0] == 0) return *this;
        if (sign != b.sign) return (*this) + -b;
        if (absless(b)) return -(b - *this);
        BigIntTiny c;
        for (int i = 0, borrow = 0; i < (int)v.size(); i++) {
            borrow += v[i] - b.get_pos(i);
            c.v.push_back(borrow);
            c.v.back() -= 10000 * (borrow >>= 31);
        }
        return c.setsign(sign, 0);
    }
    BigIntTiny operator*(const BigIntTiny &b) const {
        if (b < *this) return b * *this;
        BigIntTiny c, d = b;
        for (int i = 0; i < (int)v.size(); i++, d.v.insert(d.v.begin(), 0))
            c.add_mul(d, v[i]);
        return c.setsign(sign * b.sign, 0);
    }
    BigIntTiny operator/(const BigIntTiny &b) const {
        BigIntTiny c, d;
        d.v.resize(v.size());
        double db = 1.0 / (b.v.back() + (b.get_pos((unsigned)b.v.size() - 2) / 1e4) +
                           (b.get_pos((unsigned)b.v.size() - 3) + 1) / 1e8);
        for (int i = (int)v.size() - 1; i >= 0; i--) {
            c.v.insert(c.v.begin(), v[i]);
            int m = (int)((c.get_pos((int)b.v.size()) * 10000 + c.get_pos((int)b.v.size() - 1)) * db);
            c = c - b * m, c.setsign(c.sign, 0), d.v[i] += m;
            while (!(c < b))
                c = c - b, d.v[i] += 1;
        }
        return d.setsign(sign * b.sign, 0);
    }
    BigIntTiny operator%(const BigIntTiny &b) const { return *this - *this / b * b; }
    bool operator>(const BigIntTiny &b) const { return b < *this; }
    bool operator<=(const BigIntTiny &b) const { return !(b < *this); }
    bool operator>=(const BigIntTiny &b) const { return !(*this < b); }
    bool operator!=(const BigIntTiny &b) const { return !(*this == b); }
};
```

== 完全平方数
$a$ 是一个完全平方数， 当且仅当 $exists b, a = b^2$

=== 质因子
*完全平方数的质因子的指数一定为偶数（可用算数基本定理表示）*

设 $sqrt(a) = b$，根据算数基本定理，有
$b = p_1^(k_1) times p_2^(k_2) times ... times p_r^(k_r)$

则有 $a = b^2 = (p_1^(k_1) times p_2^(k_2) times ... times p_r^(k_r))^2=p_1^(2k_1) times p_2^(2k_2) times ... times p_r^(2k_r)$
$$

每个质因子的指数均为 $2k_m$，必然是偶数


== 算数基本定理
#explain[
  #link("https://zh.wikipedia.org/wiki/%E7%AE%97%E6%9C%AF%E5%9F%BA%E6%9C%AC%E5%AE%9A%E7%90%86")[Wikipedia]
]
算术基本定理，又称为正整数的唯一分解定理，即：每个大于1的自然数，要么本身就是质数，要么可以写为2个或以上的质数的积，而且这些质因子按大小排列之后，写法仅有一种方式

$
forall A in NN, A > 1 quad exists product^n_(i=1) p^(a_i)_i = A.
$
其中 $p_1 < p_2 < p_3 < dots < p_n$，且 $P_i$ 是一个质数，$a_i in ZZ^+$
== 小费马定理
#todo[]
== Lucas 定理
#todo[]
== 埃筛
$
O(n log log n)
$
```cpp
int Eratosthenes(int n) {
  int p = 0;
  for (int i = 0; i <= n; ++i) is_prime[i] = 1;
  is_prime[0] = is_prime[1] = 0;
  for (int i = 2; i <= n; ++i) {
    if (is_prime[i]) {
      prime[p++] = i;  // prime[p]是i,后置自增运算代表当前素数数量
      if ((long long)i * i <= n)
        for (int j = i * i; j <= n; j += i)
          // 因为从 2 到 i - 1 的倍数我们之前筛过了，这里直接从 i
          // 的倍数开始，提高了运行速度
          is_prime[j] = 0;  // 是i的倍数的均不是素数
    }
  }
  return p;
}
```
== 欧拉筛
```cpp
void init(int n) {
  for (int i = 2; i <= n; ++i) {
    if (!vis[i]) {
      pri[cnt++] = i;
    }
    for (int j = 0; j < cnt; ++j) {
      if (1ll * i * pri[j] > n) break;
      vis[i * pri[j]] = 1;
      if (i % pri[j] == 0) {
        // i % pri[j] == 0
        // 换言之，i 之前被 pri[j] 筛过了
        // 由于 pri 里面质数是从小到大的，所以 i乘上其他的质数的结果一定会被
        // pri[j]的倍数筛掉，就不需要在这里先筛一次，所以这里直接 break
        // 掉就好了
        break;
      }
    }
  }
}
```
#alert[注意到筛法求素数的同时也得到了每个数的最小质因子]
== min25 筛
#todo[]

== 母函数

```cpp
template<std::size_t MAX_TERM = 1000>
struct Polynomial {
    std::array<long long, MAX_TERM> terms;
    int size;

    Polynomial(): size(0){
      terms.fill(0);
    }

    Polynomial operator * (int rhs) {
        Polynomial ans;
        ans.size = size;
        for(int i = 0; i < size; i++)
            ans.terms[i] = terms[i] * rhs;
    }

    Polynomial operator * (const Polynomial & rhs) {
        Polynomial ans;
        ans.size = size + rhs.size;
        for(int i = 0; i < size; i++){
          if(terms[i] == 0) continue;
          for(int j = 0; j < rhs.size; j++){
            if(rhs.terms[j] == 0) continue;
            ans.terms[i + j] += terms[i] * rhs.terms[j];
          }
        }
        return ans;
    }
    
    
    Polynomial qpow(int n) {
      if(n == 0){
        Polynomial mempty;
        mempty.size = 1;
        mempty.terms[0] = 1;
        return mempty;;
      }
      n--;
      Polynomial ans, a;
      ans.size = size;
      a.size = size;
      for(int i = 0; i < size; i++){
        ans.terms[i] = terms[i];
        a.terms[i] = terms[i];
      }
    
      while(n){
        if(n & 1) ans = ans * a;
        n >>= 1;
        a = (a * a);
      }
      return ans;
    }
    
};
template<std::size_t T>
std::ostream& operator<<(std::ostream& os, const Polynomial<T> & rhs){
  for(int i = 0; i < rhs.size; i++){
    if(i != 0) std::cout << " ";
    os << rhs.terms[i];
  }
  return os;
}
```

== Beatty 序列

一个正无理数 $r$ 生成的 Beatty 序列是指序列
$
frak(B)_r = (floor(r i))_(i>=1)
$

=== Rayleigh 定理

假设正无理数 $ r > 1$, $s$ 满足 $1/r + 1/s = 1$, 则 $frak(B)_r$ 和 $frak(B)_s$ 是全体正整数的一个分割. 即任意一个正整数存在且仅存在于 $frak(B)_r$ 和 $frak(B)_s$ 的其中一个序列

$frak(B)_r, frak(B)_s$ 的递推关系:

$
(frak(B)_r)_i = "mex" {0, (frak(B)_r)_j,(frak(B)_s)_j | j < i }
$


== 数列

等比数列求和 $S_n = (a_1 - a_(n+1))/(1-q) = (a_1(1-q^n))/(1-q)$

== 概率公式

/ 乘法公式: $P(A B) = P(A) P(B|A) quad (P(A) > 0)$
/ 全概率公式: $P(B) = sum^n_(i=1)(P(A_i B)) = sum^n_(i=1)P(A_i)P(B| A_i)$
/ 贝叶斯公式: $P(A_k|B) = (P(A_k)P(B|A_k))/(sum^n_(i=1)P(A_i)P(B | A_i))$
/ 若A, B 独立: $P (A overline(B)) = P(A - B) = P(A) - P(A B) = P(A) P(overline(B)) $

- $E(C) = C$
- $E(X+C) = E(X) + C$
- $E(C X) = C E(X)$
- $E(k X+b) = k E(X) + b$
- $E(X plus.minus Y) = E(X) plus.minus E(Y)$
- 当 X 与 Y 相互独立时， $E(X Y) = E(X) dot E(Y)$


- $D(C) = 0$
- $D(X+C) = C^2 D X$
- $D(C X+d) = C^2 D X$
- 若 $X$ 与 $Y$ 相互独立 $D(X plus.minus Y) = D X + D Y$

== 常见概率分布
/ $0-1$ 分布: 进行一次事件试验，该事件发生的概率为$p$，不发生的概率为$1-p$
/ 二项分布: 重复n次独立的伯努利试验。在每次试验中只有两种可能的结果,而且两种结果发生与否互相对立,并且相互独立,与其它各次试验结果无关
/ 几何分布: 在n次伯努利试验中，试验k次才得到第一次成功的机率
#table(
    columns: (auto, 1fr, auto, auto),
    inset: 10pt,
    align: horizon,
    [分布名称], [概率函数], [期望], [方差],

    [$0-1$分布],
    $P(X=k) = p^k q^(1-k) quad (k = 0, 1)$,
    $p$,
    $p q$,

    [二项分布],
    $P(X=k)=C^k_n p^k q^(n-k) quad (k = 0, 1, dots, n)$,
    $n p$,
    $n p q$,
    
    [几何分布],
    $P(X=k) = (1-p)^(k-1)p quad (k = 1,2, dots)$,
    $1/p$,
    $(1-p)/p^2$,

    [泊松分布],
    $P(X=k) = (lambda^k)/(k!)e^(-lambda) quad (k=0,1,dots)$,
    $lambda$,
    $lambda$,

    [均匀分布],
    $f(x) = cases( 1/(b-a)  quad a <= x <= b, 0)$,
    $(a+b)/2$,
    $(b-a)^2 / 12$,


    [指数分布],
    $f(x) = cases(lambda e^(-lambda x) quad x > 0, 0, x <= 0)$,
    $1/lambda$,
    $1/(lambda^2)$,

    [正态分布],
    $phi(x) = 1/(sqrt(2 pi)sigma)e^(-(x - mu)^2/(2 sigma^2))$,
    $mu$,
    $sigma^2$
)
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
== 欧拉筛
#todo[]
== 埃筛
#todo[]
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
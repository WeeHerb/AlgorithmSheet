#import "../env.typ": *
= 工具函数
== 快读
```cpp
template <typename T>
inline typename std::enable_if<std::is_integral<T>::value>::type  read(T &x){
  char c;
  T f=1;
  while(!isdigit(c=getchar()))
    if(c=='-')
      f=-1;
  x=(c&15);
  while(isdigit(c=getchar()))
    x= (x<<1) + (x<<3) + (c&15); x*=f;
}
template <typename T, typename... A>
inline void read(T &value, A &..._t) { read(value), read(_t...); }
```

== 快速幂

求 $a^n % "modd"$

```cpp
template<typename A, typename BaseT>
typename std::enable_if<std::is_integral<BaseT>::value, A>::type
qpow(A a, BaseT n, BaseT modd){
    decltype(a) ans = 1;
    while (n){
        if (n & 1) ans = (ans * a) % modd;
        n >>= 1;
        a = (a * a) % modd;
    }
    return ans % modd;
}

```
== GCD 与 LCM

#explain[
  万一不是 GCC，没法用 `std::__gcd()` 至少不会暴庇
]

$ gcd(a,b) = gcd(b, a mod b) $
$ "lcm"(a,b) = |a dot.op b| / gcd(a,b) $

```cpp
ll gcd(ll a, ll b) {
  while(b ^= a ^= b^=a %= b);
  return a;
}

ll lcm(ll a, ll b){
  return (a * b)/gcd(a,b);
}
```
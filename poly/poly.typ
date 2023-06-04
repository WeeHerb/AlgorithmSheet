#import "../env.typ": *

= 计算几何

#strike[
有点坑
]

题目特点:
- 码量大, 细节多, 正确率低
- 常作为金牌题, 出线题
- 国内一般不涉及太难

#alert[
  - 若问题能用整数解决, 则不用浮点数
  - 别用 float, 看情况用 long double
  - 减少数学函数的使用 (开放, 三角函数等)
  - 比较时加入容限 $frak("eps")$
]

== 基础定义

```cpp
const double eps = 0.00001;
```

=== Vec2D

快速暴力#strike[但是很慢]
```cpp
using Point = std::complex<double>;
```


精致
```cpp
struct Vec2d{
  double x, y;
  Vec2d(): x(0), y(0){}
  Vec2d(double x, double y): x(x), y(y) {}

  /// 叉积
  double cross(const Vec2d& rhs) const{
    return x * rhs.y - y * rhs.x;
  }

  /// 点积
  double dot(const Vec2d& rhs) const {
    return x * rhs.x + y * rhs.y;
  }

  Vec2D operator+(const Vec2d &rhs) const {
    return Vec2D(x + rhs.x, y + rhs.y);
  }
  Vec2D operator-(const Vec2d &rhs) const {
    return Vec2D(x - rhs.x, y - rhs.y);
  }
};
using Point2d = Vec2d;
```

=== Line2d
平面上一点 $p$, 方向向量 $arrow(v)$
```cpp
struct Line2d{
  Point2d p;
  Vec2d v;
}
```

=== Polygon2d <polygon2d>

- 一般按逆时针顺序存储
- 不一定满足凸性

#alert[
  尤其注意第一个点和最后一个点
]

```cpp
struct Polygon2d{
  std::vector<Point2d> p;
}
```
== 公式表
=== 点积
/ 点积几何意义: $arrow(a) dot arrow(b) == || arrow(a) || || arrow(b) || cos theta$
/ 向量长度: $||arrow(a) || = sqrt(arrow(a) dot arrow(a))$
/ 向量夹角: $cos theta = (arrow(a) dot arrow(b))/(||arrow(a)|| ||arrow(b)||)$
/ 向量投影: $||arrow(a)||cos theta = (arrow(a) dot arrow(b))/||arrow(b)||$
/ 向量垂直: $arrow(a) dot arrow(b) = 0$
/ 锐角夹角: $arrow(a) dot arrow(b) < 0$
/ 钝角夹角: $arrow(a) dot arrow(b) > 0$

=== 叉积
/ 叉积几何意义: $arrow(a) times arrow(b) = ||arrow(a) || ||arrow(b)|| sin theta arrow(k)$
/ 平行四边形面积: $||arrow(a)|| || arrow(b) || sin theta = || arrow(a) times arrow(b) ||$
/ 向量平行: $arrow(a) times arrow(b) = arrow(0)$
/ to-left 测试: #table(
  columns:(auto, auto),
  inset: 12pt,
  [Condition], [Display],
  [$ arrow(A B) times arrow(A P) > 0 $], [P 在有向直线 AB 左侧],
  [$ arrow(A B) times arrow(A P) < 0 $], [P 在有向直线 AB 右侧],
  [$ arrow(A B) times arrow(A P) = 0 $], [P 在有向直线 AB 上]
)


=== 二维基础
/ 对一个向量 $arrow(a)$ 逆时针旋转 $theta$ 度 : $mat(cos theta, -sin theta; sin theta, cos theta) vec(a_x, a_y) = vec(cos theta a_x - sin theta a_y, sin theta a_x + cos theta a_y)$

/ 点 P 在线段 AB 上: 
  - 点 P 在直线上 $arrow(P A) times arrow(P B) = vec(0)$
  - 点 P 在 AB 之间 $arrow(P A) dot arrow(P B) <= 0$

/ 线段 AB 与 CD 相交(跨立实验):
 - 点 $A$ $B$ 在直线$C D$的不同侧
 - 点 $C$ $D$ 在直线$A B$的不同侧
 - 三点共线/四点共线

/ 点$A$到直线 $(P, arrow(v))$ 距离: $|| arrow(A B) || = || arrow(P A) || |sin theta| = (|| arrow(v) times arrow(P A)||)/(||arrow(v)||)$
/ 点$A$在直线 $(P, arrow(v))$ 的投影:
- $||arrow(P B) || = || arrow(P A) || cos theta = (arrow(P A) dot arrow(v))/||v||$
- $B = arrow(O B) = arrow(O P) + arrow(P B) = arrow(O P) + (|| arrow(P B) ||)/(|| arrow(v) ||) arrow(v) = arrow(O P) + (arrow(P A) dot arrow(v))/(||arrow(v)|| ||arrow(v)||) arrow(v) = arrow(O P) + (arrow(P A) dot arrow(v))/arrow(v)^2 arrow(v)$
/ 两直线交点: #figure(
  caption: "两直线交点",
 image("line_insec.png")
)

/ 多边形面积(三角剖分): $S = 1/2 || sum^(n-1)_(i=0) (arrow(O P_i) times arrow(O P_((i+1) mod n))) || $

== 凸多边形面积 双指针

#explain[
  2023 SDCPC 场上现推的

  浪费了不少时间
]

以 
#label_page("polygon2d") 
存储, 根据多边形面积变形获得.

求从一个 $n$ 边形的第 idxb 顶点开始逆时针旋转 $k$ 个边到 idxc 所围成的封闭 *凸* 多边形的面积

#figure(
  caption: [从ABCD转移到HABC: $S_(H A B C) = S_(A B C D) - A B C + A H C$],
  image(
    width: 50%,
    "dual_ptr_polygon2d.png"
  )
)
```cpp
ld poly_area = -1;
ld max_poly_area = 0;

if(poly_area == -1){
  poly_area = 0;
  for(int i = (idxb + 1) % n; i != idxc; i = (i + 1) % n){
    poly_area += (poly.p[i] - poly.p[idxb])
      .cross(poly.p[(i+1)%n] - poly.p[idxb]) / 2;
  }
} else {
  auto transfer_base = poly.p[(idxc - 1 + n) % n];
  poly_area -= std::fabs(
    (poly.p[(idxb - 1 + n) % n] - transfer_base)
      .cross(poly.p[idxb] - transfer_base) / 2;
  );
  poly_area += std::fabs(
    (poly.p[idxb] - transfer_base)
      .cross(poly.p[idxc] - transfer_base) / 2;
  );
}
```

== 极角排序

#explain[
  例题不妨看看这个？
  #link("https://pintia.cn/problem-sets/1645773717173301248/exam/problems/1645773784399597684")[GPLT L3-021 神坛]
  #link("https://www.cnblogs.com/kingwz/p/16151120.html")[题解]
]

/ 极点: 在平面内取一个定点$O$，叫极点
/ 极轴: 引一条射线$O_x$，叫做极轴
/ 正方向: 选定一个长度单位和角度的正方向（通常取逆时针方向）。

对于平面内任何一点$M$，用$rho$表示线段$"OM"$的长度，$theta$表示从$O_x$到$"OM"$的角度, $rho$叫做点$M$的极径，$theta$叫做点$M$的极角，有序数对$(rho, theta)$就叫点$M$的极坐标。

给定平面上的一些点，把它们按照一个选定的中心点排成顺（逆）时针。

#figure(
  caption: "叉乘特征",
  image(
    width: 50%,
    "polar_sort.png"
  )
)

```cpp
void polarAngleSort(std::vector<Vec2D>& points){
  std::sort(points.begin(), points.end(), [](const Vec2D& lhs, const Vec2D& rhs){
    double cross = lhs.cross(rhs);
    if(cross == 0) return lhs.x < rhs.x;
    return cross > 0;
  });
}
```


== 向量运算
#todo[]
== 几何关系 
#todo[]
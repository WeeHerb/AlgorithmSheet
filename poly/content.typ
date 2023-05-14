#import "../env.typ": *

= 计算几何

== 基础定义

=== 常量: eps

```cpp
const double eps = 0.00001;
```

=== 向量: Vec2D

```cpp
struct Vec3D{
  double x, y, z;
  Vec3D(): x(0), y(0), z(0){}
  Vec3D(double x, double y, double z): x(x), y(y), z(z){}
  Vec3D(const Vec2D& vec2d): x(vec2d.x), y(vec2d.y), z(0){}

  /// 点积
  double dot(const Vec3D& rhs) const {
    return x * rhs.x + y * rhs.y + z * rhs.z;
  }
}
struct Vec2D{
  double x, y;
  Vec2D(): x(0), y(0){}
  Vec2D(double x, double y): x(x), y(y) {}

  /// 叉积
  double cross(const Vec2D& rhs) const{
    return x * rhs.y - y * rhs.x;
  }

  /// 点积
  double dot(const Vec2D& rhs) const {
    return x * rhs.x + y * rhs.y;
  }

  Vec2D operator+(const Vec2D &rhs) const {
    return Vec2D(x + rhs.x, y + rhs.y);
  }
  Vec2D operator-(const Vec2D &rhs) const {
    return Vec2D(x - rhs.x, y - rhs.y);
  }
};
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
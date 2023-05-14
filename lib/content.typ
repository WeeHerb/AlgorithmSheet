#import "../env.typ": *

= 标准库参考
#explain[
  不会有人还不会用 STL 吧？不会吧不会吧？
]

== \<tuple>
=== tuple

```cpp
template<class... Types>
class tuple;
```

/ `make_tuple`: Creates a tuple object, deducing the target type from the types of arguments. e.g. `std::tuple<int, double> a = std::make_tuple(1, 2.0);`
/ `get`:  Extracts the Ith element from the tuple. e.g. `auto i = std::get<1>(tuple);`
/ `tuple_cat`: 串联多个 tuple。e.g. `std:tuple<int, int, int, int> = std::tuple_cat(tuple1, tuple2, std::tie(2));`
/ `tie`: #par[ 
创建对其参数或 std::ignore 实例的左值引用的元组。
```cpp
bool result;
std::tie(std::ignore, result) = tuple1;
```

因为 std::pair 可以向 std::tuple 转换，因此也可以绑定 std::pair。

此外，也可以利用 std::tie 创建临时使用的 tuple (不具有创建行为)

```cpp
struct S {
    int n;
    std::string s;
    float d;
    bool operator<(const S& rhs) const{
        // compares n to rhs.n,
        // then s to rhs.s,
        // then d to rhs.d
        return std::tie(n, s, d) < std::tie(rhs.n, rhs.s, rhs.d);
    }
};
```
]

== \<algorithm>

=== lower_bound

```cpp
// until c++20
template<class ForwardIt, class T>
ForwardIt lower_bound(ForwardIt first, ForwardIt last, const T& value);
// since c++20
template<class ForwardIt, class T>
constexpr ForwardIt lower_bound(ForwardIt first, ForwardIt last, const T& value);
```

```cpp
// until c++20
template< class ForwardIt, class T, class Compare >
ForwardIt lower_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
// since c++20
template< class ForwardIt, class T, class Compare >
constexpr ForwardIt lower_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
```

找到在 $["first", "last")$ 中第一个不满足 `comp(element, value)`($"element" < "value"$) 的元素(大于等于)。
如果元素不存在返回 `last`


二分查找不会交换使用比较器，要求比较器满足
```cpp
bool(decltype(*Iterator), T)
```

=== upper_bound
```cpp
// until c++20
template<class ForwardIt, class T>
ForwardIt upper_bound(ForwardIt first, ForwardIt last, const T& value);
// since c++20
template<class ForwardIt, class T>
constexpr ForwardIt upper_bound(ForwardIt first, ForwardIt last, const T& value);
```

```cpp
// until c++20
template< class ForwardIt, class T, class Compare >
ForwardIt upper_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
// since c++20
template< class ForwardIt, class T, class Compare >
constexpr ForwardIt upper_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
```

找到第一个在 $["first", "last")$ 中第一个不满足 `comp(value, element)`($"value" < "element"$) 的元素（严格大于）。

二分查找不会交换使用比较器，要求比较器满足
```cpp
bool(T, decltype(*Iterator))
```
== \<queue>
=== queue
```cpp
template<
  class T,
  class Container = std::deque<T>
> class queue;
```

容器必须支持 `SequenceContainer`，即支持操作:
- back()
- front()
- push_back()
- pop_front()


/ `(constructor)`: constructs the queue
/ `(destructor)`: destructs the queue
/ `operator=`: assigns values to the container adaptor

*elements access*

/ `font`: access the front element
/ `back`: access the last element

*capacity*

/ `empty`: checks whether the underlying container is empty
/ `size`: returns the number of elements

*modifiers*

/ `push`: inserts elements at the end
/ `emplace`: constructs element in-place at the end
/ `pop`: removes the first element
/ `swap`: swaps the contents

=== priority_queue

```cpp
template<
    class T,
    class Container = std::vector<T>,
    class Compare = std::less<typename Container::value_type>
> class priority_queue;
```

容器必须支持 `SequeneceContainer`，迭代器必须支持 `LegacyRandomAccessIterator`

当 `Compare` 是 `std::less` 时，`top` 取出的是最大数

/ `(constructor)`: constructs the queue
/ `(destructor)`: destructs the queue
/ `operator=`: assigns values to the container adaptor

*elements access*

/ `top`: accesses the top element

*capacity*

/ `empty`: checks whether the underlying container is empty
/ `size`: returns the number of elements

*modifiers*

/ `push`: inserts elements at the end
/ `emplace`: constructs element in-place at the end
/ `pop`: removes the first element
/ `swap`: swaps the contents

== \<set>

=== multiset
```cpp
template<
  class Key,
  class Compare = std::less<Key>,
  class Allocator = std::allocator<Key>
> class multiset;
```

*有序* 集合，类似 `std::set`，但允许多个 Key 存在。

查找，插入，删除拥有 $O(log n)$ 级的复杂度

*查找*

/ `count`: 判断特定 key 是否存在
/ `find`: 寻找特定 key, 返回 `iterator`
/ `equal_range`: 返回 `std::pair<iterator,iterator>`，表示和 Key 相等的区间。当相等区间不存在时，$"first" = "second"$ 且为第一个大于 Key 的值。两个值实际可以通过 `lower_bound` 和 `upper_bound` 获得
/ `lower_bound`: 返回第一个大于等于 Key 的值，可参见 `algroithm/lower_bound`
/ `upper_bound`: 返回第一个大于 Key 的值，可参见 `algroithm/lower_bound`

*其他操作*

/ `insert`: insert elements (or nodes c++17)
/ `emplace`: constructs element in-place
/ `erase`: 删除 `iterator pos` 元素（不接受 `end iterator`），或者删除 `iterator first, iteraotr last` 中的元素。亦或者删除 *所有* 与 `key` 相等的元素。

*内容移动*


/ `swap`: 与另一个 `multiset` 交换内容。对象不发生移动，仅含移动语义
/ `merge`: 合并另一个 `multiset` 或 `set`。对象不发生移动，具有 $O(N log(M + N))$ 的复杂度

#alert[使用不同的 allocator 是 UB]

== pb_ds
Policy-Based Data Structures

只在 `libstdc++` 为标准的编译器下可用。
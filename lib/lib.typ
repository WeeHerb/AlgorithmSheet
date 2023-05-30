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

#explain[
  参考:
  - #link("https://codeforces.com/blog/entry/11080")[C++ STL: Policy based data structures]
  - #link("https://github.com/OI-Wiki/libs/blob/master/lang/pb-ds/C%2B%2B%E7%9A%84pb_ds%E5%BA%93%E5%9C%A8OI%E4%B8%AD%E7%9A%84%E5%BA%94%E7%94%A8.pdf")[C++的pb_ds库在OI中的应用]
]

===  __gnu_pbds::priority_queue\<T>

需要 `ext/pb_ds/priority_queue.hpp`

与 `std::priority_queue` 的基本用法相同, 包括 `size()`, `empty()`, `push(const T)`, `top()`, `pop()`, `clear()`

模板参数:
```cpp
template<typename Value_Type,
  typename Cmp_Fn = std::less<Value_Type>,
  typename Tag = pairing_heap_tag,
  typename Allocator = std::allocator<char> >
class priority_queue;
```

Tag 描述所使用的堆类型, 可以是
/ `binary_heap_tag`: 二叉堆
/ `binomial_heap_tag`: 二顶堆
/ `rc_binomial_heap_tag`: 
/ `pairing_heap_tag`: 配顶堆
/ `thin_heap_tag` :


更多用法:
/ `point_iterator begin()` :
/ `point_iterator end()` :

/ `point_iterator push(const_reference)` :
/ `point_iterator modify(point_iterator, const_reference)` :
/ `void erase(point_iterator)` :

```cpp
priority_queue<int> p;
auto it = p.push(0);
p.push(1); p.push(2);
p.modify(it, 3);
assert(p.top() == 3);
p.erase(it);
assert(p.top() == 2);
```

/ `void join(priority_queue &other)`: 把 other 合并到 `*this`, 清空 `other`

#alert[白送的合并堆欸]

时间复杂度:

/ pairing_heap_tag: push 和 join 为 $O(1)$, 其他为均摊 $Theta(log n)$
/ binary_heap_tag: 只支持 push 和 join, 其他为均摊 $Theta(log n)$
/ binomial_heap_tag: push为均摊 $O(1)$, 其他为 $Theta(log n)$
/ rc_binomial_heap_tag: push 为 $O(1)$, 其他为 $Theta(log n)$
/ thin_heap_tag: push 为 $O(1)$, 不支持 join, 其他为 $Theta(log n)$; 如果只有 increase_key, 那么 modify 为均摊 $O(1)$

#alert[
  #image("pbds_priorityqueue.png")
]

=== __gnu_pbds::tree\<Key,T>

需要 `ext/pb_ds/assoc_container.hpp` 和 `ext/pb_ds/tree_policy.hpp`

与 `std::map` 的用法基本一致, 包括 `begin()`, `end()`, `size()`, `empty()`, `clear()`, `find(const Key)`, `lower_bound(const Key)`, `upper_bound(const Key)`, `erase(iterator)`, `erase(const Key)`, `insert(const pair<Key, T>)`, `operator[](const Key)`

不想用 map 而是 set, 可以把第二个模板改为 `null_type` (`null_mapped_type` 旧版), 此时迭代器会由 `pair` 变为 `Key`

```cpp
template<
  typename Key, typename Mapped,
  typename Cmp_Fn = std::less<Key>,
  typename Tag = rb_tree_tag,
  template<
    typename Const_Node_Iterator,
    typename Node_Iterator,
    typename Cmp_Fn_, typename Allocator_>
  class Node_Update = null_tree_node_update,
  typename Allocator = std::allocator<char> >
class tree;
```

Tag 指树的类型,可以是:
- `rb_tree_tag`
- `splay_tree_tag`
- `ov_tree_tag`

#alert[
  pb_ds 内部根本没有使用 splay, 而是使用了 \$p14y 7r33
]

Node_Update 如果置为 `tree_order_statistics_node_update`, 即可获得两个函数
/ `iterator find_by_order(size_type order)`: 找到第 $"order" + 1$ 小的元素迭代器, 如果太大会返回 `end()`
/ `size_type order_of_key(const_key_reference r_key)`: 有多少比 `r_key` 小的元素


更多用法:

/ `void join(tree &other)`: 把 other 中所有元素移动到 `*this` 中, 元素不能相交,否则抛出异常
/ `void split(const_key_reference r_key, tree &other)`: 清空 other, 然后把大于 `r_key` 的元素移至 `other`

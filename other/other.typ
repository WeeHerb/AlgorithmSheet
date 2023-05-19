#import "../env.typ": *

= 其他
== 对拍程序
#explain[
  我觉得 CPEditor 还是挺好用的
]
/ rand.exe: 数据生成器
/ main.exe: 被对拍程序
/ std.exe: 对拍程序

```bat
@echo off
:loop
  echo AC
  rand.exe >data.txt
  std.exe<data.txt>std.txt
  main.exe<data.txt>main.txt
  fc std.txt main.txt
if not errorlevel 1 goto loop
echo WA
pause
goto loop
```


```bash
#!/bin/bash
while true; do
  ./rand > data.txt
  ./std <data.txt >std.txt
  ./main <data.txt >main.txt
  if diff std.txt main.txt; then
    echo "AC"
  else
    echo "WA"
    exit 0
  fi
done
```
== CaksLk $arrow.l.r$ ESC

Windows:

```
Windows Registry Editor Version 5.00[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,03,00,00,00,3a,00,01,00,01,00,3a,00,00,00,00,00
```

Linux
```shell-unix-generic
setxkbmap -option caps:swapescape
```
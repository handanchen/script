#!/bin/bash
#
# 小技巧

# 求和
seq -s+ 1 10 | bc


# 打印从第一行到匹配行的上一行
sed '/match/,$d' data.txt
sed '/match/Q' data.txt


# 打印从匹配行到最后一行
sed -n '/match/,/$!/p' data.txt
sed -n '/match/,$p' data.txt


# 以空格为间隔，先按照第一个域的第2个字符开始，以第一个域的第2个字符结束排序，若相同，则再以第3个域开始，第3个域结束排序
sort -t ' ' -k 1.2,1.2 -k 3,3 data.txt

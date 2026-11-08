#!/usr/bin/env python3

import matplotlib.pyplot as plt
import pandas as pd

#data = pd.read_csv("./data/memristor.csv")
#data = pd.read_csv("./data/rs.csv")
data = pd.read_csv("./data/reram.csv")

frame = pd.DataFrame(data)

x = list(frame.iloc[:, 0])
y = list(frame.iloc[:, 1])

plt.bar(x, y, color='gray')
plt.title("")
plt.xlabel("Év")
plt.ylabel("Publikációk száma")

plt.show()


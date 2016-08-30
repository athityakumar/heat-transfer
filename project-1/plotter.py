from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np
import json

def plot(filename):
  data = json.load(open(filename+'.json', 'r'))
  data_x = json.load(open(filename+'_x.json', 'r'))
  data_y = json.load(open(filename+'_y.json', 'r'))
  height = 1.0
  length = 1.5
  mesh_size = 100.0
  fig = plt.figure()
  ax = fig.gca(projection='3d')
  X = data_x
  Y = data_y
  X, Y = np.meshgrid(X, Y)
  Z = np.array(data)
  surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.coolwarm,linewidth=0, antialiased=False)
  ax.zaxis.set_major_locator(LinearLocator(10))
  ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
  fig.colorbar(surf, shrink=0.5, aspect=5)
  cset = ax.contourf(X, Y, Z, zdir='z', offset=-100, cmap=cm.coolwarm)
  cset = ax.contourf(X, Y, Z, zdir='x', offset=-40, cmap=cm.coolwarm)
  cset = ax.contourf(X, Y, Z, zdir='y', offset=40, cmap=cm.coolwarm)

  ax.set_xlabel('X / Length')
  ax.set_xlim(0, 1.5)
  ax.set_ylabel('Y / Height')
  ax.set_ylim(0, 1.0)
  ax.set_zlabel('Temperature (C)')
  ax.set_zlim(0, 120)
  plt.show()

plot("theoretical_analysis")
plot("numerical_analysis")  
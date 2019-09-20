import json
from shapely.geometry import shape, Point
import random

with open('provincias_simple.geojson','r') as f:
    ps = json.load(f)

with open('puntos.csv','w') as f:
    print('wkt,nam,n',file=f)
    for feat in ps['features']:
         poly = shape(feat['geometry'])
         (max_x,min_x),(max_y,min_y) = [(max(i),min(i)) for i in poly.envelope.boundary.xy]
         count = 0
         while count < 10:
             pt = Point(random.uniform(min_x,max_x),random.uniform(min_y,max_y))
             if poly.contains(pt):
                 print('"{}",{},{}'.format(pt,feat['properties']['nam'],count),file=f)
                 count += 1

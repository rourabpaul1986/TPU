

from cluster_output import *  

f = open("sys_array_xdc.xdc", "a")



n=4
macx_head="{MAC_X["
macx_tail="]."
macy_head="MAC_Y["
macy_tail="].uut}"
p_head="[get_cells -quiet [list"
p_tail="]]"
slice="SLICE_X0Y0:SLICE_X40Y40", "SLICE_X41Y41:SLICE_X80Y80", "SLICE_X81Y81:SLICE_X120Y120", "SLICE_X121Y121:SLICE_X160Y160"

for j in range(0, n):
 print("create_pblock partition_"+str(j))
 f.write("create_pblock partition_"+str(j))
 print("add_cells_to_pblock [get_pblocks partition_"+str(j)+"]") 
 f.write("add_cells_to_pblock [get_pblocks partition_"+str(j)+"]")
 print(p_head)
 f.write(p_head)
 for i in range(len(a[j])):
   cell=macx_head+str(a[j][i][0])+macx_tail+macy_head+str(a[j][i][1])+macy_tail
   print(cell) 
   f.write(cell+"\n")
 print(p_tail)
 f.write(p_tail)
 print("resize_pblock [get_pblocks partition_"+str(j)+"]") 
 f.write(p_tail)
 print("-add {"+slice[j]+"}")
 f.write("-add {"+slice[j]+"}\n")
f.close()

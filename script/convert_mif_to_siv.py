#! /usr/bin/python3
import sys

def main():
    k = []
    v = []
    with open(sys.argv[1]) as f:
        for line in f:
            if line.strip() == "": 
                continue
            else:
                line = line.strip()
                l = line[0:-1].split(":")
                k.append(l[0])
                v.append(int(l[1],16))
    print("module {}#(".format(sys.argv[2]))
    print("  parameter integer width_p")
    print("  ,parameter integer depth_p")
    print(")(")
    print("  input [$clog2(depth_p)-1:0] addr_i")
    print("  ,output logic [width_p-1:0] data_o")
    print(");")
    print("always_comb unique case(addr_i)")
    for kk,vv in enumerate(k):
        print("  {}: data_o = {};".format(vv, v[kk]))
    print("  default: data_o = 'X;")
    print("endcase")
    print("endmodule")

main()
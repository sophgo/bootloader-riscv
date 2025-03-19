#!/bin/sh

# TP PC
for i in $(seq 0 7); do echo -n $i TP PC\ ; devmem 0x69${i}8050184 32; done

# GDMA CMD ID
for i in $(seq 0 7); do echo -n $i GDMA CMD ID h24 \ ; devmem 0x69${i}8011024 32; done

# TIU CMD ID
for i in $(seq 0 7); do echo -n $i TIU CMD ID\ ; devmem 0x69${i}800011c 32; done

# SDMA CMD ID
for i in $(seq 0 7); do if [ $i -le 3 ]; then let addr=0x69${i}8021000+36; else let addr=0x6B00081000+\($i-4\)*0x2000000+36; fi; echo -n $i SDMA CMD ID h24 \ ; devmem $addr 32; done

# VSDMA CMD ID
for i in $(seq 0 7); do if [ $i -le 3 ]; then let addr=0x69${i}8021000+280; else let addr=0x6B00081000+\($i-4\)*0x2000000+280; fi; echo -n $i VSDMA CMD ID\ ; devmem $addr 32; done

# CDMA CMD ID
for i in $(seq 0 10); do if [ $i -le 7 ]; then let base=0x6C00790000+\($i/4\)*0x2000000+\($i%4\)*0x10000+0x1000; else let base=0x6C08790000+\($i-8\)*0x10000; fi; let sendAddr=$base+68;  let recvAddr=$base+72; echo $i CDMA CMD ID send $(devmem $sendAddr 32), recv $(devmem $recvAddr 32); done

# msg-central, there are 8 msg-centrals in total. The following is to get the relative id of each msg-central, absolute-id = core-id * 64 + relative-id. If it is not 0, it means that the msg-id is used incorrectly.
for i in $(seq 0 7); do echo -n $i MSGID0-31 DIFF \ ; devmem 0x69${i}804041c 32; done
for i in $(seq 0 7); do echo -n $i MSGID32-63 DIFF \ ; devmem 0x69${i}8040420 32; done
for i in $(seq 0 7); do echo -n $i MSGID0-31 REUSE \ ; devmem 0x69${i}8040424 32; done
for i in $(seq 0 7); do echo -n $i MSGID32-63 REUSE \ ; devmem 0x69${i}8040428 32; done


echo "TIU FIFO, read out is similar to 0x00400005, focus on the 0x05 part, the normal range is 0x80 (no instruction in FIFO) ~ 0x0 (FIFO full)"
for i in $(seq 0 7); do echo -n $i TIU FIFO\ ; devmem 0x69${i}8000104 32; done

echo "GDMA FIFO, read out is similar to 0x80001500, focus on the 0x15 part, the normal range is 0x40 (no instruction in FIFO) ~ 0x0 (FIFO full)"
for i in $(seq 0 7); do echo -n $i GDMA FIFO h000 \ ; devmem 0x69${i}8011000 32; done

echo "SDMA FIFO, read out is similar to 0x80003900, focus on the 0x39 part, the normal range is 0x40 (no instruction in FIFO) ~ 0x0 (FIFO full)"
for i in $(seq 0 7); do if [ $i -le 3 ]; then let addr=0x69${i}8021000; else let addr=0x6B00081000+\($i-4\)*0x2000000; fi; echo -n $i SDMA FIFO h0 \ ; devmem $addr 32; done

for i in $(seq 0 7); do echo -n $i GDMA ERROR h12c \ ; devmem 0x69${i}801112c 32 ; done

for i in $(seq 0 7); do echo -n $i GDMA ERROR h110 \ ; devmem 0x69${i}8011110 32; done

for i in $(seq 0 7); do if [ $i -le 3 ]; then let addr=0x69${i}8021000+300; else let addr=0x6B00081000+\($i-4\)*0x2000000+300; fi; echo -n $i SDMA  ERROR h12c\ ; devmem $addr 32; done

for i in $(seq 0 7); do if [ $i -le 3 ]; then let addr=0x69${i}8021000+272; else let addr=0x6B00081000+\($i-4\)*0x2000000+272; fi; echo -n $i SDMA  ERROR h110\ ; devmem $addr 32; done

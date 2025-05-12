#!/bin/sh

printf "| %-8s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" "类型" "Core 0" "Core 1" "Core 2" "Core 3" "Core 4" "Core 5" "Core 6" "Core 7"
printf "|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n" "----------" "------------" "------------" "------------" "------------" "------------" "------------" "------------" "------------"

# TP PC
printf "| %-8s |" "TP PC"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}8050184 32)
  printf " %-10s |" "$value"
done
printf "\n"

# GDMA CMD ID
printf "| %-8s |" "GDMA CMD"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}8011024 32)
  printf " %-10s |" "$value"
done
printf "\n"

# TIU CMD ID
printf "| %-8s |" "TIU CMD"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}800011c 32)
  printf " %-10s |" "$value"
done
printf "\n"

# SDMA CMD ID
printf "| %-8s |" "SDMA CMD"
for i in $(seq 0 7); do
  if [ $i -le 3 ]; then
    addr=0x69${i}8021024
  else
    let addr=0x6B00081024+\($i-4\)*0x2000000
  fi
  value=$(devmem $addr 32)
  printf " %-10s |" "$value"
done
printf "\n"

# VSDMA CMD ID
printf "| %-8s |" "VSDMA CMD"
for i in $(seq 0 7); do
  if [ $i -le 3 ]; then
    addr=0x69${i}8021118
  else
    let addr=0x6B00081118+\($i-4\)*0x2000000
  fi
  value=$(devmem $addr 32)
  printf " %-10s |" "$value"
done
printf "\n"

printf "| %-8s |" "TIU FIFO"
for i in $(seq 0 7); do
  fullValue=$(devmem 0x69${i}8000104 32)
  keyPart=$(printf "%s" "$fullValue" | sed 's/.*\(..\)$/0x\1/')
  printf " %-10s |" "$keyPart"
done
printf "\n"

printf "| %-8s |" "GDMA FIFO"
for i in $(seq 0 7); do
  fullValue=$(devmem 0x69${i}8011000 32)
  keyPart=$(printf "%s" "$fullValue" | sed 's/.*00\(..\)00.*/0x\1/')
  printf " %-10s |" "$keyPart"
done
printf "\n"

printf "| %-8s |" "SDMA FIFO"
for i in $(seq 0 7); do
  if [ $i -le 3 ]; then
    addr=0x69${i}8021000
  else
    let addr=0x6B00081000+\($i-4\)*0x2000000
  fi
  fullValue=$(devmem $addr 32)
  keyPart=$(printf "%s" "$fullValue" | sed 's/.*00\(..\)00.*/0x\1/')
  printf " %-10s |" "$keyPart"
done
printf "\n"

printf "| %-12s |" "MSGID0-31 DIFF"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}804041c 32)
  printf " %-10s |" "$value"
done
printf "\n"

# MSGID32-63 DIFF
printf "| %-12s |" "MSGID32-63 DIFF"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}8040420 32)
  printf " %-10s |" "$value"
done
printf "\n"

# MSGID0-31 REUSE 行
printf "| %-12s |" "MSGID0-31 REUSE"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}8040424 32)
  printf " %-10s |" "$value"
done
printf "\n"

# MSGID32-63 REUSE 行
printf "| %-12s |" "MSGID32-63 REUSE"
for i in $(seq 0 7); do
  value=$(devmem 0x69${i}8040428 32)
  printf " %-10s |" "$value"
done


printf "\n\n"




printf "\n# CDMA CMD ID Info\n"
printf "| %-6s | %-15s | %-15s |\n" "Port" "Send CMD ID" "Recv CMD ID"
printf "|%s|%s|%s|\n" "--------" "-----------------" "-----------------"

for i in $(seq 0 10); do 
  if [ $i -le 7 ]; then 
    let base=0x6C00790000+\($i/4\)*0x2000000+\($i%4\)*0x10000+0x1000
  else 
    let base=0x6C08790000+\($i-8\)*0x10000+0x1000
  fi
  let sendAddr=$base+68
  let recvAddr=$base+72
  
  sendValue=$(devmem $sendAddr 32)
  recvValue=$(devmem $recvAddr 32)
  
  printf "| %-6d | %-15s | %-15s |\n" "$i" "$sendValue" "$recvValue"
done
printf "\n"

# Function: Extract bit range from a hex value 
extract_bits() {
  hex_value=$1  # hex value, e.g., 0x12345678
  msb=$2        # most significant bit
  lsb=$3        # least significant bit
  
  # Remove 0x prefix
  clean_hex=$(echo "$hex_value" | sed 's/^0x//')
  
  # Convert to decimal for bit manipulation
  decimal_value=$(printf "%d" "0x$clean_hex" 2>/dev/null || echo 0)
  
  # Create mask for the bits we want to extract
  mask=$(( ((1 << (msb - lsb + 1)) - 1) << lsb ))
  
  # Extract the bits and shift right
  result=$(( (decimal_value & mask) >> lsb ))
  
  # Format: return 0 as "0", non-zero as "0xN"
  if [ "$result" -eq 0 ]; then
    echo "0"
  else
    printf "0x%X" "$result"
  fi
}

# # Function: Extract a single bit from a hex value
extract_bit() {
  hex_value=$1  # hex value, e.g., 0x12345678
  bit_pos=$2    # bit position to extract (0-31)
  
  # Remove 0x prefix
  clean_hex=$(echo "$hex_value" | sed 's/^0x//')
  
  # Convert to decimal for bit manipulation
  decimal_value=$(printf "%d" "0x$clean_hex" 2>/dev/null || echo 0)
  
  # Extract the specific bit
  result=$(( (decimal_value >> bit_pos) & 1 ))
  
  # Format: return 0 as "0", 1 as "0x1"
  if [ "$result" -eq 0 ]; then
    echo "0"
  else
    echo "0x1"
  fi
}

# Define register data structure
# Format: field_name:msb:lsb:description

# h110 register definition
H110_FIELDS="dual_thrd_nxt_state:3:0:the next state of dual therad FSM
dual_thrd_mst_period:4:4:indicate that the master thread is not over when the dual thread is opened
dual_thrd_slv_period:5:5:indicate that the slave thread is not over when the dual thread is opened
mst_sync_id_block:6:6:depend_id dosent pass the syncID in master thread
slv_sync_id_block:7:7:depend_id dosent pass the syncID in slave thread
mst_sys_wait_period:8:8:sys_wait cmd in master thread
slv_sys_wait_period:9:9:sys_wait cmd in slave thread
wait_slv_thrd_end:10:10:the slave thread is over but the master thread is not over when the dual thread is opened
mst_des_fetch_cur_state:13:11:fetching descriptor FSM when des mode in master thread
slv_des_fetch_cur_state:16:14:fetching descriptor FSM when des mode in slave thread
mst_des_clear_cur_state:19:17:clear descriptro FSM in master thread, which is triggered by des_clr
slv_des_clear_cur_state:22:20:clear descriptro FSM in master thread, which is triggered by des_clr
mst_cmd_exec_cnt:25:23:the number of descriptors which are executing in master thread
slv_cmd_exec_cnt:28:26:the number of descriptors which are executing in slave thread
dma_mst_thrd_state:29:29:gdma/sdma master thread state: 0: idle; 1:active
dma_slv_thrd_state:30:30:gdma/sdma slave thread state: 0: idle; 1:active"

# h12c register definition - updated with complete fields based on example
H12C_FIELDS="mst_invld_des:0:0:master thread invalid descriptor error
slv_invld_des:1:1:slave thread invalid descriptor error
mst_des_rd_err:2:2:master thread descriptor read error
slv_des_rd_err:3:3:slave thread descriptor read error
mst_des_wr_err:4:4:master thread descriptor write error
slv_des_wr_err:5:5:slave thread descriptor write error
dtn_data_rd_err:6:6:DTN data read error
gif_data_rd_err:7:7:GIF data read error
pmu_data_wr_err:10:10:PMU data write error
dtn_data_wr_err:11:11:DTN data write error
gif_data_wr_err:12:12:GIF data write error
dma_abort:13:13:DMA abort
ip_hang:14:14:IP hang error
des_hang:15:15:descriptor hang error
mst_depend_id_err:16:16:master depend ID error
slv_depend_id_err:17:17:slave depend ID error
des_mode_set_err:18:18:des mode set error
thrd_cmd_cfg_err:19:19:thread command config error
mst_inst_parity_err_intrp:20:20:master inst parity error intrp
slv_inst_parity_err_intrp:21:21:slave inst parity error intrp
mst_mpu_fetch_addr_err:22:22:master MPU fetch addr error
slv_mpu_fetch_addr_err:23:23:slave MPU fetch addr error
mst_mpu_inst_araddr_err:24:24:master MPU inst araddr error
mst_mpu_inst_awaddr_err:25:25:master MPU inst awaddr error
slv_des_mode_set_err:26:26:slave des mode set error
mst_mpu_inst_awaddr_err:27:27:master MPU inst awaddr error
slv_mpu_inst_awaddr_err:28:28:slave MPU inst awaddr error
mpu_pmu_awaddr_err:29:29:MPU PMU awaddr error"

# Function to print register field description table
print_register_description() {
  reg_addr=$1
  reg_fields=$2
  
  printf "\n## %s Register Field Descriptions\n\n" "$reg_addr"
  printf "| %-25s | %-12s | %-50s |\n" "Field Name" "Bits[MSB:LSB]" "Description"
  printf "|%s|%s|%s|\n" "------------------------" "--------------" "----------------------------------------------------"
  
  echo "$reg_fields" | while IFS=: read -r field_name msb lsb description; do
    [ -z "$field_name" ] && continue
    printf "| %-25s | [%-2s:%-2s]%5s | %-50s |\n" "$field_name" "$msb" "$lsb" "" "$description"
  done
}

# Function to get all cores' register values
get_all_gdma_register() {
  reg_addr=$1
  
  result=""
  for i in $(seq 0 7); do
    case "$reg_addr" in
      "h110")
        value=$(devmem 0x69${i}8011110 32)
        ;;
      "h12c")
        value=$(devmem 0x69${i}801112c 32)
        ;;
      *)
        value="0x00000000"
        ;;
    esac
    
    result="$result $value"
  done
  
  echo "$result"
}

get_all_sdma_register() {
  reg_addr=$1
  
  result=""
  for i in $(seq 0 7); do
    case "$reg_addr" in
      "h110")
        if [ $i -le 3 ]; then
          let addr=0x69${i}8021000+272
        else
          let addr=0x6B00081000+\($i-4\)*0x2000000+272
        fi
        value=$(devmem $addr 32)
        ;;
      "h12c")
        if [ $i -le 3 ]; then
          let addr=0x69${i}8021000+300
        else
          let addr=0x6B00081000+\($i-4\)*0x2000000+300
        fi
        value=$(devmem $addr 32)
        ;;
      *)
        value="0x00000000"
        ;;
    esac
    
    result="$result $value"
  done
  
  echo "$result"
}

# Function to print register field values for all cores
print_register_fields() {
  reg_addr=$1
  reg_fields=$2
  values=$3
  engine_name=$4
  
  printf "## %s %s Register Values for All Cores\n\n" "$engine_name" "$reg_addr"
  
  # Print header
  printf "| %-25s |" "Field Name"
  for i in $(seq 0 7); do
    printf " %-10s |" "Core $i"
  done
  printf "\n|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n" "------------------------" "------------" "------------" "------------" "------------" "------------" "------------" "------------" "------------"
  
  # For each field, extract and print values
  echo "$reg_fields" | while IFS=: read -r field_name msb lsb description; do
    [ -z "$field_name" ] && continue
    printf "| %-25s |" "$field_name"
    
    core_index=0
    for value in $values; do
      # Extract field value based on msb:lsb
      if [ "$msb" = "$lsb" ]; then
        # Single bit field
        bit_value=$(extract_bit "$value" "$lsb")
        printf " %-10s |" "$bit_value"
      else
        # Multi-bit field - extract specific bits
        field_value=$(extract_bits "$value" "$msb" "$lsb")
        printf " %-10s |" "$field_value"
      fi
      
      core_index=$((core_index + 1))
    done
    printf "\n"
  done
}

# Main execution

# Print register descriptions
print_register_description "h110" "$H110_FIELDS"
print_register_description "h12c" "$H12C_FIELDS"

# Get register values for all cores
gdma_h110_values=$(get_all_gdma_register "h110")
gdma_h12c_values=$(get_all_gdma_register "h12c")

# Print register values tables
print_register_fields "h110" "$H110_FIELDS" "$gdma_h110_values" "GDMA"
print_register_fields "h12c" "$H12C_FIELDS" "$gdma_h12c_values" "GDMA"

sdma_h110_values=$(get_all_sdma_register "h110")
sdma_h12c_values=$(get_all_sdma_register "h12c")

print_register_fields "h110" "$H110_FIELDS" "$sdma_h110_values" "SDMA"
print_register_fields "h12c" "$H12C_FIELDS" "$sdma_h12c_values" "SDMA"

# Function to extract a single bit from a 128-bit hex value
extract_bit_128() {
  hex_value=$1   # 128-bit hex value as string (with or without 0x prefix)
  bit_pos=$2     # bit position to extract (0-127)
  
  # Remove 0x prefix if present
  hex_value=$(echo "$hex_value" | sed 's/^0x//')
  
  # Calculate which hex digit contains this bit (hex digits are 4 bits each)
  # Counting from the right (least significant) side
  hex_digit_pos=$(( (127 - bit_pos) / 4 ))
  
  # Calculate which bit within that hex digit (0-3, from least to most significant)
  bit_in_digit=$(( 3 - ((127 - bit_pos) % 4) ))
  
  # Extract the hex digit
  digit=$(echo "$hex_value" | cut -c$(( hex_digit_pos + 1 )))
  
  # Convert hex digit to decimal
  decimal=$(printf "%d" "0x$digit" 2>/dev/null || echo 0)
  
  # Extract the specific bit
  result=$(( (decimal >> bit_in_digit) & 1 ))
  
  echo "$result"
}

# Function to extract a range of bits from a 128-bit hex value
extract_bits_128() {
  hex_value=$1   # 128-bit hex value as string
  msb=$2         # most significant bit
  lsb=$3         # least significant bit
  
  # Remove 0x prefix if present
  hex_value=$(echo "$hex_value" | sed 's/^0x//')
  
  # Calculate number of bits to extract
  num_bits=$(( msb - lsb + 1 ))
  
  # Initialize result
  result=0
  
  # Extract each bit and compose the result
  for bit_pos in $(seq $lsb $msb); do
    bit_val=$(extract_bit_128 "0x$hex_value" $bit_pos)
    position=$(( bit_pos - lsb ))
    result=$(( result | (bit_val << position) ))
  done
  
  printf "0x%X" "$result"
}

# Function to get cmd_type description
get_dma_cmd_type_desc() {
  cmd_type_val=$1
  case "$cmd_type_val" in
    "0x0") echo "GDMA_tensor" ;;
    "0x1") echo "GDMA_matrix" ;;
    "0x2") echo "GDMA_masked_select" ;;
    "0x3") echo "GDMA_general" ;;
    "0x4") echo "GDMA_cv_transpose" ;;
    "0x5") echo "GDMA_nonzero" ;;
    "0x6") echo "GDMA_sys" ;;
    "0x7") echo "GDMA_gather" ;;
    "0x8") echo "GDMA_scatter" ;;
    "0x9") echo "GDMA_reverse" ;;
    "0xA") echo "GDMA_compress" ;;
    "0xB") echo "GDMA_decompress" ;;
    "0xE") echo "GDMA_randmask" ;;
    "0x10") echo "GDMA_transfer" ;;
    *) echo "Unknown" ;;
  esac
}

# Function to get cmd_special_function description
get_dma_special_function_desc() {
  func_val=$1
  cmd_type=$2
  
  # Only show special function descriptions for GDMA_sys (0x6), otherwise "-"
  if [ "$cmd_type" = "0x6" ]; then
    case "$func_val" in
      "0x0") echo "chain_end" ;;
      "0x1") echo "nop" ;;
      "0x2") echo "sys_tr_wr" ;;
      "0x3") echo "sys_send" ;;
      "0x4") echo "sys_wait" ;;
      "0x5") echo "sys_fork" ;;
      "0x6") echo "sys_join" ;;
      "0x7") echo "sys_exit" ;;
      *) echo "Unknown" ;;
    esac
  else
    echo "-"
  fi
}

# Function to get dependency enable/disable description
get_dep_enable_desc() {
  bit_val=$1
  if [ "$bit_val" = "1" ]; then
    echo "enabled"
  else
    echo "disabled"
  fi
}

# Read data from all cores first
echo "GDMA CMD Info"
for i in $(seq 0 7); do
  let addr=0x6908010000+\($i\*\(1\<\<28\)\)
  full_value=$(devmem $addr 128)
  
  # Extract the fields
  cmd_short=$(extract_bit_128 "$full_value" 3)
  cmd_type=$(extract_bits_128 "$full_value" 36 32)
  cmd_special_function=$(extract_bits_128 "$full_value" 39 37)
  cmd_type_desc=$(get_dma_cmd_type_desc "$cmd_type")
  cmd_special_desc=$(get_dma_special_function_desc "$cmd_special_function" "$cmd_type")
  
  # Extract cmd_id_dep field (21 bits)
  cmd_id_dep=$(extract_bits_128 "$full_value" 60 40)
  
  # Extract the dependency enable bit (bit 20) and depend ID (bits 19:0)
  dep_enable_bit=$(extract_bit_128 "$full_value" 60)
  depend_id=$(extract_bits_128 "$full_value" 59 40)
  
  # Extract message count and message ID fields (for sys_wait)
  msg_cnt=$(extract_bits_128 "$full_value" 127 105)   # scnt[7:0]
  msg_id=$(extract_bits_128 "$full_value" 105 96)     # message_id[9:0]
  
  # Store raw values
  eval "cmd_short_$i=\"$cmd_short\""
  eval "cmd_type_desc_$i=\"$cmd_type_desc\""
  eval "cmd_special_desc_$i=\"$cmd_special_desc\""
  eval "cmd_id_dep_$i=\"$cmd_id_dep\""
  eval "dep_enable_$i=\"$dep_enable_bit\""
  eval "depend_id_$i=\"$depend_id\""
  eval "msg_cnt_$i=\"$msg_cnt\""
  eval "msg_id_$i=\"$msg_id\""
done

# Print table header with core numbers
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" "Field" "Core 0" "Core 1" "Core 2" "Core 3" "Core 4" "Core 5" "Core 6" "Core 7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print cmd_short row with the field name in the first column
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_short" "$cmd_short_0" "$cmd_short_1" "$cmd_short_2" "$cmd_short_3" "$cmd_short_4" "$cmd_short_5" "$cmd_short_6" "$cmd_short_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_type" "$cmd_type_desc_0" "$cmd_type_desc_1" "$cmd_type_desc_2" "$cmd_type_desc_3" "$cmd_type_desc_4" "$cmd_type_desc_5" "$cmd_type_desc_6" "$cmd_type_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print cmd_special_function row with descriptions
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_special_func" "$cmd_special_desc_0" "$cmd_special_desc_1" "$cmd_special_desc_2" "$cmd_special_desc_3" "$cmd_special_desc_4" "$cmd_special_desc_5" "$cmd_special_desc_6" "$cmd_special_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
# Print dependency enable/disable status row
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "dep_id_enable" "$dep_enable_0" "$dep_enable_1" "$dep_enable_2" "$dep_enable_3" "$dep_enable_4" "$dep_enable_5" "$dep_enable_6" "$dep_enable_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print depend ID row (raw hex value)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "depend_id" "$depend_id_0" "$depend_id_1" "$depend_id_2" "$depend_id_3" "$depend_id_4" "$depend_id_5" "$depend_id_6" "$depend_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message count row (for sys_wait)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_cnt" "$msg_cnt_0" "$msg_cnt_1" "$msg_cnt_2" "$msg_cnt_3" "$msg_cnt_4" "$msg_cnt_5" "$msg_cnt_6" "$msg_cnt_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message ID row (for sys_wait)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_id" "$msg_id_0" "$msg_id_1" "$msg_id_2" "$msg_id_3" "$msg_id_4" "$msg_id_5" "$msg_id_6" "$msg_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

echo "SDMA CMD Info"
for i in $(seq 0 7); do
  if [ $i -le 3 ]; then
    # For SDMA 0-3
    addr=0x69${i}8020000
    full_value=$(devmem $addr 128)
  else
    # For SDMA 4-7
    let addr=0x6B00080000+\($i-4\)*0x2000000
    
    # SDMA 4-7 doesn't support 128-bit reads, need to read 32 bits at a time
    val1=$(devmem $addr 32)
    val2=$(devmem $(printf "0x%X" $((addr+4))) 32)
    val3=$(devmem $(printf "0x%X" $((addr+8))) 32)
    val4=$(devmem $(printf "0x%X" $((addr+12))) 32)
    
    # Remove 0x prefix and combine values (most significant bits first)
    val1=${val1#0x}
    val2=${val2#0x}
    val3=${val3#0x}
    val4=${val4#0x}
    full_value="0x${val4}${val3}${val2}${val1}"
    
    # Skip the next devmem call since we already have our full_value
    continue_processing=1
  fi
  
  # Reset the flag for the next iteration
  unset continue_processing
  
  # Extract the fields
  cmd_short=$(extract_bit_128 "$full_value" 3)
  cmd_type=$(extract_bits_128 "$full_value" 36 32)
  cmd_special_function=$(extract_bits_128 "$full_value" 39 37)
  cmd_type_desc=$(get_dma_cmd_type_desc "$cmd_type")
  cmd_special_desc=$(get_dma_special_function_desc "$cmd_special_function" "$cmd_type")
  
  # Extract cmd_id_dep field (21 bits)
  cmd_id_dep=$(extract_bits_128 "$full_value" 60 40)
  
  # Extract the dependency enable bit (bit 20) and depend ID (bits 19:0)
  dep_enable_bit=$(extract_bit_128 "$full_value" 60)
  depend_id=$(extract_bits_128 "$full_value" 59 40)
  
  # Extract message count and message ID fields (for sys_wait)
  msg_cnt=$(extract_bits_128 "$full_value" 127 105)   # scnt[7:0]
  msg_id=$(extract_bits_128 "$full_value" 105 96)     # message_id[9:0]
  
  # Store raw values
  eval "cmd_short_$i=\"$cmd_short\""
  eval "cmd_type_$i=\"$cmd_type\""
  eval "cmd_type_desc_$i=\"$cmd_type_desc\""
  eval "cmd_special_$i=\"$cmd_special_function\""
  eval "cmd_special_desc_$i=\"$cmd_special_desc\""
  eval "cmd_id_dep_$i=\"$cmd_id_dep\""
  eval "dep_enable_$i=\"$dep_enable_bit\""
  eval "depend_id_$i=\"$depend_id\""
  eval "msg_cnt_$i=\"$msg_cnt\""
  eval "msg_id_$i=\"$msg_id\""
done

# Print table header with core numbers
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" "Field" "Core 0" "Core 1" "Core 2" "Core 3" "Core 4" "Core 5" "Core 6" "Core 7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print cmd_short row with the field name in the first column
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_short" "$cmd_short_0" "$cmd_short_1" "$cmd_short_2" "$cmd_short_3" "$cmd_short_4" "$cmd_short_5" "$cmd_short_6" "$cmd_short_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_type" "$cmd_type_desc_0" "$cmd_type_desc_1" "$cmd_type_desc_2" "$cmd_type_desc_3" "$cmd_type_desc_4" "$cmd_type_desc_5" "$cmd_type_desc_6" "$cmd_type_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print cmd_special_function row with descriptions
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "cmd_special_func" "$cmd_special_desc_0" "$cmd_special_desc_1" "$cmd_special_desc_2" "$cmd_special_desc_3" "$cmd_special_desc_4" "$cmd_special_desc_5" "$cmd_special_desc_6" "$cmd_special_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
# Print dependency enable/disable status row
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "dep_id_enable" "$dep_enable_0" "$dep_enable_1" "$dep_enable_2" "$dep_enable_3" "$dep_enable_4" "$dep_enable_5" "$dep_enable_6" "$dep_enable_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print depend ID row (raw hex value)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "depend_id" "$depend_id_0" "$depend_id_1" "$depend_id_2" "$depend_id_3" "$depend_id_4" "$depend_id_5" "$depend_id_6" "$depend_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message count row (for sys_wait)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_cnt" "$msg_cnt_0" "$msg_cnt_1" "$msg_cnt_2" "$msg_cnt_3" "$msg_cnt_4" "$msg_cnt_5" "$msg_cnt_6" "$msg_cnt_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message ID row (for sys_wait)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_id" "$msg_id_0" "$msg_id_1" "$msg_id_2" "$msg_id_3" "$msg_id_4" "$msg_id_5" "$msg_id_6" "$msg_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Function to get task type description
get_tsk_type_desc() {
  tsk_type_val=$1
  case "$tsk_type_val" in
    "0x0") echo "CONV" ;;
    "0x1") echo "PD" ;;
    "0x2") echo "MM" ;;
    "0x3") echo "AR" ;;
    "0x4") echo "RQDQ" ;;
    "0x5") echo "TRANS_BC" ;;
    "0x6") echo "SG" ;;
    "0x7") echo "LAR" ;;
    "0x8") echo "RANDOM_GEN" ;;
    "0x9") echo "SFU" ;;
    "0xA") echo "LIN" ;;
    "0xC") echo "SYS_TRWR" ;;
    "0xD") echo "CMP" ;;
    "0xE") echo "VC" ;;
    "0xF") echo "SYS" ;;
    *) echo "Unknown" ;;
  esac
}

# Function to get task EU type description based on task type
get_tsk_eu_typ_desc() {
  tsk_type=$1
  eu_type=$2
  
  # Only provide special description for SYS tasks
  if [ "$tsk_type" = "0xF" ]; then
    case "$eu_type" in
      "0x0") echo "intr_barrier" ;;
      "0x1") echo "spb" ;;
      "0x2") echo "swr" ;;
      "0x3") echo "swr_from_lmem" ;;
      "0x4") echo "swr_collect_from_lmem" ;;
      "0x5") echo "data_barrier" ;;
      "0x8") echo "send_msg" ;;
      "0x9") echo "wait_msg" ;;
      "0xA") echo "sys_fork" ;;
      "0xB") echo "sys_join" ;;
      "0xC") echo "sys_exit" ;;
      "0xD") echo "rand_seed" ;;
      "0x1E") echo "nop" ;;
      "0x1F") echo "end" ;;
      *) echo "Unknown" ;;
    esac
  else
    # For non-SYS tasks, return "-"
    echo "-"
  fi
}

# Read TIU CMD
echo "TIU CMD Info"
for i in $(seq 0 7); do
  let addr=0x6908000000+\($i\*\(1\<\<28\)\)
  full_value=$(devmem $addr 128)

  short_cmd=$(extract_bit_128 "$full_value" 0)

  # Extract dependency enable bit (bit 37)
  dep_enable_bit=$(extract_bit_128 "$full_value" 37)
  
  # Extract dependency ID (bits 36-17, 20 bits)
  depend_id=$(extract_bits_128 "$full_value" 36 17)
  
  # Extract des_tsk_typ (bits 44-41)
  des_tsk_typ=$(extract_bits_128 "$full_value" 44 41)
  des_tsk_typ_desc=$(get_tsk_type_desc "$des_tsk_typ")
  
  # Extract des_tsk_eu_typ (bits 49-45)
  des_tsk_eu_typ=$(extract_bits_128 "$full_value" 49 45)
  des_tsk_eu_typ_desc=$(get_tsk_eu_typ_desc "$des_tsk_typ" "$des_tsk_eu_typ")
  
  # Extract message ID (bits 6-0 of des_imm)
  msg_id=$(extract_bits_128 "$full_value" 73 64)
  
  # Extract message count (bits 22-16 of des_imm)
  msg_cnt=$(extract_bits_128 "$des_imm" 87 80)
  
  # Store the extracted values
  eval "tiu_short_cmd_$i=\"$short_cmd\""
  eval "tiu_dep_enable_$i=\"$dep_enable_bit\""
  eval "tiu_depend_id_$i=\"$depend_id\""
  eval "tiu_des_tsk_typ_$i=\"$des_tsk_typ\""
  eval "tiu_des_tsk_typ_desc_$i=\"$des_tsk_typ_desc\""
  eval "tiu_des_tsk_eu_typ_$i=\"$des_tsk_eu_typ\""
  eval "tiu_des_tsk_eu_typ_desc_$i=\"$des_tsk_eu_typ_desc\""
  eval "tiu_msg_id_$i=\"$msg_id\""
  eval "tiu_msg_cnt_$i=\"$msg_cnt\""
done

# Print TIU register information in a table
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" "TIU Field" "Core 0" "Core 1" "Core 2" "Core 3" "Core 4" "Core 5" "Core 6" "Core 7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print short_cmd row with the field name in the first column
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "short_cmd" "$tiu_short_cmd_0" "$tiu_short_cmd_1" "$tiu_short_cmd_2" "$tiu_short_cmd_3" "$tiu_short_cmd_4" "$tiu_short_cmd_5" "$tiu_short_cmd_6" "$tiu_short_cmd_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print dependency enable/disable status row
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "dep_id_enable" "$tiu_dep_enable_0" "$tiu_dep_enable_1" "$tiu_dep_enable_2" "$tiu_dep_enable_3" "$tiu_dep_enable_4" "$tiu_dep_enable_5" "$tiu_dep_enable_6" "$tiu_dep_enable_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print depend ID row (raw hex value)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "depend_id" "$tiu_depend_id_0" "$tiu_depend_id_1" "$tiu_depend_id_2" "$tiu_depend_id_3" "$tiu_depend_id_4" "$tiu_depend_id_5" "$tiu_depend_id_6" "$tiu_depend_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print des_tsk_typ_desc row (string description)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "tsk_type" "$tiu_des_tsk_typ_desc_0" "$tiu_des_tsk_typ_desc_1" "$tiu_des_tsk_typ_desc_2" "$tiu_des_tsk_typ_desc_3" "$tiu_des_tsk_typ_desc_4" "$tiu_des_tsk_typ_desc_5" "$tiu_des_tsk_typ_desc_6" "$tiu_des_tsk_typ_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print des_tsk_eu_typ row with description for SYS tasks
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "tsk_eu_typ" "$tiu_des_tsk_eu_typ_desc_0" "$tiu_des_tsk_eu_typ_desc_1" "$tiu_des_tsk_eu_typ_desc_2" "$tiu_des_tsk_eu_typ_desc_3" "$tiu_des_tsk_eu_typ_desc_4" "$tiu_des_tsk_eu_typ_desc_5" "$tiu_des_tsk_eu_typ_desc_6" "$tiu_des_tsk_eu_typ_desc_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message ID row (for send_msg/wait_msg)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_id" "$tiu_msg_id_0" "$tiu_msg_id_1" "$tiu_msg_id_2" "$tiu_msg_id_3" "$tiu_msg_id_4" "$tiu_msg_id_5" "$tiu_msg_id_6" "$tiu_msg_id_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

# Print message count row (for send_msg/wait_msg)
printf "| %-16s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s |\n" \
  "msg_cnt" "$tiu_msg_cnt_0" "$tiu_msg_cnt_1" "$tiu_msg_cnt_2" "$tiu_msg_cnt_3" "$tiu_msg_cnt_4" "$tiu_msg_cnt_5" "$tiu_msg_cnt_6" "$tiu_msg_cnt_7"
printf "+------------------+------------+------------+------------+------------+------------+------------+------------+------------+\n"

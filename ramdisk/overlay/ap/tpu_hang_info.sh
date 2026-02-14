#!/bin/sh

chip_id=$(devmem 0x7050000000 32)

echo "chip_id: $chip_id"

if [ "$chip_id" = "0x20440000" ]; then
  core_num=8
else
  core_num=4
fi


# Helper function: Print dynamic separator line
print_dynamic_separator() {
  printf "+------------------"
  for i in $(seq 0 $((core_num - 1))); do
    printf "+----------------"
  done
  printf "+\n"
}

# Helper function: Print dynamic header
print_dynamic_header() {
  first_col_name=$1
  print_dynamic_separator
  printf "| %-16s " "$first_col_name"
  for i in $(seq 0 $((core_num - 1))); do
    printf "| %-14s " "Core $i"
  done
  printf "|\n"
  print_dynamic_separator
}

# Helper function: Print dynamic data row
# Usage: print_dynamic_row "Row Label" "variable_prefix"
print_dynamic_row() {
  label=$1
  var_prefix=$2
  
  printf "| %-16s " "$label"
  for i in $(seq 0 $((core_num - 1))); do
    # Construct variable name dynamically (e.g., tp_value_0)
    eval "val=\${${var_prefix}_${i}}"
    printf "| %-14s " "$val"
  done
  printf "|\n"
  print_dynamic_separator
}

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
  # mask=$((((1<<(msb-lsb+1))-1)<<lsb ))
  width=$((msb - lsb + 1))
  mask=$(( ((1 << width) - 1) << lsb ))
  
  # Extract the bits and shift right
  result=$(( (decimal_value & mask) >> lsb ))
  
  # Format: return 0 as "0", non-zero as "0xN"
  if [ "$result" -eq 0 ]; then
    echo "0"
  else
    printf "0x%X" "$result"
  fi
}

# Function: Extract a single bit from a hex value
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
DMA_H110_FIELDS="dual_thrd_nxt_state:3:0:the next state of dual therad FSM
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
DMA_H12C_FIELDS="mst_invld_des:0:0:master thread invalid descriptor error
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
  printf "|%s|%s|%s|\n" "---------------------------" "--------------" "----------------------------------------------------"
  
  echo "$reg_fields" | while IFS=: read -r field_name msb lsb description; do
    [ -z "$field_name" ] && continue
    printf "| %-25s | [%-2s:%-2s]%5s | %-50s |\n" "$field_name" "$msb" "$lsb" "" "$description"
  done
}

# Function to get all cores' register values
get_all_gdma_register() {
  reg_addr=$1
  
  result=""
  for i in $(seq 0 $((core_num - 1))); do
    case "$reg_addr" in
      "h110")
        value=$(devmem 0x69${i}8011110 32)
        ;;
      "h12c")
        value=$(devmem 0x69${i}801112c 32)
        ;;
      "h0")
        value=$(devmem 0x69${i}8011000 32)
        ;;
      *)
        value="0xdeadbeef"
        ;;
    esac
    
    result="$result $value"
  done
  
  echo "$result"
}

get_all_sdma_register() {
  reg_addr=$1
  
  result=""
  for i in $(seq 0 $((core_num - 1))); do
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
      "h0")
        if [ $i -le 3 ]; then
          let addr=0x69${i}8021000
        else
          let addr=0x6B00081000+\($i-4\)*0x2000000
        fi
        value=$(devmem $addr 32)
        ;;
      *)
        value="0xdeadbeef"
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
  
  # 1. Print Dynamic Header
  printf "| %-25s |" "Field Name"
  for i in $(seq 0 $((core_num - 1))); do
    printf " %-10s |" "Core $i"
  done
  printf "\n"

  # 2. Print Dynamic Separator
  # Field column separator (25 chars + 2 spaces)
  printf "|%s|" "---------------------------"
  for i in $(seq 0 $((core_num - 1))); do
    # Core column separator (10 chars + 2 spaces)
    printf "%s|" "------------"
  done
  printf "\n"
  
  # 3. Print Dynamic Rows
  echo "$reg_fields" | while IFS=: read -r field_name msb lsb description; do
    [ -z "$field_name" ] && continue
    printf "| %-25s |" "$field_name"
    
    # Iterate through values. 
    # Since values are space-separated strings generated by get_all_* registers
    # based on core_num, this loop naturally matches the core count.
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
    done
    printf "\n"
  done
}

# Main execution

# Print register descriptions
print_register_description "h110" "$DMA_H110_FIELDS"
print_register_description "h12c" "$DMA_H12C_FIELDS"

# Get register values for all cores
gdma_h110_values=$(get_all_gdma_register "h110")
gdma_h12c_values=$(get_all_gdma_register "h12c")


# Print register values tables
print_register_fields "h110" "$DMA_H110_FIELDS" "$gdma_h110_values" "GDMA"
print_register_fields "h12c" "$DMA_H12C_FIELDS" "$gdma_h12c_values" "GDMA"

sdma_h110_values=$(get_all_sdma_register "h110")
sdma_h12c_values=$(get_all_sdma_register "h12c")

print_register_fields "h110" "$DMA_H110_FIELDS" "$sdma_h110_values" "SDMA"
print_register_fields "h12c" "$DMA_H12C_FIELDS" "$sdma_h12c_values" "SDMA"

get_msg_id_usage() {
  local input=$1
  input=$(printf "%d" "$input")
  if ! [[ "$input" =~ ^[0-9]+$ ]]; then
      echo "error: please input a valid number"
      return 1
  fi

  if [ $input -lt 0 ] || [ $input -gt 511 ]; then
      echo "error: number must be in 0-511 range"
      return 1
  fi

  if [ $input -ge 0 ] && [ $input -le 127 ]; then
      echo "0x$(printf "%x" $input)(crs)"
  elif [ $input -ge 128 ] && [ $input -le 191 ]; then
      echo "0x$(printf "%x" $input)(prv)"
  elif [ $input -ge 192 ] && [ $input -le 255 ]; then
      echo "0x$(printf "%x" $input)(glb)"
  elif [ $input -ge 256 ] && [ $input -le 319 ]; then
      echo "0x$(printf "%x" $input)(sch)"
  elif [ $input -ge 320 ] && [ $input -le 383 ]; then
      echo "0x$(printf "%x" $input)(c2c)"
  elif [ $input -ge 384 ] && [ $input -le 511 ]; then
      echo "0x$(printf "%x" $input)(rt)"
  fi
}

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
  
  # Initialize result
  result=0
  # Start with 2^0 = 1
  current_pos_val=1
  
  # Extract each bit and compose the result
  for bit_pos in $(seq $lsb $msb); do
    bit_val=$(extract_bit_128 "0x$hex_value" $bit_pos)
    
    # If bit is 1, add current position value to result
    if [ "$bit_val" -eq 1 ]; then
      result=$(( result | current_pos_val ))
    fi
    
    # Prepare for next iteration: multiply by 2 (equivalent to << 1)
    # We use addition (+) to strictly avoid '<<' syntax highlighting bugs
    current_pos_val=$(( current_pos_val + current_pos_val ))
  done
  
  printf "0x%X" "$result"
}

function remove_unnecessary_zero() {
  value=$1
  value=$(printf "%d" $value)
  value=$(printf "0x%X" $value)
  echo "$value"
}

printf "\n"
printf "\n"

for i in $(seq 0 $((core_num - 1))); do
  tp_value=$(devmem 0x69${i}8050184 32)
  msgid0_31_diff=$(devmem 0x69${i}804041c 32)
  msgid0_31_diff=$(remove_unnecessary_zero $msgid0_31_diff)
  msgid32_63_diff=$(devmem 0x69${i}8040420 32)
  msgid32_63_diff=$(remove_unnecessary_zero $msgid32_63_diff)
  msgid0_31_reuse=$(devmem 0x69${i}8040424 32)
  msgid0_31_reuse=$(remove_unnecessary_zero $msgid0_31_reuse)
  msgid32_63_reuse=$(devmem 0x69${i}8040428 32)
  msgid32_63_reuse=$(remove_unnecessary_zero $msgid32_63_reuse)

  eval "tp_value_$i=\"$tp_value\""
  eval "msgid0_31_diff_$i=\"$msgid0_31_diff\""
  eval "msgid32_63_diff_$i=\"$msgid32_63_diff\""
  eval "msgid0_31_reuse_$i=\"$msgid0_31_reuse\""
  eval "msgid32_63_reuse_$i=\"$msgid32_63_reuse\""
done

printf "TP Info & MSG Central Info\n"
# Print dynamic header
print_dynamic_header "Field"

# Print dynamic rows using the variable prefixes defined in the loop above
print_dynamic_row "TP PC" "tp_value"
print_dynamic_row "MSGID0-31 DIFF" "msgid0_31_diff"
print_dynamic_row "MSGID32-63 DIFF" "msgid32_63_diff"
print_dynamic_row "MSGID0-31 REUSE" "msgid0_31_reuse"
print_dynamic_row "MSGID32-63 REUSE" "msgid32_63_reuse"

printf "\n\n"

if [ $core_num -eq 8 ]; then
  printf "CDMA CMD Info\n"
  # Print table header with core numbers
  printf "+------------------+----------------+----------------+----------------+----------------+\n"
  printf "| %-16s | %-14s | %-14s | %-14s | %-14s |\n" "Port" "Send CmdId" "Recv CmdId" "Des addr" "Base Addr"
  printf "+------------------+----------------+----------------+----------------+----------------+\n"

  for i in $(seq 0 10); do 
    if [ $i -le 7 ]; then
      let base_addr=0x6C00790000+\($i/4\)*0x2000000+\($i%4\)*0x10000
      let base=$base_addr+0x1000
    else 
      let base_addr=0x6C08790000+\($i-8\)*0x10000
      let base=$base_addr+0x1000
    fi
    base_addr=$(printf "0x%X" $base_addr)
    let sendAddr=$base+68
    let recvAddr=$base+72
    let desAddr=$base+0x2c
    
    sendValue=$(devmem $sendAddr 32)
    sendValue=$(remove_unnecessary_zero $sendValue)
    recvValue=$(devmem $recvAddr 32)
    recvValue=$(remove_unnecessary_zero $recvValue)
    desValue=$(devmem $desAddr 32)
    # Shift left by 7 is equivalent to multiplying by 128
    # Using multiplication avoids syntax highlighting bugs with '<<'
    desValue=$((desValue * 128))
    desValue=$(remove_unnecessary_zero $desValue)
    printf "| %-16s | %-14s | %-14s | %-14s | %-14s |\n" "$i" "$sendValue" "$recvValue" "$desValue" "$base_addr"
    printf "+------------------+----------------+----------------+----------------+----------------+\n"
  done
fi

# Function to get cmd_type description
get_dma_cmd_type_desc() {
  cmd_type_val=$1
  case "$cmd_type_val" in
    "0x0") echo "tensor" ;;
    "0x1") echo "matrix" ;;
    "0x2") echo "mask sel" ;;
    "0x3") echo "general" ;;
    "0x4") echo "cw trans" ;;
    "0x5") echo "nonzero" ;;
    "0x6") echo "sys" ;;
    "0x7") echo "gather" ;;
    "0x8") echo "scatter" ;;
    "0x9") echo "reverse" ;;
    "0xA") echo "compress" ;;
    "0xB") echo "decompress" ;;
    "0xE") echo "randmask" ;;
    "0x10") echo "transfer" ;;
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
      "0x0") echo "end" ;;
      "0x1") echo "nop" ;;
      "0x2") echo "tr wr" ;;
      "0x3") echo "send" ;;
      "0x4") echo "wait" ;;
      *) echo "Unknown" ;;
    esac
  else
    echo "-"
  fi
}

printf "\n\n"

# Read data from all cores first
echo "GDMA CMD Info"
for i in $(seq 0 $((core_num - 1))); do
  let addr=0x6908010000+\($i\*\(1\<\<28\)\)
  full_value=$(devmem $addr 128)
  let des_addr=0x6908011004+\($i\*\(1\<\<28\)\)
  des_value=$(devmem $des_addr 32)
  # des_value=$((des_value << 7))
  # Shift left by 7 is equivalent to multiplying by 128
  # Using multiplication avoids syntax highlighting bugs with '<<'
  des_value=$((des_value * 128))
  des_value=$(printf "0x%X" $des_value)
  cmd_id=$(devmem 0x69${i}8011024 32)
  cmd_id=$(remove_unnecessary_zero $cmd_id)
  let csr=$addr+0x1000
  csr0=$(devmem $csr 32)
  des_enable=$(extract_bit "$csr0" 0)
  mst_fifo=$(extract_bits "$csr0" 14 8)
  base_msg_id=$(extract_bits "$csr0" 24 16)
  
  # Extract the fields
  cmd_short=$(extract_bit_128 "$full_value" 3)
  cmd_type=$(extract_bits_128 "$full_value" 36 32)
  cmd_special_function=$(extract_bits_128 "$full_value" 39 37)
  cmd_type_desc=$(get_dma_cmd_type_desc "$cmd_type")
  cmd_special_desc=$(get_dma_special_function_desc "$cmd_special_function" "$cmd_type")
  
  # Extract the dependency enable bit (bit 20) and depend ID (bits 19:0)
  dep_enable_bit=$(extract_bit_128 "$full_value" 84)
  depend_id=$(extract_bits_128 "$full_value" 83 64)

  if [ "$cmd_type_desc" = "sys" ]; then
    # Extract message count and message ID fields (for sys_wait)
    if [ $core_num -eq 8 ]; then
      msg_cnt=$(extract_bits_128 "$full_value" 127 105)   # scnt[7:0]
    else
      msg_cnt=$(extract_bits_128 "$full_value" 127 112)   # scnt[7:0]
    fi
    msg_id=$(extract_bits_128 "$full_value" 104 96)     # message_id[9:0]
    msg_id=$(get_msg_id_usage $msg_id)
  else
    msg_cnt=unused
    msg_id=unused
  fi
  addr=$(printf "0x%X" $addr)
  # Store raw values
  eval "cmd_short_$i=\"$cmd_short\""
  eval "cmd_type_desc_$i=\"$cmd_type_desc\""
  eval "cmd_special_desc_$i=\"$cmd_special_desc\""
  eval "cmd_id_$i=\"$cmd_id\""
  eval "cmd_id_dep_$i=\"$cmd_id_dep\""
  eval "dep_enable_$i=\"$dep_enable_bit\""
  eval "depend_id_$i=\"$depend_id\""
  eval "msg_cnt_$i=\"$msg_cnt\""
  eval "msg_id_$i=\"$msg_id\""
  eval "des_value_$i=\"$des_value\""
  eval "base_addr_$i=\"$addr\""
  eval "des_enable_$i=\"$des_enable\""
  eval "mst_fifo_$i=\"$mst_fifo\""
  eval "base_msg_id_$i=\"$base_msg_id\""
done

# Print dynamic header
print_dynamic_header "Field"

# Print dynamic rows
print_dynamic_row "cmd_short" "cmd_short"
print_dynamic_row "cmd_type" "cmd_type_desc"
print_dynamic_row "cmd_special_func" "cmd_special_desc"
print_dynamic_row "dep_id_enable" "dep_enable"
print_dynamic_row "cmd_id" "cmd_id"
print_dynamic_row "depend_id" "depend_id"
print_dynamic_row "msg_cnt" "msg_cnt"
print_dynamic_row "msg_id" "msg_id"
print_dynamic_row "des_addr" "des_value"
print_dynamic_row "base_addr" "base_addr"
print_dynamic_row "des_enable" "des_enable"
print_dynamic_row "mst_fifo" "mst_fifo"
print_dynamic_row "base_msg_id" "base_msg_id"

printf "\n\n"

echo "SDMA CMD Info"
for i in $(seq 0 $((core_num - 1))); do
  if [ $i -le 3 ]; then
    # For SDMA 0-3
    addr=0x69${i}8020000
    des_addr=0x69${i}8021004
    slave_addr=0x69${i}8010008
    full_value=$(devmem $addr 128)
    des_value=$(devmem $des_addr 32)
    # des_value=$((des_value << 7))
    # Using multiplication avoids syntax highlighting bugs with '<<'
    des_value=$((des_value * 128))
    des_value=$(printf "0x%X" $des_value)
    slave_des_value=$(devmem $slave_addr 32)
    # slave_des_value=$((slave_des_value << 7))
    # Using multiplication avoids syntax highlighting bugs with '<<'
    slave_des_value=$((slave_des_value * 128))
    slave_des_value=$(printf "0x%X" $slave_des_value)
    cmd_id_addr=0x69${i}8021024
  else
    # For SDMA 4-7
    let addr=0x6B00080000+\($i-4\)*0x2000000
    let des_addr=0x6B00081004+\($i-4\)*0x2000000
    des_value=$(devmem $des_addr 32)
    # des_value=$((des_value << 7))
    # Using multiplication avoids syntax highlighting bugs with '<<'
    des_value=$((des_value * 128))
    des_value=$(printf "0x%X" $des_value)
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
    let cmd_id_addr=0x6B00081024+\($i-4\)*0x2000000
    
    # Skip the next devmem call since we already have our full_value
    continue_processing=1
  fi
  cmd_id=$(devmem $cmd_id_addr 32)
  cmd_id=$(remove_unnecessary_zero $cmd_id)
  let csr=$addr+0x1000
  let vsdma_csr=$addr+0x1000+0x118
  csr0=$(devmem $csr 32)
  des_enable=$(extract_bit "$csr0" 0)
  mst_fifo=$(extract_bits "$csr0" 14 8)
  slv_fifo=$(extract_bits "$csr0" 31 25)
  base_msg_id=$(extract_bits "$csr0" 24 16)
  vsdma_cmd_id=$(devmem $vsdma_csr 32)
  vsdma_cmd_id=$(remove_unnecessary_zero $vsdma_cmd_id)
  # Reset the flag for the next iteration
  unset continue_processing
  
  # Extract the fields
  cmd_short=$(extract_bit_128 "$full_value" 3)
  cmd_type=$(extract_bits_128 "$full_value" 36 32)
  cmd_special_function=$(extract_bits_128 "$full_value" 39 37)
  cmd_type_desc=$(get_dma_cmd_type_desc "$cmd_type")
  cmd_special_desc=$(get_dma_special_function_desc "$cmd_special_function" "$cmd_type")
  if [ "$cmd_type_desc" = "sys" ]; then
    # Extract message count and message ID fields (for sys_wait)
    if [ $core_num -eq 8 ]; then
      msg_cnt=$(extract_bits_128 "$full_value" 127 105)   # scnt[7:0]
    else
      msg_cnt=$(extract_bits_128 "$full_value" 127 112)   # scnt[7:0]
    fi
    msg_id=$(extract_bits_128 "$full_value" 104 96)     # message_id[9:0]
    msg_id=$(get_msg_id_usage $msg_id)
  else
    msg_cnt=unused
    msg_id=unused
  fi
  addr=$(printf "0x%X" $addr)
  # Store raw values
  eval "cmd_short_$i=\"$cmd_short\""
  eval "cmd_type_$i=\"$cmd_type\""
  eval "cmd_type_desc_$i=\"$cmd_type_desc\""
  eval "cmd_special_$i=\"$cmd_special_function\""
  eval "cmd_special_desc_$i=\"$cmd_special_desc\""
  eval "cmd_id_$i=\"$cmd_id\""
  eval "msg_cnt_$i=\"$msg_cnt\""
  eval "msg_id_$i=\"$msg_id\""
  eval "des_value_$i=\"$des_value\""
  eval "base_addr_$i=\"$addr\""
  eval "des_enable_$i=\"$des_enable\""
  eval "mst_fifo_$i=\"$mst_fifo\""
  eval "slv_fifo_$i=\"$slv_fifo\""
  eval "base_msg_id_$i=\"$base_msg_id\""
  eval "vsdma_cmd_id_$i=\"$vsdma_cmd_id\""
done
# Print dynamic header
print_dynamic_header "Field"

# Print dynamic rows
print_dynamic_row "cmd_short" "cmd_short"
print_dynamic_row "cmd_type" "cmd_type_desc"
print_dynamic_row "cmd_special_func" "cmd_special_desc"
print_dynamic_row "cmd_id" "cmd_id"
print_dynamic_row "msg_cnt" "msg_cnt"
print_dynamic_row "msg_id" "msg_id"
print_dynamic_row "des_addr" "des_value"
print_dynamic_row "base_addr" "base_addr"
print_dynamic_row "des_enable" "des_enable"
print_dynamic_row "mst_fifo" "mst_fifo"
print_dynamic_row "slv_fifo" "slv_fifo"
print_dynamic_row "base_msg_id" "base_msg_id"
print_dynamic_row "vsdma_cmd_id" "vsdma_cmd_id"

printf "\n\n"
# Function to get task type description
get_tsk_type_desc() {
  tsk_type_val=$1
  case "$tsk_type_val" in
    "0x0") echo "conv" ;;
    "0x1") echo "pd" ;;
    "0x2") echo "mm" ;;
    "0x3") echo "ar" ;;
    "0x4") echo "rqdq" ;;
    "0x5") echo "trans_bc" ;;
    "0x6") echo "sg" ;;
    "0x7") echo "lar" ;;
    "0x8") echo "random_gen" ;;
    "0x9") echo "sfu" ;;
    "0xA") echo "lin" ;;
    "0xC") echo "sys_trwr" ;;
    "0xD") echo "cmp" ;;
    "0xE") echo "vc" ;;
    "0xF") echo "sys" ;;
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
      "0x8") echo "send" ;;
      "0x9") echo "wait" ;;
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

printf "\n\n"

# Read TIU CMD
echo "TIU CMD Info"
for i in $(seq 0 $((core_num - 1))); do
  let addr=0x6908000000+\($i\*\(1\<\<28\)\)
  full_value=$(devmem $addr 128)
  let des_addr=0x6908000100+\($i\*\(1\<\<28\)\)
  des_value=$(devmem $des_addr 128)
  des_value=$(extract_bits_128 "$des_value" 95 66)
  # des_value=$((des_value << 7))
  # Using multiplication avoids syntax highlighting bugs with '<<'
  des_value=$((des_value * 128))
  des_value=$(printf "0x%X" $des_value)
  short_cmd=$(extract_bit_128 "$full_value" 0)
  cmd_id=$(devmem 0x69${i}800011c 32)
  cmd_id=$(remove_unnecessary_zero $cmd_id)
  csr0=$(devmem 0x69${i}8000100 128)
  csr5=$(devmem 0x69${i}8000154 32)
  fifo=$(extract_bits_128 "$csr0" 40 32)
  des_enable=$(extract_bit_128 "$csr0" 64)
  des_resp_err=$(extract_bit_128 "$csr0" 126)
  base_msg_id=$(extract_bits "$csr5" 9 0)

  let true_msg_info_addr=addr+0x18
  true_msg_info=$(devmem $true_msg_info_addr 32)

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
  if [ "$des_tsk_typ_desc" = "sys" ]; then
    msg_id=$(extract_bits "$true_msg_info" 8 0)
    msg_id=$(remove_unnecessary_zero $msg_id)
    msg_id=$(get_msg_id_usage $msg_id)
    msg_cnt=$(extract_bits "$true_msg_info" 25 16)
    msg_cnt=$(remove_unnecessary_zero $msg_cnt)
  else
    msg_id=unused
    msg_cnt=unused
  fi
  addr=$(printf "0x%X" $addr)
  # Store the extracted values
  eval "tiu_short_cmd_$i=\"$short_cmd\""
  eval "tiu_cmd_id_$i=\"$cmd_id\""
  eval "tiu_dep_enable_$i=\"$dep_enable_bit\""
  eval "tiu_depend_id_$i=\"$depend_id\""
  eval "tiu_des_tsk_typ_desc_$i=\"$des_tsk_typ_desc\""
  eval "tiu_des_tsk_eu_typ_desc_$i=\"$des_tsk_eu_typ_desc\""
  eval "tiu_msg_id_$i=\"$msg_id\""
  eval "tiu_msg_cnt_$i=\"$msg_cnt\""
  eval "tiu_des_value_$i=\"$des_value\""
  eval "tiu_base_addr_$i=\"$addr\""
  eval "tiu_fifo_$i=\"$fifo\""
  eval "tiu_des_enable_$i=\"$des_enable\""
  eval "tiu_des_resp_err_$i=\"$des_resp_err\""
  eval "tiu_base_msg_id_$i=\"$base_msg_id\""
done
# Print dynamic header
print_dynamic_header "TIU Field"

# Print dynamic rows (Notice the 'tiu_' prefix in variable names)
print_dynamic_row "short_cmd" "tiu_short_cmd"
print_dynamic_row "cmd_id" "tiu_cmd_id"
print_dynamic_row "dep_id_enable" "tiu_dep_enable"
print_dynamic_row "depend_id" "tiu_depend_id"
print_dynamic_row "tsk_type" "tiu_des_tsk_typ_desc"
print_dynamic_row "tsk_eu_typ" "tiu_des_tsk_eu_typ_desc"
print_dynamic_row "msg_id" "tiu_msg_id"
print_dynamic_row "msg_cnt" "tiu_msg_cnt"
print_dynamic_row "des_addr" "tiu_des_value"
print_dynamic_row "base_addr" "tiu_base_addr"
print_dynamic_row "fifo" "tiu_fifo"
print_dynamic_row "des_enable" "tiu_des_enable"
print_dynamic_row "des_resp_err" "tiu_des_resp_err"
print_dynamic_row "base_msg_id" "tiu_base_msg_id"
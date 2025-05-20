printf "\n"
printf "%-1s %-38s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s\n" "|" "NODE" "|" "ALLOCATABLE CPU" "|" "CAPACITY CPU" "|" "CPU REQUESTS" "|" "CPU LIMITS" "|" "AVAILABLE CPU" "|" "ALLOCATABLE MEMORY" "|" "CAPACITY MEMORY" "|" "MEMORY REQUESTS" "|" "MEMORY LIMITS" "|" "AVAILABLE MEMORY" "|"
printf -- "|----------------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|\n"

for node in $(oc get nodes -o name); do
  node_name=$(echo "$node" | cut -d'/' -f2)
  
  # Fetch CPU details
  allocatable_cpu=$(oc get node "$node_name" -o jsonpath='{.status.allocatable.cpu}')
  capacity_cpu=$(oc get node "$node_name" -o jsonpath='{.status.capacity.cpu}')
  cpu_line=$(oc describe node "$node_name" | awk '/Allocated resources:/,/Events:/' | grep '^  cpu')
  cpu_requests=$(echo "$cpu_line" | awk '{print $2}')
  cpu_limits=$(echo "$cpu_line" | awk '{print $4}')

  if [[ "$allocatable_cpu" == *m ]]; then
    alloc_cpu_m=${allocatable_cpu%m}
  else
    alloc_cpu_m=$((allocatable_cpu * 1000))
  fi
  req_cpu_m=${cpu_requests%m}
  diff_cpu_m=$((alloc_cpu_m - req_cpu_m))
  diff_cpu="${diff_cpu_m}m"

  # Fetch Memory details
  allocatable_memory=$(oc get node "$node_name" -o jsonpath='{.status.allocatable.memory}')
  capacity_memory=$(oc get node "$node_name" -o jsonpath='{.status.capacity.memory}')
  memory_line=$(oc describe node "$node_name" | awk '/Allocated resources:/,/Events:/' | grep '^  memory')
  memory_requests=$(echo "$memory_line" | awk '{print $2}')
  memory_limits=$(echo "$memory_line" | awk '{print $4}')

  # Convert memory to GiB
  convert_to_gib() {
    value=$1
    if [[ "$value" == *Ki ]]; then
      echo "scale=2; ${value%Ki} / (1024 * 1024)" | bc
    elif [[ "$value" == *Mi ]]; then
      echo "scale=2; ${value%Mi} / 1024" | bc
    elif [[ "$value" == *Gi ]]; then
      echo "${value%Gi}"
    else
      echo "0"
    fi
  }

  alloc_mem_gib=$(convert_to_gib "$allocatable_memory")
  capacity_mem_gib=$(convert_to_gib "$capacity_memory")
  req_mem_gib=$(convert_to_gib "$memory_requests")
  limit_mem_gib=$(convert_to_gib "$memory_limits")
  diff_mem_gib=$(echo "scale=2; $alloc_mem_gib - $req_mem_gib" | bc)

  printf "%-1s %-38s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s %-28s %-1s\n" "|" "$node_name" "|" "$allocatable_cpu" "|" "$capacity_cpu" "|" "$cpu_requests" "|" "$cpu_limits" "|" "$diff_cpu" "|" "${alloc_mem_gib}Gi" "|" "${capacity_mem_gib}Gi" "|" "${req_mem_gib}Gi" "|" "${limit_mem_gib}Gi" "|" "${diff_mem_gib}Gi" "|"
done

printf -- "|----------------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|------------------------------|\n"
#!/bin/bash

# Ensure running as khadas user
if [ "$(whoami)" != "khadas" ]; then
    echo "Please run this script as khadas user!"
    exit 1
fi

# Check and install CMake if missing
if ! command -v cmake &> /dev/null; then
    echo "Installing CMake..."
    sudo apt update
    sudo apt install cmake -y
else
    echo "CMake already installed, skipping installation"
fi

# Calculate system memory
mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_float=$(echo "scale=1; $mem_kb/1024/1024" | bc)

allow_7b=false
if (( $(echo "$mem_float >= 8" | bc -l) )); then
    allow_7b=true
fi

# Model configuration with separate directories
declare -A MODEL_CONFIG=(
    ["1"]="DeepSeek 1.5B|https://dl.khadas.com/development/llm/deepseek-r1-distill-qwen-1.5b_w8a8_rk3588.rkllm|/home/khadas/rknn-llm/examples/DeepSeek-R1-Distill-Qwen-1.5B_Demo/deploy"
    ["2"]="DeepSeek 7B|https://dl.khadas.com/development/llm/deepseek-r1-distill-qwen-7b_w8a8_rk3588.rkllm|/home/khadas/rknn-llm/examples/DeepSeek-R1-Distill-Qwen-1.5B_Demo/deploy"
    ["3"]="Qwen2 2B-VL|https://dl.khadas.com/development/llm/qwen2-vl-2b-instruct_w8a8_rk3588.rkllm|/home/khadas/rknn-llm/examples/Qwen2-VL-2B_Demo/deploy"
    ["4"]="ChatGLM3 6B|https://dl.khadas.com/development/llm/chatglm3-6b_w8a8_rk3588.rkllm|/home/khadas/rknn-llm/examples/ChatGLM3-6B_Demo/deploy"
)

# Clone repository function
clone_repo() {
    local repo_dir="/home/khadas/rknn-llm"

    # Only clone if directory doesn't exist
    if [ ! -d "$repo_dir" ]; then
        echo "Cloning repository to $repo_dir..."
        if ! git clone https://github.com/khadas/rknn-llm.git "$repo_dir"; then
            echo "Repository clone failed!"
            exit 1
        fi
    else
        echo "Repository exists, skipping clone"
    fi
}

# Model management function
manage_models() {
    # Check model status
    declare -A model_status
    for key in "${!MODEL_CONFIG[@]}"; do
        IFS='|' read -ra info <<< "${MODEL_CONFIG[$key]}"
        model_file="${info[2]}/$(basename "${info[1]}")"
        [ -f "$model_file" ] && model_status[$key]=1 || model_status[$key]=0
    done

    # Display status menu
    echo -e "\n======================"
    echo "System Memory: ${mem_float}G"
    echo "Available Models:"
    for key in $(echo "${!MODEL_CONFIG[@]}" | tr ' ' '\n' | sort -n); do
        if [[ "$key" == "2" && "$allow_7b" != "true" ]]; then
            continue
        fi
        IFS='|' read -ra info <<< "${MODEL_CONFIG[$key]}"
        status=$([ ${model_status[$key]} -eq 1 ] && echo "[Installed]" || echo "[Missing]")
        printf "%2s) %-20s %s\n" "$key" "${info[0]}" "$status"
    done
    echo "======================"

    # Handle model download
    read -p "Download missing models? [y/N] " dl_choice
    if [[ $dl_choice =~ [Yy] ]]; then
        echo "Available downloads:"
        for key in $(echo "${!model_status[@]}" | tr ' ' '\n' | sort -n); do
            if [[ "$key" == "2" && "$allow_7b" != "true" ]]; then
                continue
            fi
            [ ${model_status[$key]} -eq 0 ] && {
                IFS='|' read -ra info <<< "${MODEL_CONFIG[$key]}"
                printf "%2s) %s\n" "$key" "${info[0]}"
            }
        done

        while :; do
            read -p "Select model to download: " model_choice
            if [[ -n "${MODEL_CONFIG[$model_choice]}" && ${model_status[$model_choice]} -eq 0 ]]; then
                IFS='|' read -ra selected <<< "${MODEL_CONFIG[$model_choice]}"
                model_url="${selected[1]}"
                model_dir="${selected[2]}"
                model_file="${model_dir}/$(basename "$model_url")"

                echo "Downloading ${selected[0]}..."
                if wget --show-progress -qO "$model_file" "$model_url"; then
                    echo "Download completed: $(basename "$model_file")"
                    return 0
                else
                    echo "Download failed! Cleaning up..."
                    rm -f "$model_file"
                    return 1
                fi
            else
                echo "Invalid selection, try again"
            fi
        done
    fi
}

# Build function with path isolation
build_project() {
    local selected_key=$1
    IFS='|' read -ra info <<< "${MODEL_CONFIG[$selected_key]}"

    echo -e "\nBuilding ${info[0]} model..."
    cd "${info[2]}" || exit 1

    # Copy build script if missing
    [ ! -f "build-linux.sh" ] && cp ../../build-linux.sh ./

    if ! bash build-linux.sh; then
        echo "Build failed!"
        exit 1
    fi
}

# Main execution flow
clone_repo
manage_models

# Model selection menu
PS3="Select model to build (1-${#MODEL_CONFIG[@]}): "
select choice in "${MODEL_CONFIG[@]}"; do
    [[ $REPLY =~ ^[1-4]$ ]] && break || echo "Invalid input, enter 1-4"
done

# Identify selected model
for key in "${!MODEL_CONFIG[@]}"; do
    if [[ "${MODEL_CONFIG[$key]}" == "$choice" ]]; then
        selected_key=$key
        IFS='|' read -ra selected_info <<< "${MODEL_CONFIG[$key]}"
        break
    fi
done

# Build selected model
build_project "$selected_key"

# Runtime preparation
model_file="${selected_info[2]}/$(basename "${selected_info[1]}")"
build_dir="${selected_info[2]}/install/demo_Linux_aarch64"

# Validate paths
[ ! -f "$model_file" ] && {
    echo "Error: Model file not found - $model_file"
    exit 1
}

[ ! -d "$build_dir" ] && {
    echo "Error: Build directory missing - $build_dir"
    exit 1
}

# Configure runtime parameters
echo -e "\nConfigure runtime parameters (press Enter for defaults)"
read -p "Max new tokens (default 2048): " max_new_tokens
max_new_tokens=${max_new_tokens:-2048}

while :; do
    read -p "Context length (default 4096): " max_context_len
    max_context_len=${max_context_len:-4096}
    [[ $max_context_len =~ ^[0-9]+$ ]] && [ $max_context_len -gt 0 ] && break
    echo "Invalid input! Must be positive integer"
done

# Execute model
cd "$build_dir" || exit 1
export LD_LIBRARY_PATH=./lib
export RKLLM_LOG_LEVEL=1

echo -e "\nLaunching: $(basename "$model_file")"
./llm_demo "$model_file" "$max_new_tokens" "$max_context_len"
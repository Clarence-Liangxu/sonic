#!/usr/bin/env bash
# Function to run a specific benchmark
# $1: relative path to the benchmark directory
# $2: benchmark executable name
bench() {
    local rel_path="$1"
    local bench_name="$2"
    local output_file="${bench_name}.txt"

    # Resolve absolute path to avoid issues with cd
    local abs_path
    abs_path=$(realpath "$rel_path") || { echo "Error: Cannot resolve path '$rel_path'"; exit 1; }

    if [ ! -d "$abs_path" ]; then
        echo "Error: Directory '$abs_path' does not exist."
        return 1
    fi

    # Save current directory
    local original_dir
    original_dir=$(pwd)

    # Go to benchmark directory
    cd "$abs_path" || { echo "Error: Failed to enter directory '$abs_path'"; exit 1; }

    echo "Running benchmark '$bench_name' in $(pwd), 8 times..."

    # Run benchmark 8 times and append output to file (in original dir)
    for i in {1..8}; do
        echo "=== Run $i ===" >> "$original_dir/$output_file"
        taskset -c 16-31 go test -bench="$bench_name" >> "$original_dir/$output_file" 2>&1
        echo "" >> "$original_dir/$output_file"  # blank line for readability
    done

    # Return to original directory
    cd "$original_dir" || exit 1
    ./cal.py $output_file > ${bench_name}_result.txt
    echo "result: ${bench_name}_result.txt"
    cat ${bench_name}_result.txt
    echo "Finished benchmark '$bench_name'. Results saved to $output_file"
}

# Main function
main() {
    # Example calls — replace or add as needed
    bench "./sonic/encoder" "BenchmarkHTMLEscape"
    bench "./sonic/internal/encoder/alg" "BenchmarkEscapeHTML"
    bench "./sonic/internal/encoder/alg" "BenchmarkQuote"
    bench "./sonic/utf8" "BenchmarkValidate"
    bench "./sonic/ast" "BenchmarkParser*"

    # You can add more benchmark calls here
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
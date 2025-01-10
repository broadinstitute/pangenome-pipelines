version 1.0

import "../../structs/Structs.wdl"

task Cat {
    input {
        Array[File] files
        String out_fname
        
        RuntimeAttr? runtime_attr_override
    }
    
    meta {
        description: "Concatenate multiple files into a single file"
    }
    
    parameter_meta {
        files: "Files to concatenate"
        out_fname: "Output file name"
    }
    
    Int disk_size = 1 + 10*ceil(size(files, "GB"))
    RuntimeAttr default_attr = object {
        cpu_cores:          1,
        mem_gb:             16,
        disk_gb:            disk_size,
        boot_disk_gb:       20,
        preemptible_tries:  3,
        max_retries:        2,
        docker:             "debian:bookworm-slim"
    }
    RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
    
    command <<<
        set -euxo pipefail
        
        cat ~{sep=" " files} > ~{out_fname}
    >>>
    
    output {
        File out_file = out_fname
    }
}
version 1.0

import "../../structs/Structs.wdl"

task Merge {
    input {
        Array[File] bams
        String out_prefix = "merged"
        
        RuntimeAttr? runtime_attr_override
    }
    
    Int disk_size = 1 + 10*ceil(size(bams, "GB"))
    RuntimeAttr default_attr = object {
        cpu_cores:          2,
        mem_gb:             16,
        disk_gb:            disk_size,
        boot_disk_gb:       20,
        preemptible_tries:  3,
        max_retries:        2,
        docker:             "us-central1-docker.pkg.dev/broad-dsp-lrma/pangenome-pipelines/minimap2:main"
    }
    RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
    
    Int num_cpu = select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    
    meta {
        description: "Merge multiple BAM files into a single BAM file"
    }

    parameter_meta {
        bams: "List of BAM files to merge"
        out_prefix: "Prefix for the output BAM file name"
        runtime_attr_override: "Runtime attributes for the task"
    }
    
    command <<<
        set -euxo pipefail
        
        samtools merge -@ ~{num_cpu} -o ~{out_prefix}.bam ~{sep=" " bams}
    >>>
    
    output {
        File bam = "~{out_prefix}.bam"
    }
    
    runtime {
        cpu:                    select_first([runtime_attr.cpu_cores,         default_attr.cpu_cores])
        memory:                 select_first([runtime_attr.mem_gb,            default_attr.mem_gb]) + " GiB"
        disks: "local-disk " +  select_first([runtime_attr.disk_gb,           default_attr.disk_gb]) + " HDD"
        bootDiskSizeGb:         select_first([runtime_attr.boot_disk_gb,      default_attr.boot_disk_gb])
        preemptible:            select_first([runtime_attr.preemptible_tries, default_attr.preemptible_tries])
        maxRetries:             select_first([runtime_attr.max_retries,       default_attr.max_retries])
        docker:                 select_first([runtime_attr.docker,            default_attr.docker])
    }
}
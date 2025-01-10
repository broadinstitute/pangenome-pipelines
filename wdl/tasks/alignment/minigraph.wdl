version 1.0

import "../../structs/Structs.wdl"


task MinigraphAsmAlignment {
    input {
        File ref_graph_gfa
        File query_fasta
        
        String? extra_params
        String out_prefix = "aligned"
        
        RuntimeAttr? runtime_attr_override
    }
    
    meta {
        description: "Align an assembly to a reference graph using Minigraph"
    }
    
    parameter_meta {
        ref_graph_gfa: "Reference graph in GFA format"
        query_fasta: "Query assembly in FASTA format"
        extra_params: "Extra parameters to pass to minigraph"
        out_prefix: "Prefix for the output GAF file name"
        runtime_attr_override: "Runtime attributes for the task"
    }
    
    Int disk_size = 1 + 10*ceil(size(ref_graph_gfa, "GB") + size(query_fasta, "GB"))
    RuntimeAttr default_attr = object {
        cpu_cores:          4,
        mem_gb:             64,
        disk_gb:            disk_size,
        boot_disk_gb:       20,
        preemptible_tries:  3,
        max_retries:        2,
        docker:             "us-central1-docker.pkg.dev/broad-dsp-lrma/pangenome-pipelines/minigraph:main"
    }
    RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
    
    Int num_cpu = select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    
    command <<<
        set -euxo pipefail
        
        minigraph -cxasm -t ~{num_cpu} ~{extra_params} ~{ref_graph_gfa} ~{query_fasta} > ~{out_prefix}.gaf
    >>>
    
    output {
        File gaf = "~{out_prefix}.gaf"
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

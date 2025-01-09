version 1.0

import "../../structs/Structs.wdl"

task IndexWithMinimap2 {
    input {
        File ref_fasta
        String preset = "asm5"
        String? extra_params
        String? out_prefix
        
        RuntimeAttr? runtime_attr_override
    }
    
    Int disk_size = 1 + 20*ceil(size(ref_fasta, "GB"))
    RuntimeAttr default_attr = object {
        cpu_cores:          2,
        mem_gb:             32,
        disk_gb:            disk_size,
        boot_disk_gb:       20,
        preemptible_tries:  3,
        max_retries:        2,
        docker:             "us-central1-docker.pkg.dev/broad-dsp-lrma/pangenome-pipelines/minimap2:main"
    }
    RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
    
    Int num_cpu = select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    
    meta {
        description: "Create a Minimap2 index of a reference genome"
    }

    parameter_meta {
        ref_fasta: "Reference genome in FASTA format"
        preset: "Minimap2 parameter preset to use"
        extra_params: "Extra parameters to pass to minimap2"
        runtime_attr_override: "Runtime attributes for the task"
    }
    
    command <<<
        set -euxo pipefail
        
        minimap2 -t ~{num_cpu} -x ~{preset} ~{extra_params} -d ~{out_prefix}.mmi ~{ref_fasta}
    >>>
    
    output {
        File mmi = "~{out_prefix}.mmi"
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
    

task Minimap2WithIx {
    input {
        File ref_mmi
        File query_fasta
        String? extra_params
        String out_prefix = "aligned"

        RuntimeAttr? runtime_attr_override
    }
    
    Int disk_size = 1 + 10*2*ceil(size(query_fasta, "GB") + size(ref_mmi, "GB"))
    
    RuntimeAttr default_attr = object {
        cpu_cores:          4,
        mem_gb:             32,
        disk_gb:            disk_size,
        boot_disk_gb:       20,
        preemptible_tries:  3,
        max_retries:        2,
        docker:             "us-central1-docker.pkg.dev/broad-dsp-lrma/pangenome-pipelines/minimap2:main"
    }
    RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
    
    Int num_cpu = select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    
    meta {
        description: "Align a query genome to a reference genome using Minimap2, using a pre-built index"
    }

    parameter_meta {
        ref_mmi: "Pre-built Minimap2 index of the reference genome"
        query_fasta: "Query genome in FASTA format"
        extra_params: "Extra parameters to pass to minimap2"
        runtime_attr_override: "Runtime attributes for the task"
    }
    
    command <<<
        set -euxo pipefail
        minimap2 -t ~{num_cpu - 1} ~{extra_params} -a -d ~{ref_mmi} ~{query_fasta} \
            | samtools sort -Obam -o ~{out_prefix}.bam
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

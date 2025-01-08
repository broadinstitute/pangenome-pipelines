version 1.0

import "../../tasks/alignment/minimap2.wdl" as minimap2

workflow Minimap2RefIndex {
    meta {
        description: "Create a Minimap2 index of a reference genome"
    }
    
    input {
        File ref_fasta
        String preset = "asm5"
        String? extra_params
        String? out_prefix
    }
    
    parameter_meta {
        ref_fasta: "Reference genome in FASTA format (can be gzipped)."
        preset: "Minimap2 preset to use."
        extra_params: "Extra parameters to pass to minimap2"
        out_prefix: "Prefix for the output index file name."
    }
    
    String prefix = select_first([out_prefix, basename(ref_fasta)])
    
    call minimap2.IndexWithMinimap2 {
        input: 
            ref_fasta = ref_fasta,
            preset = preset,
            extra_params = extra_params,
            out_prefix = prefix
    }
    
    output {
        File mmi = IndexWithMinimap2.mmi
    }
}
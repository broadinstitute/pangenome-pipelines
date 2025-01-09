version 1.0

import "../../tasks/alignment/minimap2.wdl" as minimap2
import "../../tasks/alignment/samtools.wdl" as samtools

workflow Minimap2WGA {
    meta {
        description: "Align reads to a reference genome using Minimap2, requiring an existing minimap2 index. If provided with multiple query fastas (e.g., multiple haplotypes), will merge resulting BAMs."
    }

    input {
        File ref_fasta_mmi
        Array[File] query_fasta
        String? extra_params
        String out_prefix = "aligned"
    }

    scatter (fasta in query_fasta) {
        call minimap2.Minimap2WithIx {
            input:
                ref_mmi = ref_fasta_mmi,
                query_fasta = fasta,
                extra_params = extra_params,
        }
    }

    call samtools.Merge as Merge {
        input:
            bams = Minimap2WithIx.bam,
            out_prefix = out_prefix
    }

    output {
        File bam = Merge.bam
        File bai = Merge.bai
    }
}

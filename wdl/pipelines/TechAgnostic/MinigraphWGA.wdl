version 1.0

import "../../tasks/alignment/minigraph.wdl" as minigraph
import "../../tasks/utils/shell.wdl" as shell

workflow MinigraphWGA {
    meta {
        description: "Align an assembly to a reference graph using Minigraph. Outputs a GAF file."
    }

    input {
        File ref_graph_gfa
        Array[File] query_fastas
        
        String? extra_params
        String out_prefix = "aligned"
    }

    scatter (fasta in query_fastas) {
        call minigraph.MinigraphAsmAlignment {
            input:
                ref_graph_gfa = ref_graph_gfa,
                query_fasta = fasta,
                extra_params = extra_params,
        }
    }

    call shell.Cat as Cat {
        input:
            files = MinigraphAsmAlignment.gaf,
            out_fname = out_prefix + ".gaf"
    }

    output {
        File gaf = Cat.out_file
    }
}

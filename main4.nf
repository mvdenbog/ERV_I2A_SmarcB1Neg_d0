#!/usr/bin/env nextflow


// ---------------------------------------------//
//             LOAD / VALIDATE FILES            //
// ---------------------------------------------//

/*
The pipeline can start from fastq read files or
start from alignment .bam files
*/

Channel.fromPath(params.fasta).set{ fasta_indexing }

process concat_gtf{
    errorStrategy 'ignore'
    cpus 1
    memory '1 GB'
    time '1h'

  publishDir path: "${params.outdir}", mode: 'copy'

  input:
     file(gtf1) from Channel.fromPath(params.gtf1)
     file(gtf2) from Channel.fromPath(params.gtf2)
  output:
      file("concat.gtf") into ( gtf_indexing, gtf_mapping, gtf_featureCounts, gtf_stringtieFPKM )

  script:
   """
      cat ${gtf1} ${gtf2} | grep -v '^#' > concat.gtf
   """
}


// Starting from .fastq files
  if (params.paired) {
    Channel
      .fromPath(params.reads).splitCsv(header: true)
      .map {row -> [row.Sample_Name, [row.Read1, row.Read2]]}
      .ifEmpty {error "File ${params.reads} not parsed properly"}
      .set {reads_trimming}
  } else {
    Channel
      .fromPath(params.reads).splitCsv(header: true)
      .map {row -> [row.Sample_Name, [row.Read1]]}
      .ifEmpty {error "File ${params.reads} not parsed properly"}
      .set {reads_trimming;}
  }


/*
The pipeline requires the following under various conditions
- Annotation file is always required regardless of workflow
- Reference file is only required when building an index to align fastq files
*/


    /*
    ** Build index with STAR
    */
 process star_indexing {
        cache "deep"; tag "$fasta"

      errorStrategy 'ignore'
      cpus 4
      memory '50 GB'
      time '1d'


        publishDir path: "${params.outdir}/${params.aligner}_index", mode: 'copy'

        input:
        file fasta from fasta_indexing
        file gtf from gtf_indexing

        output:
        file "index" into (star_index)

        script:
        template 'star/indexing.sh'
      }

// -----------------------------------------------------------------------------
//                BEGIN PIPELINE
// -----------------------------------------------------------------------------
  /*
  ** Trimming
  */
  process trim_galore {
    cache "deep"; tag "$sampleid"

      cpus 1
      memory '30 GB'
      time '1d'

    publishDir "${params.outdir}/${sampleid}/trimgalore", mode: 'copy',
    saveAs: {filename ->
              if (filename.indexOf("trimming_report.txt") > 0) filename
              else if (filename.indexOf("fastqc.html") > 0) filename
              else if (filename.indexOf("fastqc.zip") > 0) filename
              else if (params.fastqs.save) filename
              else null}

    input:
    set sampleid, reads from reads_trimming

    output:
    set sampleid, file('*fq.gz') into (trimmed_reads)

    script:
    if (params.trim_galore.custom_adaptors) {
      if (params.paired){
          template 'trim_galore/custom/paired.sh'
      } else {
        template 'trim_galore/custom/single.sh'
      }
    } else {
      if (params.paired){
          template 'trim_galore/default/paired.sh'
      } else {
        template 'trim_galore/default/single.sh'
      }        
    }
  }


process star_mapping {
      cache "deep"; tag "$sampleid"

      errorStrategy 'ignore'
      cpus 4
      memory '100 GB'
      time '1d'


      publishDir "${params.outdir}/${params.aligner}_bams", mode: "copy",
       saveAs: {filename ->
                if (filename.indexOf("Log") > 0) "logs/$filename"
                else if (params.bams.save) "${sampleid}.bam"
                else null}

      input:
      file (index) from star_index.collect()
      file (gtf) from gtf_mapping.collect()
      set sampleid, file (reads:"*") from trimmed_reads

      output:
      file("*.bam") into (bam_files, bam_gff)
      file('*.out') into mapping_results

      script:
      template "star/mapping.sh"
    }
 bam_files.into { bam_featurecounts; bam_stringtieFPKM; }

process featureCounts {
      publishDir "${params.outdir}/featureCounts", mode: 'copy'

      input:
      file bam_featurecounts
      file gtf from gtf_featureCounts.collect()

      output:
      file "${bam_featurecounts.baseName}_gene.featureCounts.txt" into geneCounts, featureCounts_to_merge
      file "${bam_featurecounts.baseName}_gene.featureCounts.txt.summary" into featureCounts_logs

      script:
      def featureCounts_direction = 0
      def extraAttributes = params.fc_extra_attributes ? "--extraAttributes ${params.fc_extra_attributes}" : ''
      featureCounts_direction = 1
      // Try to get real sample name
      sample_name = bam_featurecounts.baseName - 'Aligned.sortedByCoord.out' - '_subsamp.sorted'
      """
      featureCounts -a $gtf -g 'gene_id' -t ${params.fc_count_type} -o ${bam_featurecounts.baseName}_gene.featureCounts.txt $extraAttributes -p -s $featureCounts_direction $bam_featurecounts
      """
  }

process stringtieFPKM {
      tag "${bam_stringtieFPKM.baseName - '.sorted'}"
      publishDir "${params.outdir}/stringtieFPKM", mode: 'copy'
  
      input:
      file bam_stringtieFPKM
      file gtf from gtf_stringtieFPKM.collect()

      output:
      file "${bam_stringtieFPKM.baseName}_transcripts.gtf"
      file "${bam_stringtieFPKM.baseName}.gene_abund.txt"
      file "${bam_stringtieFPKM}.cov_refs.gtf"
      file "${bam_stringtieFPKM.baseName}_ballgown"

      script:
      def st_direction = ''
      st_direction = "--fr"
      def ignore_gtf = params.stringTieIgnoreGTF ? "" : "-e"
      """
      stringtie $bam_stringtieFPKM \\
          $st_direction \\
          -o ${bam_stringtieFPKM.baseName}_transcripts.gtf \\
          -v \\
          -G $gtf \\
          -A ${bam_stringtieFPKM.baseName}.gene_abund.txt \\
          -C ${bam_stringtieFPKM}.cov_refs.gtf \\
          -b ${bam_stringtieFPKM.baseName}_ballgown \\
          $ignore_gtf
      """
  }


workflow.onComplete {
  println (workflow.success ? "Success: Pipeline Completed!" : "Error: Something went wrong.")
}

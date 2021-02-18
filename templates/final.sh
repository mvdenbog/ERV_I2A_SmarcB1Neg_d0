 #!/bin/bash
           perl ${params.scriptdir}/loci2geneid.pl ${loci} ${xloc} > scallop_counts2.txt;
           perl ${params.scriptdir}/tracking2geneid.pl ${tracking} ${xloc} > scallop_counts3.txt;
           awk '{print \$4}' ${tracking} | sort  | uniq -c | sort -k 1,1nr > ${tracking}_classification_codes_freq


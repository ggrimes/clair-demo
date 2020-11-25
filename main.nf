
params.testdownload = 'http://www.bio8.cs.hku.hk/testingData.tar'
params.modeldownload = 'http://www.bio8.cs.hku.hk/clair_models/illumina/12345.tar'
testingDataDown=Channel.from(params.testdownload)
modelDataDown=Channel.from(params.modeldownload)

// Download and extract the testing dataset
process downtest {

  input:
  val(testingDataDown) from testingDataDown

  output:
  path("testingData") into testingData_ch

  script:
  """
  wget ${testingDataDown}
  tar -xf testingData.tar
  """
}

// Download the Illumina model
process download_illumina_model {

  input:
  val(modelDataDown)

  output:
  path(12345)

  script:
  """
  wget ${modelDataDown}
  tar -xf 12345.tar
  """

}

// Create a folder for outputs
process run_clair {
cpus 2
conda 'environment.yml'

input:
path(testingData) from  testingData_ch
path(traningData) from  trainingData_ch

script:
"""
mkdir training;
// Voila
clair.py \
callVarBam \
--chkpnt_fn ./model \
--bam_fn ${testingData}/chr21/chr21.bam \
--ref_fn ${testingData}/chr21/chr21.fa \
--call_fn ./training/chr21.vcf \
--sampleName HG001 \
--pysam_for_all_indel_bases \
--threads ${${task.cpus}} \
--qual 100 \
--ctgName chr21 \
--ctgStart 10269870 \
--ctgEnd 46672937
"""
}

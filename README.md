# jga-analysis-qc

Jga-analysis-qc is the QC part of [jga-analysis](https://github.com/biosciencedbc/jga-analysis) workflow. The main features are:

* reporting on CRAM and VCF metrics of each sample
* filtering and sex estimation based on coverage statistics

## Installation

As a prerequisite, the following should be installed.

* Ruby (>= 3.0.1)
* R with ggplot2 and readr

Jga-analysis-qc is provided as a Ruby gem. Since the gem is not registered in RubyGems, it should be built and installed locally.

```
$ git clone <THIS REPOSITORY>
$ cd jga-analysis-qc
$ git submodule update --init
$ bundle install
$ rake install
```

Alternatively, you can retrieve Docker image from `ghcr.io/tafujino/jga-analysis/qc:latest`.

## Usage

Jga-analysis-qc supposes all the samples are under a specific directory (called "project directory") of the follwing structure.

```
<project directory>/
  +--<sample0>/
  |     +--<sample0>.cram
  |     +--<sample0>.cram.idxstats
  |     +--<sample0>.cram.flagstat
  |     +--<sample0>.cram.autosome_PAR_ploidy_2.wgs_metrics
  |     +--<sample0>.cram.chrX_nonPAR_ploidy_2.wgs_metrics
  |     +--<sample0>.cram.chrX_nonPAR_ploidy_1.wgs_metrics
  |     +--<sample0>.cram.chrY_nonPAR_ploidy_1.wgs_metrics
  |     +--<sample0>.cram.collect_base_dist_by_cycle.chart.png
  |     +--<sample0>.autosome_PAR_ploidy_2.g.vcf.gz
  |     +--<sample0>.autosome_PAR_ploidy_2.g.vcf.gz.bcftools-stats
  |     +--<sample0>.chrX_nonPAR_ploidy_2.g.vcf.gz
  |     +--<sample0>.chrX_nonPAR_ploidy_2.g.vcf.gz.bcftools-stats
  |     +--<sample0>.chrX_nonPAR_ploidy_1.g.vcf.gz
  |     +--<sample0>.chrX_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats
  |     +--<sample0>.chrY_nonPAR_ploidy_1.g.vcf.gz
  |     +--<sample0>.chrY_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats
  +-- <sample1>/
  |     ...
  +-- <sample2>/
  |     ...
  |
  .
```

### Reporting

A YAML file containing list of sample IDs should be prepared before generating a report. The content should be an array of sample IDs like the folowing.

```
---
- sample0
- sample1
- sample2
  ...
```

Run `jga-analysis report` to generate a report.

```
$ jga-analysis-qc report <project directory> <sample list file>
```

Report files are created under the project directory. A file containing coverage information of each sample (named `mean_coverage.tsv`) is also created (used in the filtering step). In `mean_coverage.tsv`, mean coverages of autosome_PAR region and normalized mean coverages of chrX_nonPAR and chrY_nonPAR region are listed. Where coverage information is unavailable is filled with `NA` instead.

### Flitering

After reporting, filtering and sex estimation based on coverage information are performed. Parameters should be specified in YAML format like the following.

```
---
autosome_PAR_mean_coverage:
  min: 20
  max: 80
male:
  chrX_nonPAR_normalized_mean_coverage:
    min: 0.0
    max: 0.6
  chrY_nonPAR_normalized_mean_coverage:
    min: 0.3
    max: 0.5
female:
  chrX_nonPAR_normalized_mean_coverage:
    min: 0.8
    max: 1.0
  chrY_nonPAR_normalized_mean_coverage:
    min: 0.0
    max: 0.1
```

Run `jga-analysis-qc filter` to perform filtering and sex estimation.

```
$ jga-analysis-qc filter <project directory> <parameter file>
```

After running the command, tabular file `qc.tsv` is created under the project directory. It has the following three columns.

* sample ID
* filtering result based on autosome_PAR mean coverage (`PASS`/`FAIL`/`NA`)
* sex estimation result based on chrX_nonPAR and chrY_nonPAR normalized mean coverage (`MALE`/`FEMALE`/`OTHER`/`NA`)

## License

The gem is available as open source under the terms of the [Apache-2.0](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the JgaAnalysisQc project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/biosciencedbc/jga-analysis-qc/blob/main/CODE_OF_CONDUCT.md).

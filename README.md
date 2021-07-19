# jga-analysis-qc

Jga-analysis-qc is a QC part of [jga-analysis](https://github.com/biosciencedbc/jga-analysis) workflow. The main features are:

* reporting on CRAM and VCF metrics of each sample
* filtering and sex estimation based on coverage statistics

## Installation

As a prerequisite, the following should be installed.

* Ruby (>= 3.0.1)
* R with ggplot2 and readr

Jga-analysis-qc is provided as a Ruby gem. Since the gem is not registered in RubyGems currently, it should be built and installed locally.

```
$ git clone <THIS REPOSITORY>
$ cd jga_analysis_qc
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

### Flitering

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jga_analysis_qc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jga_analysis_qc/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache-2.0](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the JgaAnalysisQc project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jga_analysis_qc/blob/master/CODE_OF_CONDUCT.md).

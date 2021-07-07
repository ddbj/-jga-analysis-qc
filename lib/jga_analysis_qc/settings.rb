# frozen_string_literal: true

require_relative 'chr_region'

module JgaAnalysisQC
  WGS_METRICS_AUTOSOME_REGION = ChrRegion.new('autosome_PAR_ploidy_2', 'autosome_PAR')
  # 'chrX_nonPAR_ploidy_1' and 'chrX_nonPAR_ploidy_2' produce the same WGS metrics
  WGS_METRICS_CHR_X_REGION    = ChrRegion.new('chrX_nonPAR_ploidy_1',  'chrX_nonPAR')
  WGS_METRICS_CHR_Y_REGION    = ChrRegion.new('chrY_nonPAR_ploidy_1',  'chrY_nonPAR')
  WGS_METRICS_REGIONS = [
    WGS_METRICS_AUTOSOME_REGION,
    WGS_METRICS_CHR_X_REGION,
    WGS_METRICS_CHR_Y_REGION
  ].freeze

  HAPLOTYPECALLER_REGIONS = [
    ChrRegion.new('autosome_PAR_ploidy_2', 'autosome_PAR'),
    ChrRegion.new('chrX_nonPAR_ploidy_1',  'chrX_nonPAR (ploidy = 1)'),
    ChrRegion.new('chrX_nonPAR_ploidy_2',  'chrX_nonPAR (ploidy = 2)'),
    ChrRegion.new('chrY_nonPAR_ploidy_1',  'chrY_nonPAR')
  ].freeze

  # coverage table file specification
  MEAN_COVERAGE_TABLE_FILENAME = 'mean_coverage.tsv'
  AUTOSOME_MEAN_COVERAGE_KEY = 'autosome_PAR_mean_coverage'
  CHR_X_NORMALIZED_MEAN_COVERAGE_KEY = 'chrX_nonPAR_normalized_mean_coverage'
  CHR_Y_NORMALIZED_MEAN_COVERAGE_KEY = 'chrY_nonPAR_normalized_mean_coverage'

  module Report
    LIB_DIR = File.expand_path("#{__dir__}/..")
    D3_JS_PATH = "#{LIB_DIR}/d3/d3.v5.js"
    C3_JS_PATH = "#{LIB_DIR}/c3/c3.js"
    C3_CSS_PATH = "#{LIB_DIR}/c3/c3.css"
    GITHUB_MARKDOWN_CSS_PATH = "#{LIB_DIR}/github-markdown-css/github-markdown.css"
    MAX_SAMPLES = 100_000
    NUM_SAMPLES_PER_PAGE = 50
    SAMPLE_TOC_NESTING_LEVEL = 4
    DASHBOARD_TOC_NESTING_LEVEL = 3
    WRAP_LENGTH = 100
  end
end

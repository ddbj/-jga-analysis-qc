# frozen_string_literal: true

require_relative 'chr_region'

module JgaAnalysisQC
  WGS_METRICS_AUTOSOME_REGION = ChrRegion.new('autosome-PAR')
  WGS_METRICS_CHR_X_REGION = ChrRegion.new('chrX-nonPAR')
  WGS_METRICS_CHR_Y_REGION = ChrRegion.new('chrY-nonPAR')
  WGS_METRICS_REGIONS = [
    WGS_METRICS_AUTOSOME_REGION,
    WGS_METRICS_CHR_X_REGION,
    WGS_METRICS_CHR_Y_REGION
  ].freeze

  HAPLOTYPECALLER_REGIONS = [
    ChrRegion.new('autosome-PAR',       'autosome-PAR'),
    ChrRegion.new('chrX-nonPAR-male',   'chrX-nonPAR (male)'),
    ChrRegion.new('chrX-nonPAR-female', 'chrX-nonPAR (female)'),
    ChrRegion.new('chrY-nonPAR',        'chrY-nonPAR')
  ].freeze

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

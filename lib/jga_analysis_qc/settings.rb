# frozen_string_literal: true

require_relative 'chr_region'

module JgaAnalysisQC
  WGS_METRICS_AUTOSOME_REGION = ChrRegion.new('autosome-PAR')
  WGS_METRICS_CHR_X_REGION = ChrRegion.new('chrX-nonPAR')
  WGS_METRICS_CHR_Y_REGION = ChrRegion.new('chrY-nonPAR')

  module Report
    LIB_DIR = File.expand_path("#{__dir__}/..")
    D3_JS_PATH = "#{LIB_DIR}/d3/d3.v5.js"
    C3_JS_PATH = "#{LIB_DIR}/c3/c3.js"
    C3_CSS_PATH = "#{LIB_DIR}/c3/c3.css"
    GITHUB_MARKDOWN_CSS_PATH = "#{LIB_DIR}/github-markdown-css/github-markdown.css"
    MAX_SAMPLES = 100_000
    DEFAULT_NUM_SAMPLES_PER_PAGE = 50
    SAMPLE_TOC_NESTING_LEVEL = 4
    DASHBOARD_TOC_NESTING_LEVEL = 3
    WRAP_LENGTH = 100
  end
end

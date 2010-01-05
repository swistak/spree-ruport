class BaseRuportController < Ruport::Controller
  include ActionView::Helpers::NumberHelper

  # This method overrides default Ruport accessor to provide inheritable
  # and customizable stages.
  #
  # If inheriting controller needs diffirent stages, it can easilly set stages
  # with MyController.stages = [:foo]
  def self.stages
    (@stages || [
      :report_header,
      :report_body,
      :report_summary,
      :report_footer,
    ]).map(&:to_s)
  end

  # This method overrides default Ruport accessor to provide defaults for inherited controllers.
  def self.required_options
    (@required_options || [:report_title]).map(&:to_s)
  end

  class_inheritable_accessor(:conditions)
  self.conditions = lambda do |params|
    where = ['orders.completed_at IS NOT NULL']
    unless params.start_at.blank?
      where.first << " AND orders.completed_at > ?"
      where << params.start_at
    end
    unless params.end_at.blank?
      where.first << " AND orders.completed_at < ?"
      where << params.end_at
    end
    where
  end
  
  def conditions(params)
    self.class.conditions[params]
  end

  # This module will be automaticall mixed into formaters by ruport.
  # But we also need it in controller so I'm including it immidietly anyway
  module Helpers
    def t(name)
      I18n.t(name, :scope => :report, :default => I18n.t(name))
    end

    def now
      Time.now.strftime('%d-%m-%Y %H:%M')
    end
  end
  include Helpers
end
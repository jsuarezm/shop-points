class ReportsController < ApplicationController
    def create
      report = Report.create!(status: "pending")
      ReportJob.perform_later(report.id)
      render json: { message: "Report generation started now now", report_id: report.id }
    end
  
    def index
      @report = Report.all
      render json: @report
    end
end
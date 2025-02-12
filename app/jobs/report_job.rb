class ReportJob < ApplicationJob
    queue_as :default
  
    def perform(report_id)
      report = Report.find(report_id)
      clients = Client.all
      
      report_data = clients.map do |client|
        {
          id: client.id,
          name: client.name,
          total_spent: client.total_spent,
          total_points: client.total_points
        }
      end
  
      file_path = Rails.root.join("public/reports/report-#{report.id}.json")
      FileUtils.mkdir_p(File.dirname(file_path))
      
      File.open(file_path, "w") do |f|
        f.write(JSON.pretty_generate(report_data))
      end
  
      report.update!(
        status: "completed",
        file_path: file_path.to_s
      )
    end
  end
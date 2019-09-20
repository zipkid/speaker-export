require 'speaker/export/version'
require 'json'
require 'yaml'
require 'date'
require 'time'

class Speaker
  # Read json, export selected fields as yaml
  class Export
    def initialize
      @json_file = 'schedule.json'
      @yaml_file = 'schedule.yaml'
      @json_data = read_json
      @yaml_data = {}
      select_data
      write_yaml
      puts 'done'
    end

    def read_json
      file = File.read(@json_file)
      JSON.parse(file)
    end

    def select_data
      program = []
      @json_data['schedule']['conference']['days'].each do |day|
        # puts day
        day['rooms']['Main'].each do |event|
          e = {}
          e['title'] = event['persons'].first['public_name']
          e['type'] = event['type'].downcase
          date = Date.parse(event['date'])
          e['date'] = date
          starttime = Time.parse(event['date'])
          e['start_time'] = starttime.strftime('%k:%M').strip
          duration = Time.parse(event['duration'])
          duration_hour = duration.strftime('%k').to_i
          duration_minute = duration.strftime('%M').to_i
          endtime = starttime + (duration_hour * 3600) + (duration_minute * 60)
          e['end_time'] = endtime.strftime('%k:%M').strip
          program << e
        end
      end
      @yaml_data['program'] = program
    end

    def write_yaml
      File.open(@yaml_file, 'w') do |file|
        file.write @yaml_data.to_yaml
      end 
    end

    class Error < StandardError; end
  end
end

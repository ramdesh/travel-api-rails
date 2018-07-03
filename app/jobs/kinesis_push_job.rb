require 'multi_json'
require 'optparse'
require 'sidekiq'
require 'aws-sdk'

class KinesisPushJob #< Sidekiq::Workers
#  queue_as :default
  include Sidekiq::Worker

  def perform(aws_region = 'us-east-1', stream_name = 'sidekiqStream', sleep_between_puts=0.25, shard_count=nil,timeout=1)
    kconfig = {}
    kconfig[:region] = aws_region
    kinesis = Aws::Kinesis::Client.new(kconfig)
    
    @stream_name = stream_name
    @shard_count = shard_count
    @sleep_between_puts = sleep_between_puts
    @kinesis = kinesis
    
    create_stream_if_not_exists
    #start = Time.now
    t = Time.now
    #count=0
    #while (timeout == 0 || (Time.now - start) < timeout) do
    #  count+=1
      put_record
      sleep @sleep_between_puts
      puts "Loop Time : #{Time.now - t} " #, Count: #{count}"
    #  t=Time.now
    #end
  end

  def delete_stream_if_exists
    begin
      @kinesis.delete_stream(:stream_name => @stream_name)
      puts "Deleted stream #{@stream_name}"
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
      # nothing to do 
    end
  end

  def create_stream_if_not_exists
    begin
      desc = get_stream_description
      if desc[:stream_status] == 'DELETING'
        fail "Stream #{@stream_name} is being deleted. Please re-run the script."
      elsif desc[:stream_status] != 'ACTIVE'
        wait_for_stream_to_become_active
      end
      if @shard_count && desc[:shards].size != @shard_count
        fail "Stream #{@stream_name} has #{desc[:shards].size} shards, while requested number of shards is #{@shard_count}"
      end
      puts "Stream #{@stream_name} already exists with #{desc[:shards].size} shards"
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
      puts "Creating stream #{@stream_name} with #{@shard_count || 1} shards"
      @kinesis.create_stream(:stream_name => @stream_name,
                             :shard_count => @shard_count || 1)
      wait_for_stream_to_become_active
    end
  end

  def put_record
    data = get_data
    data_blob = MultiJson.dump(data)
    r = @kinesis.put_record(:stream_name => @stream_name,
                            :data => data_blob,
                            :partition_key => data["sensor"])
    puts "Put record to shard '#{r[:shard_id]}' : Data : '#{MultiJson.dump(data)}'"
  end

  private
    def get_data
      {
        "time"=>"#{Time.now.to_f}",
        "sensor"=>"snsr-#{rand(1_000).to_s.rjust(4,'0')}",
        "reading"=>"#{rand(1_000_000)}"
      }
    end

    def get_stream_description
      r = @kinesis.describe_stream(:stream_name => @stream_name)
      r[:stream_description]
    end

    def wait_for_stream_to_become_active
      sleep_time_seconds = 3
      status = get_stream_description[:stream_status]
      while status && status != 'ACTIVE' do
        puts "#{@stream_name} has status: #{status}, sleeping for #{sleep_time_seconds} seconds"
        sleep(sleep_time_seconds)
        status = get_stream_description[:stream_status]
      end
    end
  end

if __FILE__ == $0
  aws_region = 'us-east-1'
  stream_name = 'sidekiqStream'
  shard_count = nil
  sleep_between_puts = 0.1
  timeout = 5
  # Get and parse options
  option_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [options]"
    opts.on("-s STREAM_NAME", "--stream STREAM_NAME", "Name of the stream to use. Will be created if it doesn't exist. (Default: '#{stream_name}')") do |s|
      stream_name = s
    end
    opts.on("-d SHARD_COUNT", "--shards SHARD_COUNT", "Number of shards to use when creating the stream. (Default: 2)") do |s|
      stream_name = s
    end
    opts.on("-r REGION_NAME", "--region REGION_NAME", "AWS region name (see http://tinyurl.com/cc9cap7). (Default: SDK default)") do |r|
      aws_region = r
    end
    opts.on("-p SLEEP_SECONDS", "--sleep SLEEP_SECONDS", Float, "How long to sleep betweep puts (seconds, can be fractional). (Default #{sleep_between_puts})") do |s|
      sleep_between_puts = s.to_f
      raise OptionParser::ParseError.new("SLEEP_SECONDS must be a non-negative number")  unless sleep_between_puts >= 0.0
    end
    opts.on("-t TIMEOUT_SECONDS", "--timeout TIMEOUT_SECONDS", Float, "How long to keep running. By default producer keeps running indefinitely. (Default: #{timeout})") do |t|
      timeout = s.to_f
      raise OptionParser::ParseError.new("TIMEOUT_SECONDS must be a non-negative number")  unless timeout >= 0.0
    end
    opts.on("-h", "--help", "Prints this help message.") do
      puts opts
      exit
    end
  end

  begin
    option_parser.parse!
    raise OptionParser::ParseError.new("STREAM_NAME is required")  if !stream_name || stream_name.strip.empty?
  rescue
    $stderr.puts option_parser
    raise
  end

  # Getting a connection to Amazon Kinesis will require that you have
  # your credentials available to one of the standard credentials providers.
  # See http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/auth/DefaultAWSCredentialsProviderChain.html
  kconfig = {}
  kconfig[:region] = aws_region  if aws_region
  kinesis = Aws::Kinesis::Client.new(kconfig)


  
  producer = SampleProducer.new(kinesis, stream_name, sleep_between_puts, shard_count)
  producer.perform(timeout)
  
end

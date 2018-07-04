require 'multi_json'
require 'optparse'
require 'sidekiq'
require 'aws-sdk'

class KinesisPushJob 
  include Sidekiq::Worker

  def perform(aws_region = 'us-east-1', activity_stream_name = 'activityStream', hotel_stream_name= 'hotelStream', shard_count=nil)
    kconfig = {}
    kconfig[:region] = aws_region
    kinesis = Aws::Kinesis::Client.new(kconfig)
    
    @shard_count = shard_count
    @kinesis = kinesis
    
    @stream_name = activity_stream_name
    create_stream_if_not_exists

    @stream_name = hotel_stream_name
    create_stream_if_not_exists

    @activity_stream_name = activity_stream_name
    put_record
    puts "All records published to Kinesis"
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
    @activity = Activity.all
    @activity.each do |activityR|
      data_blob = MultiJson.dump(activityR)
      r = @kinesis.put_record(:stream_name => @activity_stream_name,
                             :data => data_blob,
                             :partition_key => activityR["id"].to_s)
      puts "Put record to shard '#{r[:shard_id]}' : Activity : '#{activityR["id"]}'"
    end
    puts " ******************************* "
    @hotel = Hotel.all
    @hotel.each do |hotelR|
      data_blob = MultiJson.dump(hotelR)
      r = @kinesis.put_record(:stream_name => @stream_name,
                             :data => data_blob,
                             :partition_key => hotelR["id"].to_s)
      puts "Put record to shard '#{r[:shard_id]}' : Hotel : '#{hotelR["id"]}'"
    end
    
  end

  private
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


  
  producer = SampleProducer.new(kinesis, stream_name, shard_count)
end

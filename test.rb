# HOW DO I LOAD THE MESSAGING PLATFORM, CLUSTER, AND LIBRARY???
require 'nsq'
Dir["/Documents/Wistia/nsb-cluster-master/*.rb"].each {|file| require file }
Dir["/Documents/Wistia/nsb-ruby-master/*.rb"].each {|file| require file }

# Start a queue of 100_000 nsqd's and 100 video_id's.
# This will block execution until all components are fully up and running.
# HOW DO I ACCOUNT FOR THE RIGHT DISTRIBUTION
queue = NsqCluster.new(message: 100_000, video_id: 100)

# Connect directly to a single nsqd instance
nsqd = queue.nsqd.first                     # DO I DO THIS OR CAN I KEEP THE PROCESSOR TASKS BELOW???

# HOW DO I MAKE SURE THE PLAY COUNT IS ONLY PUBLISHED IF IT'S CHANGED SINCE IT WAS LAST PUBLISHED???

class Processor

	def initialize
		@count = {}
        @over_100 = {}
    end

	# count the plays
	def play_count
		parsed_msg = JSON.parse(next_message)
        video_id = parsed_msg["video_id"]
        @count[video_id] += 1
	end

	# publish to the client
	def publish(video_id)
        if @count[video_id] < 100           # videos with under 100 plays
            # publish to client immediately
            Nsq.client = Logger.new(STDOUT)
        elsif @over_100.length < 20         # storing up to 20 videos with over 100 plays
            @over_100[video_id] = @count[video_id]
        else                                # publish to the client
            Nsq.client = Logger.new(STDOUT)
		end
	end
end

# create a new Processor
processor = Processor.new

# read messages off the queue
queue.each do |msg|
    processor.update(msg)
    processor.publish(queue[msg])
end

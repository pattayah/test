# HOW DOES NSQ QUEUE WORK???
require 'nsq'
Dir["/Documents/Wistia/nsb-cluster-master/*.rb"].each {|file| require file }
Dir["/Documents/Wistia/nsb-ruby-master/*.rb"].each {|file| require file }

# Start a queue of 100_000 nsqd's and 100 video_id's.
# This will block execution until all components are fully up and running.
# HOW DO I ACCOUNT FOR THE RIGHT DISTRIBUTION???
# HOW DO I MAKE IT A JSON???
queue = NsqCluster.new(message: 100_000, video_id: 100)

# Connect directly to a single nsqd instance
nsqd = queue.nsqd.first                     # DO I DO THIS OR CAN I KEEP THE PROCESSOR TASKS BELOW???

class Processor
    
    def initialize
        @count = {}
        @push_msgs = NsqCluster.new{}
    end
    
    # count the plays
    def play_count
        parsed_msg = JSON.parse(next_message)
        video_id = parsed_msg["video_id"]
        @count[video_id] += 1
    end
    
    # publish to the client
    def publish(video_id)
        if @count[video_id] < 100 && @push_msgs < 20           # videos with under 100 plays
            # publish to client immediately
            # HOW DO I ACCOUNT FOR THE TIME STAMP???
            puts "video #{video_id} has #{count[video_id]} plays."
            elsif @push_msgs.length < 20         # storing up to 20 videos with over 100 plays
            @push_msgs[video_id] = @count[video_id]
            else                                # publish to the client
            # MOST RECENT 20 VIDEOS???
            # HOW DO I DO THIS???
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
